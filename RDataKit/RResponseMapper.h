//
//  ResponseMapper.h
//  RDataKit
//
//  Created by Robin Qu on 14-4-30.
//  Copyright (c) 2014年 Robin Qu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface RResponseMapper : NSObject

+ (instancetype)defaultResponseMapper;

// Key, identifier helpers
- (NSString *)identifierKeyNameForModel:(Class)modelClass;
- (NSString *)keyPathForObject:(id)object ofModel:(Class)modelClass;
- (BOOL)isGoodResponseForOperation:(AFHTTPRequestOperation*)opearation model:(Class)modalClass;

// Response parsing
- (NSArray *)parseObjectsFromResponse:(id)response forModel:(Class)modelClass;
- (id)parseObjectFromResponse:(id)response forModel:(Class)modelClass;


@end
