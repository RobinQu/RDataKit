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

@synthesize identifier = _identifier;

static RDataContext *ctx;

+ (void)regisiterDataContext:(RDataContext *)dataContext
{
    ctx = dataContext;
}
    
+ (void)loadAllWithOptions:(NSDictionary *)options callback:(ResourcesResponseCallbackBlock)callback
{
    [ctx loadAllRecords:self withOptions:options callback:callback];
}

+ (NSString *)buildPathOptions:(NSDictionary *)options
{
    return [ctx pathNameForModal:self];
}

+ (void)loadByIdentifier:(NSString *)identifier withOptions:(NSDictionary *)options callback:(ResourceResponseCallbackBlock)callback
{
    [ctx loadRecord:self byIdentifier:identifier withOptions:options callback:callback];
}

+ (void)createWithObject:(NSDictionary *)obj callback:(ResourceResponseCallbackBlock)callback
{
    [ctx createRecord:self withObject:obj callback:callback];
}


+ (void)requestRecord:(Class)modalClass atPath:(NSString *)path method:(NSString *)method withObject:(NSDictionary *)obj callback:(ResourceResponseCallbackBlock)callback forRaw:(BOOL)raw
{
    [ctx handleRecord:modalClass atPath:path byMehtod:method shouldRefresh:!raw withObject:obj withCallback:callback];
}
    
- (void)updateWithObject:(NSDictionary *)obj callback:(ResourceResponseCallbackBlock)callback
{
    [ctx updateRecord:[self class] withObject:obj byIdentifier:self.identifier withCallback:callback];
}

- (void)destroyWithOptions:(NSDictionary *)options callback:(ErrorCallbackBlock)callback
{
    [ctx destroyRecord:[self class] byIdentifier:self.identifier withOptions:options callback:callback];
}

//- (void)setupWithObject:(NSDictionary *)obj
//{
//    NSAssert(![self isKindOfClass:[RModel class]], @"should override this method");
//}

+ (id)findOneByIdentifier:(NSString *)identifier
{
    return [ctx findOneByModal:self identifier:identifier];
}

+ (NSArray *)findByPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors
{
    NSAssert(predicate, @"should at least have a predicate");
    NSFetchRequest *fRequest = [NSFetchRequest fetchRequestWithEntityName:[self description]];
    fRequest.predicate = predicate;
    if (sortDescriptors) {
        fRequest.sortDescriptors = sortDescriptors;
    }
    return [ctx findByFetchRequest:fRequest];
}

+ (void)deleteByIdentifier:(NSString *)identifier autoCommit:(BOOL)autoCommit
{
    RModel *obj = [self findOneByIdentifier:identifier];
    if (obj) {
        [[ctx mainQueueMOC] deleteObject:obj];
        if (autoCommit) {
            [[ctx mainQueueMOC] save:nil];
        }
    }
}
    
@end
