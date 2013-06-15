//
//  RDataService.m
//  RDataKit
//
//  Created by Robin Qu on 13-6-15.
//  Copyright (c) 2013年 Robin Qu. All rights reserved.
//

#import "RDataService.h"
#import "RServiceOperation.h"
#import "RDataKitConfiguration.h"

@interface RDataService ()
    
@end

@implementation RDataService

    
+ (id)defaultDataService
{
    static RDataService *ds = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *conf = [RDataKitConfiguration get];
        ds = [[RDataService alloc] initWithBaseURL:[NSURL URLWithString:[conf valueForKeyPath:@"url.base"]]];
        [ds registerHTTPOperationClass:[RServiceOperation class]];
    });
    return ds;
}
    
- (NSDictionary *)transformOptions:(NSDictionary *)options path:(NSString *)path
{
    
    NSDictionary *conf = [RDataKitConfiguration get];
    if ([conf valueForKeyPath:@"url.options"]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:options];
        [dict addEntriesFromDictionary:[conf valueForKeyPath:@"url.options"]];
        return dict;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(dataService:handleQueryOptionForPath:options:)]) {
        return [self.delegate dataService:self handleQueryOptionForPath:path options:options];
    }
    return options;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters
{
    NSDictionary *dict = [self transformOptions:parameters path:path];
    return [super requestWithMethod:method path:path parameters:dict];
}

@end
