//
//  RDataKitCommons.h
//  RDataKit
//
//  Created by Robin Qu on 13-6-15.
//  Copyright (c) 2013年 Robin Qu. All rights reserved.
//

#ifndef RDataKit_RDataKitCommons_h
#define RDataKit_RDataKitCommons_h

#define ServiceResponseErrorCode 1
#define RecordDeletedByServerErrorCode 2
#define NonRootCategoryErrorCode 3
#define ServiceNotReachableErrorCode 4
#define UserTokenUnkownErrorCode 5
#define WeiboNicknameUnknownErrorCode 6
#define UserSIIDUnkownErrorCode 7


#define DEFAULT_PRIMARY_KEYNAME @"_id.$oid"
#define DEFAULT_STATUS_KEYNAME @"status"
#define DEFAULT_ERROR_DOMAIN @"com.elfvision.datakit"
#define SERVICE_RESPONSE_ERROR [NSError errorWithDomain:DEFAULT_ERROR_DOMAIN code:ServiceResponseErrorCode userInfo:nil]

typedef void(^ResourcesResponseCallbackBlock)(NSError *error, NSArray *records);
typedef void(^ErrorCallbackBlock)(NSError *error);
typedef void(^ResourceResponseCallbackBlock)(NSError *error, id one);


#endif


#if DEBUG
# define RLog(fmt, ...) NSLog((@"%s [Line %d] " fmt),__PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define RLog(fmt, ...)
#endif
