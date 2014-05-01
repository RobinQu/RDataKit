//
//  RNestedDataContext.h
//  RDataKit
//
//  Created by Robin Qu on 14-5-1.
//  Copyright (c) 2014年 Robin Qu. All rights reserved.
//

#import "RDataContext.h"

@interface RNestedDataContext : RDataContext


// background queue moc
@property (readonly, strong, nonatomic) NSManagedObjectContext *writerManagedObjectContext;


- (NSManagedObjectContext *)makeChildContext;
- (void)commitChildContext:(NSManagedObjectContext *)context callback:(ErrorCallbackBlock)callback;


@end
