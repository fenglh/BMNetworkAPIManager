//
//  BMDownloadAPIManager.h
//  BMWash
//
//  Created by fenglh on 2017/2/20.
//  Copyright © 2017年 月亮小屋（中国）有限公司. All rights reserved.
//

#import <BMBaseAPIManager.h>

@interface BMDownloadAPIManager : BMBaseAPIManager
/**
 * 描述：文件下载
 * 参数：url 完整的url地址,例如：http://abc.com/abc/file.txt
 */
- (NSInteger )downloadDataWithUrl:(NSString *)url;
@end
