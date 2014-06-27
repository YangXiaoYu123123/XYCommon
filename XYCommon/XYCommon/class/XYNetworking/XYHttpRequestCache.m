//
//  XYHttpRequestCache.m
//  XYCommon
//
//  Created by YangXIAOYU on 14-6-26.
//  Copyright (c) 2014年 杨 逍宇. All rights reserved.
//

#import "XYHttpRequestCache.h"
#import "NSString+x.h"
#import "Utils.h"

@implementation XYHttpRequestCache
+ (id)defaultCache{
    static id _defaultHttpRequestCache = nil;
    static dispatch_once_t initOnceDefaultCache;
    dispatch_once(&initOnceDefaultCache, ^{
        _defaultHttpRequestCache = [[XYHttpRequestCache alloc] init];
        //_defaultHttpRequestCache.ca :BHttpRequestCachePolicyFallbackToCacheIfLoadFails];
    });
    return _defaultHttpRequestCache;
}
+ (id)fileCache{
    static id _fileRequestCache = nil;
    static dispatch_once_t initOnceFileCache;
    dispatch_once(&initOnceFileCache, ^{
        _fileRequestCache = [[XYHttpRequestCache alloc] init];
        //[_fileRequestCache setCachePolicy:BHttpRequestCachePolicyLoadIfNotCached];
    });
    return _fileRequestCache;
}

- (NSString *)cachePathForURL:(NSURL *)url{
    return [XYHttpRequestCache cachePathForURL:url];
}
- (NSData *)cacheDataForURL:(NSURL *)url{
    return [XYHttpRequestCache cacheDataForURL:url];
}
+ (NSString *)cachePathForURL:(NSURL *)url{
    NSString *fn = [[url absoluteString] md5];
    NSString *ext = [url pathExtension];
    return getFilePath(fn, ext, gImageCacheDir);
}
+ (NSData *)cacheDataForURL:(NSURL *)url{
    NSString *fp = [self cachePathForURL:url];
    if (fp && [[NSFileManager defaultManager] fileExistsAtPath:fp]) {
        return [NSData dataWithContentsOfFile:fp];
    }
    return nil;
}

@end
