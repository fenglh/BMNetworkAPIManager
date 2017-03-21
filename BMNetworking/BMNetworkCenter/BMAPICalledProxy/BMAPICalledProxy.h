//
//  BMAPICalledProxy.h
//  BlueMoonBlueHouse
//
//  Created by 冯立海 on 15/9/26.
//  Copyright (c) 2015年 fenglh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMURLResponse.h"

typedef void(^BMAPICallback)(BMURLResponse *response);

/*
 * 网络层请求代理，用来管理AFHTTPRequestOperationManager队列
 */
@interface BMAPICalledProxy : NSObject
+ (instancetype)sharedInstance;
- (NSNumber *)generateRequestId;//生成requestId，此方法开放出来，是为了让使用了缓存的接口也生成一个requestId

//** GET 请求 **/
- (NSInteger)callGETWithParams:(NSDictionary *)params
                           url:(NSString *)url
                   queryString:(NSString *)queryString
                       apiName:(NSString *)apiName
                      progress:(void(^)(NSProgress * progress,NSInteger requestId))progress
                       success:(BMAPICallback)success
                       failure:(BMAPICallback)failure;


//** JSON post 请求 **//
- (NSInteger)callPOSTWithParams:(NSDictionary *)params
                            url:(NSString *)url
                    queryString:(NSString *)queryString
                        apiName:(NSString *)apiName
                       progress:(void(^)(NSProgress * progress,NSInteger requestId))progress
                        success:(BMAPICallback)success
                        failure:(BMAPICallback)failure;

//** multipart/form-data Http Post请求 **/
- (NSInteger)callMineTypePOSTWithParams:(NSDictionary *)params
                                    url:(NSString *)url
                            queryString:(NSString *)queryString
                                apiName:(NSString *)apiName
                               progress:(void(^)(NSProgress * progress, NSInteger requestId))progress
                                success:(BMAPICallback)success
                                failure:(BMAPICallback)failure;



//取消请求
- (void)cancelRequestWithRequestId:(NSNumber *)requestID;
- (void)cancelRequestWithRequestIdList:(NSArray *)requestIDList;
@end
