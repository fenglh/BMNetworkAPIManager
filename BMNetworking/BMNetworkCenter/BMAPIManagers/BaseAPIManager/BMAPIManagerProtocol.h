//
//  BMAPIManagerProtocol.h
//  BMWash
//
//  Created by fenglh on 2016/10/11.
//  Copyright © 2016年 月亮小屋（中国）有限公司. All rights reserved.

/*
 *----------------------------
 *
 * 修改：
 *  1.将protocol Delegate 剥离到一个单独的文件
 *  2.去掉BMService类
 *  3.基类自带分页功能
 * 版本：2.0.0
 * 日期：2016/10/11 冯立海
 *----------------------------
 *
 * 修改：抽离弱业务的代码到BMBaseNetworkConfigure类中
 *
 * 版本：2.1.0
 * 日期：2016/10/11 冯立海
 *
 */

//

@class BMBaseAPIManager;





#import <Foundation/Foundation.h>
#import "BMURLResponse.h"
#import "BMEnumType.h"




/***********************************************************************************************************/
/*                          api回调代理 BMAPIManagerApiCallBackDelegate                                     */
/***********************************************************************************************************/
@protocol BMAPIManagerCallBackDelegate <NSObject>
@optional

/**
 *  成功回调，表示网络请求是成功的并且返回的数据是正确的，调用者可以直接使用，在该方法里面调用[manager fetchDataWithReformer:(id<BMAPIManagerCallBackDataReformer>)]来获取网络返回的数据
 *
 *  @param manager manager对象
 */
- (void)managerCallApiDidSuccess:(BMBaseAPIManager *)manager;

/**
 *  失败回调, 例如：网络可能不可达、返回数据不正确,例如登录失败中的密码错误、都会再这里返回
 *
 *  @param manager manager对象
 */
- (void)managerCallApiDidFailed:(BMBaseAPIManager *)manager;

/**
 * 接口调用进度
 */
- (void)managerCallApiProgress:(BMBaseAPIManager *)manager progress:(NSProgress *)progress;

@end

/***********************************************************************************************************/
/*                          api回调数据格式化器 BMAPIManagerCallBackDataReformer                              */
/***********************************************************************************************************/
@protocol BMAPIManagerCallBackDataReformer <NSObject>
@optional
/**
 *  格式化器,
 *
 *  @param manager manager对象
 *  @param data    网络请求返回的原始数据
 *
 *  @return 格式化之后的数据
 */
- (id)manager:(BMBaseAPIManager *)manager reformData:(NSDictionary *)data;
+ (id)manager:(BMBaseAPIManager *)manager reformData:(NSDictionary *)data;
@end


/***********************************************************************************************************/
/*                          api验证器 BMAPIManagerValidator                                                 */
/***********************************************************************************************************/
@protocol BMAPIManagerValidator <NSObject>
@required
- (BOOL)manager:(BMBaseAPIManager *)manager isCorrectWithCallBackData:(NSDictionary *)data;
- (BOOL)manager:(BMBaseAPIManager *)manager isCorrectWithParamsData:(NSDictionary *)data;
@end


/***********************************************************************************************************/
/*                          api参数源代理 BMAPIManagerParamsSourceDelegate                                   */
/***********************************************************************************************************/
@protocol BMAPIManagerParamsSourceDelegate <NSObject>
@required
- (NSDictionary *)paramsForApi:(BMBaseAPIManager *)manager;
@end


/***********************************************************************************************************/
/*                          apiManager BMAPIManager                                                        */
/***********************************************************************************************************/
@protocol BMAPIManager<NSObject>

@optional

//接口地址
- (NSString *)baseUrl;      //正式地址, 默认@""
- (NSString *)baseUrlTest;  //测试地址, 默认@""
//接口在3.0.0版本将不再支持，请使用- (NSString *)baseUrlTest 代替
- (NSString *)testBaseUrl DEPRECATED_MSG_ATTRIBUTE("接口在3.0.0版本将不再支持，请使用- (NSString *)baseUrlTest 代替");
- (NSString *)interfaceUrl; //接口地址，默认@""
- (BOOL)isTestEnVironment;  //是否测试环境,默认NO

//分页
- (BOOL)usePage;            //是否使用分页，默认NO
- (BMPageType)pageType;     //分页类型，默认BMPageTypeTimeStamp
- (NSUInteger)unPageSize;   //不分页大小,默认10
- (NSUInteger)pageSize;     //分页大小，默认10
- (NSUInteger)pageStartIndex; //默认0
- (NSString *)pageTimeStampKey; //分页时间戳的key，默认@"timestamp"
- (NSString *)pageIndexKey;//当使用BMPageTypePageNumber,类型的分页方式时候，需要用到该key,默认@"pageIndex"
- (NSString *)pageTotalKey;//当使用BMPageTypePageNumber,类型的分页方式时候，需要用到该key,默认@"pageTotal"
- (NSString *)pageSizeKey;//分页大小key，默认@"pageSize"
- (NSInteger)pageTotalCount;
- (BOOL)hasMorePage:(NSDictionary *)data; //是否存在更多页

//请求和响应
- (BMAPIManagerRequestType)requestType;//默认BMAPIManagerRequestTypePost
- (NSString *)responseMsgKey;//默认@"responseMsg"
- (NSString *)responseCodeKey;//默认@"responseCode"
- (NSInteger)responseCodeSuccess;//默认0
- (void)responseErrorEvent:(BMBaseAPIManager *)manager;//请求错误事件
- (NSString *)queryStringWithParam:(NSDictionary *)params;//查询字符串

//缓存
- (BOOL)shouldCache;//是否缓存，YES缓存（5分钟）

//格式化
- (NSDictionary *)reformParams:(NSDictionary *)params;//格式化参数，例如去前后空格
- (NSDictionary *)reformHeaders:(NSDictionary *)headers;//格式化header


//登录
- (void)userUnLoginEvent:(BMBaseAPIManager *)manager ;//用户未登录事件
- (BMUserLoginStatus)loginStatus; //登录状态

//token
- (BOOL)useToken;//默认NO
- (BMTokenTransmissionMode)tokenTransmissionMode;
- (NSString *)tokenKey;//默认@"token"
- (NSString *)tokenValue;//默认@""
- (void)tokenInvalidEvent:(BMBaseAPIManager *)manager;//token无效事件
- (NSInteger)tokenInvalidValue;//默认-1




@end


/***********************************************************************************************************/
/*                          BMAPIManagerInterceptor 拦截器                                                  */
/***********************************************************************************************************/

@protocol BMAPIManagerInterceptor <NSObject,BMAPIManager>

@optional

- (void)manager:(BMBaseAPIManager *)manager beforePerformSuccessWithResponse:(BMURLResponse *)response; //网络请求完毕，在调用成功回调之前
- (void)manager:(BMBaseAPIManager *)manager afterPerformSuccessWithResponse:(BMURLResponse *)response;  //网络请求完毕，在调用成功回调之后

- (void)manager:(BMBaseAPIManager *)manager beforePerformFailWithResponse:(BMURLResponse *)response;    //网络请求完毕，在调用失败回调之前
- (void)manager:(BMBaseAPIManager *)manager afterPerformFailWithResponse:(BMURLResponse *)response;     //网络请求完毕，在调用失败回调之后

- (BOOL)manager:(BMBaseAPIManager *)manager shouldCallAPIWithParams:(NSDictionary *)params;DEPRECATED_MSG_ATTRIBUTE("接口在3.0.2版本将不再支持，请使用- (BOOL)manager: shouldCallAPIWithParams:responseMsg: 代替");

- (BOOL)manager:(BMBaseAPIManager *)manager shouldCallAPIWithParams:(NSDictionary *)params responseMsg:(NSString **)responseMsg;//是否允许调用api



- (void)manager:(BMBaseAPIManager *)manager beforeCallingAPIWithParams:(NSDictionary *)params;
- (void)manager:(BMBaseAPIManager *)manager afterCallingAPIWithParams:(NSDictionary *)params;

@end

