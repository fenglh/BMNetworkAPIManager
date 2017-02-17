//
//  BMCachedObject.h
//  BlueMoonBlueHouse
//
//  Created by fenglh on 15/9/25.
//  Copyright (c) 2015年 fenglh. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 缓存对象
 */
@interface BMCachedObject : NSObject
@property (nonatomic, copy, readonly) NSData *content;
@property (nonatomic, copy, readonly) NSDate *lastUpdateTime;

@property (nonatomic, assign, readonly) BOOL isOutDated;
@property (nonatomic, assign, readonly) BOOL isEmpty;

- (instancetype)initWithContent:(NSData *)conten;
- (void)updateContent:(NSData *)content;

@end
