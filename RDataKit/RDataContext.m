//
//  RDataContext.m
//  RDataKit
//
//  Created by Robin Qu on 13-6-15.
//  Copyright (c) 2013年 Robin Qu. All rights reserved.
//

#import "RDataContext.h"
#import "RDataKitConfiguration.h"
#import "AFHTTPRequestOperation.h"
#import "RModel.h"
#import <objc/runtime.h>


@interface RDataContext ()

@property (nonatomic, retain) NSURL *storeURL;
@property (nonatomic, retain) NSURL *modelURL;

@end

@implementation RDataContext

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize writerManagedObjectContext = _writerManagedObjectContext;


- (instancetype)initWithModelURL:(NSURL *)modelURL storeURL:(NSURL *)storeURL
{
    self = [super init];
    if (self) {
        self.storeURL = storeURL;
        self.modelURL = modelURL;
        self.responseMapper = [RResponseMapper defaultResponseMapper];
        self.router = [RRouter defaultRouter];
    }
    return self;
}

#pragma mark - Core Data stack


// The main context is on background queue
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.parentContext = self.writerManagedObjectContext;
    }
    return _managedObjectContext;
}

// Writer context is on background queue, so that saving won't block main UI
- (NSManagedObjectContext *)writerManagedObjectContext
{
    if (_writerManagedObjectContext) {
        return _writerManagedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _writerManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_writerManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _writerManagedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:nil error:&error]) {
        [[NSFileManager defaultManager] removeItemAtURL:self.storeURL error:nil];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Local Data Access

// Child context helper

- (NSManagedObjectContext *)makeChildContext
{
    __block NSManagedObjectContext *temperaroyMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temperaroyMoc.parentContext = self.managedObjectContext;
    return temperaroyMoc;
}

- (void)commitChildContext:(NSManagedObjectContext *)context callback:(void(^)(NSError *error))callback
{
    __block NSError *error = nil;
    __block NSManagedObjectContext *writerMoc = self.writerManagedObjectContext;
    __block NSManagedObjectContext *mainMOC = self.managedObjectContext;
    
    if (![context save:&error]) {
        RLog(@"temp moc error %@", error);
        callback(error);
    };
    [mainMOC performBlock:^{
        if (![mainMOC save:&error]) {
            RLog(@"main moc error %@", error);
            callback(error);
        };
        [writerMoc performBlock:^{
            if (![writerMoc save:&error]) {
                RLog(@"writer moc error %@", error);
                callback(error);
            }
        }];
    }];
}


// Create or update a model with object in given context
- (id)createOrUpdateInContext:(NSManagedObjectContext *)context WithObject:(id)obj ofClass:(Class)modelClass;
{
    NSString *keyPath = [self.responseMapper keyPathForObject:obj ofModel:modelClass];
    NSAssert(keyPath, @"should have keyPath");
    NSString *identifier = [obj valueForKeyPath:keyPath];
    NSAssert(identifier, @"should have identifier");
    NSString *keyname = [self.responseMapper identifierKeyNameForModel:modelClass];
    NSAssert(keyname, @"should have primary key name");
    id one = [self findOneInContext:context byModal:modelClass identifier:identifier];
    SEL setup = @selector(setupWithObject:);
    SEL setup2 = @selector(setupWithObject:isUpdate:);
    BOOL isUpdate = YES;
    if (!one) {//perfrom creation
        one = [NSEntityDescription insertNewObjectForEntityForName:[modelClass description] inManagedObjectContext:context];
        [one setValue:identifier forKey:keyname];
        isUpdate = NO;
    }
    if ([one respondsToSelector:setup2]) {
        [one setupWithObject:obj isUpdate:isUpdate];
    } else if ([one respondsToSelector:setup]) {
        [one setupWithObject:obj];
    }
    return one;
}


- (id)findOneInContext:(NSManagedObjectContext *)context byModal:(Class)modalClass identifier:(NSString *)identifier;
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", [self.responseMapper identifierKeyNameForModel:modalClass], identifier];
    NSFetchRequest *fRequest = [NSFetchRequest fetchRequestWithEntityName:[modalClass description]];
    fRequest.predicate = predicate;
    NSArray *results = [context executeFetchRequest:fRequest error:nil];
    if (results.count) {
        return [results objectAtIndex:0];
    } else {
        return nil;
    }

}

- (void)removeAllInContext:(NSManagedObjectContext *)context ofClass:(Class)modelClass ;
{
    NSFetchRequest *fRequest = [NSFetchRequest fetchRequestWithEntityName:[modelClass description]];
    NSArray *results = [self.managedObjectContext executeFetchRequest:fRequest error:nil];
    [results enumerateObjectsUsingBlock:^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
    }];
}
    
@end
