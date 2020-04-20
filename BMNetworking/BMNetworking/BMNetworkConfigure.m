//
//  BMNetworkConfigure.m
//  BMNetworking
//
//  Created by fenglh on 2017/2/15.
//  Copyright © 2017年 BlueMoon. All rights reserved.
//

#import "BMNetworkConfigure.h"

#define BASE_URL        @"http://mallapi.bluemoon.com.cn"         // 正式地址
#define BASE_URL_TEST   @"http://tmallapi.bluemoon.com.cn" // 测试地址

@implementation BMNetworkConfigure


- (BOOL)isTestEnVironment
{
    return YES;
}
- (NSString *)baseUrl
{
    return BASE_URL;
}

- (NSString *)baseUrlTest
{
    return BASE_URL_TEST;
}
- (NSString *)tokenValue
{
    return @"18d01191fed4a1789da6b90606ec8d17";
}
- (NSInteger)tokenInvalidValue
{
    return 1301;
}
- (NSInteger)responseCodeSuccessValue
{
    return 0;
}

- (BMUserLoginStatus)loginStatus
{
    return BMUserLoginStatusLoginNormal;
}

- (NSString *)secrect
{
    return @"Er78s1hcT4Tyoaj2";
}
- (NSString *)clientUUID
{
    return @"9FEF140A-C9A4-4282-BDE7-32F72E54139D";
}


- (NSString *)appVersion
{
    return @"1.2.1";
}
- (NSString *)appType
{
    return @"washMall";
}
- (BMNetworkLogLevel)networkLogLevel
{
    return BMNetworkLogLevelRequest | BMNetworkLogLevelResponse;
}

@end
