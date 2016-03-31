//
//  LoadButton.h
//  FileTransListModel
//
//  Created by Wangjc on 16/3/22.
//  Copyright © 2016年 wangjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadButton : UIButton
- (instancetype)initWithFrame:(CGRect)frame arcWidth:(double)width current:(double)current total:(double)total;
@end
