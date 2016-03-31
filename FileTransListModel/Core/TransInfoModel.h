//
//  TransInfoModel.h
//  FileTransListModel
//
//  Created by Wangjc on 16/3/23.
//  Copyright © 2016年 wangjc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TransStatusUnStart  @"unStart"
#define TransStatusOnGoing  @"onGoing"
#define TransStatusFinish   @"finish"
#define TransStatusFailed   @"failed"


#define TransTypeUpload     @"Upload"
#define TransTypeDownload   @"Download"

#define TRANS_ID_POOL           @"trans_id_pool"
#define TRANS_ID_UPLOAD_POOL   [NSString stringWithFormat:@"%@-%@",TRANS_ID_POOL,TransTypeUpload]
#define TRANS_ID_DOWNLOAD_POOL  [NSString stringWithFormat:@"%@-%@",TRANS_ID_POOL,TransTypeDownload]

@interface TransInfoModel : NSObject
@property(nonatomic) NSString *transId;//传输任务唯一标示
@property(nonatomic) NSString *fileName;
@property(nonatomic) NSString *transStatus;
@property(nonatomic) NSString *transBytes;//已传完
@property(nonatomic) NSString *allBytes;//全部
@property(nonatomic) NSString *address;
@property(nonatomic) NSString *transType;

/**
 * 新建传输model
 * @param name 文件名
 * @param addr 上传/下载地址 
 * @param transType 上传或下载：TransTypeUpload   TransTypeDownload
 * @param size 传输的总文件大小
 */

+(instancetype)TransInfoWithName:(NSString *)name andAddress:(NSString *)addr andTransType:(NSString *)transType andFileSize:(NSString *)size;

/**
 * 新建传输model
 * @param name 文件名
 * @param addr 上传/下载地址
 * @param transType 上传或下载：TransTypeUpload   TransTypeDownload
 * @param size 传输的总文件大小
 */
-(instancetype)initWithName:(NSString *)name andAddress:(NSString *)addr andTransType:(NSString *)transType andFileSize:(NSString *)size
;
@end
