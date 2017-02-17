//
//  BMBaseNetworkConfigure.h
//  BMNetworking
//
//  Created by fenglh on 2017/1/20.
//  Copyright © 2017年 BlueMoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMBaseNetworkConfigureProtocol.h"



/*
 * 描述:抽离网络层的公共配置，每个app中的网络层公共配置都不同，所以将公共的配置(BMBaseNetworkConfigureProtocol)抽离到该类
 *
 * --------------------
 * 版本 :1.0.0
 * 描述：首版
 * 2017/01/20 fenglh
 */
#define networkConfigureInstance ([BMBaseNetworkConfigure shareInstance])

@interface BMBaseNetworkConfigure : NSObject<BMBaseNetworkConfigureProtocol>
+ (instancetype)shareInstance;

@end
