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

static ResponseCallbackBlock noop = ^(NSError *error, id one){};

@implementation RModel

@synthesize identifier = _identifier;

static RDataContext *ctx;

+ (void)regisiterDataContext:(RDataContext *)dataContext
{
    ctx = dataContext;
}

+ (void)refreshWithOptions:(NSDictionary *)options callback:(ResponseCallbackBlock)callback
{
    if (!callback) {
        callback = noop;
    }
    [self loadAllWithOptions:options callback:^(NSError *error, NSArray* results) {
        NSString *identifierKey = [ctx.responseMapper identifierKeyNameForModel:[self class]];
        __block NSArray *newIDs = [results valueForKey:identifierKey];
        if (newIDs.count) {
            [ctx performBlock:^BOOL(NSManagedObjectContext *moc) {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[[self class] description]];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"NOT (%K IN %@)", identifierKey, newIDs];
                NSError *error = nil;
                NSArray *old = [moc executeFetchRequest:fetchRequest error:&error];
                if (error) {
                    RLog(@"fetch error %@", error);
                }
                [old enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [moc deleteObject:obj];
                }];
                return YES;
            } afterCommit:^(NSError *error) {
                callback(error, results);
            }];
        } else {
            callback(nil, results);
        }
    }];
}

+ (void)handleRecordsByMethod:(NSString *)method atPath:(NSString *)path  withObject:(NSDictionary*)object callback:(ResponseCallbackBlock)callback
{
    if (!callback) {
        callback = noop;
    }
    Class modelClass = [self class];
    [ctx.dataService GET:path parameters:object success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([ctx.responseMapper isGoodResponseForOperation:operation model:modelClass]) {
            NSArray *objs = [ctx.responseMapper parseObjectsFromResponse:responseObject forModel:modelClass];
            __block NSMutableArray *results = [NSMutableArray array];
            [ctx performBlock:^BOOL(NSManagedObjectContext *moc) {
                __block RModel *one = nil;
                for (int i=0; i<[objs count]; i++) {
                    one = [ctx createOrUpdateInContext:moc WithObject:[objs objectAtIndex:i] ofClass:modelClass];
                    if (one) {
                        [results addObject:one];
                    } else {
                        RLog(@"failed to process obj %@", [objs objectAtIndex:i]);
                    }
                }
//                callback(nil, results);
                return YES;
            } afterCommit:^(NSError *error) {
                callback(error, results);
            }];
        } else {
            callback(SERVICE_RESPONSE_ERROR, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(error, operation);
    }];
}

// Handling GET to index
+ (void)loadAllWithOptions:(NSDictionary *)options callback:(ResponseCallbackBlock)callback
{
    Class modelClass = [self class];
    NSString *path = [ctx.router pathNameForModal: modelClass];
    [self handleRecordsByMethod:@"GET" atPath:path withObject:options callback:callback];
}

// Handling GET, PUT, DELETE for a single record; POST request should pass nil as identifier
+ (void)handleRecordByIdentifier:(NSString *)identifier byMethod:(NSString *)method withObject:(NSDictionary*)object callback:(ResponseCallbackBlock)callback
{
    Class modelClass = [self class];
    NSString *fullpath = [ctx.router pathNameForModal:modelClass];
    if (identifier) {
        fullpath = [fullpath stringByAppendingPathComponent:identifier];
    }
    [self handleRecordByMethod:method atPath:fullpath withObject:object callback:callback];
}

+ (void)handleRecordByMethod:(NSString *)method atPath:(NSString *)path withObject:(NSDictionary*)object callback:(ResponseCallbackBlock)callback
{
    if (!callback) {
        callback = noop;
    }
    NSString *fullpath = [ctx.dataService.baseURL.absoluteString stringByAppendingPathComponent:path];
    NSURLRequest *request = [ctx.dataService.requestSerializer requestWithMethod:method URLString:fullpath parameters:object];
    AFHTTPRequestOperation *operation = [ctx.dataService HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Class modelClass = [self class];
        if ([ctx.responseMapper isGoodResponseForOperation:operation model:modelClass]) {
            __block id obj = [ctx.responseMapper parseObjectFromResponse:responseObject forModel:modelClass];
            __block RModel *one = nil;
            [ctx performBlock:^BOOL(NSManagedObjectContext *moc) {
                if ([method isEqualToString:@"DELETE"]) {
                    NSString *identifierKeyPath = [ctx.responseMapper keyPathForObject:obj ofModel:modelClass];
                    NSString *identifier = [obj valueForKey:identifierKeyPath];
                    NSAssert(identifier, @"should have found identifier in response");
                    one = [ctx findOneInContext:moc byModel:modelClass identifier:identifier];
                    [moc deleteObject:one];
                } else {//GET, CREATE, PUT, POST
                    one = [ctx createOrUpdateInContext:moc WithObject:obj ofClass:modelClass];
                }
//                callback(nil, one);
                return YES;
            } afterCommit:^(NSError *error) {
                callback(error, one);
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


- (void)updateWithObject:(NSDictionary *)obj callback:(ResourceResponseCallbackBlock)callback
{
    [[self class] updateByIdentifier:[self getDefaultIdentifier] withOptions:obj callback:callback];
}

- (void)destroyWithOptions:(NSDictionary *)options callback:(ResourceResponseCallbackBlock)callback
{
    [[self class] deleteByIdentifier:[self getDefaultIdentifier] withOptions:options callback:callback];
}

@end


@implementation RModel (Extensible)

- (NSString *)getDefaultIdentifier
{
    NSString *identifierKey = [ctx.responseMapper identifierKeyNameForModel:[self class]];
    NSString *identifier = [self valueForKey:identifierKey];
    return identifier;
}

- (void)setupWithObject:(NSDictionary *)obj
{
    RLog(@"should implment in subclass");
}

- (void)setupWithObject:(NSDictionary *)obj isUpdate:(BOOL)update
{
    RLog(@"should implment in subclass");
}

- (void)setupWithObject:(NSDictionary *)obj isUpdate:(BOOL)update inContext:(NSManagedObjectContext *)context
{
    RLog(@"should implment in subclass");
}

@end
