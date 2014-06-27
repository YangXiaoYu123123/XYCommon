//
//  XYCommon.h
//  XYCommon
//
//  Created by YangXIAOYU on 14-6-27.
//  Copyright (c) 2014年 杨 逍宇. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DLOG(...)  NSLog(@"[DEBUG][%s] - [line:%d] %@",__func__, __LINE__, [NSString stringWithFormat:__VA_ARGS__]);
#define DaySec                      3600*24
#define HourSec                        3600

#define CacheSchemeName                 @"cache-image"

//categories
#import "NSNull+x.h"
#import "NSDate+x.h"
#import "NSArray+x.h"
#import "NSDictionary+x.h"
#import "NSMutableData+x.h"
#import "NSString+x.h"
#import "UIImage+x.h"
#import "UIColor+x.h"
#import "NSThread+x.h"

//Utils
#import "Utils.h"
#import "UIUtils.h"

//NetWorking
#import "XYHttpRequestOperation.h"
#import "XYHTTPClient.h"
#import "XYHttpRequestCache.h"

@interface XYCommon : NSObject

@end
