//
//  ContinueGameAlertView.m
//  PopStar
//
//  Created by apple air on 15/12/23.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//

#import "ContinueGameAlertView.h"
#import "continueGameView.h"

@interface ContinueGameAlertView ()

// 动画效果
@property (strong,nonatomic)UIDynamicAnimator *animator;
// 弹窗
@property (strong,nonatomic)continueGameView *alertview;
// 整个手机的背景
@property (strong,nonatomic)UIView *backgroundview;


@end

@implementation ContinueGameAlertView

- (instancetype)init
{
    if (self = [super initWithFrame:[[UIApplication sharedApplication] keyWindow].frame]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    CGFloat alertviewWidth = ScreenWidth * 0.8;
    if (IS_IPAD) {
        alertviewWidth = ScreenWidth * 0.6;
    }
    CGFloat alertviewHeight = alertviewWidth * 291.0/400.0;
    // 背景view
    self.backgroundview = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].frame];
    self.backgroundview.backgroundColor = [UIColor blackColor];
    self.backgroundview.alpha = 0.7;
    [self addSubview:self.backgroundview];
    // 弹窗
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"continueGameView" owner:nil options:nil];
    self.alertview = [views lastObject];
    
    self.alertview.frame = CGRectMake(0, 0, alertviewWidth, alertviewHeight);
    UIView * keywindow = [[UIApplication sharedApplication] keyWindow];
    self.alertview.center = CGPointMake(CGRectGetMidX(keywindow.frame), -CGRectGetMidY(keywindow.frame));
    [self addSubview:self.alertview];
    // 左边按钮
    self.alertview.leftButton.tag = 1;
    [self.alertview.leftButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    self.alertview.leftButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    // 右边的按钮
    self.alertview.rightButton.tag = 2;
    [self.alertview.rightButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    self.alertview.rightButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
}
#pragma mark - 点击按钮
-(void)clickButton:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(didClickContinueGameButtonAtIndex:sender:)]) {
        [self.delegate didClickContinueGameButtonAtIndex:(button.tag -1) sender:self];
    }
    [self dismiss];
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
    sanp.damping = 0.7;
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
