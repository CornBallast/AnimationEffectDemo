//
//  ViewController.m
//  AnimationEffectDemo
//
//  Created by ys on 2017/4/24.
//  Copyright © 2017年 ys. All rights reserved.
//

#import "ViewController.h"
#import "UIView+YSTransform.h"
#import "CAShapeLayer+AnimaitonBorder.h"
#import "UIView+ViewBoom.h"
#import <objc/runtime.h>
@interface ViewController ()<CAAnimationDelegate>
@property (nonatomic, strong) dispatch_source_t timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor redColor];
    //动态虚线框
    CAShapeLayer *borderLayer = [CAShapeLayer animationBorderLayerWithRect:CGRectMake(100, 100, 200, 100)];
    [self.view.layer addSublayer:borderLayer];
    //爆炸效果
    [self addPaopaos];
    //动态虚线框GCD定时器
    //[self addDashLine];
    
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint touchPos = [touch locationInView:self.view];
    if (touchPos.y > self.view.frame.size.height / 2) {
        UIColor *toColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
        [self.view YSTransform_circleColor_toColor:toColor Duration:1 StartPoint:touchPos];
    }else{
        NSString* imageName = [NSString stringWithFormat:@"image_%@.jpg",@(arc4random() % 13)];
        [self.view YSTransform_circleImage_toImage:[UIImage imageNamed:imageName] Duration:1 StartPoint:touchPos];
    }
}

//添加动态虚线框
-(void)addDashLine{
    CAShapeLayer* dashLineShapeLayer = [CAShapeLayer layer];
    //创建贝塞尔曲线
    UIBezierPath* dashLinePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 200, 100) cornerRadius:20];
    
    dashLineShapeLayer.path = dashLinePath.CGPath;
    //dashLineShapeLayer.position = CGPointMake(100, 100);
    dashLineShapeLayer.fillColor = [UIColor clearColor].CGColor;
    dashLineShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    dashLineShapeLayer.lineWidth = 3;
    dashLineShapeLayer.lineDashPattern = @[@(6),@(6)];
    dashLineShapeLayer.strokeStart = 0;
    dashLineShapeLayer.strokeEnd = 1;
    dashLineShapeLayer.zPosition = 999;
    //
    [self.view.layer addSublayer:dashLineShapeLayer];
    
    //
    NSTimeInterval delayTime = 0.3f;
    //定时器间隔时间
    NSTimeInterval timeInterval = 0.1f;
    //创建子线程队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //使用之前创建的队列来创建计时器
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //设置延时执行时间，delayTime为要延时的秒数
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
    //设置计时器
    dispatch_source_set_timer(_timer, startDelayTime, timeInterval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        //执行事件
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGFloat _add = 3;
            dashLineShapeLayer.lineDashPhase -= _add;
        });
    });
    // 启动计时器
    dispatch_resume(_timer);
}


//泡泡爆炸效果
//泡泡
-(void)addPaopaos{
    for (int i = 0; i < 100; i++) {
        UIView *paopao = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        paopao.layer.zPosition = 999;
        paopao.center = CGPointMake(100, 400);
        paopao.backgroundColor = [UIColor clearColor];
        paopao.layer.borderColor = [UIColor whiteColor].CGColor;
        paopao.layer.cornerRadius = 5;
        paopao.layer.borderWidth = 1;
        [self.view addSubview:paopao];
        [self addPaopaoAniWith:paopao WithDelay:i];
    }
}

-(void)addPaopaoAniWith:(UIView*)paopao WithDelay:(CGFloat)delay{
    CABasicAnimation* positionAni = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAni.toValue = [NSValue valueWithCGPoint:CGPointMake(200, 200)];
    [positionAni setValue:positionAni.toValue forKey:@"endPoint"];
    //控制动画节奏 不同时间动画变化的快慢
    positionAni.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    objc_setAssociatedObject(positionAni, @"paopaoView", paopao, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    CABasicAnimation* scaleAni = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAni.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    scaleAni.toValue = @(3);
    
    CAAnimationGroup* aniGroup = [CAAnimationGroup animation];
    aniGroup.animations = @[positionAni,scaleAni];
    aniGroup.duration = 3;
    aniGroup.beginTime = CACurrentMediaTime() + delay;
    aniGroup.removedOnCompletion = NO;
    aniGroup.fillMode = kCAFillModeForwards;
    aniGroup.delegate = self;
    
    [paopao.layer addAnimation:aniGroup forKey:@"paopaoGroupAni"];
}


-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    CAAnimationGroup *groupAni = (CAAnimationGroup*)anim;
    CABasicAnimation *positionAni = (CABasicAnimation*)[groupAni.animations firstObject];
    UIView* paopao = objc_getAssociatedObject(positionAni, @"paopaoView");
    paopao.center = [[positionAni valueForKey:@"endPoint"] CGPointValue];
    paopao.transform = CGAffineTransformMakeScale(3, 3);
    [paopao bubbleBoom];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [paopao removeFromSuperview];
    });
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
