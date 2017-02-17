//
//  BMUploadPictureAPIManager.m
//  BMNetworking
//
//  Created by fenglh on 2017/2/16.
//  Copyright © 2017年 BlueMoon. All rights reserved.
//

#import "BMUploadPictureAPIManager.h"
#import <UIKit/UIKit.h>
#import "NSString+Networking.h"

@implementation BMUploadPictureAPIManager

- (NSString *)interfaceUrl
{
    return @"washMall/user/uploadIcon";
}

- (BOOL)useToken
{
    return YES;
}



- (NSDictionary *)reformParams:(NSDictionary *)params
{
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    
    UIImage *image = [mutableParams objectForKey:@"fileData"] ;
    
    //原图大小
    NSData *orignData = UIImageJPEGRepresentation(image, 1);
    //base64大小
    NSString *base64 = [orignData base64EncodedStringWithOptions:0];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.png",[base64 md5String]];//以前是用时间戳,现在改成用md5，可以确保一个图片跟名字一一对应.便于做缓存
    [mutableParams setObject:fileName forKey:@"fileName"];
    [mutableParams setObject:base64 forKey:@"fileData"];


    return mutableParams;
}

@end
