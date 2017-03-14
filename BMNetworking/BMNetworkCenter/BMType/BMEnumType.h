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
    BMAPIManagerRequestTypePostMimeType
};


//网络日志等级
typedef NS_ENUM (NSUInteger , BMNetworkLogLevel){
    BMNetworkLogLevelInfo,
    BMNetworkLogLevelVerbose
};

#endif /* BMEnumType_h */
