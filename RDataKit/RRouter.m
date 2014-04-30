//
//  RRouter.m
//  RDataKit
//
//  Created by Robin Qu on 14-4-30.
//  Copyright (c) 2014年 Robin Qu. All rights reserved.
//

#import "RRouter.h"
#import "NSString+Inflections.h"
#import "RDataKitConfiguration.h"

@implementation RRouter

+ (instancetype)defaultRouter
{
    static RRouter *router = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [RRouter new];
    });
    return router;
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


@end
