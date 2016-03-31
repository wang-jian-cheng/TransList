//
//  NetWorking.m
//  FileTransListModel
//
//  Created by Wangjc on 16/3/23.
//  Copyright © 2016年 wangjc. All rights reserved.
//

#import "NetWorkingBase.h"
#import "Define.h"
#import "AFHTTPSessionManager.h"
//#import "AFHTTPRequestOperationManager.h"
#import "AFURLRequestSerialization.h"

@interface NetWorkingBase ()
{
    id CallBackObject;
    NSString * successCallBackFunctionName;
    NSString * failCallBackFunctionName;
}

@end

@implementation NetWorkingBase


- (void)setDelegateObject:(id)cbobject setSuccessBackFunctionName:(NSString *)selectorName
{
    CallBackObject = cbobject;
    
    successCallBackFunctionName = selectorName;
}

- (void)setDelegateObject:(id)cbobject setFailBackFunctionName:(NSString *)selectorName
{
    CallBackObject = cbobject;
    failCallBackFunctionName = selectorName;
}



-(void)UploadUrl:(NSString *)url andPrm:(NSDictionary *)prm andData:(NSData *)data
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    [manager POST:url parameters:prm constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:data name:@"file" fileName:@"video.mov" mimeType:@"video/mov"];
        
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {

        NSLog(@"%lf",1.0 *uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Post success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"%@",error);  //这里打印错误信息
    }];
    
}

-(void)UploadUrl:(NSString *)url andPrm:(NSDictionary *)prm andDataUrl:(NSURL *)dataurl
{
    //1.创建管理者对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //2.上传文件
    [manager POST:url parameters:prm constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileURL:dataurl name:@"file" fileName:@"video.mov" mimeType:@"application/octet-stream" error:nil];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        //打印下上传进度
        NSLog(@"%lf",1.0 *uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //请求成功
        NSLog(@"请求成功：%@",responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //请求失败
        NSLog(@"请求失败：%@",error);
    }];
}

#define Url @"http://120.27.115.235/"

-(void)uploadVideoWithPath:(NSURL *)videoPath
{
    if (videoPath) {
        NSString *url = [NSString stringWithFormat:@"%@Hewuzhe.asmx/UpLoadVideo",Url];
        NSData* imageData = [[NSData alloc] initWithContentsOfURL:videoPath];
        NSString *imagebase64= [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        
        NSDictionary *prm = @{@"fileName":@"video.mov",@"filestream":imagebase64};
        
        DLog(@"Start trans");
        [self postRequst:url andPrm:prm];
        //        [self uploadVideoWithFilePath:videoPath andurl:url andprm:prm];
    }else{
   
    }
}


-(void)UploadImgWithImgdata:(NSString *)imageData andTransModel:(TransInfoModel *)transModel
{
    if (imageData && transModel) {
        NSString * url=[NSString stringWithFormat:@"%@Helianmeng.asmx/UpLoadImage",Url];
        NSDictionary * prm=@{@"fileName":@"imgsrc.jpg",@"filestream":imageData};
        [self postRequst:url andPrm:prm andTransModel:transModel];
    }
    
}


-(void)postRequst:(NSString *)url andPrm:(NSDictionary *)prm andTransModel:(TransInfoModel *)transModel
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    manager.requestSerializer.timeoutInterval = 20;
    [manager POST:url parameters:prm progress:^(NSProgress * _Nonnull uploadProgress) {
        
        int64_t transBytes;
        int64_t allBytes;
        
        if ([[[UIDevice currentDevice] systemVersion]floatValue] < 8.0 && [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            NSURLSessionTask *tempSession = (NSURLSessionTask *)uploadProgress;
            transBytes = tempSession.countOfBytesSent;
            allBytes = tempSession.countOfBytesExpectedToSend;
            DLog(@"%lf",1.0 *tempSession.countOfBytesSent / tempSession.countOfBytesExpectedToSend);
        }
        else if([[[UIDevice currentDevice] systemVersion]floatValue] >= 8.0)
        {
            transBytes = uploadProgress.completedUnitCount;
            allBytes = uploadProgress.totalUnitCount;
            DLog(@"%lf",1.0 *uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        }
        
        
    
        
        transModel.transBytes = [NSString stringWithFormat:@"%lld",transBytes];
        transModel.allBytes = [NSString stringWithFormat:@"%lld",allBytes];
        [TransInfoManager WriteModelToFile:transModel];
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        NSString *str=[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSData * data =[str dataUsingEncoding:NSUTF8StringEncoding];
        id dict =[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        SEL func_selector = NSSelectorFromString(successCallBackFunctionName);
        if ([CallBackObject respondsToSelector:func_selector]) {
            NSLog(@"回调成功...");
            [CallBackObject performSelector:func_selector withObject:dict];
        }else{
            NSLog(@"回调失败...");
        }
        
        
        transModel.transStatus = TransStatusFinish;
        [TransInfoManager WriteModelToFile:transModel];
        
        
        NSLog(@"Post success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);  //这里打印错误信息
        
        SEL func_selector = NSSelectorFromString(successCallBackFunctionName);
        if ([CallBackObject respondsToSelector:func_selector]) {
            NSLog(@"回调成功...");
            [CallBackObject performSelector:func_selector withObject:error];
        }else{
            NSLog(@"回调失败...");
        }
        
    }];
}



-(void)postRequst:(NSString *)url andPrm:(NSDictionary *)prm
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manage.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/plain"]
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    manager.requestSerializer.timeoutInterval = 20;
    [manager POST:url parameters:prm progress:^(NSProgress * _Nonnull uploadProgress) {
//        NSLog(@"progress");
        
        
        
        if ([[[UIDevice currentDevice] systemVersion]floatValue] < 8.0 && [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            NSURLSessionTask *tempSession = (NSURLSessionTask *)uploadProgress;
            
            DLog(@"%lf",1.0 *tempSession.countOfBytesSent / tempSession.countOfBytesExpectedToSend);
        }
        else if([[[UIDevice currentDevice] systemVersion]floatValue] >= 8.0)
        {
            DLog(@"%lf",1.0 *uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        }
        
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        NSString *str=[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSData * data =[str dataUsingEncoding:NSUTF8StringEncoding];
        id dict =[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        SEL func_selector = NSSelectorFromString(successCallBackFunctionName);
        if ([CallBackObject respondsToSelector:func_selector]) {
            NSLog(@"回调成功...");
            [CallBackObject performSelector:func_selector withObject:dict];
        }else{
            NSLog(@"回调失败...");
        }
        
        NSLog(@"Post success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"%@",error);  //这里打印错误信息
        
        SEL func_selector = NSSelectorFromString(successCallBackFunctionName);
        if ([CallBackObject respondsToSelector:func_selector]) {
            NSLog(@"回调成功...");
            [CallBackObject performSelector:func_selector withObject:error];
        }else{
            NSLog(@"回调失败...");
        }
        
    }];
}


-(void)getRequst:(NSString *)url andPrm:(NSDictionary *)prm
{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    }
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             NSLog(@"get success");
             
         }
     
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
             
             NSLog(@"%@",error);  //这里打印错误信息
             
         }];
}

@end
