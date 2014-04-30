//
//  RDataService.m
//  RDataKit
//
//  Created by Robin Qu on 13-6-15.
//  Copyright (c) 2013年 Robin Qu. All rights reserved.
//

#import "RDataService.h"
//#import "RServiceOperation.h"
#import "RDataKitConfiguration.h"


@interface RDataService ()
    
@end

@implementation RDataService

    
+ (instancetype)defaultDataService
{
    static RDataService *ds = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *conf = [RDataKitConfiguration get];
        ds = [[RDataService alloc] initWithBaseURL:[NSURL URLWithString:[conf valueForKeyPath:@"url.base"]]];
        ds.requestSerializer = [AFJSONRequestSerializer serializer];
        ds.responseSerializer = [AFJSONResponseSerializer serializer];
        ds.securityPolicy = [AFSecurityPolicy defaultPolicy];
    });
    return ds;
}

@end
