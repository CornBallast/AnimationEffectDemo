//
//  ViewController.m
//  AnimationEffectDemo
//
//  Created by ys on 2017/4/24.
//  Copyright © 2017年 ys. All rights reserved.
//

#import "ViewController.h"
#import "UIView+YSTransform.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
