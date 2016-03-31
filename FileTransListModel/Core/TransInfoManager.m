//
//  TransInfoManager.m
//  FileTransListModel
//
//  Created by Wangjc on 16/3/24.
//  Copyright © 2016年 wangjc. All rights reserved.
//

#import "TransInfoManager.h"

/**
 *  在文件中维护两个key :TRANS_ID_POOL 和  TransInfoKey  根据transid池中的id到transinfo中提取info
 */


@implementation TransInfoManager

+(BOOL)WriteModelToFile:(TransInfoModel *)model
{
    @synchronized(self) {//互斥锁
        
        NSMutableDictionary *transInfo = [[NSMutableDictionary alloc] initWithDictionary:[TransInfoManager readAllTransInfos]];
        [transInfo setValue:model forKey:model.transId];
        [TransInfoManager setTransInfo:transInfo];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TRANS_INFO_MANAGER_WRITE_NOTICE object:nil userInfo:[NSDictionary dictionaryWithObject:model.transId forKey:TRANS_ID_NOTICEKEY]];
        
        
    }
    return YES;
}


+(TransInfoModel *)getTransInfo:(NSString *)transId
{
    if (transId == nil) {
        return nil;
    }
    
    @try {
        
        NSDictionary *tempDict = [TransInfoManager readAllTransInfos];
        return tempDict[transId];
        
//        return [NSKeyedUnarchiver unarchiveObjectWithData:transData];
        
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
        
    }
}


#pragma mark - 文件操作层 
//直接操作文件，单独作为一层接口，保证上层接口不动，可替换本层api内部实现从而替换掉传输信息文件的保存方式
//调试阶段可放在userdefault中 如实际应用必须新建文件，以防频繁操作 userdefault 影响其他模块使用userdefault


+(NSDictionary *)readAllTransInfos
{
    
    NSData *tempData = get_sp(TransInfoKey);
    /*之前将存放model的字典转成nsdata 返回时再转回 字典*/
    return [NSKeyedUnarchiver unarchiveObjectWithData:tempData];
}

+(NSArray *)getTransIdPoolWithType:(NSString *)transPoolType
{
    return get_sp(transPoolType);
}

+(void)setTransInfo:(NSDictionary *)transInfo
{
     /*字典中 包含的 model 是自定义对象 要先将其转为nsdata才能写入userdefault*/
    NSData *tempData = [NSKeyedArchiver archivedDataWithRootObject:transInfo];
    
    set_sp(TransInfoKey, tempData);
}
@end
