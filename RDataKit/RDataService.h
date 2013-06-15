//
//  RDataService.h
//  RDataKit
//
//  Created by Robin Qu on 13-6-15.
//  Copyright (c) 2013年 Robin Qu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@class RDataService, AFHTTPRequestOperation;

@protocol RDataServiceDelegate <NSObject>

@optional
- (NSDictionary *)dataService:(RDataService *)dataService handleQueryOptionForPath:(NSString *)path options:(NSDictionary*)options;

@end


@interface RDataService : AFHTTPClient
    
@property (nonatomic, assign) id<RDataServiceDelegate> delegate;

+ (id)defaultDataService;
    
@end
