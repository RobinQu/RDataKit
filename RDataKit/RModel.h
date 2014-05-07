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
    
@property (nonatomic, assign, readonly) NSString *identifier;

+ (void)regisiterDataContext:(RDataContext *)dataContext;

// Raw methods
+ (void)handleRecordsByMethod:(NSString *)method atPath:(NSString *)path  withObject:(NSDictionary*)object callback:(ResponseCallbackBlock)callback;
+ (void)handleRecordByMethod:(NSString *)method atPath:(NSString *)path withObject:(NSDictionary*)object callback:(ResponseCallbackBlock)callback;


// CRUD methods
+ (void)loadAllWithOptions:(NSDictionary *)options callback:(ResponseCallbackBlock)callback;
+ (void)refreshWithOptions:(NSDictionary *)options callback:(ResponseCallbackBlock)callback;
+ (void)loadByIdentifier:(NSString *)identifier withOptions:(NSDictionary *)options callback:(ResourceResponseCallbackBlock)callback;
+ (void)createWithObject:(NSDictionary *)obj callback:(ResourceResponseCallbackBlock)callback;
+ (void)updateByIdentifier:(NSString *)identifier withOptions:(NSDictionary *)options callback:(ResourceResponseCallbackBlock)callback;
+ (void)deleteByIdentifier:(NSString *)identifier withOptions:(NSDictionary *)options callback:(ResourceResponseCallbackBlock)callback;

- (void)updateWithObject:(NSDictionary *)obj callback:(ResourceResponseCallbackBlock)callback;
- (void)destroyWithOptions:(NSDictionary *)options callback:(ResourceResponseCallbackBlock)callback;

@end

@interface RModel (Extensible)

- (NSString *)getDefaultIdentifier;
- (void)setupWithObject:(NSDictionary *)obj;
- (void)setupWithObject:(NSDictionary *)obj isUpdate:(BOOL)update;
- (void)setupWithObject:(NSDictionary *)obj isUpdate:(BOOL)update inContext:(NSManagedObjectContext *)context;

@end