//
//  NSString+Networking.m
//  BMNetworking
//
//  Created by fenglh on 2017/1/20.
//  Copyright © 2017年 BlueMoon. All rights reserved.
//

#import "NSString+Networking.h"
#import "NSData+Networking.h"
#include <CommonCrypto/CommonCrypto.h>

@implementation NSString (Networking)

- (NSString *)md5String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5String];
}



@end
