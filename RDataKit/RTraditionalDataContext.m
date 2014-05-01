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
        NSError *error = nil;
        __block id observer = nil;
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:moc queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [self.managedObjectContext mergeChangesFromContextDidSaveNotification:note];
            // cancel the observer after a single merge
            [[NSNotificationCenter defaultCenter] removeObserver:observer name:NSManagedObjectContextDidSaveNotification object:moc];
            commitCallback(error);
        }];
        if (![moc save:&error]) {
            RLog(@"commit error %@", error);
        }
        

    }
}

@end
