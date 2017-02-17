//
//  BMChace.m
//  BlueMoonBlueHouse
//
//  Created by fenglh on 15/9/25.
//  Copyright (c) 2015年 fenglh. All rights reserved.
//

#import "BMChace.h"
#import "BMCachedObject.h"
#import "NSDictionary+AXNetworkingMethods.h"
#import "NSString+Networking.h"
#import "BMBaseNetworkConfigure.h"

@interface BMChace ()

@property(strong, nonatomic)NSCache *cache;
//@property (nonatomic, assign, readwrite) NSUInteger cacheSizeB; //缓存大小
@end

@implementation BMChace

#pragma  setter and getters
- (NSCache *)cache
{
    if (_cache == nil) {
        _cache = [[NSCache alloc] init];
        _cache.countLimit = [networkConfigureInstance cacheCountLimit];
    }
    return _cache;
}



#pragma mark - 生命周期
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static BMChace *shareInstance;
    dispatch_once(&onceToken, ^{
        shareInstance = [[BMChace alloc] init];
    });
    return shareInstance;
}

#pragma mark - 公共方法

- (NSString *)keyWithUrl:(NSString *)url apiName:(NSString *)apiName requestParams:(NSDictionary *)requestParams
{
    NSString *keyString = [NSString stringWithFormat:@"%@%@%@", url, apiName,[requestParams AIF_urlParamsStringSignature:NO]];
    return [keyString md5String];
}

- (NSData *)fetchCachedDataWithUrl:(NSString *)url apiName:(NSString *)apiName requestParams:(NSDictionary *)requestParams
{
    return [self fetchcachedDatawithKey:[self keyWithUrl:url apiName:apiName requestParams:requestParams]];
}

- (void)saveCacheWithData:(NSData *)cachedData Url:(NSString *)url apiName:(NSString *)mehtodName requestParams:(NSDictionary *)requestParams
{
    [self saveCacheWithData:cachedData key:[self keyWithUrl:url apiName:mehtodName requestParams:requestParams]];
}

- (void)deleteCacheWithUrl:(NSString *)url apiName:(NSString *)apiName requestParams:(NSDictionary *)requestParams
{
    [self deleteCacheWithKey:[self keyWithUrl:url apiName:apiName requestParams:requestParams]];
}

- (NSData *)fetchcachedDatawithKey:(NSString *)key
{
    BMCachedObject *cachedObject = [self.cache objectForKey:key];
    if (cachedObject.isOutDated || cachedObject.isEmpty) {
        return nil;
    }else{
        return  cachedObject.content;
    }
}

- (void)saveCacheWithData:(NSData *)cachedData key:(NSString *)key
{
    BMCachedObject *cachedObject = [self.cache objectForKey:key];
    if (cachedObject == nil) {//在缓存中还没有相同key的缓存
        cachedObject = [[BMCachedObject alloc] init];
    }
    [cachedObject updateContent:cachedData];
    [self.cache setObject:cachedObject forKey:key];
}

- (void)deleteCacheWithKey:(NSString *)key
{
    [self.cache removeObjectForKey:key];
}

- (void)clean
{
    [self.cache removeAllObjects];
}




@end
