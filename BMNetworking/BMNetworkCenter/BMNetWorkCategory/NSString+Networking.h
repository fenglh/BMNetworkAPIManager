//
//  NSString+Networking.h
//  BMNetworking
//
//  Created by fenglh on 2017/1/20.
//  Copyright © 2017年 BlueMoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Networking)
/**
 Returns a lowercase NSString for md5 hash.
 */
- (nullable NSString *)md5String;

@end
