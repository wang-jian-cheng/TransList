//
//  TestPageViewController.m
//  FileTransListModel
//
//  Created by Wangjc on 16/3/22.
//  Copyright © 2016年 wangjc. All rights reserved.
//

#import "TestPageViewController.h"
#import "TransListViewController.h"
#import "NetWorkingBase.h"
#import "TransInfoModel.h"
#import "TransInfoManager.h"
#import <Photos/Photos.h>

@interface TestPageViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation TestPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *uploadBtn = [[UIButton alloc] initWithFrame:CGRectMake(80, 100, 100, 50)];
    uploadBtn.backgroundColor = [UIColor redColor];
    [uploadBtn setTitle:@"上传视频" forState:UIControlStateNormal];
    [uploadBtn addTarget:self action:@selector(videoSelectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:uploadBtn];
    
    UIButton *uploadimgBtn = [[UIButton alloc] initWithFrame:CGRectMake(220, 100, 100, 50)];
    uploadimgBtn.backgroundColor = [UIColor blueColor];
    [uploadimgBtn setTitle:@"上传图片" forState:UIControlStateNormal];
    [uploadimgBtn addTarget:self action:@selector(imgSelectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:uploadimgBtn];
    
    
    UIButton *showListBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 50)];
    showListBtn.backgroundColor = [UIColor greenColor];
    [showListBtn setTitle:@"传输列表" forState:UIControlStateNormal];
    [showListBtn addTarget:self action:@selector(showListBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showListBtn];
    
    
    // Do any additional setup after loading the view.
}

-(void)imgSelectBtnClick:(UIButton *)sender
{
    UIImagePickerController *imgPickerCtl =[[UIImagePickerController alloc] init];
    imgPickerCtl.delegate = self;
//    NSArray *mediaTypes;
//    mediaTypes = @[(NSString *)kUTTypeMovie];
//    imgPickerCtl.mediaTypes = mediaTypes;
    [self presentViewController:imgPickerCtl animated:YES completion:^{
        
    }];

}

-(void)videoSelectBtnClick:(UIButton *)sender
{
    UIImagePickerController *imgPickerCtl =[[UIImagePickerController alloc] init];
    imgPickerCtl.delegate = self;
    NSArray *mediaTypes;
    mediaTypes = @[(NSString *)kUTTypeMovie];
    imgPickerCtl.mediaTypes = mediaTypes;
    [self presentViewController:imgPickerCtl animated:YES completion:^{
        
    }];
}


-(void)showListBtnClick:(UIButton *)sender
{
    TransListViewController *translistViewCtl = [[TransListViewController alloc] init];
    
    [self presentViewController:translistViewCtl animated:YES completion:^{
        
    }];
}

#define Url @"http://120.27.115.235/"

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    NSLog(@"%@",info);
    
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if([mediaType isEqualToString:@"public.movie"])
    {
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSURL *videoURL2 = [info objectForKey:UIImagePickerControllerReferenceURL];
        
        long long size =  [self fileSizeAtPath:[videoURL path]];
        NSLog(@"size = [%lld]",size) ;
        
//        AVAsset *avAsset = [AVAsset assetWithURL:videoURL];
        
//        AVAssetTrack *avtrack = [avAsset tracksWithMediaType:AVMediaTypeVideo];
//        NetWorkingBase *netWork = [[NetWorkingBase alloc] init];
//        [netWork setDelegateObject:self setSuccessBackFunctionName:@"TransSuccessCallBack:"];
//        
        TransInfoModel *transModel = [TransInfoModel TransInfoWithName:@"123" andAddress:@"" andTransType:TransTypeUpload andFileSize:[NSString stringWithFormat:@"%lld",size]];
        [TransInfoManager WriteModelToFile:transModel];
//
//        [netWork uploadVideoWithPath:videoURL];
//        
        

    }
    else if([mediaType isEqualToString:@"public.image"])
    {
        UIImage *photoImg = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *data = UIImagePNGRepresentation(photoImg);
        NSString *base64 = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        
        __block NSString* imageFileName;
        
        NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
        
//        
//        TransInfoModel *transModel = [TransInfoModel TransInfoWithName:@"123" andAddress:@"http:" andTransType:TransTypeUpload andFileSize:[NSString stringWithFormat:@"%lld",(long long)100]];
//        [TransInfoManager WriteModelToFile:transModel];
//        
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            ALAssetRepresentation *representation = [myasset defaultRepresentation];
            imageFileName = [representation filename];

            long long filesize = [representation size];
            
            NSLog(@"sizeimage = %lld",filesize);

            TransInfoModel *transModel = [TransInfoModel TransInfoWithName:imageFileName andAddress:@"http://" andTransType:TransTypeUpload andFileSize:[NSString stringWithFormat:@"%lld",(long long)filesize]];
            [TransInfoManager WriteModelToFile:transModel];
            
            
            NetWorkingBase *netWork = [[NetWorkingBase alloc] init];
            [netWork setDelegateObject:self setSuccessBackFunctionName:@"TransSuccessCallBack:"];
            [netWork UploadImgWithImgdata:base64 andTransModel:transModel];
            
        };
        
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        
        [assetslibrary assetForURL:imageURL
                       resultBlock:resultblock
                      failureBlock:nil];
        
    }
    else
    {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请您选择视频文件" preferredStyle:(UIAlertControllerStyleAlert)];
        
        [self presentViewController:alert animated:YES completion:^{
            
        }];
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alert addAction:action];
    }

}

- (long long) fileSizeAtPath:(NSString*) filePath{
    
    //
    //    NSData* data = [NSData dataWithContentsOfFile:[VoiceRecorderBaseVC getPathByFileName:_convertAmr ofType:@"amr"]];
    //    NSLog(@"amrlength = %d",data.length);
    //    NSString * amr = [NSString stringWithFormat:@"amrlength = %d",data.length];
    
    NSFileManager* manager = [[NSFileManager alloc] init];
    
    if ([manager fileExistsAtPath:filePath]){
    
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
    
}


-(void)TransSuccessCallBack:(id)dict
{
    DLog(@"%@",dict);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
