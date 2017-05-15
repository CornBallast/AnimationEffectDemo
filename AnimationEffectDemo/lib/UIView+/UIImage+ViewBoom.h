//
//  UIImage+ViewBoom.h
//  JR_New_AnimationDemo
//
//  Created by ys on 2017/3/20.
//  Copyright © 2017年 ys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ViewBoom)

- (UIColor*)getPixelColorAtLocation:(CGPoint)point;
- (UIImage*)scaleImageToSize:(CGSize)size;

@end
