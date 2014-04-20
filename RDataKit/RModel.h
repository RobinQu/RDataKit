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
+ (void)loadAllWithOptions:(NSDictionary *)options callback:(ResourcesResponseCallbackBlock)callback;
+ (void)loadByIdentifier:(NSString *)identifier withOptions:(NSDictionary *)options callback:(ResourceResponseCallbackBlock)callback;
+ (void)requestRecord:(Class)modalClass atPath:(NSString *)path method:(NSString *)method withObject:(NSDictionary *)obj callback:(ResourceResponseCallbackBlock)callback forRaw:(BOOL)raw;
+ (void)createWithObject:(NSDictionary *)obj callback:(ResourceResponseCallbackBlock)callback;
+ (NSString *)buildPathOptions:(NSDictionary *)options;

- (void)updateWithObject:(NSDictionary *)obj callback:(ResourceResponseCallbackBlock)callback;
- (void)destroyWithOptions:(NSDictionary *)options callback:(ErrorCallbackBlock)callback;

//Local helpers
+ (id)findOneByIdentifier:(NSString *)identifier;
+ (NSArray *)findByPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;
+ (void)deleteByIdentifier:(NSString *)identifier autoCommit:(BOOL)autoCommit;

@end


@interface RModel (Extensible)

- (void)setupWithObject:(NSDictionary *)obj;
- (void)setupWithObject:(NSDictionary *)obj isUpdate:(BOOL)update;

@end