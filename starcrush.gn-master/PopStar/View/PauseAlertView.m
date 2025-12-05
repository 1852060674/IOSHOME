//
//  PauseAlertView.m
//  连连看
//
//  Created by apple air on 15/11/16.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//

#import "PauseAlertView.h"
#import "pauseView.h"

@interface PauseAlertView()
// 动画效果
@property (strong,nonatomic)UIDynamicAnimator *animator;
// 弹窗
@property (strong,nonatomic)pauseView *alertview;
// 整个手机的背景
@property (strong,nonatomic)UIView *backgroundview;
// 图片
@property (nonatomic,strong) UIImage *image;
// 图片
@property (nonatomic,strong) UIImage *rightButtonImage;
// 关卡
@property (nonatomic,assign)int level;
// 分数
@property (nonatomic,assign)int score;


@end

@implementation PauseAlertView

#pragma mark - 设置子控件
- (void)setupSubviews
{
    CGFloat alertviewWidth = ScreenWidth * 0.8;
    if (IS_IPAD) {
        alertviewWidth = ScreenWidth * 0.6;
    }
    CGFloat alertviewHeight = alertviewWidth * 441.0/463.0;

    // 背景view
    self.backgroundview = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].frame];
    self.backgroundview.backgroundColor = [UIColor blackColor];
    self.backgroundview.alpha = 0.7;
    [self addSubview:self.backgroundview];
//    // 点击背景弹窗消失
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
//    [self.backgroundview addGestureRecognizer:tap];
    
    // 弹窗
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"pauseView" owner:nil options:nil];
    self.alertview = [views lastObject];
    
    self.alertview.frame = CGRectMake(0, 0, alertviewWidth, alertviewHeight);
//    self.alertview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, alertviewWidth, alertviewHeight)];
    UIView * keywindow = [[UIApplication sharedApplication] keyWindow];
    self.alertview.center = CGPointMake(CGRectGetMidX(keywindow.frame), -CGRectGetMidY(keywindow.frame));
    [self addSubview:self.alertview];
    
    // 图片
//    self.alertview.imageView.image = self.image;
    self.alertview.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // 左边的按钮
    self.alertview.leftButton.tag = 1;
    [self.alertview.leftButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    self.alertview.leftButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // 中间的按钮
    self.alertview.middleButton.tag = 2;
    [self.alertview.middleButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    self.alertview.middleButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // 右边的按钮
    self.alertview.rightButton.tag = 3;
    [self.alertview.rightButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
//    [self.alertview.rightButton setImage:self.rightButtonImage forState:UIControlStateNormal];
    self.alertview.rightButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // 关卡view
    [self.alertview.levelView setNumberWith:self.level fontWidth:self.alertview.levelView.frame.size.height * 0.8 * FontWidthToHeight fontHeight:self.alertview.levelView.frame.size.height * 0.8 prefix:@"level"];
    
    // 分数view
    [self.alertview.scoreView setNumberWith:self.score fontWidth:self.alertview.scoreView.frame.size.height * 0.8 * FontWidthToHeight fontHeight:self.alertview.scoreView.frame.size.height * 0.8 prefix:@"pause_score" toLeft:YES];
    NSLog(@"zzx test1`");
}



#pragma mark - 点击按钮
-(void)clickButton:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(didClickPauseButtonAtIndex:sender:)]) {
        [self.delegate didClickPauseButtonAtIndex:(button.tag -1) sender:self];
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

#pragma mark - 初始化方法
- (instancetype)initWithLevel:(int)level score:(int)score
{
    if (self = [super initWithFrame:[[UIApplication sharedApplication] keyWindow].frame]) {
        self.level = level;
        self.score = score;
        [self setupSubviews];
    }
    return self;
}


// 显示view方法
- (void)show
{
    // 这样会把弹窗直接加到window最前面,挡住其他view,下面是获取当前的view,然后再将弹窗加到当前view上
    UIView * keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:self];
//    UIView *currentView = [[[UIApplication sharedApplication] keyWindow] subviews][0];
//    NSLog(@"zzx %@",currentView);
//    [currentView addSubview:self];
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    UISnapBehavior * sanp = [[UISnapBehavior alloc] initWithItem:self.alertview snapToPoint:self.center];
    sanp.damping = 0.7;
    [self.animator addBehavior:sanp];
    NSLog(@"zzx %@",sanp);
    NSLog(@"zzx self.center %lf",self.center.y);
}


@end
