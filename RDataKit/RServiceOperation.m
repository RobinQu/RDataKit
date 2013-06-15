//
//  RServiceOperation.m
//  RDataKit
//
//  Created by Robin Qu on 13-6-15.
//  Copyright (c) 2013年 Robin Qu. All rights reserved.
//

#import "RServiceOperation.h"

@implementation RServiceOperation

@synthesize successCallbackQueue = _successCallbackQueue;
@synthesize failureCallbackQueue = _failureCallbackQueue;

+ (NSSet *)acceptableContentTypes
{
    return [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
}

+ (BOOL)canProcessRequest:(NSURLRequest *)urlRequest
{
    return YES;
}

//这两个类型的回调都在main_queue, callback里面的CoreData处理会明显柱塞了UI，因该将其移出main_queue
//MOC对象不是thread-safe, 如果网络请求的callback在别的queue执行（对应不同的thread），这些callback将不能正常操作CoreData
//http://stackoverflow.com/questions/3446983/collection-was-mutated-while-being-enumerated-on-executefetchrequest
//http://www.duckrowing.com/2010/03/11/using-core-data-on-multiple-threads/

//TODO: 在不同的queue使用不同的MOC，在main_queue合并

//- (dispatch_queue_t)successCallbackQueue
//{
//    if (!_successCallbackQueue) {
////        _successCallbackQueue = dispatch_queue_create("network_success_callback", DISPATCH_QUEUE_CONCURRENT);
//        _successCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//        dispatch_retain(_successCallbackQueue);
//    }
//    RLog(@"success queue");
//    return _successCallbackQueue;
//}
//
//- (dispatch_queue_t)failureCallbackQueue
//{
//    if (!_failureCallbackQueue) {
//        _failureCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//        dispatch_retain(_failureCallbackQueue);
//    }
//    RLog(@"failure queue");
//    return _failureCallbackQueue;
//}
    
@end
