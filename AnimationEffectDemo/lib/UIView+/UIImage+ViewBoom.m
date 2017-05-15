//
//  UIImage+ViewBoom.m
//  JR_New_AnimationDemo
//
//  Created by ys on 2017/3/20.
//  Copyright © 2017年 ys. All rights reserved.
//

#import "UIImage+ViewBoom.h"
#import <objc/runtime.h>

@implementation UIImage (ViewBoom)

const char* aRGBBitmapContextName = "aRGBBitmapContext";

- (CGContextRef)aRGBBitmapContext
{
    return (__bridge CGContextRef)(objc_getAssociatedObject(self, aRGBBitmapContextName));
}

- (void)setARGBBitmapContext:(CGContextRef)newValue
{
    objc_setAssociatedObject(self, aRGBBitmapContextName, (__bridge id)(newValue),OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGContextRef)createARGBBitmapContextFromImage
{
    if (self.aRGBBitmapContext != nil) {
        return self.aRGBBitmapContext;
    }else{
        size_t pixelsWidth = CGImageGetWidth(self.CGImage);
        size_t pixelsHeitht = CGImageGetHeight(self.CGImage);
        size_t bitmapBytesPerRow = pixelsWidth * 4;
        size_t bitmapByteCount = bitmapBytesPerRow * pixelsHeitht;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        void* bitmapData = malloc(bitmapByteCount);
        CGContextRef context = CGBitmapContextCreate(bitmapData,pixelsWidth,pixelsHeitht,8,bitmapBytesPerRow,colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
        self.aRGBBitmapContext = context;
        //free(bitmapData);
        return context;
    }
}

- (UIColor*)getPixelColorAtLocation:(CGPoint)point
{
    CGImageRef inImage = self.CGImage;
    CGContextRef cgctx = [self createARGBBitmapContextFromImage];
    CGFloat w = (CGFloat)CGImageGetWidth(inImage);
    CGFloat h = (CGFloat)CGImageGetHeight(inImage);
    CGRect rect = CGRectMake(0, 0, w, h);
    CGContextDrawImage(cgctx, rect, inImage);
    UInt8* resData = CGBitmapContextGetData(cgctx);
    NSInteger pixelInfo = 4*((NSInteger)(w*round(point.y))+(NSInteger)round(point.x));
    
    CGFloat a = (CGFloat)resData[pixelInfo] / 255.0f;
    CGFloat r = (CGFloat)resData[pixelInfo+1] / 255.0f;
    CGFloat g = (CGFloat)resData[pixelInfo+2] / 255.0f;
    CGFloat b = (CGFloat)resData[pixelInfo+3] / 255.0f;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

- (UIImage*)scaleImageToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* res = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return res;
}

@end
