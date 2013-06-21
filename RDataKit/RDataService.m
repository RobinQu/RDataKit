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
//        [ds setDefaultHeader:@"Content-Type" value:@"application/json"];
        ds.parameterEncoding = AFJSONParameterEncoding;
        [ds registerHTTPOperationClass:[RServiceOperation class]];
    });
    return ds;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters
{
    //options that appends to url
    NSMutableDictionary *dict = [@{} mutableCopy];
    NSDictionary *conf = [RDataKitConfiguration get];
    if ([conf valueForKeyPath:@"url.options"]) {
        [dict addEntriesFromDictionary:[conf valueForKeyPath:@"url.options"]];
    } else if (self.delegate && [self.delegate respondsToSelector:@selector(dataService:handleQueryOptionForPath:options:)]) {
        [dict addEntriesFromDictionary:[self.delegate dataService:self handleQueryOptionForPath:path options:parameters]];
    }
    
    if ([@[@"GET", @"DELETE", @"HEAD"] indexOfObject:method] == NSNotFound) {
        //if we have object named form; we are extracting it and appending rest of `parameters` to the request path as querystring
        if ([parameters valueForKey:@"form"]) {
            [dict addEntriesFromDictionary:parameters];
            [dict removeObjectForKey:@"form"];
            parameters = [parameters valueForKey:@"form"];
        }
    }
    NSString *newPath = [path stringByAppendingFormat:([path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@"), AFQueryStringFromParametersWithEncoding(dict,NSUTF8StringEncoding)];
    NSMutableURLRequest *urlRequest = [super requestWithMethod:method path:newPath parameters:parameters];
    
    return urlRequest;
}

@end
