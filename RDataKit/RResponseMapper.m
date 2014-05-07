//
//  ResponseMapper.m
//  RDataKit
//
//  Created by Robin Qu on 14-4-30.
//  Copyright (c) 2014年 Robin Qu. All rights reserved.
//

#import "RResponseMapper.h"
#import "RDataKitConfiguration.h"
#import "NSString+Inflections.h"


static NSString *const kDefaultIdentifierName = @"identifier";

@implementation RResponseMapper

+ (instancetype)defaultResponseMapper
{
    static RResponseMapper *mapper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapper = [RResponseMapper new];
    });
    return mapper;
}

- (BOOL)isGoodResponseForOperation:(AFHTTPRequestOperation *)opearation model:(Class)modelClass
{
    NSInteger statusCode = opearation.response.statusCode;
    return statusCode >= 200 && statusCode < 400;
}

- (NSString *)identifierKeyNameForModel:(Class)modalClass
{
    NSDictionary *conf = [RDataKitConfiguration get];
    if ([conf valueForKey:@"identifierName"]) {
        return [conf valueForKey:@"identifierName"];
    }
    return kDefaultIdentifierName;
}

- (NSString *)keyPathForObject:(id)object ofModel:(Class)modalClass
{
    NSDictionary *conf = [RDataKitConfiguration get];
    if ([conf valueForKey:@"identifierKeyPath"]) {
        return [conf valueForKey:@"identifierKeyPath"];
    }
    return kDefaultIdentifierName;
}

- (NSDictionary *)parseObjectFromResponse:(id)response forModel:(Class)modalClass
{
    NSString *resourceName = [[modalClass description] lowercaseString];
    if ([response valueForKey:resourceName]) {
        return [response valueForKey:resourceName];
    }
    return response;
}

- (NSArray *)parseObjectsFromResponse:(id)response forModel:(Class)modalClass
{
    NSString *collectionName = [[[modalClass description] pluralize] lowercaseString];
    if ([response valueForKey:collectionName]) {
        return [response valueForKey:collectionName];
    }
    return response;
}


@end
