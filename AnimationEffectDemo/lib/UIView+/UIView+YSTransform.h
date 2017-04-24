//
//  UIView+YSTransform.h
//  JR_New_AnimationDemo
//
//  Created by ys on 2017/3/20.
//  Copyright © 2017年 ys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (YSTransform)<CAAnimationDelegate>

-(void)YSTransform_circleColor_toColor:(UIColor*)toColor Duration:(CGFloat)duration StartPoint:(CGPoint)startPoint;

-(void)YSTransform_circleImage_toImage:(UIImage*)toImage Duration:(CGFloat)duration StartPoint:(CGPoint)startPoint;

-(void)YSTransForm_beginZoom_max:(CGFloat)max min:(CGFloat)min;
-(void)YSTransForm_StopZoom;
@end
