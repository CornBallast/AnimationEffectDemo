//
//  UIView+ViewBoom.m
//  JR_New_AnimationDemo
//
//  Created by ys on 2017/3/20.
//  Copyright © 2017年 ys. All rights reserved.
//

#import "UIView+ViewBoom.h"
#import <objc/runtime.h>
#import "UIImage+ViewBoom.h"

@implementation UIView (ViewBoom)

const char* BoomCellsName = "XXYBoomCells";
const char* ScaleSnapshotName = "XXYBoomScaleSnapshot";

- (NSArray<CALayer*>*)boomCells
{
    return objc_getAssociatedObject(self, BoomCellsName);
}

- (void)setBoomCells:(NSArray<CALayer*>*)newValue
{
    objc_setAssociatedObject(self, BoomCellsName, newValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//截图
- (UIImage*)scaleSnapshot
{
    return objc_getAssociatedObject(self,ScaleSnapshotName);
}

- (void)setScaleSnapshot:(UIImage*)newValue
{
    objc_setAssociatedObject(self,ScaleSnapshotName, newValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//view的缩放和透明度动画
- (void)scaleOpacityAnimations
{
    //缩放
    CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.toValue = @(0.01);
    scaleAnimation.duration = 0.15;
    scaleAnimation.fillMode = kCAFillModeForwards;
    
    //透明度
    CABasicAnimation* opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(1);
    opacityAnimation.toValue = @(0);
    opacityAnimation.duration = 0.15;
    opacityAnimation.fillMode = kCAFillModeForwards;
    
    [self.layer addAnimation:scaleAnimation forKey:@"lscale"];
    [self.layer addAnimation:opacityAnimation forKey:@"lopacity"];
    self.layer.opacity = 0;
}

//粒子动画
- (void)cellAnimations{
    NSArray* cellArr = self.boomCells;
    for (CALayer* shape in cellArr){
        shape.position = self.center;
        shape.opacity = 1;
        //路径
        CAKeyframeAnimation* moveAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        moveAnimation.path = [self makeRandomPath:shape].CGPath;
        moveAnimation.removedOnCompletion = false;
        moveAnimation.fillMode = kCAFillModeForwards;
        moveAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.240000: 0.590000: 0.506667: 0.026667];
        moveAnimation.duration = (NSTimeInterval)(arc4random()%10) * 0.05 + 0.3;
        
        CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.toValue = @(self.makeScaleValue);
        scaleAnimation.duration = moveAnimation.duration;
        scaleAnimation.removedOnCompletion = false;
        scaleAnimation.fillMode = kCAFillModeForwards;
        
         CABasicAnimation* opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = @(1);
        opacityAnimation.toValue = @(0);
        opacityAnimation.duration = moveAnimation.duration;
        opacityAnimation.delegate = nil;
        opacityAnimation.removedOnCompletion = true;
        opacityAnimation.fillMode = kCAFillModeForwards;
        opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.380000: 0.033333: 0.963333: 0.260000];
        
        shape.opacity = 0;
        [shape addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        [shape addAnimation:moveAnimation forKey:@"moveAnimation"];
        [shape addAnimation:opacityAnimation forKey:@"opacityAnimation"];
    }
}

//随机产生震动值
- (CGFloat)makeShakeValue:(CGFloat)p
{
    CGFloat basicOrigin = -(CGFloat)10;
    CGFloat maxOffset = -2 * basicOrigin;
    return basicOrigin + maxOffset * ((arc4random()%101)/100.f) + p;
}


//随机产生缩放数值
- (CGFloat)makeScaleValue
{
    return 1 - 0.7 * ((random()%101 - 50)/50.f);
}

//随机产生粒子路径
- (UIBezierPath*) makeRandomPath:(CALayer*)aLayer
{
    UIBezierPath* particlePath = [UIBezierPath bezierPath];
    [particlePath moveToPoint:(self.layer.position)];
    CGFloat basicLeft = -(1.3 * self.layer.frame.size.width);
    long maxOffset = 2 * fabs(basicLeft);
    double randomNumber = random()%101;
    CGFloat endPointX = basicLeft + maxOffset * ((randomNumber)/(100)) + aLayer.position.x;
    CGFloat controlPointOffSetX = (endPointX - aLayer.position.x)/2  + aLayer.position.x;
    CGFloat controlPointOffSetY = self.layer.position.y - 0.2 * self.layer.frame.size.height - (random()%(int)(1.2 * self.layer.frame.size.height));
    CGFloat endPointY = self.layer.position.y + self.layer.frame.size.height/2 + (random()%(int)(self.layer.frame.size.height/2));
    [particlePath addQuadCurveToPoint:CGPointMake(endPointX, endPointY) controlPoint: CGPointMake(controlPointOffSetX, controlPointOffSetY)];
    return particlePath;
}

- (UIColor*)colorWithPoint:(int)x :(int)y :(UIImage*)image
{
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    UInt8* data = (UInt8*)CFDataGetBytePtr(pixelData);
    
    int pixelInfo  = (((image.size.width) * y) + x) * 4;
    
    CGFloat a = (CGFloat)data[pixelInfo] / 255.0f;
    CGFloat r = (CGFloat)data[pixelInfo+1] / 255.0f;
    CGFloat g = (CGFloat)data[pixelInfo+2] / 255.0f;
    CGFloat b = (CGFloat)data[pixelInfo+3] / 255.0f;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}


//移除粒子
- (void)boomClear
{
    if (self.boomCells == nil)return;
    for(CALayer* item in self.boomCells){
        [item removeFromSuperlayer];
    }
    self.boomCells = nil;
    self.scaleSnapshot = nil;
}

//MARK: - 公开方法
//从layer获取View的截图
- (UIImage*)snapshot
{
    UIGraphicsBeginImageContext(self.layer.frame.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)boom
{
    //摇摆~ 摇摆~ 震动~ 震动~
    CAKeyframeAnimation* shakeXAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    shakeXAnimation.duration = 0.2;
    shakeXAnimation.values = @[@([self makeShakeValue:self.layer.position.x]),@([self makeShakeValue:self.layer.position.x]),@([self makeShakeValue:self.layer.position.x]),@([self makeShakeValue:self.layer.position.x])];
    CAKeyframeAnimation* shakeYAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    shakeYAnimation.duration = shakeXAnimation.duration;
    shakeYAnimation.values = @[@([self makeShakeValue:self.layer.position.y]),@([self makeShakeValue:self.layer.position.y]),@([self makeShakeValue:self.layer.position.y]),@([self makeShakeValue:self.layer.position.y])];
    
    [self.layer addAnimation:shakeXAnimation forKey:@"shakeXAnimation"];
    [self.layer addAnimation:shakeYAnimation forKey:@"shakeYAnimation"];
    
    [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(scaleOpacityAnimations) userInfo:nil repeats:false];
    
    if (self.boomCells == nil){
        NSMutableArray* marr = [NSMutableArray new];
        self.boomCells = marr;
        for(int i=0; i<=16; i++){
            for(int j=0; j<=16; j++){
                if (self.scaleSnapshot == nil){
                    self.scaleSnapshot = [[self snapshot] scaleImageToSize:CGSizeMake(34, 34)];
                }
                if (self.scaleSnapshot){
                    CGFloat pWidth = MIN(self.frame.size.width,self.frame.size.height)/17;
                    UIColor* color = [self.scaleSnapshot getPixelColorAtLocation:CGPointMake((i * 2), j * 2)];
                    CALayer* shape = [CALayer layer];
                    shape.backgroundColor = color.CGColor;
                    shape.opacity = 0;
                    shape.cornerRadius = pWidth/2;
                    shape.frame = CGRectMake((i) * pWidth, (j) * pWidth, pWidth, pWidth);
                    if(self.layer.superlayer)[self.layer.superlayer addSublayer:shape];
                    [marr addObject:shape];
                }
            }
        }
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(cellAnimations) userInfo:nil repeats:false];
}

- (void)bubbleBoom{
    self.layer.opacity = 0;
    if (self.boomCells == nil){
        NSMutableArray* marr = [NSMutableArray new];
        self.boomCells = marr;
        for(int i=0; i<=4; i++){
            for(int j=0; j<=4; j++){
                if (self.scaleSnapshot == nil){
                    self.scaleSnapshot = [[self snapshot] scaleImageToSize:CGSizeMake(34, 34)];
                }
                if (self.scaleSnapshot){
                    CGFloat pWidth = MIN(self.frame.size.width,self.frame.size.height)/17;
                    UIColor* color = [UIColor colorWithCGColor:self.layer.borderColor];
                    CALayer* shape = [CALayer layer];
                    shape.backgroundColor = color.CGColor;
                    shape.opacity = 0;
                    shape.cornerRadius = pWidth/2;
                    shape.frame = CGRectMake((i) * pWidth, (j) * pWidth, pWidth, pWidth);
                    if(self.layer.superlayer)[self.layer.superlayer addSublayer:shape];
                    [marr addObject:shape];
                }
            }
        }
    }
    [self cellAnimations];
}



//重置状态
- (void)boomResetSelf{
    self.layer.opacity = 1;
}

@end
