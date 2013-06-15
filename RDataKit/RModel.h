//
//  RModel.h
//  RDataKit
//
//  Created by Robin Qu on 13-6-15.
//  Copyright (c) 2013年 Robin Qu. All rights reserved.
//

#import <CoreData/CoreData.h>

@class RDataContext;

@interface RModel : NSManagedObject
    
    @property (nonatomic, assign, readonly) NSString *identifer;
+ (void)regisiterDataContext:(RDataContext *)dataContext;
+ (void)loadAllWithOptions:(NSDictionary *)options callback:(ResourcesResponseCallbackBlock)callback;
+ (void)loadByIdentifier:(NSString *)identifier withOptions:(NSDictionary *)options callback:(ResourceResponseCallbackBlock)callback;
+ (void)createWithObject:(NSDictionary *)obj callback:(ResourceResponseCallbackBlock)callback;
- (void)updateWithObject:(NSDictionary *)obj callback:(ResourceResponseCallbackBlock)callback;
- (void)destroyWithOptions:(NSDictionary *)options callback:(ErrorCallbackBlock)callback;
    
- (void)setupWithObject:(NSDictionary *)obj;    
    
    
@end
