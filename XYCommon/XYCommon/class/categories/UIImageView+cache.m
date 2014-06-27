//
//  UIImageView+cache.m
//  iLookForiPhone
//
//  Created by Yinghui Zhang on 6/6/12.
//  Copyright (c) 2012 LavaTech. All rights reserved.
//


#import "UIImageView+cache.h"
#import <objc/runtime.h>
#import "XYCommon.h"

static char UIImageViewCacheOperationObjectKey;

@interface UIImageView()
@property (readwrite, nonatomic, strong) NSOperation *requestOperation;
@end
@implementation UIImageView(cache)
- (NSOperation *)requestOperation {
    return (NSOperation *)objc_getAssociatedObject(self, &UIImageViewCacheOperationObjectKey);
}

- (void)setRequestOperation:(NSOperation *)requestOperation{
    objc_setAssociatedObject(self, &UIImageViewCacheOperationObjectKey, requestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSOperationQueue *)sharedImageRequestOperationQueue {
    static NSOperationQueue *_imageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        [_imageRequestOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    });
    
    return _imageRequestOperationQueue;
}

- (void)cancelImageRequestOperation {
    [self.requestOperation cancel];
    self.requestOperation = nil;
}
- (id)setImageURL:(NSURL *)imageURL placeholderImage:(UIImage *)placeholderImage withImageLoadedCallback:(void (^)(NSURL *imageURL, NSString *filePath, NSError *error))callback{
    [self cancelImageRequestOperation];
    NSString *fp = [UIImageView cachePathForURL:imageURL];
    if (fp) {
        UIImage *img = [UIImage imageWithContentsOfFile:fp];
        if (img) {
            self.image = img;
            if (callback) {
                callback(imageURL,fp,nil);
            }
            return nil;
        }
    }
    self.image = placeholderImage;
    XYHTTPClient *client = [XYHTTPClient defaultClient];
    NSURLRequest *request = [client requestWithGetURL:imageURL parameters:nil];
    XYHttpRequestOperation *operation = [client dataRequestWithURLRequest:request
                                                                 success:^(XYHttpRequestOperation *operation, id data) {
                                                                     NSDictionary *userInfo = [operation userInfo];
                                                                     id object = userInfo?[userInfo valueForKey:@"object"]:nil;
                                                                     NSString *fp = operation.cacheFilePath;
                                                                     if (self == object) {
                                                                         [self setImage:[UIImage imageWithContentsOfFile:fp]];
                                                                         if (callback) {
                                                                             callback(imageURL, fp, nil);
                                                                         }
                                                                     }
                                                                 }
                                                                 failure:^(XYHttpRequestOperation *request, NSError *error) {
                                                                     
                                                                     if (callback) {
                                                                         callback(imageURL, nil, error);
                                                                     }
                                                                 }];
    [operation setUserInfo:[NSDictionary dictionaryWithObject:self forKey:@"object"]];
    [operation setRequestCache:[XYHttpRequestCache fileCache]];
    self.requestOperation = operation;
    [[[self class] sharedImageRequestOperationQueue] addOperation:self.requestOperation];
    return operation;
}
- (void)setImageURL:(NSURL *)imageURL{
    [self setImageURL:imageURL placeholderImage:nil withImageLoadedCallback:nil];
}
- (void)setImageURL:(NSURL *)imageURL placeholderImage:(UIImage *)placeholderImage{
    [self setImageURL:imageURL placeholderImage:placeholderImage withImageLoadedCallback:nil];
}

- (id)setImageURL:(NSURL *)imageURL withImageLoadedCallback:(void (^)(NSURL *imageURL, NSString *filePath, NSError *error))callback{
    return [self setImageURL:imageURL placeholderImage:nil withImageLoadedCallback:callback];
}

+ (NSString *)cachePathForURL:(NSURL *)imageURL{
    return [XYHttpRequestCache cachePathForURL:imageURL];
}
+ (NSData *)cacheDataForURL:(NSURL *)imageURL{
    return [XYHttpRequestCache cacheDataForURL:imageURL];
}
@end
