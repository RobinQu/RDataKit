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
//    if (self.delegate && [self.delegate respondsToSelector:@selector(isGoodResponseForOperation:dataContext:modal:)]) {
//        return [self.delegate isGoodResponseForOperation:opearation dataContext:self modal:modalClass];
//    } else {
        NSInteger statusCode = opearation.response.statusCode;
        return statusCode >= 200 && statusCode < 400;
//    }
}

- (NSString *)identifierKeyNameForModel:(Class)modalClass
{
    NSDictionary *conf = [RDataKitConfiguration get];
    if ([conf valueForKey:@"identifierName"]) {
        return [conf valueForKey:@"identifierName"];
    }
//    if (self.delegate && [self.delegate respondsToSelector:@selector(dataContext:identifierKeyNameForModal:)]) {
//        return [self.delegate dataContext:self identifierKeyNameForModal:modalClass];
//    }
    return kDefaultIdentifierName;
}

- (NSString *)keyPathForObject:(id)object ofModel:(Class)modalClass
{
    NSDictionary *conf = [RDataKitConfiguration get];
    if ([conf valueForKey:@"identifierKeyPath"]) {
        return [conf valueForKey:@"identifierKeyPath"];
    }
//    if (self.delegate && [self.delegate respondsToSelector:@selector(dataContext:identifierKeyPathForResponse:modal:)]) {
//        return [self.delegate dataContext:self identifierKeyPathForResponse:object modal:modalClass];
//    }
    return kDefaultIdentifierName;
}

- (NSDictionary *)parseObjectFromResponse:(id)response forModel:(Class)modalClass
{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(dataContext:parseObjectFromResponse:modal:)]) {
//        return [self.delegate dataContext:self parseObjectFromResponse:response modal:modalClass];
//    }
    NSString *resourceName = [[modalClass description] lowercaseString];
    if ([response valueForKey:resourceName]) {
        return [response valueForKey:resourceName];
    }
    return response;
}

- (NSArray *)parseObjectsFromResponse:(id)response forModel:(Class)modalClass
{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(dataContext:parseObjectsFromResponse:modal:)]) {
//        return [self.delegate dataContext:self parseObjectsFromResponse:response modal:modalClass];
//    }
    NSString *collectionName = [[[modalClass description] pluralize] lowercaseString];
    if ([response valueForKey:collectionName]) {
        return [response valueForKey:collectionName];
    }
    return response;
}


@end
