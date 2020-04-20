//
//  BMBaseNetworkConfigure.m
//  BMNetworking
//
//  Created by fenglh on 2017/1/20.
//  Copyright © 2017年 BlueMoon. All rights reserved.
//

#import "BMBaseNetworkConfigure.h"
#import <objc/runtime.h>
#import "BMNetworkAPIManager.h"

@implementation BMBaseNetworkConfigure
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static BMBaseNetworkConfigure *shareInstance;
    dispatch_once(&onceToken, ^{
        Class subclass = [[BMBaseNetworkConfigure getSubclasses] firstObject];
        shareInstance = [[subclass alloc] init];
    });
    return shareInstance;
}


//密钥，默认BMAPIParamsSign使用，可以抽离
- (NSString *)secrect
{
    return @"";
}

//默认BMAPIParamsSign使用，可以抽离
- (NSString *)clientUUID
{
    return @"";
}

//默认BMAPIParamsSign使用，可以抽离
- (NSString *)appVersion
{
    return @"1.0.0";
}

//appType,例如：iOSDemo,默认BMAPIParamsSign使用，可以抽离
- (NSString *)appType
{
    return @"iOSDemo";
}


//默认@"json",默认BMAPIParamsSign使用，可以抽离
- (NSString *)contentFormat
{
    return @"json";
}

//@"ios",默认BMAPIParamsSign使用，可以抽离
- (NSString *)clientPlatform
{
    return @"ios";
}



//网络日志等级,BMLoger使用，可以抽离
- (BMNetworkLogLevel)networkLogLevel
{
    return BMNetworkLogLevelRequest | BMNetworkLogLevelResponse;
}

#pragma mark - 私有方法（获取基类的子类）
+ (NSArray *)getSubclasses
{
    NSMutableArray *subclasses = [NSMutableArray array];
    int numClasses;
    Class *classes = NULL;
    numClasses = objc_getClassList(NULL,0);
    
    if (numClasses >0 )
    {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            if (class_getSuperclass(classes[i]) == [self class]){
                [subclasses addObject:classes[i]];
                NSLog(@"发现基础网络配置子类：%@", NSStringFromClass(classes[i]));
            }
        }  
        free(classes);  
    }
    return subclasses;
}

@end
