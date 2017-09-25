//
//  BMBaseAPIManager+BMBlock.m
//  BMOnlineManagement
//
//  Created by ___liangdahong on 2017/9/25.
//  Copyright © 2017年 月亮小屋（中国）有限公司. All rights reserved.
//

#import "BMBaseAPIManager+BMBlock.h"
#import <objc/runtime.h>

@interface BMBaseAPIManager () <BMAPIManagerCallBackDelegate>

@property (copy, nonatomic) BMSuccessBlock successBlock;
@property (copy, nonatomic) BMFailureBlock failureBlock;

@end

@implementation BMBaseAPIManager (BMBlock)

#pragma mark - Public Method

- (NSInteger)bm_loadDataWithSuccessBlock:(BMSuccessBlock)successBlock
                            failureBlock:(BMFailureBlock)failureBlock {
    self.apiCallBackDelegate = self;
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    return [self loadData];
}

- (NSInteger)bm_loadDataWithParams:(NSDictionary *)params
                      successBlock:(BMSuccessBlock)successBlock
                      failureBlock:(BMFailureBlock)failureBlock {
    self.apiCallBackDelegate = self;
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    return [self loadDataWithParams:params];
}

- (NSInteger)bm_loadNextPageWithSuccessBlock:(BMSuccessBlock)successBlock
                                failureBlock:(BMFailureBlock)failureBlock {
    self.apiCallBackDelegate = self;
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    return [self loadNextPage];
}

#pragma mark - Custom Delegate

- (void)managerCallApiDidSuccess:(BMBaseAPIManager *)manager {
    if (self.successBlock) {
        self.successBlock(manager, [manager fetchDataWithReformer:nil]);
    }
}

- (void)managerCallApiDidFailed:(BMBaseAPIManager *)manager {
    if (self.failureBlock) {
        self.failureBlock(manager);
    }
}

#pragma mark - Getters Setters

- (void)setSuccessBlock:(BMSuccessBlock)successBlock {
    objc_setAssociatedObject(self, _cmd, successBlock, OBJC_ASSOCIATION_COPY);
}

- (BMSuccessBlock)successBlock {
    return objc_getAssociatedObject(self, @selector(setSuccessBlock:));
}

- (void)setFailureBlock:(BMFailureBlock)failureBlock {
    objc_setAssociatedObject(self, _cmd, failureBlock, OBJC_ASSOCIATION_COPY);
}

- (BMFailureBlock)failureBlock {
    return objc_getAssociatedObject(self, @selector(setFailureBlock:));
}

@end
