//
//  UIView+ViewBoom.h
//  JR_New_AnimationDemo
//
//  Created by ys on 2017/3/20.
//  Copyright © 2017年 ys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ViewBoom)

- (void)boom;
- (void)boomClear;//清除boom数据
- (void)boomResetSelf; //恢复自己的显示

- (void)bubbleBoom;

@end
