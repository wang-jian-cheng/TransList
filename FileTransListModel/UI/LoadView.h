//
//  LoadView.h
//  FileTransListModel
//
//  Created by Wangjc on 16/3/23.
//  Copyright © 2016年 wangjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadView : UIView

@property(nonatomic)double pieCapacity;

- (instancetype)initWithFrame:(CGRect)frame arcWidth:(double)width current:(double)current total:(double)total;
@end
