//
//  Define.h
//  FileTransListModel
//
//  Created by Wangjc on 16/3/22.
//  Copyright © 2016年 wangjc. All rights reserved.
//

#ifndef Define_h
#define Define_h

#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#endif


#ifndef SCREEN_HEIGHT
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#endif

#define DLog(fmt,...)   NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define Err(fmt,...)    NSLog((@"%s [Line %d] ERROR: " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define remove_sp(a) [[NSUserDefaults standardUserDefaults] removeObjectForKey:a]
#define get_sp(a) [[NSUserDefaults standardUserDefaults] objectForKey:a]
#define get_Dsp(a) [[NSUserDefaults standardUserDefaults]dictionaryForKey:a]
#define set_sp(a,b) [[NSUserDefaults standardUserDefaults] setObject:b forKey:a]
#define sp [NSUserDefaults standardUserDefaults]


#define TransInfoKey    @"wangjc-TransInfo"

#define TRANS_ID_HEAD   @"WANGJC-"


#endif /* Define_h */
