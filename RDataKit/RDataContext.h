//
//  RDataContext.h
//  RDataKit
//
//  Created by Robin Qu on 13-6-15.
//  Copyright (c) 2013年 Robin Qu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDataService.h"

@class RModel, RDataContext, AFHTTPRequestOperation;

@protocol RDataContextDelegate <NSObject>

@optional
- (NSString *)dataContext:(RDataContext *)dataContext identifierKeyNameForModal:(Class)modalClass;
- (NSString *)dataContext:(RDataContext *)dataContext pathNameForModal:(Class)modlaClass;
- (BOOL)isGoodResponseForOperation:(AFHTTPRequestOperation *)opearation dataContext:(RDataContext *)dataContext modal:(Class)modalClass;
- (NSArray *)dataContext:(RDataContext *)dataContext parseObjectsFromResponse:(id)response modal:(Class)modalClass;
- (id)dataContext:(RDataContext *)dataContext parseObjectFromResponse:(id)response modal:(Class)modalClass;
- (NSString *)dataContext:(RDataContext *)dataContext identifierKeyPathForResponse:(id)response modal:(Class)modalClass;
@end

@interface RDataContext : NSObject

@property (nonatomic, retain) NSManagedObjectContext *mainQueueMOC;
@property (nonatomic, assign) id<RDataContextDelegate> delegate;
@property (nonatomic, retain) RDataService* dataService;
    
+ (id)sharedDataContext;
    
//remote data methods
- (void)loadAllRecords:(Class)modalClass withOptions:(NSDictionary *)options callback:(ResourcesResponseCallbackBlock)callback;
- (void)loadRecord:(Class)modalClass byIdentifier:(NSString *)identifier withOptions:(NSDictionary *)options callback:(ResourceResponseCallbackBlock)callback;
- (void)destroyRecord:(Class)modalClass byIdentifier:(NSString *)identifier withOptions:(NSDictionary *)options callback:(ErrorCallbackBlock)callback;
- (void)updateRecord:(Class)modalClass withObject:(NSDictionary *)obj byIdentifier:(NSString *)identifier withCallback:(ResourceResponseCallbackBlock)callback;
- (void)createRecord:(Class)modalClass withObject:(NSDictionary *)obj callback:(ResourceResponseCallbackBlock)callback;
    
  
//local data methods
- (id)findOneByModal:(Class)modalClass identifier:(NSString *)identifier;
- (NSArray *)findByFetchRequest:(NSFetchRequest *)fetchRequest;

- (NSString *)identifierKeyNameForModal:(Class)modalClass;
- (NSString *)keyPathForObject:(id)object ofModal:(Class)modalClass;
- (BOOL)isGoodResponseForOperation:(AFHTTPRequestOperation*)opearation modal:(Class)modalClass;
- (NSArray *)parseObjectsFromResponse:(id)response forModal:(Class)modalClass;
- (id)parseObjectFromResponse:(id)response forModal:(Class)modalClass;
- (id)createOrUpdateModal:(Class)modalClass withObject:(id)obj autoCommit:(BOOL)autoCommit;
- (void)removeAll:(Class)modalClass;
    
@end
