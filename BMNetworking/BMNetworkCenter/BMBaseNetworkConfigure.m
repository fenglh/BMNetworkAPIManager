//
//  BMBaseNetworkConfigure.m
//  BMNetworking
//
//  Created by fenglh on 2017/1/20.
//  Copyright © 2017年 BlueMoon. All rights reserved.
//

#import "BMBaseNetworkConfigure.h"
#import <objc/runtime.h>

@implementation BMBaseNetworkConfigure
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static BMBaseNetworkConfigure *shareInstance;
    dispatch_once(&onceToken, ^{
        Class subclass = [[BMBaseNetworkConfigure getSubclasses] firstObject];
        shareInstance = [[subclass alloc] init];
    });
    return shareInstance;
}




//baseUrl
- (NSString *)baseUrl
{
    NSAssert(0, @"子类必须实现协议方法:%@",NSStringFromSelector(_cmd));
    return nil;
}
//baseUrlTest
- (NSString *)baseUrlTest
{
    NSAssert(0, @"子类必须实现协议方法:%@",NSStringFromSelector(_cmd));
    return nil;
}

//token 值
- (NSString *)tokenValue
{
    NSAssert(0, @"子类必须实现协议方法:%@",NSStringFromSelector(_cmd));
    return nil;
}

//响应码成功值
- (NSInteger)responseCodeSuccessValue
{
    NSAssert(0, @"子类必须实现协议方法:%@",NSStringFromSelector(_cmd));
    return 0;
}

//登录状态
- (BMUserLoginStatus)loginStatus
{
    NSAssert(0, @"子类必须实现协议方法:%@",NSStringFromSelector(_cmd));
    return BMUserLoginStatusUnLogin;
}

//@"Er78s1hcT4Tyoaj2";//私钥
- (NSString *)secrect
{
    NSAssert(0, @"子类必须实现协议方法:%@",NSStringFromSelector(_cmd));
    return nil;
}

//设备唯一标示符
- (NSString *)clientUUID
{
    NSAssert(0, @"子类必须实现协议方法:%@",NSStringFromSelector(_cmd));
    return nil;
}

//时间戳,传[NSString stringWithFormat:@"%ld",time(NULL)];即可
- (NSString *)timeStamp
{
    NSAssert(0, @"子类必须实现协议方法:%@",NSStringFromSelector(_cmd));
    return nil;
}

//客户端版本
- (NSString *)appVersion
{
    NSAssert(0, @"子类必须实现协议方法:%@",NSStringFromSelector(_cmd));
    return nil;
}

//appType,即可至尊：washMall
- (NSString *)appType
{
    NSAssert(0, @"子类必须实现协议方法:%@",NSStringFromSelector(_cmd));
    return nil;
}

//是否测试环境
- (BOOL)isTestEnVironment
{
    NSAssert(0, @"子类必须实现协议方法:%@",NSStringFromSelector(_cmd));
    return NO;
}


//token无效值
- (NSInteger)tokenInvalidValue
{
    NSAssert(0, @"子类必须实现协议方法:%@",NSStringFromSelector(_cmd));
    return 0;
}


#pragma mark - 可选
//token
- (NSString *)tokenKey
{
    return @"token";
}
- (NSString *)pageIndexKey
{
    return @"pageIndex";
}
- (NSString *)pageTotalKey
{
    return @"total";
}

//分页key
- (NSString *)pageSizeKey
{
    return @"pageSize";
}

- (NSUInteger)unPageSize
{
    return 10;
}

//分页大小
- (NSUInteger)pageSize
{
    return 10;
}

//时间戳key
- (NSString *)timestampKey
{
    return @"timestamp";
}

//响应码key
- (NSString *)responseCodeKey
{
    return @"responseCode";
}

//响应信息key
- (NSString *)responseMsgKey
{
    return @"responseMsg";
}

//最多缓存数量
- (NSUInteger)cacheCountLimit
{
    return 1000;
}

//缓存时间
- (NSTimeInterval)cacheTimeOutSeconds
{
    return 300;
}

//网络超时时间
- (NSTimeInterval)requestTimeOutSeconds
{
    return 20;
}

//默认@"json"
- (NSString *)contentFormat
{
    return @"json";
}

//@"ios"
- (NSString *)clientPlatform
{
    return @"ios";
}

//定位
- (CLLocation *)location
{
    return nil;
}

//网络日志等级
- (BMNetworkLogLevel)networkLogLevel
{
    return BMNetworkLogLevelVerbose;
}

#pragma mark - 私有方法（获取基类的子类）
+ (NSArray *)getSubclasses
{
    NSMutableArray *subclasses = [NSMutableArray array];
    int numClasses;
    Class *classes = NULL;
    numClasses = objc_getClassList(NULL,0);
    
    if (numClasses >0 )
    {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            if (class_getSuperclass(classes[i]) == [self class]){
                [subclasses addObject:classes[i]];
                NSLog(@"发现基础网络配置子类：%@", NSStringFromClass(classes[i]));
            }
        }  
        free(classes);  
    }
    return subclasses;
}

@end
