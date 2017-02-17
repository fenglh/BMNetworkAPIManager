//
//  BMAPIParamsSign.h
//  BMNetworking
//
//  Created by fenglh on 2017/2/14.
//  Copyright © 2017年 BlueMoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMAPIParamsSign : NSObject

/**
 * 生成已签名的url查询字符串，业务参数参与签名
 *
 */
+ (NSString *)generateSignaturedUrlQueryStringWithBusinessParam:(NSDictionary *)businessParam signBusinessParam:(BOOL)signBusinessParam;

@end
