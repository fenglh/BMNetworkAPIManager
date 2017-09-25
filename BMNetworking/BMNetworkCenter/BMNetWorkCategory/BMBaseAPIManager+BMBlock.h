//
//  BMBaseAPIManager+BMBlock.h
//  BMOnlineManagement
//
//  Created by ___liangdahong on 2017/9/25.
//  Copyright © 2017年 月亮小屋（中国）有限公司. All rights reserved.
//

#import "BMBaseAPIManager.h"

typedef void(^BMSuccessBlock)(__kindof BMBaseAPIManager *manager, id data);
typedef void(^BMFailureBlock)(__kindof BMBaseAPIManager *manager);

@interface BMBaseAPIManager (BMBlock)

- (NSInteger)bm_loadDataWithSuccessBlock:(BMSuccessBlock)successBlock
                            failureBlock:(BMFailureBlock)failureBlock;

- (NSInteger)bm_loadDataWithParams:(NSDictionary *)params
                      successBlock:(BMSuccessBlock)successBlock
                      failureBlock:(BMFailureBlock)failureBlock;

- (NSInteger)bm_loadNextPageWithSuccessBlock:(BMSuccessBlock)successBlock
                                failureBlock:(BMFailureBlock)failureBlock;

@end
