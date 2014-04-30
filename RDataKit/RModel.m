//
//  RModel.m
//  RDataKit
//
//  Created by Robin Qu on 13-6-15.
//  Copyright (c) 2013年 Robin Qu. All rights reserved.
//

#import "RModel.h"
#import "RDataContext.h"
#import <AFNetworking.h>


@implementation RModel

@synthesize identifier = _identifier;

static RDataContext *ctx;

+ (void)regisiterDataContext:(RDataContext *)dataContext
{
    ctx = dataContext;
}

// Handling GET to index
+ (void)loadAllWithOptions:(NSDictionary *)options callback:(ResponseCallbackBlock)callback
{
    NSAssert(callback, @"should provide request callback");
    Class modelClass = [self class];
    NSString *path = [ctx.router pathNameForModal: modelClass];
    [ctx.dataService GET:path parameters:options success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([ctx.responseMapper isGoodResponseForOperation:operation model:modelClass]) {
            __block NSManagedObjectContext *temperaroyMoc = [ctx makeChildContext];
            [temperaroyMoc performBlock:^{
                NSArray *objs = [ctx.responseMapper parseObjectsFromResponse:responseObject forModel:modelClass];
                NSMutableArray *results = [NSMutableArray array];
                for (int i=0; i<[objs count]; i++) {
                    RModel *one = [ctx createOrUpdateInContext:temperaroyMoc WithObject:[objs objectAtIndex:i] ofClass:modelClass];
                    if (one) {
                        [results addObject:one];
                    } else {
                        RLog(@"failed to process obj %@", [objs objectAtIndex:i]);
                    }
                }
                [ctx commitChildContext:temperaroyMoc callback:^(NSError *error) {
                    callback(error, results);
                }];
            }];
        } else {
            callback(SERVICE_RESPONSE_ERROR, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(error, operation);
    }];
}

// Handling GET, PUT, DELETE for a single record; POST request should pass nil as identifier
+ (void)handleRecordByIdentifier:(NSString *)identifier byMethod:(NSString *)method withObject:(NSDictionary*)object callback:(ResponseCallbackBlock)callback
{
    NSAssert(callback, @"should provide request callback");
    Class modelClass = [self class];
    
    NSString *fullpath = [ctx.router pathNameForModal:modelClass];
    if (identifier) {
        fullpath = [fullpath stringByAppendingPathComponent:identifier];
    }
    NSURLRequest *request = [ctx.dataService.requestSerializer requestWithMethod:method URLString:fullpath parameters:object];
    AFHTTPRequestOperation *operation = [ctx.dataService HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Class modelClass = [self class];
        if ([ctx.responseMapper isGoodResponseForOperation:operation model:modelClass]) {
            __block id obj = [ctx.responseMapper parseObjectFromResponse:responseObject forModel:modelClass];
            __block NSManagedObjectContext *temperaroyMoc = [ctx makeChildContext];
            [temperaroyMoc performBlock:^{
                RModel *one = nil;
                if ([method isEqualToString:@"DELETE"]) {
                    one = [ctx findOneInContext:temperaroyMoc byModal:modelClass identifier:identifier];
                    [temperaroyMoc deleteObject:one];
                } else {//GET, CREATE, PUT, POST
                    one = [ctx createOrUpdateInContext:temperaroyMoc WithObject:obj ofClass:modelClass];
                }
                [ctx commitChildContext:temperaroyMoc callback:^(NSError *error) {
                    callback(error, one);
                }];
                
            }];
        } else {
            if (callback) {
                callback(SERVICE_RESPONSE_ERROR, nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (callback) {
            callback(error, operation);
        }
    }];
    
    [ctx.dataService.operationQueue addOperation:operation];
}

+ (void)loadByIdentifier:(NSString *)identifier withOptions:(NSDictionary *)options callback:(ResourceResponseCallbackBlock)callback
{
    [self handleRecordByIdentifier:identifier byMethod:@"GET" withObject:options callback:callback];
}

+ (void)createWithObject:(NSDictionary *)obj callback:(ResourceResponseCallbackBlock)callback
{
    [self handleRecordByIdentifier:nil byMethod:@"POST" withObject:obj callback:callback];
}

+ (void)updateByIdentifier:(NSString *)identifier withOptions:(NSDictionary *)options callback:(ResourceResponseCallbackBlock)callback
{
    [self handleRecordByIdentifier:identifier byMethod:@"PUT" withObject:options callback:callback];
}

+ (void)deleteByIdentifier:(NSString *)identifier withOptions:(NSDictionary *)options callback:(ResourceResponseCallbackBlock)callback
{
    [self handleRecordByIdentifier:identifier byMethod:@"DELETE" withObject:options callback:callback];
}

- (NSString *)getDefaultIdentifier
{
    NSString *identifierKey = [ctx.responseMapper identifierKeyNameForModel:[self class]];
    NSString *identifier = [self valueForKey:identifierKey];
    return identifier;
}

- (void)updateWithObject:(NSDictionary *)obj callback:(ResourceResponseCallbackBlock)callback
{
    [[self class] updateByIdentifier:[self getDefaultIdentifier] withOptions:obj callback:callback];
}

- (void)destroyWithOptions:(NSDictionary *)options callback:(ResourceResponseCallbackBlock)callback
{
    [[self class] deleteByIdentifier:[self getDefaultIdentifier] withOptions:options callback:callback];
}

@end
