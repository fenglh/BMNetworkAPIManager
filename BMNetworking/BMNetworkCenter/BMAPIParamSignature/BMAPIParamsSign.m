//
//  BMAPIParamsSign.m
//  BMNetworking
//
//  Created by fenglh on 2017/2/14.
//  Copyright © 2017年 BlueMoon. All rights reserved.
//

#import "BMAPIParamsSign.h"
#import "BMBaseNetworkConfigure.h"
#import "NSDictionary+AXNetworkingMethods.h"
#import "NSString+Networking.h"


#define kBMClientPlatform [networkConfigureInstance respondsToSelector:@selector(clientPlatform)] ? [networkConfigureInstance clientPlatform] : @"ios"
#define kBMClientUUID [networkConfigureInstance respondsToSelector:@selector(clientUUID)] ?[networkConfigureInstance clientUUID] : @""
#define kBMContentFormat [networkConfigureInstance respondsToSelector:@selector(contentFormat)] ? [networkConfigureInstance contentFormat] :@"json"
#define kBMAppVersion [networkConfigureInstance respondsToSelector:@selector(appVersion)] ?  [networkConfigureInstance appVersion] : @""
#define kBMSecrect [networkConfigureInstance respondsToSelector:@selector(secrect)] ?  [networkConfigureInstance secrect] : @""
#define kBMAppType [networkConfigureInstance respondsToSelector:@selector(appType)] ?  [networkConfigureInstance appType] : @""


@implementation BMAPIParamsSign
#pragma mark - 公有方法

/**
 * 生成签名查询字符串
 */



+ (NSString *)generateSignaturedUrlQueryStringWithParam:(NSDictionary *)param requestType:(BMAPIManagerRequestType)type
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSDictionary *nonSignaturedParams = [self nonSignaturedParams];
    NSDictionary *signaturedParams = [self signaturedParamsWithParam:param requestType:type];
    [params addEntriesFromDictionary:nonSignaturedParams];
    [params addEntriesFromDictionary:signaturedParams];
    
    //将参数组装成参数字符串： key1=value1&key2=value2&key3=value3&....
    return [self urlQueryStringWithParams:params];
}


#pragma mark - 私有方法


/**
 * 不需要签名的参数
 */
+ (NSDictionary *)nonSignaturedParams
{
    //获取非签名公参
    NSMutableDictionary *nonSignParams = [NSMutableDictionary dictionary];
    if ([networkConfigureInstance respondsToSelector:@selector(location)]) {
        CLLocation *location = [networkConfigureInstance location];
        if (location) {
            [nonSignParams setObject:@(location.coordinate.longitude) forKey:@"lng"];
            [nonSignParams setObject:@(location.coordinate.latitude) forKey:@"lat"];
            [nonSignParams setObject:@(location.altitude) forKey:@"hig"];
        }
    }

    [nonSignParams setObject:kBMAppType forKey:@"appType"];
    return nonSignParams;
}


/**
 * 已签名的参数
 * 签名方式:公参+业务参数，即可param
 */
+ (NSDictionary *)signaturedParamsWithParam:(NSDictionary *)param requestType:(BMAPIManagerRequestType)type
{

    
    

    
    
    NSString *clientPlatform = kBMClientPlatform;
    NSString *clientUUID = kBMClientUUID;
    NSString *format = kBMContentFormat;
    NSString *timeStamp = [NSString stringWithFormat:@"%ld000",time(NULL)];
    NSString *version = kBMAppVersion;
    NSString *paramJsonString = param.jsonStringEncoded;//不能使用[NSDictionary dictionaryWithDictionary:businessParam].jsonStringEncoded，否则会导致jsonStringEncoded不一致
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithDictionary:@{@"client":clientPlatform,@"cuid":clientUUID,@"format":format,@"time":timeStamp,@"version":version}];
    //进行签名
    NSString *signatureString = [self signWithParams:paramsDict businessJsonString:paramJsonString requestType:type];
    [paramsDict setObject:signatureString forKey:@"sign"];
    return paramsDict;
}


/**
 * 参数签名
 */
//+ (NSString *)signWithParams:(NSDictionary *)params businessJsonString:(NSString *)businessJsonString signBusinessParam:(BOOL)signBusinessParam
+ (NSString *)signWithParams:(NSDictionary *)params businessJsonString:(NSString *)businessJsonString requestType:(BMAPIManagerRequestType)type
{
    NSString *secrect = kBMSecrect;//私钥
    
    //1.按字母顺序排序
    NSArray *keys = [params allKeys];
    NSArray *sortedKeysArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    //2.拼装签名用的string，拼装算法：secrect+params[key1]+params[key2]+params[key3]+params[key4]+...
    NSString *signString=@"";
    signString = [signString stringByAppendingString:secrect];
    for (NSString *key in sortedKeysArray) {
        signString = [signString stringByAppendingString:[params objectForKey:key]];
    }
    
    BOOL signBusinessParam = YES;
    if (type == BMAPIManagerRequestTypePostMimeType) {
        signBusinessParam = NO;
    }
    //3.拼装签名用string，直接使用json string。拼装算法：signString +businessParam.jsonStringEncoded
    if (signBusinessParam && businessJsonString) {
        //增加业务参数
        signString = [signString stringByAppendingString:businessJsonString];
    }
    
    //4.最终组装之后，进行md5
    signString = [signString stringByAppendingString:secrect];
    return [signString md5String];
}


/**
 * 组装url 查询字符串
 */
+ (NSString *)urlQueryStringWithParams:(NSDictionary *)dict
{
    //拼接字符串
    NSArray *keys = [dict allKeys];
    keys = [dict allKeys];
    NSArray *sortedKeysArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableString *contentString  =[NSMutableString string];
    for (NSString *key in sortedKeysArray) {
        [contentString appendFormat:@"%@=%@&", key, [dict objectForKey:key]];
    }
    //去掉最后一个&字符
    if ([[contentString substringFromIndex:contentString.length-1] isEqualToString:@"&"]) {
        contentString = [[contentString substringToIndex:contentString.length-1] mutableCopy];
    }
    
    return contentString;
}


@end
