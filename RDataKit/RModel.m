//
//  RModel.m
//  RDataKit
//
//  Created by Robin Qu on 13-6-15.
//  Copyright (c) 2013年 Robin Qu. All rights reserved.
//

#import "RModel.h"
#import "RDataContext.h"


@implementation RModel
    
    @synthesize identifer = _identifer;
    
    static RDataContext *ctx;
    
+ (void)regisiterDataContext:(RDataContext *)dataContext
    {
        ctx = dataContext;
    }
    
+ (void)loadAllWithOptions:(NSDictionary *)options callback:(ResourcesResponseCallbackBlock)callback
    {
        [ctx loadAllRecords:self withOptions:options callback:callback];
    }
    
+ (void)loadByIdentifier:(NSString *)identifier withOptions:(NSDictionary *)options callback:(ResourceResponseCallbackBlock)callback
    {
        [ctx loadRecord:self byIdentifier:identifier withOptions:options callback:callback];
    }
    
+ (void)createWithObject:(NSDictionary *)obj callback:(ResourceResponseCallbackBlock)callback
    {
        [ctx createRecord:self withObject:obj callback:callback];
    }
    
- (void)updateWithObject:(NSDictionary *)obj callback:(ResourceResponseCallbackBlock)callback
    {
        [ctx updateRecord:[self class] withObject:obj byIdentifier:self.identifer withCallback:callback];
    }
    
- (void)destroyWithOptions:(NSDictionary *)options callback:(ErrorCallbackBlock)callback
    {
        [ctx destroyRecord:[self class] byIdentifier:self.identifer withOptions:options callback:callback];
    }
    
- (void)setupWithObject:(NSDictionary *)obj
    {
        NSAssert(![self isKindOfClass:[RModel class]], @"should override this method");
    }
    
    @end
