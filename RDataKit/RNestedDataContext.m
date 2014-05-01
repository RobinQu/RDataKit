//
//  RNestedDataContext.m
//  RDataKit
//
//  Created by Robin Qu on 14-5-1.
//  Copyright (c) 2014年 Robin Qu. All rights reserved.
//

#import "RNestedDataContext.h"

@implementation RNestedDataContext

@synthesize writerManagedObjectContext = _writerManagedObjectContext;
@synthesize managedObjectContext = _managedObjectContext;

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
        _managedObjectContext.persistentStoreCoordinator = coordinator;
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

- (void)performBlock:(BOOL (^)(NSManagedObjectContext *))block afterCommit:(ErrorCallbackBlock)commitCallback
{
    __block NSManagedObjectContext *temperaryMoc = [self makeChildContext];
    temperaryMoc.parentContext = self.managedObjectContext;
    [temperaryMoc performBlock:^{
        BOOL shouldCommit = block(temperaryMoc);
        if (shouldCommit) {
            [self commitChildContext:temperaryMoc callback:commitCallback];
        }
    }];
}

@end
