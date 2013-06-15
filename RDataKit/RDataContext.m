//
//  RDataContext.m
//  RDataKit
//
//  Created by Robin Qu on 13-6-15.
//  Copyright (c) 2013年 Robin Qu. All rights reserved.
//

#import "RDataContext.h"
#import "RDataKitConfiguration.h"
#import "NSString+Inflections.h"
#import "AFHTTPRequestOperation.h"
#import "RModel.h"
#import <objc/runtime.h>

static NSString *const kDefaultIdentifierName = @"id";

@implementation RDataContext

+ (id)sharedDataContext
{
    NSAssert([self isSubclassOfClass:[RDataContext class]], @"should invoke on subclasses");
    return nil;
}
    
- (NSString *)pathNameForModal:(Class)modlaClass
{
    NSDictionary *map = [[RDataKitConfiguration get] valueForKey:@"routes"];
    NSString *path = nil;
    NSString *plural = [[modlaClass description] pluralize];
    if (map && map.count) {
        path = [map valueForKey:plural];
    }
    if (!path) {
        path = [plural copy];
    }
    return path;
}

- (BOOL)isGoodResponseForOperation:(AFHTTPRequestOperation *)opearation modal:(Class)modalClass
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(isGoodResponseForOperation:dataContext:modal:)]) {
        return [self.delegate isGoodResponseForOperation:opearation dataContext:self modal:modalClass];
    } else {
        NSInteger statusCode = opearation.response.statusCode;
        return statusCode >= 200 && statusCode < 400;
    }
}

- (NSString *)identifierKeyNameForModal:(Class)modalClass
{
    NSDictionary *conf = [RDataKitConfiguration get];
    if ([conf valueForKey:@"identifierName"]) {
        return [conf valueForKey:@"identifierName"];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(dataContext:identifierKeyNameForModal:)]) {
        return [self.delegate dataContext:self identifierKeyNameForModal:modalClass];
    }
    return kDefaultIdentifierName;
}

- (NSString *)keyPathForObject:(id)object ofModal:(Class)modalClass
{
    NSDictionary *conf = [RDataKitConfiguration get];
    if ([conf valueForKey:@"identifierKeyPath"]) {
        return [conf valueForKey:@"identifierKeyPath"];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(dataContext:identifierKeyPathForResponse:modal:)]) {
        return [self.delegate dataContext:self identifierKeyPathForResponse:object modal:modalClass];
    }
    return kDefaultIdentifierName;
}

- (NSDictionary *)parseObjectFromResponse:(id)response forModal:(Class)modalClass
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dataContext:parseObjectFromResponse:modal:)]) {
        return [self.delegate dataContext:self parseObjectFromResponse:response modal:modalClass];
    }
    NSString *resourceName = [[self class] description];
    if ([response valueForKey:resourceName]) {
        return [response valueForKey:resourceName];
    }
    return response;
}

- (NSArray *)parseObjectsFromResponse:(id)response forModal:(Class)modalClass
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dataContext:parseObjectsFromResponse:modal:)]) {
        return [self.delegate dataContext:self parseObjectsFromResponse:response modal:modalClass];
    }
    return response;
}

- (void)loadAllRecords:(Class)modalClass withOptions:(NSDictionary *)options callback:(ResourcesResponseCallbackBlock)callback
{
    NSString *path = [self pathNameForModal:modalClass];
    [self.dataService getPath:path parameters:options success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([self isGoodResponseForOperation:operation modal:modalClass]) {
            NSArray *objs = [self parseObjectsFromResponse:responseObject forModal:modalClass];
            NSMutableArray *results = [NSMutableArray array];
            [objs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                RModel *one = [self createOrUpdateModal:modalClass withObject:obj autoCommit:NO];
                if (one) {
                    [results addObject:one];
                } else {
                    RLog(@"failed to process obj %@", obj);
                }
            }];
            NSError *saveError = nil;
            [self.mainQueueMOC save:&saveError];
            if (saveError) {
                callback(saveError, nil);
            } else {
                callback(nil, results);
            }
        } else {
            if (callback) {
                callback(SERVICE_RESPONSE_ERROR, nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (callback) {
            callback(error, nil);
        }
    }];
}

- (void)loadRecord:(Class)modalClass byIdentifier:(NSString *)identifier withOptions:(NSDictionary *)options callback:(ResourceResponseCallbackBlock)callback
{
    NSString *path = [[self pathNameForModal:modalClass] stringByAppendingPathComponent:identifier];
    [self.dataService getPath:path parameters:options success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([self isGoodResponseForOperation:operation modal:modalClass]) {
            id obj = [self parseObjectFromResponse:responseObject forModal:modalClass];
            [self createOrUpdateModal:modalClass withObject:obj autoCommit:YES];
        } else {
            if (callback) {
                callback(SERVICE_RESPONSE_ERROR, nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (callback) {
            callback(error, nil);
        }
    }];
}

- (id)createOrUpdateModal:(Class)modalClass withObject:(id)obj autoCommit:(BOOL)autoCommit
{
    NSString *keyPath = [self keyPathForObject:obj ofModal:modalClass];
    NSAssert(keyPath, @"should have keyPath");
    NSString *identifier = [obj valueForKeyPath:keyPath];
    NSAssert(identifier, @"should have identifier");
    NSString *keyname = [self identifierKeyNameForModal:modalClass];
    NSAssert(keyname, @"should have primary key name");
    id one = [self findOneByModal:modalClass identifier:identifier];
    if (!one) {
        one = [NSEntityDescription insertNewObjectForEntityForName:[modalClass description] inManagedObjectContext:self.mainQueueMOC];
        [one setValue:identifier forKey:keyname];
    }
    SEL setup = @selector(setupWithObject:);
    if ([one respondsToSelector:setup]) {
        [one performSelector:setup withObject:obj];
    }
    if (autoCommit) {
        [self.mainQueueMOC save:nil];
    }
    return one;
}

- (void)createRecord:(Class)modalClass withObject:(NSDictionary *)obj callback:(ResourceResponseCallbackBlock)callback
{

}
    
- (void)updateRecord:(Class)modalClass withObject:(NSDictionary *)obj byIdentifier:(NSString *)identifier withCallback:(ResourceResponseCallbackBlock)callback
{
    
}
    
- (void)destroyRecord:(Class)modalClass byIdentifier:(NSString *)identifier withOptions:(NSDictionary *)options callback:(ErrorCallbackBlock)callback
{
    NSFetchRequest *fRequest = [NSFetchRequest fetchRequestWithEntityName:[modalClass description]];
    NSArray *results = [self.mainQueueMOC executeFetchRequest:fRequest error:nil];
    [results enumerateObjectsUsingBlock:^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
        [self.mainQueueMOC deleteObject:obj];
    }];
    [self.mainQueueMOC save:nil];
}

- (id)findOneByModal:(Class)modalClass identifier:(NSString *)identifier
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", [self identifierKeyNameForModal:modalClass], identifier];
    NSFetchRequest *fRequest = [NSFetchRequest fetchRequestWithEntityName:[modalClass description]];
    fRequest.predicate = predicate;
    NSArray *results = [self findByFetchRequest:fRequest];
    if (results.count) {
        return [results objectAtIndex:0];
    } else {
        return nil;
    }
}

- (NSArray *)findByFetchRequest:(NSFetchRequest *)fetchRequest
{
    NSError *error = nil;
    NSArray *results = [self.mainQueueMOC executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error whiling fetching %@", error);
    }
    return results;
}

- (void)removeAll:(Class)modalClass
{
    
}
    
@end
