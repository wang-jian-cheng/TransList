//
//  TransInfoModel.m
//  FileTransListModel
//
//  Created by Wangjc on 16/3/23.
//  Copyright © 2016年 wangjc. All rights reserved.
//

#import "TransInfoModel.h"


@implementation TransInfoModel

+(instancetype)TransInfoWithName:(NSString *)name andAddress:(NSString *)addr andTransType:(NSString *)transType andFileSize:(NSString *)size
{
    return [[self alloc] initWithName:name andAddress:addr andTransType:transType andFileSize:size];
}

-(instancetype)initWithName:(NSString *)name andAddress:(NSString *)addr andTransType:(NSString *)transType andFileSize:(NSString *)size
{
    self = [super init];
    
    if (self) {
        self.transId = [self getTransIdWithType:transType];
        self.fileName = name;
        self.transStatus = TransStatusUnStart;
        self.transBytes = @"0";
        self.allBytes = size;
        self.address = addr;
        self.transType = transType;
    }
    
    return self;
}


#define CODER_KEY_TransId       @"transId"
#define CODER_KEY_FileName      @"fileName"
#define CODER_KEY_TransStatus   @"transStatus"
#define CODER_KEY_TransBytes    @"transBytes"
#define CODER_KEY_AllBytes      @"allBytes"
#define CODER_KEY_Address       @"address"
#define CODER_KEY_TransType     @"transType"

/*
 * 自定义的对象 无法直接写入到userdefault中 需要转化为 nsdata 这时需要实现下面两个方法
 */
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.transId forKey:CODER_KEY_TransId];
    [coder encodeObject:self.fileName forKey:CODER_KEY_FileName];
    [coder encodeObject:self.transStatus forKey:CODER_KEY_TransStatus];
    [coder encodeObject:self.transBytes forKey:CODER_KEY_TransBytes];
    [coder encodeObject:self.allBytes forKey:CODER_KEY_AllBytes];
    [coder encodeObject:self.address forKey:CODER_KEY_Address];
    [coder encodeObject:self.transType forKey:CODER_KEY_TransType];
    
}


-(instancetype)initWithCoder:(NSCoder *)coder
{
    self.transId = [[coder decodeObjectForKey:CODER_KEY_TransId] copy];
    self.fileName = [[coder decodeObjectForKey:CODER_KEY_FileName] copy];
    self.transStatus = [[coder decodeObjectForKey:CODER_KEY_TransStatus] copy];
    self.transBytes = [[coder decodeObjectForKey:CODER_KEY_TransBytes] copy];
    self.allBytes = [[coder decodeObjectForKey:CODER_KEY_AllBytes] copy];
    self.address = [[coder decodeObjectForKey:CODER_KEY_Address] copy];
    self.transType = [[coder decodeObjectForKey:CODER_KEY_TransType] copy];
    

    return self;
}


-(NSString *)getTransIdWithType:(NSString *)transtype
{
    NSString *transID = [NSString stringWithFormat:@"%@%f",TRANS_ID_HEAD,[NSDate timeIntervalSinceReferenceDate]];
    [self saveTransidInPool:transID andTransType:transtype];
    return transID;
}

-(BOOL)saveTransidInPool:(NSString *)transId andTransType:(NSString *)transType
{
    NSMutableArray *tempArr = [NSMutableArray array];
    @try {
        
        NSString *transIdKey = [NSString stringWithFormat:@"%@-%@",TRANS_ID_POOL,transType];
        
        if(get_sp(transIdKey) == nil)
        {
            [tempArr addObject:transId];
        }
        else
        {
            [tempArr addObjectsFromArray:get_sp(transIdKey)];
            
            for (NSString *tempStr in tempArr) {
                if ([tempStr isEqualToString:transId]) {
                    return NO;
                }
            }
            
            [tempArr addObject:transId];
        }
        
        set_sp(transIdKey, tempArr);
        
        return YES;
        
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally {
        
    }
    
}

@end
