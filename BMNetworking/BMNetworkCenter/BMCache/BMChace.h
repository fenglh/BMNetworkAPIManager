//
//  BMChace.h
//  BlueMoonBlueHouse
//
//  Created by fenglh on 15/9/25.
//  Copyright (c) 2015年 fenglh. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 缓存管理
 */
@interface BMChace : NSObject

+ (instancetype)shareInstance;

/*
 *
 */
-(NSString *)keyWithUrl:(NSString *)url
                              apiName:(NSString *)apiName
                           requestParams:(NSDictionary *)requestParams;

- (NSData *)fetchCachedDataWithUrl:(NSString *)url
                                      apiName:(NSString *)apiName
                                   requestParams:(NSDictionary *)requestParams;

- (void)saveCacheWithData:(NSData *)cachedData
        Url:(NSString *)url
               apiName:(NSString *)mehtodName
            requestParams:(NSDictionary *)requestParams;

- (void)deleteCacheWithUrl:(NSString *)url
                              apiName:(NSString *)apiName
                           requestParams:(NSDictionary *)requestParams;

- (NSData *)fetchcachedDatawithKey:(NSString *)key;
- (void)saveCacheWithData:(NSData *)cachedData key:(NSString *)key;
- (void)deleteCacheWithKey:(NSString *)key;
- (void)clean;

//@property (nonatomic, assign, readonly) NSUInteger cacheSizeB; //缓存大小

@end
