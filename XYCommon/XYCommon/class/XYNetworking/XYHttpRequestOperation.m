//
//  XYHttpRequestOperation.m
//  XYCommon
//
//  Created by YangXIAOYU on 14-6-26.
//  Copyright (c) 2014年 杨 逍宇. All rights reserved.
//

#import "XYHttpRequestOperation.h"
#import "NSString+x.h"
#import "XYHTTPClient.h"

typedef void (^BHttpRequestOperationReceiveBlock)(NSData *data);

typedef void (^AFURLConnectionOperationProgressBlock)(NSUInteger bytes, long long totalBytes, long long totalBytesExpected);

@interface AFURLConnectionOperation(x)<NSURLConnectionDataDelegate>
- (long long)totalBytesRead;
- (void)setTotalBytesRead:(long long)t;
- (AFURLConnectionOperationProgressBlock)downloadProgress;
- (NSRecursiveLock *)lock;
- (void)finish;
- (void)operationDidStart;
@end

@interface XYHttpRequestOperation()
@property (nonatomic, retain) NSString *tmpFilePath;
@property (nonatomic, assign) BOOL readFromCache;
@property (nonatomic, copy)   BHttpRequestOperationReceiveBlock receiveBlock;
@end

@implementation XYHttpRequestOperation
- (void)dealloc{
    _cacheFilePath=nil;
    _requestCache=nil;
    _tmpFilePath=nil;
    if (_receiveBlock)
        (_receiveBlock=nil);
}
- (NSString *)responseString{
    NSString *s = [super responseString];
    if (!s && [self responseData]) {
        s = [[NSString alloc] initWithData:[self responseData] encoding:NSUTF8StringEncoding];
    }
    return s;
}
+ (BOOL)canProcessRequest:(NSURLRequest *)urlRequest{
    return YES;
}
- (void)setTmpFilePath:(NSString *)tmpFilePath{
    _tmpFilePath = tmpFilePath;
    if (!self.downloadResume)
        [tmpFilePath deleteFile];
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:tmpFilePath append:YES];
}

- (void)setCacheFilePath:(NSString *)cacheFilePath{
    //DLOG(@"cache file:%@",cacheFilePath);
    _cacheFilePath = cacheFilePath;
    NSString *tmpFilePath = tmpFilePath = [cacheFilePath stringByAppendingPathExtension:@"download"];
    if (!self.downloadResume) {
        [[NSString stringWithFormat:@"%@.%d",cacheFilePath,(int)arc4random()] stringByAppendingPathExtension:@"download"];
    }
    [self setTmpFilePath:tmpFilePath];
}
- (XYHttpRequestCache *)requestCache{
    if (!_requestCache) {
        _requestCache = [[XYHttpRequestCache alloc] init];
    }
    return _requestCache;
}
- (NSData *)responseData{
    NSData *data = [super responseData];
    if (!data && [self.cacheFilePath sizeOfFile] > 0) {
        data = [NSData dataWithContentsOfFile:self.cacheFilePath];
        if (!data && [self.tmpFilePath fileExists]) {
            data = [NSData dataWithContentsOfFile:self.tmpFilePath];
        }
    }
    return data;
}
- (void)operationDidStart{
    [self.lock lock];
    self.readFromCache = NO;
    // 准备缓存路径
    if ( (self.requestCache.cachePolicy & BHttpRequestCachePolicyLoadIfNotCached)
        || (self.requestCache.cachePolicy & BHttpRequestCachePolicyFallbackToCacheIfLoadFails)
        || (self.requestCache.cachePolicy & BHttpRequestCachePolicySaveCache)) {
        NSString *cacheFilePath = [self.requestCache cachePathForURL:self.request.URL];
        [self setCacheFilePath:cacheFilePath];
    }
    //优先使用缓存
    if (self.requestCache.cachePolicy & BHttpRequestCachePolicyLoadIfNotCached) {
        if ([self.cacheFilePath sizeOfFile]>0) {
            self.readFromCache = YES;
            [self finish];
            [self.lock unlock];
            //DLOG(@"read from cache directory");
            return;
        };
    }
    long long downloadSize = [self.tmpFilePath sizeOfFile];
    if (self.downloadResume) {
        [(NSMutableURLRequest *)self.request setValue:[NSString stringWithFormat:@"bytes=%lld-", downloadSize] forHTTPHeaderField:@"Range"];
    }
    [self.lock unlock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.totalBytesRead += downloadSize;
        
        if (self.downloadProgress) {
            self.downloadProgress(0, self.totalBytesRead, self.response.expectedContentLength);
        }
    });
    [super operationDidStart];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if (self.receiveBlock) {
        self.receiveBlock(data);
    }
    [super connection:connection didReceiveData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [self.outputStream close];
    if (self.cacheFilePath) {
        NSLog(@"renameto");
        [self.cacheFilePath deleteFile];
        BOOL flag = [self.tmpFilePath renameToPath:self.cacheFilePath];
        if (![self.cacheFilePath fileExists]) {
            NSLog(@"cache file:%d", flag);
        }
    }
    [super connectionDidFinishLoading:connection];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (self.requestCache.cachePolicy & BHttpRequestCachePolicyFallbackToCacheIfLoadFails) {
        if ([self.cacheFilePath sizeOfFile]>0) {
            self.readFromCache = YES;
        }
    }
    [super connection:connection didFailWithError:error];
}
- (NSError *)error{
    if (self.readFromCache) {
        return nil;
    }
    return [super error];
}
- (void)setReceiveDataBlock:(void (^)(NSData *data))block{
    _receiveBlock = [block copy];
}

@end

@implementation XYHttpRequest

+ (XYHttpRequestOperation *)queryWithUrl:(NSString *)url params:(NSDictionary *)params   cache:(XYHttpRequestCache*)cache callback:(void(^)(XYHttpRequestOperation *operation, id response, NSError *error))callback{
    XYHTTPClient *client = [XYHTTPClient defaultClient];
    NSURLRequest *request = [client requestWithGetURL:[NSURL URLWithString:url] parameters:params];
    id operation =
    [client dataRequestWithURLRequest:request
                              success:^(XYHttpRequestOperation *operation, id data) {
                                  if (callback) {
                                      callback(operation, data,nil);
                                  }
                              }
                              failure:^(XYHttpRequestOperation *operation, NSError *error) {
                                  if (callback) {
                                      callback(operation, nil,error);
                                  }
                                  
                              }];
    [operation setRequestCache:cache];
    [client enqueueHTTPRequestOperation:operation];
    return operation;
}
+ (XYHttpRequestOperation *)postWithUrl:(NSString *)url params:(NSDictionary *)params   cache:(XYHttpRequestCache*)cache callback:(void(^)(XYHttpRequestOperation *operation, id response, NSError *error))callback{
    XYHTTPClient *client = [XYHTTPClient defaultClient];
    NSURLRequest *request = [client requestWithPostURL:[NSURL URLWithString:url] parameters:params];
    id operation =
    [client dataRequestWithURLRequest:request
                              success:^(XYHttpRequestOperation *operation, id data) {
                                  if (callback) {
                                      callback(operation, data,nil);
                                  }
                              }
                              failure:^(XYHttpRequestOperation *operation, NSError *error) {
                                  if (callback) {
                                      callback(operation, nil,error);
                                  }
                                  
                              }];
    [operation setRequestCache:cache];
    [client enqueueHTTPRequestOperation:operation];
    return operation;
}
@end

