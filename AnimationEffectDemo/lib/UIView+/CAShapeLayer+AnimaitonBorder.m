//
//  CAShapeLayer+AnimaitonBorder.m
//  AnimationEffectDemo
//
//  Created by ys on 2017/5/15.
//  Copyright © 2017年 ys. All rights reserved.
//

#import "CAShapeLayer+AnimaitonBorder.h"

@implementation CAShapeLayer (AnimaitonBorder)

+(CAShapeLayer*)animationBorderLayerWithRect:(CGRect)rect{
    CAShapeLayer* dashLineShapeLayer = [CAShapeLayer layer];
    //创建贝塞尔曲线
    UIBezierPath* dashLinePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:20];
    
    dashLineShapeLayer.path = dashLinePath.CGPath;
    dashLineShapeLayer.fillColor = [UIColor clearColor].CGColor;
    dashLineShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    dashLineShapeLayer.lineWidth = 3;
    dashLineShapeLayer.lineDashPattern = @[@(6),@(6)];
    dashLineShapeLayer.strokeStart = 0;
    dashLineShapeLayer.strokeEnd = 1;
    dashLineShapeLayer.zPosition = 999;
    //
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGFloat _add = 3;
            dashLineShapeLayer.lineDashPhase -= _add;
        });
    }];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    //
    return dashLineShapeLayer;
}

@end
