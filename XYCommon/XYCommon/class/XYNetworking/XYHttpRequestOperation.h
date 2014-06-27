//
//  XYHttpRequestOperation.h
//  XYCommon
//
//  Created by YangXIAOYU on 14-6-26.
//  Copyright (c) 2014年 杨 逍宇. All rights reserved.
//

#import "AFHTTPRequestOperation.h"
#import "AFURLConnectionOperation.h"
#import "XYHttpRequestCache.h"

@interface XYHttpRequestOperation : AFHTTPRequestOperation
@property (nonatomic, retain) NSString *cacheFilePath;
@property (nonatomic, retain) XYHttpRequestCache *requestCache;
@property (nonatomic, readonly) BOOL readFromCache;
@property (nonatomic, readonly) BOOL downloadResume;
- (void)setReceiveDataBlock:(void (^)(NSData *data))block;
@end

@interface XYHttpRequest: NSObject

+ (XYHttpRequestOperation *)queryWithUrl:(NSString *)url params:(NSDictionary *)params  cache:(XYHttpRequestCache*)cache callback:(void(^)(XYHttpRequestOperation *operation, id response, NSError *error))callback;
+ (XYHttpRequestOperation *)postWithUrl:(NSString *)url params:(NSDictionary *)params  cache:(XYHttpRequestCache*)cache callback:(void(^)(XYHttpRequestOperation *operation, id response, NSError *error))callback;
@end