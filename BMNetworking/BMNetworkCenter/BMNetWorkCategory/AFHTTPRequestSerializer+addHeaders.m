//
//  AFHTTPRequestSerializer+addHeaders.m
//  BMNetworking
//
//  Created by fenglh on 2017/11/23.
//  Copyright © 2017年 BlueMoon. All rights reserved.
//

#import "AFHTTPRequestSerializer+addHeaders.h"

@implementation AFHTTPRequestSerializer (addHeaders)



- (void)addHeaders:(NSDictionary *)headers {
    if (headers == nil) {
        return;
    }
    NSArray *allKeys = [headers allKeys];
    for (NSString *key in allKeys) {
        [self setValue:[headers valueForKey:key] forHTTPHeaderField:key];
    }
}


@end
