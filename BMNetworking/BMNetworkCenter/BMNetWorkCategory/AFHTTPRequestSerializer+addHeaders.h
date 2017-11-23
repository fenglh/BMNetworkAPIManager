//
//  AFHTTPRequestSerializer+addHeaders.h
//  BMNetworking
//
//  Created by fenglh on 2017/11/23.
//  Copyright © 2017年 BlueMoon. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface AFHTTPRequestSerializer (addHeaders)
- (void)addHeaders:(NSDictionary *)headers;

@end
