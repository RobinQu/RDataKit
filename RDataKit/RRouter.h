//
//  RRouter.h
//  RDataKit
//
//  Created by Robin Qu on 14-4-30.
//  Copyright (c) 2014年 Robin Qu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RRouter : NSObject

+ (instancetype)defaultRouter;

- (NSString *)pathNameForModal:(Class)modlaClass;


@end
