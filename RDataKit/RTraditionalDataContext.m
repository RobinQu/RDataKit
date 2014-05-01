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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:moc];
        NSError *error = nil;
        if (![moc save:&error]) {
            RLog(@"commit error %@", error);
        }
        commitCallback(error);
    }
}

- (void)contextDidSave:(NSNotification*)notification
{
    [self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:NO];
}

@end
