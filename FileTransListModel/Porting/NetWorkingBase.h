//
//  NetWorking.h
//  FileTransListModel
//
//  Created by Wangjc on 16/3/23.
//  Copyright © 2016年 wangjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransInfoModel.h"
#import "TransInfoManager.h"

@interface NetWorkingBase : NSObject

- (void)setDelegateObject:(id)cbobject setSuccessBackFunctionName:(NSString *)selectorName;
- (void)setDelegateObject:(id)cbobject setFailBackFunctionName:(NSString *)selectorName;



-(void)UploadUrl:(NSString *)url andPrm:(NSDictionary *)prm andData:(NSData *)data;
-(void)UploadUrl:(NSString *)url andPrm:(NSDictionary *)prm andDataUrl:(NSString *)dataurl;
-(void)uploadVideoWithPath:(NSURL *)videoPath;
-(void)UploadImgWithImgdata:(NSString *)imageData andTransModel:(TransInfoModel *)transModel;
@end
