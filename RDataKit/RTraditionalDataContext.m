//
//  RTraditionalDataContext.m
//  RDataKit
//
//  Created by Robin Qu on 14-5-1.
//  Copyright (c) 2014年 Robin Qu. All rights reserved.
//

#import "RTraditionalDataContext.h"

@implementation RTraditionalDataContext

- (NSManagedObjectContext *)makeChildContext
{
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
    moc.persistentStoreCoordinator = self.persistentStoreCoordinator;
    return moc;
}

- (void)performBlock:(BOOL (^)(NSManagedObjectContext *))block afterCommit:(ErrorCallbackBlock)commitCallback
{
    NSManagedObjectContext *moc = [self makeChildContext];
    BOOL shouldCommit = block(moc);
    if (shouldCommit) {
        __block NSError *error = nil;
        __block id observer = nil;
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:moc queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            
            for(NSManagedObject *object in [[note userInfo] objectForKey:NSUpdatedObjectsKey]) {
                [[moc objectWithID:[object objectID]] willAccessValueForKey:nil];
            }
            [self.managedObjectContext mergeChangesFromContextDidSaveNotification:note];
            // cancel the observer after a single merge
            [[NSNotificationCenter defaultCenter] removeObserver:observer name:NSManagedObjectContextDidSaveNotification object:moc];
            if (![self.managedObjectContext save:&error]) {
                RLog(@"main context commit error %@", error);
            }
            dispatch_async(dispatch_get_main_queue(), ^{//ensure it's run on main thread
                commitCallback(error);
            });
        }];
        if (![moc save:&error]) {
            RLog(@"commit error %@", error);
        }
    }
}

@end
