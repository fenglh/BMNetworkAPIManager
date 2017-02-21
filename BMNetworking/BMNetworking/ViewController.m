//
//  ViewController.m
//  BMNetworking
//
//  Created by fenglh on 2017/1/19.
//  Copyright © 2017年 BlueMoon. All rights reserved.
//

#import "ViewController.h"
#import "BMTestAPIManager.h"
#import "BMUploadPictureAPIManager.h"
#import "BMDownloadAPIManager.h"

@interface ViewController ()<BMAPIManagerCallBackDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) BMTestAPIManager *testAPIManager;
@property (nonatomic, assign) NSInteger testRequestId;

@property (nonatomic, strong) BMUploadPictureAPIManager *uploadPictureAPIManager;
@property (nonatomic, assign) NSInteger uploadPictureRequestId;

@property(nonatomic, strong) BMDownloadAPIManager *downloadAPIManager;
@property (nonatomic, assign) NSInteger downloadRequestId;

@property (nonatomic, strong) UILabel *progressLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addProgressLabel];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button  = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"下载视频" forState:UIControlStateNormal];
    button.frame = CGRectMake((self.view.frame.size.width-100)/2.0, 200, 100, 60);
    [self.view addSubview:button];
    [button addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button2  = [UIButton buttonWithType:UIButtonTypeSystem];
    [button2 setTitle:@"上传照片" forState:UIControlStateNormal];
    button2.frame = CGRectMake(80, 300, 80, 60);
    [self.view addSubview:button2];
    [button2 addTarget:self action:@selector(uploadPicture) forControlEvents:UIControlEventTouchUpInside];
    
    

}

- (void)addProgressLabel
{
    self.progressLabel = [[UILabel alloc] init];
    self.progressLabel.frame = CGRectMake(180, 300, 200, 60);
    [self.view addSubview:self.progressLabel];
}

- (void)uploadPicture
{
    //调用系统相册的类
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
    
    
    //设置选取的照片是否可编辑
    pickerController.allowsEditing = YES;
    //设置相册呈现的样式
    pickerController.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;//图片分组列表样式
    //照片的选取样式还有以下两种
    //UIImagePickerControllerSourceTypePhotoLibrary,直接全部呈现系统相册
    //UIImagePickerControllerSourceTypeCamera//调取摄像头
    
    //选择完成图片或者点击取消按钮都是通过代理来操作我们所需要的逻辑过程
    pickerController.delegate = self;
    //使用模态呈现相册
    [self.navigationController presentViewController:pickerController animated:YES completion:^{
        
    }];

}
- (void)btnClick
{
    NSLog(@"开始请求接口...");
    self.downloadRequestId = [self.downloadAPIManager downloadDataWithUrl:@"http://pubfile.bluemoon.com.cn//group1/M00/04/B2/wKgwB1ijGMCAIMjeABF7Hokao64425.mp4"];
}


#pragma mark - 系统delegate
//选择照片完成之后的代理方法

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{

    
    UIImage *resultImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    self.uploadPictureRequestId = [self.uploadPictureAPIManager loadDataWithParams:@{@"fileData":resultImage}];
    
    //使用模态返回到软件界面
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark - 接口

- (BMDownloadAPIManager *)downloadAPIManager
{
    if (_downloadAPIManager == nil) {
        _downloadAPIManager = [[BMDownloadAPIManager alloc] init];
        _downloadAPIManager.apiCallBackDelegate = self;
    }
    return _downloadAPIManager;
}

- (BMUploadPictureAPIManager *)uploadPictureAPIManager
{
    if (_uploadPictureAPIManager == nil) {
        _uploadPictureAPIManager = [[BMUploadPictureAPIManager alloc] init];
        _uploadPictureAPIManager.apiCallBackDelegate = self;
    }
    return _uploadPictureAPIManager;
}

- (BMTestAPIManager *)testAPIManager
{
    if (_testAPIManager == nil) {
        _testAPIManager = [[BMTestAPIManager alloc] init];
        _testAPIManager.apiCallBackDelegate = self;
    }
    return _testAPIManager;
}
- (void)managerCallApiProgress:(BMBaseAPIManager *)manager progress:(NSProgress *)progress
{
    if (manager.requestId == self.uploadPictureRequestId) {
        NSString *string = [NSString stringWithFormat:@"上传:%@",progress.localizedDescription];
        NSLog(@"%@",string);
        self.progressLabel.text = string;
    }else{
        NSString *string = [NSString stringWithFormat:@"下载:%@",progress.localizedDescription];
        NSLog(@"%@",string);
        self.progressLabel.text = string;
    }

    
}
- (void)managerCallApiDidSuccess:(BMBaseAPIManager *)manager
{
    if (self.uploadPictureRequestId == manager.requestId) {
        self.progressLabel.text = @"图片上传成功!";
    }else if(self.downloadRequestId == manager.requestId){
        self.progressLabel.text = @"视频下载成功!";
    }else{
        
    }
}

- (void)managerCallApiDidFailed:(BMBaseAPIManager *)manager
{
    if (self.uploadPictureRequestId == manager.requestId) {
        self.progressLabel.text = @"图片上传失败!";
    }else if(self.downloadRequestId == manager.requestId){
        self.progressLabel.text = @"视频下载失败!";
    }else{
        
    }
}
@end
