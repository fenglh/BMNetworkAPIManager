//
//  BMMineTypeFileModel.h
//  BMNetworking
//
//  Created by fenglh on 2017/2/17.
//  Copyright © 2017年 BlueMoon. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 指针指定为mineType类型的Conten-type（上传文件），需要指定该文件的mineType类型、文件名。所以
 */

static NSString * const kBMMineTypeFileModels = @"kBMMineTypeFileModels";

@interface BMMineTypeFileModel : NSObject
@property(nonatomic, strong) NSString *fileName;//包含后缀的文件名,例如:123.mp4、report.txt等等
@property(nonatomic, strong) NSString *mineType;//mineType类型，对照表参考：http://tool.oschina.net/commons
@property(nonatomic, strong) NSString *fileDataKey;//文件data key
@end
