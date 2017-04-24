//
//  BMBaseNetworkConfigureProtocol.h
//  BMNetworking
//
//  Created by fenglh on 2017/1/23.
//  Copyright © 2017年 BlueMoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BMEnumType.h"


@protocol BMBaseNetworkConfigureProtocol <NSObject>
@required

- (BOOL)isTestEnVironment;              //是否测试环境
- (NSString *)baseUrl;                  //baseUrl
- (NSString *)baseUrlTest;              //baseUrl
- (NSString *)tokenValue;               //token值
- (NSInteger)responseCodeSuccessValue;  //响应码成功值
- (BMUserLoginStatus)loginStatus;       //登录状态
- (NSString *)secrect;                  //@"Er78s1hcT4Tyoaj2";//私钥
- (NSString *)clientUUID;               //设备唯一标示符
- (NSString *)appVersion;               //客户端版本
- (NSString *)appType;                  //appType,即可至尊：washMall
- (NSInteger)tokenInvalidValue;         //token无效值


@optional

- (NSString *)tokenKey;                 //token key,默认@"token"
- (NSString *)pageSizeKey;              //分页key,默认@"pageSize"

- (NSUInteger)unPageSize;                //不分页（下拉）大小,默认@"10"
- (NSUInteger)pageSize;                 //分页大小,默认@"10"
- (NSString *)timestampKey;             //时间戳key,默认@"timestamp"

- (NSString *)pageIndexKey;             //当使用BMPageTypePageNumber,类型的分页方式时候，需要用到该key,默认@"pageIndex"
- (NSString *)pageTotalKey;             //当使用BMPageTypePageNumber,类型的分页方式时候，需要用到该key,默认@"total"
- (NSString *)responseCodeKey;          //响应码key,默认@"responseCode"
- (NSString *)responseMsgKey;           //响应信息key,默认@"responseMsg"
- (NSUInteger)cacheCountLimit;          //最多缓存数量,默认1000
- (NSTimeInterval)cacheTimeOutSeconds;  //缓存时间，默认5分钟
- (NSTimeInterval)requestTimeOutSeconds;//网络超时时间,默认20s
- (NSString *)contentFormat;            //http content 格式,默认@"json"
- (NSString *)clientPlatform;           //客户端类型,@"ios"
- (CLLocation *)location;               //定位信息,默认nil
- (BMNetworkLogLevel)networkLogLevel;   //网络日志等级

/**
 * 返回查询字符串，默认的生成的签名算法为至尊洗衣
 */
-(NSString *)queryStringWithParam:(NSDictionary *)businessParam requestType:(BMAPIManagerRequestType)type;//查询字符串签名方法


@end
