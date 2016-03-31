//
//  TransInfoManager.h
//  FileTransListModel
//
//  Created by Wangjc on 16/3/24.
//  Copyright © 2016年 wangjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransInfoModel.h"


#define TRANS_INFO_MANAGER_WRITE_NOTICE     @"TransInfoManagerWrite"
#define TRANS_ID_NOTICEKEY                  @"TransIDNoticeKey"
@interface TransInfoManager : NSObject

/**
 *  写入transinfo 到文件 以及更新
 */
+(BOOL)WriteModelToFile:(TransInfoModel *)model;

/**
 *  读取对应id的transinfo
 */
+(TransInfoModel *)getTransInfo:(NSString *)transId;


/**
 * 获取上传／下载 trans id
 * @param transPoolType :  TRANS_ID_UPLOAD_POOL   TRANS_ID_DOWNLOAD_POOL
 */
+(NSArray *)getTransIdPoolWithType:(NSString *)transPoolType;

/**
 * 获取全部传输信息
 */
+(NSDictionary *)readAllTransInfos;
@end
