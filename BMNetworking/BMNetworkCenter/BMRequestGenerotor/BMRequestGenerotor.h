//
//  BMRequestGenerotor.h
//  BlueMoonBlueHouse
//
//  Created by 冯立海 on 15/9/26.
//  Copyright (c) 2015年 fenglh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMRequestGenerotor : NSObject
+ (instancetype)sharedInstance;
- (NSURLRequest *)generateGETRequestWithUrl:(NSString *)url requestParams:(NSDictionary *)params apiName:(NSString *)apiName;
- (NSURLRequest *)generatePOSTRequestWithUrl:(NSString *)url requestParams:(NSDictionary *)params apiName:(NSString *)apiName;
- (NSURLRequest *)generateJSONPOSTRequestWithUrl:(NSString *)url requestParams:(NSDictionary *)params apiName:(NSString *)apiName;

//使用multipartForm上传文件，文件参数传NSURL类型即可
- (NSURLRequest *)generateMultipartPOSTRequestWithUrl:(NSString *)url requestParams:(NSDictionary *)params apiName:(NSString *)apiName;
@end
