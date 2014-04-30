//
//  RDataContext.h
//  RDataKit
//
//  Created by Robin Qu on 13-6-15.
//  Copyright (c) 2013年 Robin Qu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDataService.h"
#import "RResponseMapper.h"
#import "RRouter.h"

@class RModel, RDataContext, AFHTTPRequestOperation;

@protocol RDataContextDelegate <NSObject>

@optional
//- (NSString *)dataContext:(RDataContext *)dataContext identifierKeyNameForModal:(Class)modalClass;
//- (NSString *)dataContext:(RDataContext *)dataContext pathNameForModal:(Class)modlaClass;
//- (BOOL)isGoodResponseForOperation:(AFHTTPRequestOperation *)opearation dataContext:(RDataContext *)dataContext modal:(Class)modalClass;
//- (NSArray *)dataContext:(RDataContext *)dataContext parseObjectsFromResponse:(id)response modal:(Class)modalClass;
//- (id)dataContext:(RDataContext *)dataContext parseObjectFromResponse:(id)response modal:(Class)modalClass;
//- (NSString *)dataContext:(RDataContext *)dataContext identifierKeyPathForResponse:(id)response modal:(Class)modalClass;
@end

@interface RDataContext : NSObject

// main queue moc
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
// background queue moc
@property (readonly, strong, nonatomic) NSManagedObjectContext *writerManagedObjectContext;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) RResponseMapper *responseMapper;
@property (nonatomic, retain) RRouter *router;

@property (nonatomic, assign) id<RDataContextDelegate> delegate;
@property (nonatomic, retain) RDataService* dataService;

- (instancetype)initWithModelURL:(NSURL *)modelURL storeURL:(NSURL *)storeURL;

- (NSManagedObjectContext *)makeChildContext;
- (void)commitChildContext:(NSManagedObjectContext *)context callback:(ErrorCallbackBlock)callback;

// Sync Model CRUD
- (id)findOneInContext:(NSManagedObjectContext *)context byModal:(Class)modalClass identifier:(NSString *)identifier;
- (id)createOrUpdateInContext:(NSManagedObjectContext *)context WithObject:(id)obj ofClass:(Class)modelClass;
- (void)removeAllInContext:(NSManagedObjectContext *)context ofClass:(Class)modelClass ;

@end
