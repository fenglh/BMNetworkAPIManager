//
//  BMAPICalledProxy.m
//  BlueMoonBlueHouse
//
//  Created by 冯立海 on 15/9/26.
//  Copyright (c) 2015年 fenglh. All rights reserved.
//

#import "BMAPICalledProxy.h"
#import "BMURLResponse.h"
#import "BMLoger.h"
#import "BMBaseNetworkConfigure.h"
#import "NSDictionary+AXNetworkingMethods.h"
#import "NSURLRequest+AIFNetworkingMethods.h"
#import "AFHTTPRequestSerializer+addHeaders.h"
#import "BMMineTypeFileModel.h"
#import "EXTScope.h"
#import <AFNetworking/AFHTTPSessionManager.h>


#define kBMRequestTimeOutSeconds ([networkConfigureInstance respondsToSelector:@selector(requestTimeOutSeconds)] ? [networkConfigureInstance requestTimeOutSeconds]:10)

#define callHttpRequest(MANAGER,REQUEST_METHOD, REQUEST_URL, REQUEST_PARAMS, PROGRESS_CALLBACK, SUCCESS_CALLBACK, FAILURE_CALLBACK)\
{\
NSNumber *requestId = [self generateRequestId];\
[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];\
@weakify(self);\
NSURLSessionTask *task = [MANAGER REQUEST_METHOD:REQUEST_URL parameters:REQUEST_PARAMS progress:^(NSProgress * _Nonnull uploadProgress) {\
@strongify(self);\
[self callAPIPogress:uploadProgress requestId:[requestId integerValue] progressCallback:progress];\
} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {\
@strongify(self);\
[self callAPISuccess:task responseObject:responseObject requestId:requestId successCallback:SUCCESS_CALLBACK];\
} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {\
@strongify(self);\
[self callAPIFailure:task error:error requestId:requestId failureCallback:FAILURE_CALLBACK];\
}];\
task.originalRequest.requestParams = REQUEST_PARAMS;\
self.httpRequestTaskTable[requestId] = task;\
return [requestId integerValue];\
}

@interface BMAPICalledProxy ()

@property (strong, nonatomic) NSNumber *recordRequestId;

@property (strong, nonatomic) NSMutableDictionary *httpRequestTaskTable;//保存httpRequestTaskTable 的返回值，便于之后对task的处理
@end

@implementation BMAPICalledProxy

#pragma mark - 生命周期
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceTocke;
    static BMAPICalledProxy *sharedInstance = nil;
    dispatch_once(&onceTocke, ^{
        sharedInstance = [[BMAPICalledProxy alloc] init];
    });
    return sharedInstance;
    
}

#pragma mark -公共方法



//#warning get
- (NSInteger)callGETWithParams:(NSDictionary *)params
                       headers:(NSDictionary *)headers
                           url:(NSString *)url
                   queryString:(NSString *)queryString
                       apiName:(NSString *)apiName
                      progress:(void(^)(NSProgress * progress,NSInteger requestId))progress
                       success:(BMAPICallback)success
                       failure:(BMAPICallback)failure
{
    
    
    NSString *urlString = [self urlString:url queryString:queryString];
    AFHTTPSessionManager *manager = [self sharedSessionManager];
    [manager.requestSerializer clearAuthorizationHeader]; //先删除
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json" ,@"text/javascript",@"video/mp4", nil]; // 设置相应的 http header Content-Type
    [manager.requestSerializer addHeaders:headers];
    
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:urlString parameters:params error:NULL];
    [BMLoger logDebugInfoWithRequest:request apiName:apiName url:url requestParams:params httpMethod:@"GET"];
    callHttpRequest(manager, GET, urlString, params, progress, success, failure);
    
}

- (NSInteger)callPOSTWithParams:(NSDictionary *)params
                        headers:(NSDictionary *)headers
                            url:(NSString *)url
                    queryString:(NSString *)queryString
                        apiName:(NSString *)apiName
                       progress:(void(^)(NSProgress * progress,NSInteger requestId))progress
                        success:(BMAPICallback)success
                        failure:(BMAPICallback)failure
{
    
    NSString *urlString = [self urlString:url queryString:queryString];
    
    AFHTTPSessionManager *manager = [self sharedSessionManager];
    [manager.requestSerializer clearAuthorizationHeader]; //先删除
    [manager.requestSerializer addHeaders:headers];
    
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"POST" URLString:urlString parameters:params error:NULL];
    [BMLoger logDebugInfoWithRequest:request apiName:apiName url:url requestParams:params httpMethod:@"POST"];
    callHttpRequest(manager,POST, urlString, params, progress, success, failure);
    
}


//** PUT 请求 **/
- (NSInteger)callPUTWithParams:(NSDictionary *)params
                       headers:(NSDictionary *)headers
                           url:(NSString *)url
                   queryString:(NSString *)queryString
                       apiName:(NSString *)apiName
                      progress:(void(^)(NSProgress * progress,NSInteger requestId))progress
                       success:(BMAPICallback)success
                       failure:(BMAPICallback)failure
{
    NSString *urlString = [self urlString:url queryString:queryString];
    
    AFHTTPSessionManager *manager = [self sharedSessionManager];
    [manager.requestSerializer clearAuthorizationHeader]; //先删除
    [manager.requestSerializer addHeaders:headers];
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"PUT" URLString:urlString parameters:params error:NULL];
    [BMLoger logDebugInfoWithRequest:request apiName:apiName url:url requestParams:params httpMethod:@"PUT"];
    
    NSNumber *requestId = [self generateRequestId];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    @weakify(self);
    NSURLSessionTask *task = [manager PUT:urlString parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self);
        [self callAPISuccess:task responseObject:responseObject requestId:requestId successCallback:success];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        @strongify(self);
        [self callAPIFailure:task error:error requestId:requestId failureCallback:failure];
    }];
    task.originalRequest.requestParams = params;
    self.httpRequestTaskTable[requestId] = task;
    return [requestId integerValue];
    
}

//** DELETE 请求 **/
- (NSInteger)callDELETEWithParams:(NSDictionary *)params
                          headers:(NSDictionary *)headers
                              url:(NSString *)url
                      queryString:(NSString *)queryString
                          apiName:(NSString *)apiName
                         progress:(void(^)(NSProgress * progress,NSInteger requestId))progress
                          success:(BMAPICallback)success
                          failure:(BMAPICallback)failure
{
    NSString *urlString = [self urlString:url queryString:queryString];
    AFHTTPSessionManager *manager = [self sharedSessionManager];
    [manager.requestSerializer clearAuthorizationHeader]; //先删除
    [manager.requestSerializer addHeaders:headers];
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"DELETE" URLString:urlString parameters:params error:NULL];
    [BMLoger logDebugInfoWithRequest:request apiName:apiName url:url requestParams:params httpMethod:@"DELETE"];
    
    NSNumber *requestId = [self generateRequestId];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    @weakify(self);
    NSURLSessionTask *task = [manager DELETE:urlString parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self);
        [self callAPISuccess:task responseObject:responseObject requestId:requestId successCallback:success];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        @strongify(self);
        [self callAPIFailure:task error:error requestId:requestId failureCallback:failure];
    }];
    task.originalRequest.requestParams = params;
    self.httpRequestTaskTable[requestId] = task;
    return [requestId integerValue];
}


- (NSInteger)callMineTypePOSTWithParams:(NSDictionary *)params
                                headers:(NSDictionary *)headers
                                    url:(NSString *)url
                            queryString:(NSString *)queryString
                                apiName:(NSString *)apiName
                               progress:(void(^)(NSProgress * progress,NSInteger requestId))progress
                                success:(BMAPICallback)success
                                failure:(BMAPICallback)failure
{
    
    
    
    NSNumber *requestId = [self generateRequestId];//生成requestId
    NSString *urlString = [self urlString:url queryString:queryString];
    
    
    AFHTTPSessionManager *manager = [self sharedSessionManager];
    [manager.requestSerializer clearAuthorizationHeader]; //先删除
    [manager.requestSerializer addHeaders:headers];
    
    //1.分离NSData类型和非NSData类型参数
    NSMutableDictionary *noDataDict = [params mutableCopy];
    NSMutableDictionary *dataDict =[NSMutableDictionary dictionary];
    NSArray *allKeys = [params allKeys];
    for (NSString *key in allKeys) {
        id obj = [params objectForKey:key];
        if ([obj isKindOfClass:[NSData class]]) {
            [dataDict setObject:obj forKey:key];
        }else{
            [noDataDict setObject:obj forKey:key];
        }
    }
    //2.取出kBMMineTypeFileModels ，该列表指出哪些参数是作为文件来上传
    NSArray *mineTypeFileModels = [params objectForKey:kBMMineTypeFileModels];
    [noDataDict removeObjectForKey:kBMMineTypeFileModels];//移除该参数，因该参数只是辅助作用
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    @weakify(self);
    NSURLSessionTask *task = [manager POST:urlString parameters:noDataDict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //3.组装
        NSString *fileName=[NSString stringWithFormat:@"%.0f.unknow",[NSDate date].timeIntervalSince1970];//默认
        NSString *mineType=@"";//默认
        NSData *fileData = nil;//默认
        //针对文件数组，逐个组装
        for (BMMineTypeFileModel *model in mineTypeFileModels) {
            fileName = model.fileName;
            mineType = model.mineType;
            fileData = [dataDict objectForKey:model.fileDataKey];
            [formData appendPartWithFileData:fileData name:model.fileDataKey fileName:fileName mimeType:mineType];
        }
        NSLog(@"form-data:组装完成");
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        @strongify(self);
        [self callAPIPogress:uploadProgress requestId:[requestId integerValue] progressCallback:progress];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self);
        [self callAPISuccess:task responseObject:responseObject requestId:requestId successCallback:success];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        @strongify(self);
        [self callAPIFailure:task error:error requestId:requestId failureCallback:failure];
    }];
    task.originalRequest.requestParams = params;
    self.httpRequestTaskTable[requestId] = task;
    //注释掉request转换，因为在调用上传视频接口是，params不符合json格式，导致转换失败。
    //    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"MineTypePOST" URLString:urlString parameters:params error:NULL];
    [BMLoger logDebugInfoWithRequest:nil apiName:apiName url:url requestParams:params httpMethod:@"MineTypePOST"];
    return [requestId integerValue];
}

#pragma mark - 私有方法

- (NSString *)urlString:(NSString *)url queryString:(NSString *)queryString {
    if (queryString && ![queryString isEqualToString:@""]) {
        return [NSString stringWithFormat:@"%@?%@",url,queryString];
    }else {
        return url;
    }
}


/**
 * 生成requestId
 */
- (NSNumber *)generateRequestId
{
    if (_recordRequestId == nil) {
        _recordRequestId = @(1);
    }else if([_recordRequestId integerValue] == NSIntegerMax){
        _recordRequestId = @(1);
    }else{
        _recordRequestId = @([_recordRequestId integerValue] + 1);
    }
    
    return _recordRequestId;
}


/**
 * 调用进度
 */
- (void)callAPIPogress:(NSProgress *)progress requestId:(NSInteger)requestId progressCallback:(void(^)(NSProgress *progress, NSInteger requestId))progressCallback
{
    dispatch_async(dispatch_get_main_queue(), ^{
        progressCallback?progressCallback(progress,requestId):nil;
    });
}

/**
 * API 调用失败
 */
- (void)callAPIFailure:(NSURLSessionTask *)task error:(NSError *)error requestId:(NSNumber *)requestId failureCallback:(BMAPICallback)failureCallback
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSURLSessionTask *storedTask = self.httpRequestTaskTable[requestId];
    if (storedTask == nil) {
        NSLog(@"接口请求失败！但在接口请求过程中接口被取消掉了，所以忽略该请求!");
        return;
    }else{
        [self.httpRequestTaskTable removeObjectForKey:requestId];
    }
    [BMLoger logDebugInfoWithResponse:nil resposeString:nil request:task.originalRequest error:error];
    BMURLResponse *response = [[BMURLResponse alloc] initWithResponseString:nil requestId:requestId request:task.originalRequest response:(NSHTTPURLResponse *)task.response responseData:nil error:error];
    failureCallback?failureCallback(response):nil;
}

/**
 * API 调用成功
 */
- (void)callAPISuccess:(NSURLSessionTask *)task responseObject:(id)responseObject requestId:(NSNumber *)requestId successCallback:(BMAPICallback)successCallback
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSURLSessionTask *storedTask = self.httpRequestTaskTable[requestId];
    if (storedTask == nil) {
        NSLog(@"接口请求成功！但在接口请求过程中接口被取消掉了，所以忽略该请求!");
        return;
    }else{
        [self.httpRequestTaskTable removeObjectForKey:requestId];
    }
    
    NSString *contentString;
    NSError *err;
    NSJSONSerialization *serialization = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&err];
    if (err || serialization == nil) {
        contentString = @"(responseObject 不是有效的JSON对象(例如：文件、视频等)，此类型数据不作日志打印输出！)";
    }else{
        NSDictionary *responseDictionary = (NSDictionary *)serialization;
        contentString = responseDictionary.jsonStringEncoded;
    }
    
    
//    if ([NSJSONSerialization isValidJSONObject:responseObject]) {
//        responseData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];\
//        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
//        contentString = responseDictionary.jsonStringEncoded;
//    }else{
//        contentString = @"(responseObject 不是有效的JSON对象(例如：文件、视频等)，此类型数据不作日志打印输出！)";
//        responseData = responseObject;
//    }
    
    [BMLoger logDebugInfoWithResponse:(NSHTTPURLResponse *)task.response resposeString:contentString request:task.originalRequest error:NULL];
    BMURLResponse *response = [[BMURLResponse alloc] initWithResponseString:contentString requestId:requestId request:task.originalRequest response:(NSHTTPURLResponse *)task.response responseData:responseObject status:BMURLResponseStatusSuccess];
    successCallback?successCallback(response):nil;
    
}

//取消单个请求
- (void)cancelRequestWithRequestId:(NSNumber *)requestID
{
    NSURLSessionDataTask *task = self.httpRequestTaskTable[requestID];
    [task cancel];
    [self.httpRequestTaskTable removeObjectForKey:requestID];
}

//取消所有请求
- (void)cancelRequestWithRequestIdList:(NSArray *)requestIDList
{
    for (NSNumber *requestId in requestIDList) {
        [self cancelRequestWithRequestId:requestId];
    }
}

#pragma mark - getters and setters

- (AFHTTPSessionManager *)sharedSessionManager {
    
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval =kBMRequestTimeOutSeconds;
    });
    return manager;
    
}
- (AFHTTPSessionManager *)newManager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = kBMRequestTimeOutSeconds;
    manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;//默认缓存策略
    return manager;
}


- (NSMutableDictionary *)httpRequestTaskTable
{
    if (_httpRequestTaskTable == nil) {
        _httpRequestTaskTable = [[NSMutableDictionary alloc] init];
    }
    return _httpRequestTaskTable;
}


@end


@implementation BMAPICalledProxy (DefaultHeader)

//** GET 请求 **/
- (NSInteger)callGETWithParams:(NSDictionary *)params
                           url:(NSString *)url
                   queryString:(NSString *)queryString
                       apiName:(NSString *)apiName
                      progress:(void(^)(NSProgress * progress,NSInteger requestId))progress
                       success:(BMAPICallback)success
                       failure:(BMAPICallback)failure {
    return [self callGETWithParams:params headers:nil url:url queryString:queryString apiName:apiName progress:progress success:success failure:failure];
    
}

//** PUT 请求 **/
- (NSInteger)callPUTWithParams:(NSDictionary *)params
                           url:(NSString *)url
                   queryString:(NSString *)queryString
                       apiName:(NSString *)apiName
                      progress:(void(^)(NSProgress * progress,NSInteger requestId))progress
                       success:(BMAPICallback)success
                       failure:(BMAPICallback)failure {
    return [self callPUTWithParams:params headers:nil url:url queryString:queryString apiName:apiName progress:progress success:success failure:failure];
}

//** DELETE 请求 **/
- (NSInteger)callDELETEWithParams:(NSDictionary *)params
                              url:(NSString *)url
                      queryString:(NSString *)queryString
                          apiName:(NSString *)apiName
                         progress:(void(^)(NSProgress * progress,NSInteger requestId))progress
                          success:(BMAPICallback)success
                          failure:(BMAPICallback)failure {
    return [self callDELETEWithParams:params headers:nil url:url queryString:queryString apiName:apiName progress:progress success:success failure:failure];
}


//** JSON post 请求 **//
- (NSInteger)callPOSTWithParams:(NSDictionary *)params
                            url:(NSString *)url
                    queryString:(NSString *)queryString
                        apiName:(NSString *)apiName
                       progress:(void(^)(NSProgress * progress,NSInteger requestId))progress
                        success:(BMAPICallback)success
                        failure:(BMAPICallback)failure {
    return [self callPOSTWithParams:params headers:nil url:url queryString:queryString apiName:apiName progress:progress success:success failure:failure];
}

//** multipart/form-data Http Post请求 **/
- (NSInteger)callMineTypePOSTWithParams:(NSDictionary *)params
                                    url:(NSString *)url
                            queryString:(NSString *)queryString
                                apiName:(NSString *)apiName
                               progress:(void(^)(NSProgress * progress, NSInteger requestId))progress
                                success:(BMAPICallback)success
                                failure:(BMAPICallback)failure {
    return [self callMineTypePOSTWithParams:params headers:nil url:url queryString:queryString apiName:apiName progress:progress success:success failure:failure];
}

@end
