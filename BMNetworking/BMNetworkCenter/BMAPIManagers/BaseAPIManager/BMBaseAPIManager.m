//
//  BMBaseAPIManager.m
//  BlueMoonBlueHouse
//
//  Created by fenglh on 15/9/25.
//  Copyright (c) 2015年 fenglh. All rights reserved.
//  修订2016/1011 冯立海

#import "BMBaseAPIManager.h"
#import "BMChace.h"
#import "BMAPICalledProxy.h"
#import "BMLoger.h"
#import "NSDictionary+AXNetworkingMethods.h"
#import "NSArray+AXNetworkingMethods.h"
#import "BMBaseNetworkConfigure.h"
#import "NSString+Networking.h"
#import "EXTScope.h"
#import "BMAPIParamsSign.h"



#define kBMTokenTransmissionMode        ([networkConfigureInstance respondsToSelector:@selector(tokenTransmissionMode)]?[networkConfigureInstance tokenTransmissionMode] :BMTokenTransmissionModeInParams)
#define kBMTokenValue                   ([networkConfigureInstance respondsToSelector:@selector(tokenValue)]?[networkConfigureInstance tokenValue]:@"")
#define kBMTokenInvalidEvent(manager)   ([networkConfigureInstance respondsToSelector:@selector(tokenInvalidEvent:)]?[networkConfigureInstance tokenInvalidEvent:manager]:nil)
#define kBMUserUnLoginEvent(manager)    ([networkConfigureInstance respondsToSelector:@selector(userUnLoginEvent:)]?[networkConfigureInstance userUnLoginEvent:manager]:nil)
#define kBMResponseErrorEvent(manager)  ([networkConfigureInstance respondsToSelector:@selector(responseErrorEvent:)]?[networkConfigureInstance responseErrorEvent:manager]:nil)
#define kBMLoginStatus                  ([networkConfigureInstance respondsToSelector:@selector(loginStatus)]?[networkConfigureInstance loginStatus]:BMUserLoginStatusUnLogin)
#define kBMIsTestEnVironment            ([networkConfigureInstance respondsToSelector:@selector(isTestEnVironment)]?[networkConfigureInstance isTestEnVironment]:NO)
#define kBMBaseUrl                      ([networkConfigureInstance respondsToSelector:@selector(baseUrl)]?[networkConfigureInstance baseUrl]:@"")
#define kBMBaseUrlTest                  ([networkConfigureInstance respondsToSelector:@selector(baseUrlTest)]?[networkConfigureInstance baseUrlTest]:@"")
#define KBMTokenInvalid             ([networkConfigureInstance respondsToSelector:@selector(tokenInvalidValue)]?[networkConfigureInstance tokenInvalidValue]:-1)
#define kBMResponseMsg              ([networkConfigureInstance respondsToSelector:@selector(responseMsgKey)]?[networkConfigureInstance responseMsgKey]:@"responseMsg")
#define kBMResponseCode             ([networkConfigureInstance respondsToSelector:@selector(responseCodeKey)]?[networkConfigureInstance responseCodeKey]:@"responseCode")
#define kBMResponseCodeSuccess      ([networkConfigureInstance respondsToSelector:@selector(responseCodeSuccessValue)]?[networkConfigureInstance responseCodeSuccessValue]:0)
#define kBMPageSizeKey              ([networkConfigureInstance respondsToSelector:@selector(pageSizeKey)]?[networkConfigureInstance pageSizeKey]:@"pageSize")
#define kBMPageStartIndex           ([networkConfigureInstance respondsToSelector:@selector(pageStartIndex)]?[networkConfigureInstance pageStartIndex]:0)
#define kBMPageSize                 ([networkConfigureInstance respondsToSelector:@selector(pageSize)]?[networkConfigureInstance pageSize]:10)
#define kBMUnPageSize               ([networkConfigureInstance respondsToSelector:@selector(unPageSize)]?[networkConfigureInstance unPageSize]:10)
#define kBMTimestampKey                ([networkConfigureInstance respondsToSelector:@selector(timestampKey)]?[networkConfigureInstance timestampKey]:@"timestamp")
#define kBMToken                    ([networkConfigureInstance respondsToSelector:@selector(tokenKey)]?[networkConfigureInstance tokenKey]:@"token")
#define kBMPageIndexKey             ([networkConfigureInstance respondsToSelector:@selector(pageIndexKey)]?[networkConfigureInstance pageIndexKey]:@"pageIndex")
#define kBMPageTotalKey             ([networkConfigureInstance respondsToSelector:@selector(pageTotalKey)]?[networkConfigureInstance pageTotalKey]:@"pageTotal")
#define kBMResponseDataKey          ([networkConfigureInstance respondsToSelector:@selector(responseDataKey)]?[networkConfigureInstance responseDataKey]:@"data")
#define kBMPageType


//判断是否为空nil null
#define isNillOrNull(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]))


//是否成功
#define isAPICallingSuccess(_ref) ( !isNillOrNull([(_ref) objectForKey:[self responseCodeKey]]) &&\
        [[(_ref) objectForKey:[self responseCodeKey]] integerValue] == [self responseCodeSuccess])

//获取服务端返回信息
#define getAPICallingResponseMsg(_ref) (isNillOrNull(_ref)?@"服务器返回数据异常":(isNillOrNull([(_ref) objectForKey:[self responseMsgKey]])?@"服务器返回错误信息异常":[(_ref) objectForKey:[self responseMsgKey]]))


#define BMCallAPI(REQUEST_METHOD, REQUEST_PARAMS,REQUEST_ID)                                            \
{                                                                                                       \
    /*将token插入到header(打了token标记的接口，都会增加header，在params即http body中也会保留这个值，兼容旧版本) */                                                                              \
    BOOL useToken = [self useToken];                                                                    \
    NSMutableDictionary *httpHeaderFields = [NSMutableDictionary dictionary];                           \
    if (useToken && [self tokenTransmissionMode] == BMTokenTransmissionModeInHeaders) {                                                                                     \
        [httpHeaderFields setValue:[self tokenValue] forKey:[self tokenKey]];   \
    }                                                                                                   \
    NSDictionary *headers = [self reformHeaders:httpHeaderFields];                                          \
    /*调用请求*/                                                                                         \
    REQUEST_ID = [[BMAPICalledProxy sharedInstance] call##REQUEST_METHOD##WithParams:REQUEST_PARAMS  headers:headers url:[self requestUrl] queryString:[self queryString] apiName:[self apiName] progress:^(NSProgress * progress, NSInteger requestId){\
        [self callingProgress:progress requestId:(NSInteger )requestId];                                \
    }                                                                                                   \
    success:^(BMURLResponse *response) {                                                                \
        [self successedOnCallingAPI:response];                                                          \
    } failure:^(BMURLResponse *response) {                                                              \
        [self failedOnCallingAPI:response withErrorType:[self turnBMURLResponseStatusToBMAPIManagerErrorType:response.status]];        \
    }];                                                                                                 \
        [self.requestIdList addObject:@(REQUEST_ID)];                                                   \
}

NSString * BMNotificationNetworkingTokenInvalid = @"BMNotificationNetworkingTokenInvalid";
NSString * BMNotificationNetworkingUserUnLogin = @"BMNotificationNetworkingUserUnLogin";

static NSInteger BMManagerDefaultOtherError = -9999;//网络错误码
static NSInteger BMManagerDefaultAPINotAllow = -9998;//
static NSInteger BMManagerDefaultParamsError = -9997;
static NSInteger BMManagerDefaultNoNextPage = -9000;//没有下一页了

@interface BMBaseAPIManager ()<BMAPIManager, BMAPIManagerValidator, BMAPIManagerInterceptor,BMAPIManagerParamsSourceDelegate>
@property (strong, nonatomic) BMChace *cache;
@property (nonatomic, copy, readwrite) BMURLResponse *response; //请参数

@property (nonatomic, assign, readwrite)BMAPIManagerErrorType errorType;
@property (nonatomic, assign, readwrite)NSInteger                errorCode;      //相对于errorType的具体化的错误代码
@property (nonatomic, strong, readwrite )NSString *responseMsg;
@property (strong, nonatomic) NSMutableArray *requestIdList;    //请求id列表
@property (nonatomic, strong, readwrite) id fetchedRawData;
@property (nonatomic, assign, readwrite) NSInteger requestId;   //请求ID
@property (nonatomic, copy, readwrite) NSDictionary *requestParams; //请参数

//管理自己所有的请求参数,每次请求都会把参数存放到该数组里面。（该属性是为方便管自身的每一次参数请求而设计的）
@property (nonatomic, strong)NSMutableDictionary *allRequestParams;//所有请求参数key-params

//分页
@property (nonatomic,assign) NSInteger nextPageNumber;  //下一页,分页类型是BMPageTypePageNumber时使用
@property (nonatomic, assign) NSInteger totalDataCount; //总数量，用于判断是否达到最后一页，分页类型是BMPageTypePageNumber时使用
@property (nonatomic, assign) long long nextPageTimeStamp;//分页时间戳，分页类型是BMPageTypeTimeStamp时使用
@property (nonatomic, readwrite,assign) BOOL isPageRequest;//是否是分页请求

@end

@implementation BMBaseAPIManager


- (void)dealloc
{
    [self cancelRequestWithRequestId:self.requestId];
    NSLog(@">>接口%@ dealloc ",NSStringFromClass([self class]));
}


#pragma getters and setters

-(BMChace *)cache
{
    if(_cache == nil){
        _cache = [BMChace shareInstance];
    }
    return _cache;
}

- (NSMutableDictionary *)allRequestParams{
    if (_allRequestParams == nil) {
        _allRequestParams = [[NSMutableDictionary alloc] init];
    }
    return _allRequestParams;
}


- (NSMutableArray *)requestIdList
{
    if (_requestIdList == nil) {
        _requestIdList = [[NSMutableArray alloc] init];
    }
    return _requestIdList;
}

- (BOOL)isReachable
{    
    return YES;
}

- (NSString *)responseMsg
{
    if (_responseMsg == nil) {
        _responseMsg = @"";
    }
    return _responseMsg;
}



#pragma mark - 生命周期
- (instancetype)init
{
    self = [super init];
    if (self) {
        _apiCallBackDelegate = nil;
        _validator = self;//验证器
        _interceptor = self;//拦截器
        _paramSource = self;
        _fetchedRawData = nil;
        _responseMsg = nil;
        _errorCode = BMManagerDefaultOtherError;//通指网络错误
         //因为时间戳分页，timestamp都会从loadData第一次请求之后返回，告诉你下一次分页的timestamp值，而页码分页不会，所以第一次在初始化的时候就+1
        // 页码分页和时间戳分页还是有区别，页码分页可以直接跳到指定分页，而时间戳分页只能上一页跳到下一页，不能夸页。
        //目前，页码分页的实现也只有在上一页成功之后，才能请求下一页！
        _nextPageNumber = [self pageStartIndex] + 1;
    }
    return self;
    
}





#pragma mark - 调用 api 
//不分页
- (NSInteger)loadData
{
    self.isPageRequest = NO;
    NSDictionary *params = [self.paramSource paramsForApi:self];
    //兼容调用者没有使用paramSource delegate设置参数的方式，导致中间者调用loadData参数缺漏的情况
    if (params == nil && self.requestParams) {
        params = self.requestParams;
    }
    NSInteger requestId = [self _loadDataWithParams:params];
    return requestId;
}

-(NSInteger)loadDataWithParams:(NSDictionary *)params
{
    self.isPageRequest = NO;
    NSInteger requestId = [self _loadDataWithParams:params];
    return requestId;
}

//分页请求

- (NSInteger)loadNextPage
{
    self.isPageRequest = YES;
    NSDictionary *params = [self.paramSource paramsForApi:self];
    //兼容调用者没有使用paramSource delegate设置参数的方式，导致中间者调用loadData参数缺漏的情况
    if (params == nil && self.requestParams) {
        params = self.requestParams;
    }
    NSInteger requestId = [self _loadDataWithParams:params];
    return requestId;
}

-(NSInteger)loadNextPageWithParams:(NSDictionary *)params
{
    self.isPageRequest = YES;
    NSInteger requestId = [self _loadDataWithParams:params];
    return requestId;
}




-(NSInteger)_loadDataWithParams:(NSDictionary *)params
{
    
    //注：requestParams只能记录接口的原始参数，不能记录格式化后（例如：在方法reformParamBase中重新赋值）参数。即只能在这里进行赋值
    self.requestParams = [params copy];
    
    NSInteger requestId = 0;
    //拦截器，是否允许调用API
    if ([self shouldCallAPIWithParams:params]) {
        //验证器
        if ([self.validator manager:self isCorrectWithParamsData:params]) {
            //格式化参数
            //特别注意：params和[params copy] 的却别就是他们的key的顺序不同，key顺序不同会导致转jsonString不一致！！这样会导致签名错误。如果之后，不把业务参数的jsonString加入签名，那么这里可以忽略两者区别。
            //在ios10之后， [params copy] 和 params的顺序应该是一致的！！
            NSDictionary *apiParams = [self reformParamsBase:self.requestParams];
            //检查缓存，如果缓存中取到的data==nil，那么requestId = 0,则跳过return去请求网络.
            
            if ([self shouldCache]) {
                [self saveRequestParams:apiParams];
                if ((requestId = [self fetchCacheDataWithParams:apiParams])) {
                    return requestId;
                }
            }
            
            
            //网络请求
            if ([self isReachable]) {
                [self beforeCallingAPIWithParams:apiParams];
                //调用方式get or post
                switch (self.requestType) {
                    case BMAPIManagerRequestTypeGet:
                        BMCallAPI(GET,apiParams, requestId);
                        break;
                    case BMAPIManagerRequestTypePost:
                        BMCallAPI(POST,apiParams, requestId);
                        break;
                    case BMAPIManagerRequestTypePostMimeType:
                        BMCallAPI(MineTypePOST,apiParams, requestId);
                        break;
                    case BMAPIManagerRequestTypePut:
                        BMCallAPI(PUT,apiParams, requestId);
                        break;
                    case BMAPIManagerRequestTypeDelete:
                        BMCallAPI(DELETE,apiParams, requestId);
                        break;
                    default:
                        BMCallAPI(POST,apiParams, requestId);
                        break;
                }
                NSMutableDictionary *lastParams = [apiParams mutableCopy];
                lastParams[kBMAPIBaseManagerRequestID] = @(requestId);
                [self afterCallingAPIWithParams:lastParams];
                return requestId;
            }else{
                [self failedOnCallingAPI:nil withErrorType:BMAPIManagerErrorTypeNoNetWork];
                return requestId;
            }
        }else{
            [self failedOnCallingAPI:nil withErrorType:BMAPIManagerErrorTypeParamsError];
            return requestId;
        }
    }else{
        [self failedOnCallingAPI:nil withErrorType:BMAPIManagerErrorTypeNotAllowCallingApi];
        return requestId;
    }

    return requestId;
}

#pragma mark - 拦截器

/**
 * 1.由于多态的特性，如果子类重写了父类的方法，调用顺序是：先会找到子类的该方法，存在则调用，如果子类不存在该方法则会去父类找
 * 2.当子类继承了父类时，子类对象和父类对象指的都是同一块内存，即父类的self 和子类的self所表示 的对象是同样的。
 */
- (void)beforePerformSuccessWithResponse:(BMURLResponse *)response
{

    if ([self usePage]) {
        NSDictionary *data = [response.content copy];
        if (kBMResponseDataKey) {
            data = [response.content objectForKey:kBMResponseDataKey];
        }
        if ([data isKindOfClass:[NSDictionary class]]) {
            if ([self pageType] == BMPageTypeTimeStamp) {
                //分页记录
                int64_t timeStamp = [[data objectForKey:[self pageTimeStampKey]] longLongValue];
                self.nextPageTimeStamp = timeStamp;
            }else{
                self.totalDataCount = [[data objectForKey:[self pageTotalKey]] floatValue];
                if (self.isPageRequest) {//若是是上拉，那么页码递增
                    NSInteger totalPageCount = ceilf((double)self.totalDataCount / (double)[self pageSize]);//类型转换double，防止int 除以 int 忽略小数点数值
                    if (self.nextPageNumber <= totalPageCount) {
                        self.nextPageNumber++;
                    }
                }else{
                    self.nextPageNumber = [self pageStartIndex] + 1;
                }

            }
        }
        

    }

    
    if ([self.interceptor respondsToSelector:@selector(manager:beforePerformSuccessWithResponse:)]) {
        [self.interceptor manager:self beforePerformSuccessWithResponse:response];
    }
}

- (void)afterPerformSuccessWithResponse:(BMURLResponse *)response
{

    if ([self.interceptor respondsToSelector:@selector(manager:afterPerformSuccessWithResponse:)]) {
        [self.interceptor manager:self afterPerformSuccessWithResponse:response];
    }
}

- (void)beforePerformFailWithResponse:(BMURLResponse *)response
{
    if ([self.interceptor respondsToSelector:@selector(manager:beforePerformFailWithResponse:)]) {
        [self.interceptor manager:self beforePerformFailWithResponse:response];
    }
}

- (void)afterPerformFailWithResponse:(BMURLResponse *)response
{
    if ([self.interceptor respondsToSelector:@selector(manager:afterPerformFailWithResponse:)]) {
        [self.interceptor manager:self afterPerformFailWithResponse:response];
    }
}

//只有返回YES才会继续调用API
- (BOOL)shouldCallAPIWithParams:(NSDictionary *)params
{
    BOOL useToken = [self useToken];
    BMUserLoginStatus loginStatus = [self loginStatus];
    // 未登录or token无效情况
    if (useToken ) {
        if ( loginStatus == BMUserLoginStatusTokenInvalid) {
            self.responseMsg = @"Token失效";
            NSLog(@"%@，用户登录状态:%@",self.responseMsg, @(loginStatus));
            if ([self respondsToSelector:@selector(tokenInvalidEvent:)]) {
                [self tokenInvalidEvent:self];
            }else {
                [[NSNotificationCenter defaultCenter] postNotificationName:BMNotificationNetworkingTokenInvalid object:self];
            }
            return NO;
        }else if (loginStatus == BMUserLoginStatusUnLogin){
            self.responseMsg = @"用户未登录";
            NSLog(@"%@，用户登录状态:%@",self.responseMsg, @(loginStatus));
            if ([self respondsToSelector:@selector(userUnLoginEvent:)]) {
                [self userUnLoginEvent:self];
            }else {
                [[NSNotificationCenter defaultCenter] postNotificationName:BMNotificationNetworkingUserUnLogin object:self];
            }
            return NO;
        }

    }
    
    if ([self usePage]) {
        if (self.isPageRequest && [self pageType] == BMPageTypePageNumber) {
            if (self.nextPageNumber >0) {
                //如果分页达到上限，则不请求
                NSInteger totalPageCount = ceilf((double)self.totalDataCount / (double)[self pageSize]);
                if (self.nextPageNumber > totalPageCount ) {
                    self.responseMsg = @"已经没有下一页了!";
                    self.errorCode = BMManagerDefaultNoNextPage;
                    return NO;
                }
            }
        }
    }

    
    
    if ([self.interceptor respondsToSelector:@selector(manager:shouldCallAPIWithParams:)]) {
        return [self.interceptor manager:self shouldCallAPIWithParams:params];
    } else {
        return YES;
    }
}

- (void)afterCallingAPIWithParams:(NSDictionary *)params
{
    if ([self.interceptor respondsToSelector:@selector(manager:afterCallingAPIWithParams:)]) {
        [self.interceptor manager:self afterCallingAPIWithParams:params];
    }
}

- (void)beforeCallingAPIWithParams:(NSDictionary *)params
{
    if ([self.interceptor respondsToSelector:@selector(manager:beforeCallingAPIWithParams:)]) {
        [self.interceptor manager:self beforeCallingAPIWithParams:params];
    }
}



#pragma mark - 默认配置数据

//默认缓存配置
- (BOOL)shouldCache
{
    return NO;
}
- (BOOL)useToken
{
    return NO;
}

- (BOOL)usePage
{
    return NO;
}


- (NSString *)interfaceUrl
{
    return @"";
}

- (BMPageType)pageType
{
    return BMPageTypeTimeStamp;
}


- (BMTokenTransmissionMode)tokenTransmissionMode {
    return kBMTokenTransmissionMode;
}
- (NSString *)tokenKey {
    return kBMToken;

}
- (NSString *)tokenValue {
    return kBMTokenValue;
}
- (void)tokenInvalidEvent:(BMBaseAPIManager *)manager {
    return kBMTokenInvalidEvent(manager);
}
- (void)userUnLoginEvent:(BMBaseAPIManager *)manager {
    return kBMUserUnLoginEvent(manager);
}
- (void)responseErrorEvent:(BMBaseAPIManager *)manager {
   return kBMResponseErrorEvent(manager);
}

- (BMUserLoginStatus)loginStatus {
    return kBMLoginStatus;
}
- (BOOL)isTestEnVironment {
    return kBMIsTestEnVironment;
}
- (NSString *)baseUrl {
    return kBMBaseUrl;
}
- (NSString *)baseUrlTest{
    return kBMBaseUrlTest;
}

- (NSString *)responseMsgKey {
    return kBMResponseMsg;
}

- (NSString *)responseCodeKey {
    return kBMResponseCode;
}

- (NSInteger)tokenInvalidValue {
    return KBMTokenInvalid;
}
- (NSInteger)responseCodeSuccess {
    return kBMResponseCodeSuccess;
}



- (NSString *)pageTimeStampKey
{
    return kBMTimestampKey;
}


- (NSString *)pageSizeKey
{
    return kBMPageSizeKey;
}

- (NSUInteger)pageStartIndex
{
    return kBMPageStartIndex;
}
- (NSString *)pageIndexKey
{
    return kBMPageIndexKey;
}
- (NSString *)pageTotalKey
{
    return kBMPageTotalKey;
}
- (NSUInteger)pageSize
{
    return kBMPageSize;
}
- (NSUInteger)unPageSize
{
    return kBMUnPageSize;
}




//这里传入的param，不能是self.requestParams。因为
- (NSString *)queryString
{
    //返回查询字符串，优先级：接口 > BMBaseNetworkConfigure  > BMAPIParamsSign
    if ([self respondsToSelector:@selector(queryStringWithParam:)]) {
        NSLog(@"生成查询字符串，签名方式：使用接口单独配置的签名!");
        return [self queryStringWithParam:[self reformParamsBase:self.requestParams]];
    }else{
        if ([[BMBaseNetworkConfigure shareInstance] respondsToSelector:@selector(queryStringWithParam:requestType:)]) {
            NSLog(@"生成查询字符串，签名方式：使用BMBaseNetworkConfigure全局配置的签名!");
            return [networkConfigureInstance queryStringWithParam:[self reformParamsBase:self.requestParams] requestType:self.requestType];
        }else if ([[BMBaseNetworkConfigure shareInstance] respondsToSelector:@selector(queryStringWithParam:requestType:url:)]){
            NSLog(@"生成查询字符串，签名方式：使用BMBaseNetworkConfigure全局配置的签名!");
            return [networkConfigureInstance queryStringWithParam:[self reformParamsBase:self.requestParams] requestType:self.requestType url:[self requestUrl]];
        }else{
            NSLog(@"生成查询字符串，签名方式：使用BMAPIParamsSign框架自带配置的签名!");
            return [BMAPIParamsSign generateSignaturedUrlQueryStringWithParam:[self reformParamsBase:self.requestParams] requestType:self.requestType];
        }
    }
}


//api名字
- (NSString *)apiName
{
    return NSStringFromClass([self class]);
}

- (NSString *)serviceIdentifier
{
    return [[self apiName] stringByAppendingString:@"serviceIdentifier"];
}

- (NSString *)requestUrl
{
    BOOL isTestEnvironment = [self isTestEnVironment];
    NSString *url = isTestEnvironment? ([self respondsToSelector:@selector(testBaseUrl)]?[self testBaseUrl]:[self baseUrlTest]):[self baseUrl];
    NSString *path = [self interfaceUrl];
    

    if ([[url substringFromIndex:url.length-1] isEqualToString:@"/"] || [[path substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"/"]) {
        url = [url stringByAppendingString:path];
    }else {
       url = [url stringByAppendingString:[NSString stringWithFormat:@"/%@", path]];
    }
    
    return url;
}

- (NSDictionary *)reformParams:(NSDictionary *)params
{
    //不做任何处理，返回原有参数≈
    return params;
}

- (NSDictionary *)reformHeaders:(NSDictionary *)headers {
    return headers;
}

//默认请求类型
- (BMAPIManagerRequestType)requestType
{
    return BMAPIManagerRequestTypePost;
}
//默认参数
- (NSDictionary *)paramsForApi:(BMBaseAPIManager *)manager
{
    return nil;
}
//默认验证器配置
- (BOOL)manager:(BMBaseAPIManager *)manager isCorrectWithCallBackData:(NSDictionary *)data
{

    if (isAPICallingSuccess(data)) {
        return YES;
    }else{
        return NO;
    }
    
}

//默认验证器配置
- (BOOL)manager:(BMBaseAPIManager *)manager isCorrectWithParamsData:(NSDictionary *)data
{
    return YES;
}



#pragma mark - 私有方法

/*
 * 当接口要求缓存时，记录每次请求的不同参数（只会增加不会减少，不同的参数不会太多所以目前不做删除处理）
 */
- (void)saveRequestParams:(NSDictionary *)params
{

    //这里只是调用了cache的一个
    NSString *key = [[NSString stringWithFormat:@"%@%@%@", [self requestUrl], [self apiName],[params AIF_urlParamsStringSignature:NO]] md5String];
    if ([self.allRequestParams objectForKey:key] == nil) {
        [self.allRequestParams setObject:params forKey:key];
        //调试日志
//        NSLog(@"调试日志,新增一组请求参数,当请求参数一共有:%@组",@([[self.allRequestParams allKeys] count]));
    }else{
//        NSLog(@"调试日志,已存在改组请求参数,当请求参数一共有:%@组",@([[self.allRequestParams allKeys] count]));
    }
}



- (NSInteger )fetchCacheDataWithParams:(NSDictionary *)params
{

    NSData *result = [self.cache fetchCachedDataWithUrl:[self requestUrl] apiName:[self apiName] requestParams:params];
    
    if (result == nil) {
        return 0;
    }
    
//    NSLog(@"调试日志,接口%@取得缓存数据",NSStringFromClass([self class]));
    BMURLResponse *response = [[BMURLResponse alloc] initWithData:result];//这里只用initwithData初始化来表示，response是从缓存中取出来
    response.requestParams = params;
    self.requestId = response.requestId;
    //日志
    [BMLoger logDebugInfoWithCachedResponse:response apiName:[self apiName] url:[self requestUrl]];

    //延迟执行
    @weakify(self);
    double delayInSeconds = 0.5;
    dispatch_time_t afterTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(afterTime, dispatch_get_main_queue(), ^{
        @strongify(self)
        [self successedOnCallingAPI:response];
    });
    
    return response.requestId;
    
}

//从本地列表中移除一个请求(无论是成功还是失败，都会调用该方法的)
- (void)removeRequestWithRequestId:(NSInteger)requestId
{
    NSNumber *requestIdToRemove = nil;
    for (NSNumber *storeRequestId in self.requestIdList) {
        if ([storeRequestId integerValue] == requestId) {
            requestIdToRemove = storeRequestId;
            break;
        }
    }
    if (requestIdToRemove) {
        [self.requestIdList removeObject:requestIdToRemove];
    }
}

//将网络成错误，转对成Manager对应的错误
- (BMAPIManagerErrorType )turnBMURLResponseStatusToBMAPIManagerErrorType:(BMURLResponseStatus)status
{
    BMAPIManagerErrorType errorType = BMAPIManagerErrorTypeDefault;
    switch (status) {
        case BMURLResponseStatusErrorTimeout:
            errorType = BMAPIManagerErrorTypeTimeout;
            break;
        case NSURLResponseStatusErrorCannotFindHost:
            errorType = BMAPIManagerErrorTypeCannotFindHost;
            break;
        case NSURLResponseStatusErrorBadServerResponse:
            errorType = BMAPIManagerErrorTypeBadServerResponse;
            break;
        case NSURLResponseStatusErrorNotConnectedToInternet:
            errorType = BMAPIManagerErrorTypeNotConnectedToInternet;
            break;
        case NSURLResponseStatusErrorNetworkConnectionLost:
            errorType = BMAPIManagerErrorTypeNetworkConnectionLost;
            break;
        case BMURLResponseStatusErrorUnknowError:
            errorType = BMAPIManagerErrorTypeUnknowError;
            break;
        default:
            break;
    }
    return errorType;
}


#pragma mark - 公有方法
- (id)fetchDataWithReformer:(id<BMAPIManagerCallBackDataReformer>)reformer
{
    id resultData = nil;
    if ([reformer respondsToSelector:@selector(manager:reformData:)]) {
        resultData = [reformer manager:self reformData:self.fetchedRawData];
    }else{
        resultData = [self.fetchedRawData mutableCopy];
    }
    return resultData;
}



- (NSDictionary *)reformParamsBase:(NSDictionary *)params
{
    
    NSMutableDictionary *mutableParams = params?[params mutableCopy]:[[NSMutableDictionary alloc]init];
    //是否使用token
    if ([self useToken] && [self tokenTransmissionMode] == BMTokenTransmissionModeInParams) {
        // 配置token
        NSString *tokenKey = [self tokenKey];
        mutableParams[tokenKey] = [self tokenValue];
    }
    
    if ([self usePage]) {
        //是否分页请求
        if (self.isPageRequest) {
            mutableParams[[self pageSizeKey]] = @([self pageSize]);
            
            if ([self pageType] == BMPageTypeTimeStamp) {
                mutableParams[[self pageTimeStampKey]] = @(self.nextPageTimeStamp);
            }else{
                mutableParams[[self pageIndexKey]] = @(self.nextPageNumber);
            }
            
        }else{
            //因服务端某些接口存在定义[self unPageSize]/[self pageTimeStampKey]/[self pageIndexKey]参数是必传的！所以这里全都都当做必传！
            mutableParams[[self pageSizeKey]] = @([self unPageSize]);
            if ([self pageType] == BMPageTypeTimeStamp) {
                mutableParams[[self pageTimeStampKey]] = @(0);
            }else{
                mutableParams[[self pageIndexKey]]= @([self pageStartIndex]);
            }
        }
    }



    
    
    //格式化参数
    if ([self respondsToSelector:@selector(reformParams:)]) {
        mutableParams = [[self reformParams:mutableParams] mutableCopy];
    }
    return mutableParams;
}

- (void)cancelAllRequest
{
    [[BMAPICalledProxy sharedInstance] cancelRequestWithRequestIdList:self.requestIdList];
    [self.requestIdList removeAllObjects];
}

- (void)cancelRequestWithRequestId:(NSInteger)requestID
{
    //删除本地列表
    [self removeRequestWithRequestId:requestID];
    //移除真正的请求
    [[BMAPICalledProxy sharedInstance] cancelRequestWithRequestId:@(requestID)];
}

#pragma api callbacks

- (void)callingProgress:(NSProgress *)progress requestId:(NSInteger )requestId
{
    self.requestId = requestId;
    if ([self.apiCallBackDelegate respondsToSelector:@selector(managerCallApiProgress:progress:)]) {
        [self.apiCallBackDelegate managerCallApiProgress:self progress:progress];
    }
}


- (void)successedOnCallingAPI:(BMURLResponse *)response
{
    if (response.content) {
        self.fetchedRawData = [response.content copy];
    }
    self.response = response;
    self.errorCode = [[response.content objectForKey:[self responseCodeKey]] integerValue];
    self.responseMsg = getAPICallingResponseMsg(response.content);
    self.requestId = response.requestId;
    [self removeRequestWithRequestId:response.requestId];//清除列表
    //处理token过期
    
    //子类检查
    if ([self.validator manager:self isCorrectWithCallBackData:response.content]) {
        if ([self shouldCache] && !response.isCache) {//1.如果接口需且还没有缓存，则进行缓存
            [self.cache saveCacheWithData:response.responseData Url:[self requestUrl] apiName:[self apiName] requestParams:response.requestParams];
        }
        //拦截器
        self.errorType = BMAPIManagerErrorTypeSuccess;
        [self beforePerformSuccessWithResponse:response];
        if ([self.apiCallBackDelegate respondsToSelector:@selector(managerCallApiDidSuccess:)]) {
            [self.apiCallBackDelegate managerCallApiDidSuccess:self];
        }
        [self afterPerformSuccessWithResponse:response];
    }else{
        
        [self failedOnCallingAPI:response withErrorType:BMAPIManagerErrorTypeFail];
    }
    
}

- (void)failedOnCallingAPI:(BMURLResponse *)response withErrorType:(BMAPIManagerErrorType)errorType
{
    self.errorType = errorType;
    self.response = response;
    if (errorType == BMAPIManagerErrorTypeNotAllowCallingApi) {
        self.errorCode = BMManagerDefaultAPINotAllow;
    }else
    {
        if (errorType == BMAPIManagerErrorTypeParamsError){
            self.responseMsg = @"参数错误(前端校验)";
            self.errorCode = BMManagerDefaultParamsError;
        }else{
            if ([response.content objectForKey:[self responseCodeKey]]) {
                self.errorCode =[[response.content objectForKey:[self responseCodeKey]] integerValue];
                self.responseMsg = getAPICallingResponseMsg(response.content);
            }else{
                //默认认为网络或者服务器错误BMManagerDefaultOtherError
                self.errorCode = BMManagerDefaultOtherError;//默认其他错误
                self.responseMsg = response.error.localizedDescription;
            }
        }

        //处理token过期
        if (self.errorCode == [self tokenInvalidValue]) {
            if ([self respondsToSelector:@selector(tokenInvalidEvent:)]) {
                [self tokenInvalidEvent:self];
            }else {
                [[NSNotificationCenter defaultCenter] postNotificationName:BMNotificationNetworkingTokenInvalid object:self];
            }
        }
    }
    if ([self respondsToSelector:@selector(responseErrorEvent:)]) {
        [self responseErrorEvent:self];
    }

    NSLog(@">> 【%@】接口请求失败:\n\t错误描述：%@\n\t错误类型：%lu\n\t错误码%@：%ld",NSStringFromClass([self class]),self.responseMsg,(unsigned long)errorType,[self responseCodeKey],(long)self.errorCode);


    self.requestId = response.requestId;
    [self removeRequestWithRequestId:response.requestId];//清除列表
    [self beforePerformFailWithResponse:response];
    if ([self.apiCallBackDelegate respondsToSelector:@selector(managerCallApiDidFailed:)]) {
        [self.apiCallBackDelegate managerCallApiDidFailed:self];
    }
    
    
    [self afterPerformFailWithResponse:response];
}





@end

@implementation BMBaseAPIManager (cache)

//是否存在缓存
- (BOOL)hasCacheWithParams:(NSDictionary *)params
{
    //接口没有实现缓存代理时，则忽略参数保存
    if (![self shouldCache]) {
        return NO;
    }
    NSDictionary *reformerParam = [[self reformParamsBase:params] copy];
    
    NSData *result = [self.cache fetchCachedDataWithUrl:[self requestUrl] apiName:[self apiName] requestParams:reformerParam];
    if (result == nil) {
        return NO;
    }
    return YES;
}


/*
 * 针对特定参数删除缓存
 */
- (void)deleteCacheWithParams:(NSDictionary *)params
{
    //接口没有实现缓存代理时，则忽略参数保存
    if (![self shouldCache]) {
        return;
    }
    NSDictionary *reformerParam = [[self reformParamsBase:params] copy];
    [self.cache deleteCacheWithUrl:[self requestUrl] apiName:[self apiName] requestParams:reformerParam];
    NSString *key = [[NSString stringWithFormat:@"%@%@%@", [self requestUrl], [self apiName],[reformerParam AIF_urlParamsStringSignature:NO]] md5String];
    [self.allRequestParams removeObjectForKey:key];
}

//删除该接口的所有缓存
- (void)cleanAllParamsCaChe
{
    //接口没有实现缓存代理时，则忽略参数保存
    if (![self shouldCache]) {
        return;
    }
    NSArray *allKeys = [self.allRequestParams allKeys];
    for (NSString *key in allKeys) {
        NSDictionary *param = [self.allRequestParams objectForKey:key];
        [self deleteCacheWithParams:param];
    }
    
    
}



@end

@implementation BMBaseAPIManager (http)

- (BMURLResponse *)fetchHttpUrlResponse {
    return self.response;
}

@end
