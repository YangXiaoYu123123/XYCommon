//
//  XYHTTPClient.h
//  XYCommon
//
//  Created by YangXIAOYU on 14-6-26.
//  Copyright (c) 2014年 杨 逍宇. All rights reserved.
//

#import "AFHTTPClient.h"
#import "XYHttpRequestOperation.h"
enum{
    HttpRequestMethodGET,
    HttpRequestMethodPOST,
    HttpRequestMethodPUT
};
typedef UInt32 HttpRequestMethod;

@interface XYHTTPClient : AFHTTPClient
+ (id)defaultClient;
- (id)jsonRequestWithURLRequest:(NSURLRequest *)urlRequest
                        success:(void (^)(XYHttpRequestOperation *operation, id json))success
                        failure:(void (^)(XYHttpRequestOperation *operation, NSError *error))failure;

- (id)dataRequestWithURLRequest:(NSURLRequest *)urlRequest
                        success:(void (^)(XYHttpRequestOperation *operation, id data))success
                        failure:(void (^)(XYHttpRequestOperation *operation, NSError *error))failure;

- (NSMutableURLRequest *)requestWithPostURL:(NSURL *)url parameters:(NSDictionary *)parameters;
- (NSMutableURLRequest *)requestWithGetURL:(NSURL *)url parameters:(NSDictionary *)parameters;
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                       url:(NSURL *)url
                                parameters:(NSDictionary *)parameters;
@end
