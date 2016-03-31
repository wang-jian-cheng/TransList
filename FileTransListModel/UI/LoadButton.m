//
//  LoadButton.m
//  FileTransListModel
//
//  Created by Wangjc on 16/3/22.
//  Copyright © 2016年 wangjc. All rights reserved.
//

#import "LoadButton.h"

@interface LoadButton ()
{
    double arcWidth;
    double pieCapacity;
}

@end


@implementation LoadButton

#define PI 3.14159265358979323846




- (instancetype)initWithFrame:(CGRect)frame arcWidth:(double)width current:(double)current total:(double)total
{
    self = [super initWithFrame:frame];
    if (self) {
        arcWidth=width;
        pieCapacity=360*current/total;
        NSLog(@"pieCapacity->>%f",pieCapacity);
    }
    return self;
}



static inline float radians(double degrees) {
    return degrees * PI / 180;
}





- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();//获得当前view的图形上下文(context)
    //设置填充颜色
    CGContextSetRGBFillColor(context, 207/255.0, 214/255.0, 221/255.0,1.0);
//    设置画笔颜色
        CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
//    设置画笔线条粗细
        CGContextSetLineWidth(context, 1);
    
    //扇形参数
    double radius; //半径
    if(self.frame.size.width>self.frame.size.height){
        radius=self.frame.size.height/2-self.frame.size.height/10;
    }else{
        radius=self.frame.size.width/2-self.frame.size.width/10;
    }
    int startX=self.frame.size.width/2;//圆心x坐标
    int startY=self.frame.size.height/2;//圆心y坐标
    double pieStart=270;//起始的角度
    int clockwise=1;//0=逆时针,1=顺时针
    
    //顺时针画扇形
    CGContextMoveToPoint(context, startX, startY);
    CGContextAddArc(context, startX, startY, radius, radians(pieStart), radians(pieStart+pieCapacity), clockwise);
    CGContextClosePath(context);
    //    CGContextDrawPath(context, kCGPathEOFillStroke);
    CGContextFillPath(context);
    
    clockwise=0;//0=逆时针,1=顺时针
    CGContextSetRGBStrokeColor(context, 255/255.0, 153/255.0, 0/255.0, 1);
    CGContextSetRGBFillColor(context, 52/255.0, 139/255.0, 249/255.0, 1);
    //逆时针画扇形
    CGContextMoveToPoint(context, startX, startY);
    CGContextAddArc(context, startX, startY, radius, radians(pieStart), radians(pieStart+pieCapacity), clockwise);
    CGContextClosePath(context);
    //    CGContextDrawPath(context, kCGPathEOFillStroke);
    CGContextFillPath(context);
    
    //    画圆
    CGContextBeginPath(context);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGRect circle = CGRectInset(self.bounds, arcWidth, arcWidth);
    CGContextAddEllipseInRect(context, circle);
    CGContextFillPath(context);
    
}

@end
