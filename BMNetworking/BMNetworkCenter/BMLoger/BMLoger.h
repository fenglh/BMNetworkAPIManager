//
//  BMLoger.h
//  BlueMoonBlueHouse
//
//  Created by 冯立海 on 15/9/25.
//  Copyright (c) 2015年 fenglh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMURLResponse.h"

@interface BMLoger : NSObject


+ (void)logDebugInfoWithRequest:(NSURLRequest *) request apiName:(NSString *)apiName url:(NSString *)url requestParams:(id)requestParams httpMethod:(NSString *)httpMethod;

+ (void)logDebugInfoWithResponse:(NSHTTPURLResponse *)response resposeString:(NSString *)responseString request:(NSURLRequest *)request error:(NSError *)error;

+ (void)logDebugInfoWithCachedResponse:(BMURLResponse *)response apiName:(NSString *)apiName url:(NSString *)url;
@end
