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

- (instancetype)initWithModelURL:(NSURL *)modelURL storeURL:(NSURL *)storeURL
{
    self = [super init];
    if (self) {
        self.storeURL = storeURL;
        self.modelURL = modelURL;
        self.responseMapper = [RResponseMapper defaultResponseMapper];
        self.router = [RRouter defaultRouter];
        self.dataService = [RDataService defaultDataService];
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
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = coordinator;
    }
    return _managedObjectContext;
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


// Local data helpers
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *context = self.managedObjectContext;
    if (context) {
        if ([context hasChanges] && ![context save:&error]) {
            RLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
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
    id one = [self findOneInContext:context byModel:modelClass identifier:identifier];
    SEL setup = @selector(setupWithObject:);
    SEL setup2 = @selector(setupWithObject:isUpdate:);
    SEL setup3 = @selector(setupWithObject:isUpdate:inContext:);
    BOOL isUpdate = YES;
    if (!one) {//perfrom creation
        one = [NSEntityDescription insertNewObjectForEntityForName:[modelClass description] inManagedObjectContext:context];
        [one setValue:identifier forKey:keyname];
        isUpdate = NO;
    }
    if ([one respondsToSelector:setup3]) {
        [one setupWithObject:obj isUpdate:isUpdate inContext:context];
    } else if ([one respondsToSelector:setup2]) {
        [one setupWithObject:obj isUpdate:isUpdate];
    } else if ([one respondsToSelector:setup]) {
        [one setupWithObject:obj];
    }
    return one;
}


- (id)findOneInContext:(NSManagedObjectContext *)context byModel:(Class)modelClass identifier:(NSString *)identifier;
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", [self.responseMapper identifierKeyNameForModel:modelClass], identifier];
    NSFetchRequest *fRequest = [NSFetchRequest fetchRequestWithEntityName:[modelClass description]];
    fRequest.predicate = predicate;
//    fRequest.returnsObjectsAsFaults = NO;
    NSError *error = nil;
    // fetch in main moc only
    NSArray *results = [context executeFetchRequest:fRequest error:&error];
    //    NSArray *results = [self.managedObjectContext executeFetchRequest:fRequest error:&error];
    if (error) {
        RLog(@"failed to find %@ by identifier %@: %@", [modelClass description], identifier, error);
    }
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

// Should implement in subclasses
- (NSManagedObjectContext *)makeChildContext
{
    RLog(@"should implement in subclass");
    return nil;
}

- (void)performBlock:(BOOL (^)(NSManagedObjectContext *))block afterCommit:(ErrorCallbackBlock)commitCallback
{
    RLog(@"should implement in subclass");
}

@end
