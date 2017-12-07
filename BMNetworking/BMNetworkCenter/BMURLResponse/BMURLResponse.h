//
//  BMURLResponse.h
//  BlueMoonBlueHouse
//
//  Created by fenglh on 15/9/25.
//  Copyright (c) 2015年 fenglh. All rights reserved.
//

#import <Foundation/Foundation.h>


//网络层错误
typedef NS_ENUM(NSUInteger, BMURLResponseStatus)
{
    BMURLResponseStatusSuccess,                     //作为底层，请求是否成功只考虑是否成功收到服务器反馈。至于数据是否返回正确以及完整，由商城BMBaseAPIManager来决定.
    BMURLResponseStatusErrorTimeout,                //超时
    NSURLResponseStatusErrorCannotFindHost,         //未找到指定主机名的服务器
    NSURLResponseStatusErrorCannotConnectToHost,    //未能连接到主机
    NSURLResponseStatusErrorBadServerResponse,      //服务器错误,未找到资源:404
    NSURLResponseStatusErrorNotConnectedToInternet,  //已断开与互联网的连接
    NSURLResponseStatusErrorNetworkConnectionLost,  //网络连接已中断
    BMURLResponseStatusErrorUnknowError             //未知错误
};


@interface BMURLResponse : NSObject

@property (nonatomic, assign, readonly) BMURLResponseStatus status;
@property (nonatomic, copy, readonly) NSString *contentString;
@property (nonatomic, copy, readonly) id content;
@property (nonatomic, copy, readonly) NSError *error;
@property (nonatomic, assign, readonly) NSInteger requestId;
@property (nonatomic, copy, readonly) NSHTTPURLResponse *response;
@property (nonatomic, copy, readonly) NSURLRequest *request;
@property (nonatomic, copy, readonly) NSData *responseData;
@property (copy, nonatomic) NSDictionary *requestParams;
@property (nonatomic, assign, readonly) BOOL isCache;


- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request response:(NSHTTPURLResponse *)response responseData:(NSData *)responseData status:(BMURLResponseStatus)status;

- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request response:(NSHTTPURLResponse *)response responseData:(NSData *)responseData error:(NSError *)error;


//注意：这3个初始化response的方法是不可以随便用的，在只有在hasCacheWithParams return YES时，中才会使用- (instancetype)initWithData:(NSData *)data;来初始化response，表示该response是从缓存中取出来。为什么取缓存response的方法中，设置response.isCache = YES，是因为对于其他类isCache是readOnly的!设计成readOnly就可以保证response.isCache不会被误修改!
- (instancetype)initWithData:(NSData *)data;




@end
