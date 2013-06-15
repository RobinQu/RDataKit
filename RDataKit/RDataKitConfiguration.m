//
//  RDataKitConfiguration.m
//  RDataKit
//
//  Created by Robin Qu on 13-6-15.
//  Copyright (c) 2013年 Robin Qu. All rights reserved.
//

#import "RDataKitConfiguration.h"

@implementation RDataKitConfiguration

+ (NSDictionary *)get
{
    static NSDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RLog(@"%@", [NSBundle mainBundle]);
        NSString *fp = [[NSBundle mainBundle] pathForResource:@"RDataKit" ofType:@"plist"];
        dict = [NSDictionary dictionaryWithContentsOfFile:fp];
    });
    NSAssert(dict, @"should have loaded the configuration plist");
    return dict;
}
    
@end
