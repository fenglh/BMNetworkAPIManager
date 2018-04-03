//
//  BMEnumType.h
//  BMNetworking
//
//  Created by fenglh on 2017/3/14.
//  Copyright © 2017年 BlueMoon. All rights reserved.
//

#ifndef BMEnumType_h
#define BMEnumType_h

typedef NS_ENUM (NSUInteger , BMUserLoginStatus){
    BMUserLoginStatusUnLogin,
    BMUserLoginStatusTokenInvalid,
    BMUserLoginStatusLoginNormal,
};

//HTTP 请求类型
typedef NS_ENUM(NSUInteger, BMAPIManagerRequestType){
    BMAPIManagerRequestTypeGet,
    BMAPIManagerRequestTypePost,
    BMAPIManagerRequestTypePut,
    BMAPIManagerRequestTypeDelete,
    BMAPIManagerRequestTypePostMimeType
};


//分页类型
typedef NS_ENUM (NSUInteger , BMPageType){
    BMPageTypeTimeStamp,//按时间戳分页
    BMPageTypePageNumber//按页码分页
};


//网络日志等级
typedef NS_ENUM (NSUInteger , BMNetworkLogLevel){
    BMNetworkLogLevelUnLog      = 0,
    BMNetworkLogLevelRequest    = 1 << 0,
    BMNetworkLogLevelResponse   = 1 << 1,
};


//token 传输方式
typedef NS_ENUM (NSUInteger, BMTokenTransmissionMode){
    BMTokenTransmissionModeInParams,  //在参数中
    BMTokenTransmissionModeInHeaders, //在header中
};
#endif /* BMEnumType_h */
