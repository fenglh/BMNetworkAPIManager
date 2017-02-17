//
//  BMRequestGenerotor.m
//  BlueMoonBlueHouse
//
//  Created by 冯立海 on 15/9/26.
//  Copyright (c) 2015年 fenglh. All rights reserved.
//


/*
 * 1.0.1
 * 修改：增加对业务参数进行签名
 * fenglh 2016/11/22
 */

#import "BMRequestGenerotor.h"
#import "AFNetworking.h"
#import "NSURLRequest+AIFNetworkingMethods.h"
#import "NSDictionary+AXNetworkingMethods.h"
#import "NSString+Networking.h"
#import "BMLoger.h"
#import "BMBaseNetworkConfigure.h"


@interface BMRequestGenerotor ()

@property (strong, nonatomic) AFJSONRequestSerializer *httpJSONRequestSerializer;   //JSON格式请求
@property (strong, nonatomic) AFHTTPRequestSerializer *httpRequestSerializer;       //普通格式请求

@end

@implementation BMRequestGenerotor

#pragma mark - getters
- (AFJSONRequestSerializer *)httpJSONRequestSerializer
{
    if (_httpJSONRequestSerializer == nil) {
        _httpJSONRequestSerializer = [AFJSONRequestSerializer serializer];
        _httpJSONRequestSerializer.timeoutInterval = [networkConfigureInstance timeOutSeconds];
        _httpJSONRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;//默认缓存策略
    }
    return _httpJSONRequestSerializer;
}

- (AFHTTPRequestSerializer *)httpRequestSerializer
{
    if (_httpRequestSerializer == nil) {
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        _httpRequestSerializer.timeoutInterval = [networkConfigureInstance timeOutSeconds];
        _httpRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;//默认缓存策略
    }
    return _httpRequestSerializer;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static BMRequestGenerotor *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BMRequestGenerotor alloc] init];
    });
    return sharedInstance;
}


- (NSURLRequest *)generateGETRequestWithUrl:(NSString *)url requestParams:(NSDictionary *)params apiName:(NSString *)apiName
{

    NSString *urlString =[NSString stringWithFormat:@"%@?%@",url,[self getPublicParamsStringWithBusinessParam:params isFormData:NO]];
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"GET" URLString:urlString parameters:params error:NULL];
    request.requestParams = params;//这里只是通过关联的作用吧params添加个request对象，方便调试用得po request.requestParams
    [BMLoger logDebugInfoWithRequest:request apiName:apiName url:url requestParams:params httpMethod:@"GET"];
    return request;
}

- (NSURLRequest *)generatePOSTRequestWithUrl:(NSString *)url requestParams:(NSDictionary *)params apiName:(NSString *)apiName
{
    NSString *urlString =[NSString stringWithFormat:@"%@?%@",url,[self getPublicParamsStringWithBusinessParam:params isFormData:NO]];
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"POST" URLString:urlString parameters:params error:NULL];
    request.requestParams = params;//这里只是通过关联的作用吧params添加个request对象，方便调试用得po request.requestParams
    [BMLoger logDebugInfoWithRequest:request apiName:apiName url:url requestParams:params httpMethod:@"POST"];
    return request;
}

- (NSURLRequest *)generateJSONPOSTRequestWithUrl:(NSString *)url requestParams:(NSDictionary *)params apiName:(NSString *)apiName
{
    NSString *urlString =[NSString stringWithFormat:@"%@?%@",url,[self getPublicParamsStringWithBusinessParam:params isFormData:NO]];
    NSMutableURLRequest *request = [self.httpJSONRequestSerializer requestWithMethod:@"POST" URLString:urlString parameters:params error:NULL];
    request.requestParams = params;//这里只是通过关联的作用吧params添加个request对象，方便调试用得po request.requestParams
    [BMLoger logDebugInfoWithRequest:request apiName:apiName url:url requestParams:params httpMethod:@"POST"];
    return request;
}


//multipart/form-data
- (NSURLRequest *)generateMultipartPOSTRequestWithUrl:(NSString *)url requestParams:(NSDictionary *)params apiName:(NSString *)apiName
{
    NSString *urlString =[NSString stringWithFormat:@"%@?%@",url,[self getPublicParamsStringWithBusinessParam:params isFormData:YES]];
    NSError *error = nil;
    NSMutableURLRequest *request = [self.httpRequestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^ void(id<AFMultipartFormData> formData) {
        NSArray *allKeys = [params allKeys];
        for (NSString *key in allKeys) {
            id obj = [params objectForKey:key];
            NSString *mimetype;
            
            //如果是URL，即文件
            if ([obj isKindOfClass:[NSURL class]]) {
                NSString *fileName = [[obj absoluteString] lastPathComponent];
                mimetype = @"application/octet-stream";
                [formData appendPartWithFileURL:obj name:key fileName:fileName mimeType:mimetype error:nil];
            }
        
            if ([obj isKindOfClass:[NSData class]]) {
                mimetype = @"application/octet-stream";
                //这里的filename和mimeType自行判断
                [formData appendPartWithFormData:obj name:key];
            }
            else if([obj isKindOfClass:[NSString class]]){
                mimetype = @"text/plain";
                NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
                [formData appendPartWithFormData:data name:key];
            }
        }
        
    } error:&error];
    [BMLoger logDebugInfoWithRequest:request apiName:apiName url:url requestParams:params httpMethod:@"POST"];
    return request;
    
}

#pragma mark - 私有
#pragma mark - 私有

- (NSString *)getPublicParamsStringWithBusinessParam:(NSDictionary *)businessParam isFormData:(BOOL)isFormData
{
    
    
    //获取非签名公参
    NSDictionary *normalParamsDict = @{@"lng":@([networkConfigureInstance location].coordinate.longitude),
                                       @"lat":@([networkConfigureInstance location].coordinate.latitude),
                                       @"hig":@([networkConfigureInstance location].altitude),
                                       @"appType":[networkConfigureInstance appType]};
    //获取签名公参
    NSMutableDictionary *publicParams = [NSMutableDictionary dictionaryWithDictionary:normalParamsDict];
    [publicParams addEntriesFromDictionary:[self signParamsWithBusinessParam:businessParam isFormData:isFormData]];
    return [self publicParamsPackingWithDict:publicParams];
}



- (NSString *)publicParamsPackingWithDict:(NSDictionary *)dict
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


- (NSDictionary *)signParamsWithBusinessParam:(NSDictionary *)businessParam isFormData:(BOOL)isFormData
{
    NSString *secrect = [networkConfigureInstance secrect];//私钥
    NSString *clientPlatform = [networkConfigureInstance clientPlatform];
    NSString *clientUUID = [networkConfigureInstance clientUUID];
    NSString *format = [networkConfigureInstance contentFormat];
    NSString *timeStamp = [NSString stringWithFormat:@"%ld",time(NULL)];
    NSString *version = [networkConfigureInstance appVersion];
    

    
    
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithDictionary:@{@"client":clientPlatform,@"cuid":clientUUID,@"format":format,@"time":timeStamp,@"version":version}];
    
    //组装
    NSArray *keys = [paramsDict allKeys];
    //按字母顺序排序
    NSArray *sortedKeysArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSString *signString=@"";
    signString = [signString stringByAppendingString:secrect];
    for (NSString *key in sortedKeysArray) {
        signString = [signString stringByAppendingString:[paramsDict objectForKey:key]];
    }
    if (!isFormData) {
        //增加业务参数
        NSString *businessParamJsonStr = businessParam.jsonStringEncoded;
        if (businessParamJsonStr != nil) {
            signString = [signString stringByAppendingString:businessParamJsonStr];
        }
    }else{
        //不做处理
    }
    
    //最终组装之后，进行md5
    signString = [signString stringByAppendingString:secrect];
    NSString *signMD5 = [signString md5String];
    [paramsDict setObject:signMD5 forKey:@"sign"];
    return paramsDict;
}
@end
