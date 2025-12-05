//
//  BuyAlertView.m
//  PopStar
//
//  Created by apple air on 15/12/23.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//

#import "BuyAlertView.h"
#import "BuyView.h"

@interface BuyAlertView ()

// 动画效果
@property (strong,nonatomic)UIDynamicAnimator *animator;
// 弹窗
@property (strong,nonatomic)BuyView *alertview;
// 整个手机的背景
@property (strong,nonatomic)UIView *backgroundview;

@end

@implementation BuyAlertView
- (instancetype)init
{
    if (self = [super initWithFrame:[[UIApplication sharedApplication] keyWindow].frame]) {
        [self setupSubviews];
    }
    return self;
}


- (void)setupSubviews
{
//    CGFloat alertviewWidth = ScreenWidth * 1;
//    if (IS_IPAD) {
//        alertviewWidth = ScreenWidth * 0.8;
//    }
//    CGFloat alertviewHeight = alertviewWidth * 365.0/300.0;
    CGFloat alertviewWidth = ScreenWidth;
    CGFloat alertviewHeight = ScreenHeight;
  
    // 背景view
    self.backgroundview = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].frame];
    self.backgroundview.backgroundColor = [UIColor blackColor];
    self.backgroundview.alpha = 1;
    [self addSubview:self.backgroundview];
    //    // 点击背景弹窗消失
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
    [self.backgroundview addGestureRecognizer:tap];
    // 弹窗
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"buyView" owner:nil options:nil];
    self.alertview = [views lastObject];
    if (IS_IPAD || Iphone4) {
        self.alertview = [[[NSBundle mainBundle] loadNibNamed:@"buyViewIpad" owner:nil options:nil] lastObject];
    }
    if ([[UIScreen mainScreen] bounds].size.height >= 812) {
        alertviewHeight=alertviewHeight-44-30-100;
        }
    self.alertview.frame = CGRectMake(0, 0, alertviewWidth, alertviewHeight);
    UIView * keywindow = [[UIApplication sharedApplication] keyWindow];
    self.alertview.center = CGPointMake(CGRectGetMidX(keywindow.frame), -CGRectGetMidY(keywindow.frame));
    [self addSubview:self.alertview];
    // 按钮
    [self.alertview.buy1 addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.alertview.buy2 addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.alertview.buy3 addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.alertview.buy4 addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.alertview.buy5 addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.alertview.buy6 addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    // 看视频免费金箔
    [self.alertview.buyFree addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    // 关闭按钮
    [self.alertview.close addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    // 将按钮都设置为不变形

    for (UIButton *button in self.alertview.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
}

#pragma mark - 点击按钮
-(void)clickButton:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(didClickBuyButtonAtIndex:sender:)]) {
        [self.delegate didClickBuyButtonAtIndex:button.tag sender:self];
    }
    [self dismiss];
}

#pragma mark - Gesture
-(void)click:(UITapGestureRecognizer *)sender{
    CGPoint tapLocation = [sender locationInView:self.backgroundview];
    CGRect alertFrame = self.alertview.frame;
    if (!CGRectContainsPoint(alertFrame, tapLocation)) {
        [self dismiss];
    }
}

-(void)dismiss{
    [self.animator removeAllBehaviors];
    [UIView animateWithDuration:0.7 animations:^{
        self.alpha = 0.0;
        CGAffineTransform rotate = CGAffineTransformMakeRotation(0.9 * M_PI);
        CGAffineTransform scale = CGAffineTransformMakeScale(0.1, 0.1);
        self.alertview.transform = CGAffineTransformConcat(rotate, scale);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.alertview = nil;
    }];
    
}
// 显示view方法
- (void)show
{
    // 这样会把弹窗直接加到window最前面,挡住其他view,下面是获取当前的view,然后再将弹窗加到当前view上
    UIView * keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:self];
    //    UIView *currentView = [[[UIApplication sharedApplication] keyWindow] subviews][0];
    //    //    NSLog(@"%@",currentView);
    //    [currentView addSubview:self];
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    UISnapBehavior * sanp = [[UISnapBehavior alloc] initWithItem:self.alertview snapToPoint:self.center];
    sanp.damping = 1;
    [self.animator addBehavior:sanp];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
