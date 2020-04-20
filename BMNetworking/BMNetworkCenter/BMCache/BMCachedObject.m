//
//  BMCachedObject.m
//  BlueMoonBlueHouse
//
//  Created by fenglh on 15/9/25.
//  Copyright (c) 2015年 fenglh. All rights reserved.
//

#import "BMCachedObject.h"
#import "BMBaseNetworkConfigure.h"

@interface BMCachedObject ()

@property (nonatomic, copy, readwrite) NSData *content;
@property (nonatomic, copy, readwrite) NSDate *lastUpdateTime;

@end

@implementation BMCachedObject

#pragma mark - getters and setters
-(BOOL)isEmpty
{
    return self.content == nil;
}

- (BOOL)isOutDated
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastUpdateTime];
    return timeInterval > [networkConfigureInstance respondsToSelector:@selector(cacheTimeOutSeconds)] ? [networkConfigureInstance cacheTimeOutSeconds] :300;
}


- (void)setContent:(NSData *)content
{
    _content = [content copy];
    self.lastUpdateTime = [NSDate dateWithTimeIntervalSinceNow:0];
}

#pragma mark - 生命周期
- (instancetype)initWithContent:(NSData *)conten
{
    self = [super init];
    if (self) {
        self.content = conten;
    }
    return self;
}

#pragma mark - 公共方法
- (void)updateContent:(NSData *)content
{
    self.content = content;
}
@end
