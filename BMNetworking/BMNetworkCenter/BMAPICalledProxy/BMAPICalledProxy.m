//
//  BMAPICalledProxy.m
//  BlueMoonBlueHouse
//
//  Created by 冯立海 on 15/9/26.
//  Copyright (c) 2015年 fenglh. All rights reserved.
//

#import "BMAPICalledProxy.h"
#import "BMRequestGenerotor.h"
#import "AFNetworking.h"
#import "BMURLResponse.h"
#import "BMLoger.h"
#import "BMBaseNetworkConfigure.h"
#import "BMAPIParamsSign.h"
#import "NSDictionary+AXNetworkingMethods.h"
#import "NSURLRequest+AIFNetworkingMethods.h"
#import "BMMineTypeFileModel.h"



#define callHttpRequest(REQUEST_METHOD, REQUEST_URL, REQUEST_PARAMS, PROGRESS_CALLBACK, SUCCESS_CALLBACK, FAILURE_CALLBACK)\
{\
    NSNumber *requestId = [self generateRequestId];\
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];\
\
    NSURLSessionTask *task = [self.sessionManager REQUEST_METHOD:REQUEST_URL parameters:REQUEST_PARAMS progress:^(NSProgress * _Nonnull uploadProgress) {\
        [self callAPIPogress:uploadProgress progressCallback:PROGRESS_CALLBACK];\
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {\
        [self callAPISuccess:task responseObject:responseObject requestId:requestId successCallback:SUCCESS_CALLBACK];\
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {\
        [self callAPIFailure:task error:error requestId:requestId failureCallback:FAILURE_CALLBACK];\
    }];\
    task.originalRequest.requestParams = REQUEST_PARAMS;\
    self.httpRequestTaskTable[requestId] = task;\
    return [requestId integerValue];\
}

@interface BMAPICalledProxy ()

@property (strong, nonatomic) NSNumber *recordRequestId;
//@property (strong, nonatomic) AFHTTPRequestOperationManager *operationManager;
@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
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


//#warning get 方法没有经过验证
- (NSInteger)callGETWithParams:(NSDictionary *)params url:(NSString *)url apiName:(NSString *)apiName progress:(void(^)(NSProgress * progress))progress success:(BMAPICallback)success failure:(BMAPICallback)failure
{
    NSString *urlString =[NSString stringWithFormat:@"%@?%@",url,[BMAPIParamsSign generateSignaturedUrlQueryStringWithBusinessParam:params signBusinessParam:YES]];
    callHttpRequest(GET, urlString, params, progress, success, failure);

}

- (NSInteger)callPOSTWithParams:(NSDictionary *)params url:(NSString *)url apiName:(NSString *)apiName progress:(void(^)(NSProgress * progress))progress success:(BMAPICallback)success failure:(BMAPICallback)failure
{
    NSString *urlString =[NSString stringWithFormat:@"%@?%@",url,[BMAPIParamsSign generateSignaturedUrlQueryStringWithBusinessParam:params signBusinessParam:YES]];
    callHttpRequest(POST, urlString, params, progress, success, failure);
    
}

- (NSInteger)callMineTypePOSTWithParams:(NSDictionary *)params url:(NSString *)url apiName:(NSString *)apiName progress:(void(^)(NSProgress * progress))progress success:(BMAPICallback)success failure:(BMAPICallback)failure
{
    NSNumber *requestId = [self generateRequestId];//生成requestId
    NSString *urlString =[NSString stringWithFormat:@"%@?%@",url,[BMAPIParamsSign generateSignaturedUrlQueryStringWithBusinessParam:params signBusinessParam:NO]];
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
    NSURLSessionTask *task = [self.sessionManager POST:urlString parameters:noDataDict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
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
        [self callAPIPogress:uploadProgress progressCallback:progress];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self callAPISuccess:task responseObject:responseObject requestId:requestId successCallback:success];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self callAPIFailure:task error:error requestId:requestId failureCallback:failure];
    }];
    task.originalRequest.requestParams = params;
    self.httpRequestTaskTable[requestId] = task;
    
    return [requestId integerValue];
}

#pragma mark - 私有方法


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
- (void)callAPIPogress:(NSProgress *)progress progressCallback:(void(^)(NSProgress *))progressCallback
{
    dispatch_async(dispatch_get_main_queue(), ^{
        progressCallback?progressCallback(progress):nil;
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
    BMURLResponse *response = [[BMURLResponse alloc] initWithResponseString:nil requestId:requestId request:task.originalRequest responseData:nil error:error];
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
    NSString *contentString = responseObject;
    NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];\
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        contentString = responseDictionary.jsonStringEncoded;
    }
    [BMLoger logDebugInfoWithResponse:(NSHTTPURLResponse *)task.response resposeString:contentString request:task.originalRequest error:NULL];
    BMURLResponse *response = [[BMURLResponse alloc] initWithResponseString:contentString requestId:requestId request:task.originalRequest responseData:responseData status:BMURLResponseStatusSuccess];
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

- (AFHTTPSessionManager *)sessionManager
{
    if (_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.requestSerializer.timeoutInterval = [networkConfigureInstance timeOutSeconds];
        _sessionManager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;//默认缓存策略
        _sessionManager.requestSerializer =  [AFJSONRequestSerializer serializer];
    }
    return _sessionManager;
}

- (NSMutableDictionary *)httpRequestTaskTable
{
    if (_httpRequestTaskTable == nil) {
        _httpRequestTaskTable = [[NSMutableDictionary alloc] init];
    }
    return _httpRequestTaskTable;
}





@end
