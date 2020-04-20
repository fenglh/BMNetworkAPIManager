//
//  BMBaseAPIManager.h
//  BlueMoonBlueHouse
//
//  Created by fenglh on 15/9/25.
//  Copyright (c) 2015年 fenglh. All rights reserved.
//----------------------------------------



#define BMAPIManagerInit(clas, name, delegate) - (clas *)name {if (!_##name) {_##name = [[clas alloc] init];_##name.apiCallBackDelegate = delegate;}return _##name;}
#define BMAPIManagerDelegateSelfInit(clas, name)  BMAPIManagerInit(clas, name, self)


#import <Foundation/Foundation.h>
#import "BMURLResponse.h"
#import "BMNetworkAPIManager.h"

@class BMBaseAPIManager;

// 在调用成功之后的params字典里面，用这个key可以取出requestID
static NSString * const kBMAPIBaseManagerRequestID = @"kRTAPIBaseManagerRequestID";


typedef NS_ENUM(NSUInteger, BMAPIManagerErrorType){
    BMAPIManagerErrorTypeDefault,                   //0、没有产生过api调用，默认
    BMAPIManagerErrorTypeSuccess,                   //1、一切正常。api接口调用成功以及返回数据合法
    BMAPIManagerErrorTypeFail,                      //2、responseCode != 0 都返回这个
    BMAPIManagerErrorTypeParamsError,               //3、前端校验参数合法性返回的错误，都属于该类型。例如：参数传入nil、null、手机号码不合法、密码不合法等等
    BMAPIManagerErrorTypeNotAllowCallingApi,        //4、前端校验是否允许调用api返回的错误，都属于该类型。例如：未登录、token无效等
    
    BMAPIManagerErrorTypeNoNetWork,                 //5、网络不通。
    BMAPIManagerErrorTypeTimeout,                   //6、请求超时
    BMAPIManagerErrorTypeCannotFindHost,            //7、未能找到主机
    BMAPIManagerErrorTypeCannotConnectToHost,       //8、未能连接到主机
    BMAPIManagerErrorTypeBadServerResponse,         //9、服务器响应失败
    BMAPIManagerErrorTypeNotConnectedToInternet,    //10、未能连接到因特网
    BMAPIManagerErrorTypeNetworkConnectionLost,     //11、网络连接中断
    BMAPIManagerErrorTypeUnknowError                //12、未知错误
};


/***********************************************************************************************************/
/*                          BMBaseAPIManager 接口                                                           */
/***********************************************************************************************************/



@interface BMBaseAPIManager : NSObject <BMAPIManager,BMAPIManagerInterceptor,BMAPIManagerValidator>

@property (weak, nonatomic) id<BMAPIManagerCallBackDelegate>        apiCallBackDelegate;    //成功和失败回调
@property (weak, nonatomic) id<BMAPIManagerParamsSourceDelegate>    paramSource;            //参数源
@property (weak, nonatomic) id<BMAPIManagerInterceptor>             interceptor;            //拦截器
@property (weak, nonatomic) id<BMAPIManagerValidator>               validator;              //验证器

@property (strong, nonatomic) id userInfo;      //针对这个请求，可以用来存储额外的数据,默认nil。

//只读
@property (nonatomic, copy, readonly) NSDictionary              *requestParams; //请参数
@property (nonatomic, assign, readonly) NSInteger               requestId;      //请求Id,根据requestId可以可以判断是哪一次请求
@property (nonatomic, strong, readonly )NSString                *responseMsg;  //接口请求返回的信息responseMsg都在这里，以及网络错误信息也在这里
@property (nonatomic, assign, readonly)BMAPIManagerErrorType    errorType;      //成功和失败的错误类型
@property (nonatomic, assign, readonly)NSInteger                errorCode;      //相对于errorType的具体化的错误代码
@property (nonatomic, assign, readonly) BOOL                    isReachable;    //网络是否可达
@property (nonatomic, assign, readonly) BOOL                    isPageRequest;  //是否是分页请求



/*
 * 发起请求
 */
- (NSInteger)loadData;
- (NSInteger)loadDataWithParams:(NSDictionary *)params;
- (NSInteger)loadNextPage;
- (NSInteger)loadNextPageWithParams:(NSDictionary *)params OBJC_SWIFT_UNAVAILABLE("请使用'loadNextPage' 方法代替");




/**
 *  获取数据，该方法一定是在successDelegate中调用的,可以传nil获取原始数据
 *
 *  @param reformer 格式化器，例如登录请求返回的是一个json（response，token，timestap等），而调用者需要的数据仅仅是登录成功的token。那么这个格式化器里面做的就是直接取到token返回即可
 *
 *  @return id 任意类型
 */
- (id)fetchDataWithReformer:(id<BMAPIManagerCallBackDataReformer>)reformer;

/* 格式化参数，例如去掉前后空格、密码做md5值等,可再此函数中添加额外操作。当子类有自己特有的格式化参数时候，则可以重写该函数。如子类既需要父类的参数格式化需求，又由自己特殊的参数格式化需求。那么在重写该函数的时候，
 * 应该调用[super reformParams:params];
 *
 */

- (NSDictionary *)reformParams:(NSDictionary *)params;

/**
 *  取消所有请求
 */
- (void)cancelAllRequest;

/**
 *  取消指定请求
 *
 *  @param requestID 请求id
 */
- (void)cancelRequestWithRequestId:(NSInteger)requestID;

//通知
extern NSString * BMNotificationNetworkingTokenInvalid;   //token无效
extern NSString * BMNotificationNetworkingUserUnLogin;        //用户未登录


@end



/**
 缓存相关
 */
@interface BMBaseAPIManager (cache)


- (BOOL)hasCacheWithParams:(NSDictionary *)params;//是否存在缓存
- (void)deleteCacheWithParams:(NSDictionary *)params;//删除指定参数缓存
- (void)cleanAllParamsCaChe;//删除所有缓存

@end


/**
 HTTP 信息相关
 */
@interface BMBaseAPIManager (http)

- (BMURLResponse *)fetchHttpUrlResponse;

@end


