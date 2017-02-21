//
//  BMDownloadAPIManager.m
//  BMWash
//
//  Created by fenglh on 2017/2/20.
//  Copyright © 2017年 月亮小屋（中国）有限公司. All rights reserved.
//

#import "BMDownloadAPIManager.h"

@interface BMDownloadAPIManager ()
@property (nonatomic, strong) NSString *hostUrl;
@property (nonatomic, strong) NSString *path;
@end
@implementation BMDownloadAPIManager

- (NSString *)interfaceUrl
{
    return self.path;
}
- (BMAPIManagerRequestType)requestType
{
    return BMAPIManagerRequestTypeGet;
}

- (NSString *)baseUrl
{
    return self.hostUrl;
}
- (NSString *)testBaseUrl
{
    return self.hostUrl;
}

- (BOOL)manager:(BMBaseAPIManager *)manager isCorrectWithCallBackData:(NSDictionary *)data
{
    return YES;
}

- (NSInteger )downloadDataWithUrl:(NSString *)url
{

    NSURL *downloadUrl = [NSURL URLWithString:url];
    self.hostUrl = [NSString stringWithFormat:@"%@://%@",downloadUrl.scheme, downloadUrl.host];
    self.path = downloadUrl.path;
    return [self loadData];
}


@end
