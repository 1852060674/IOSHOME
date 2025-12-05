//
//  GameOverAlertView.m
//  连连看
//
//  Created by apple air on 15/11/16.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//

#import "GameOverAlertView.h"
#import "gameoverView.h"

@interface GameOverAlertView()
// 动画效果
@property (strong,nonatomic)UIDynamicAnimator *animator;
// 弹窗
@property (strong,nonatomic)gameoverView *alertview;
// 整个手机的背景
@property (strong,nonatomic)UIView *backgroundview;
// 图片
@property (nonatomic,strong) UIImage *image;
// 分数
@property (nonatomic,assign)int score;
// 关卡
@property (nonatomic,assign)int level;



@end

@implementation GameOverAlertView

#pragma mark - 设置子控件
- (void)setupSubviews
{
    CGFloat alertviewWidth = ScreenWidth * 1.5;
    if (IS_IPAD) {
        alertviewWidth = ScreenWidth ;
    }
    CGFloat alertviewHeight = alertviewWidth * 616.0/414.0;

    // 背景view
    self.backgroundview = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].frame];
    self.backgroundview.backgroundColor = [UIColor blackColor];
    self.backgroundview.alpha = 0.7;
    [self addSubview:self.backgroundview];
//    // 点击背景弹窗消失
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
//    [self.backgroundview addGestureRecognizer:tap];
    
    // 弹窗
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"gameoverView" owner:nil options:nil];
    self.alertview = [views lastObject];
    
    self.alertview.frame = CGRectMake(0, 0, alertviewWidth, alertviewHeight);
    UIView * keywindow = [[UIApplication sharedApplication] keyWindow];
//    self.alertview.center = CGPointMake(CGRectGetMidX(keywindow.frame), -CGRectGetMidY(keywindow.frame));
    [self addSubview:self.alertview];
    
    // 图片
//    self.alertview.imageView.image = self.image;
    self.alertview.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // 左边的按钮
    self.alertview.leftButton.tag = 1;
    [self.alertview.leftButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    self.alertview.leftButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // 右边的按钮
    self.alertview.rightButton.tag = 2;
    [self.alertview.rightButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
//    [self.alertview.rightButton setImage:self.rightButtonImage forState:UIControlStateNormal];
    self.alertview.rightButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // 得分
//    self.alertview.currentScore.text = [NSString stringWithFormat:@"%d",self.score];
    [self.alertview.scoreView setNumberWith:self.score fontWidth:self.alertview.scoreView.frame.size.height * 0.8 *FontWidthToHeight fontHeight:self.alertview.scoreView.frame.size.height * 0.8 prefix:@"over_score"];
    // 关卡
//    self.alertview.currentLevel.text = [NSString stringWithFormat:@"第%d关",self.level];
    [self.alertview.levelView setNumberWith:self.level fontWidth:self.alertview.levelView.frame.size.height * 0.8 *FontWidthToHeight fontHeight:self.alertview.levelView.frame.size.height * 0.8 prefix:@"level"];
    // 奖励金币
//    self.alertview.plusCoin.text = [NSString stringWithFormat:@"+%d",self.score/1000];
    [self.alertview.plusCoinView setNumberWith:self.score/1000 fontWidth:self.alertview.plusCoinView.frame.size.height * 0.8 *FontWidthToHeight fontHeight:self.alertview.plusCoinView.frame.size.height * 0.8 prefix:@"plus_coin"];
    // 历史最高
    int highScore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"highestScore"];
//    self.alertview.highestScore.text = [NSString stringWithFormat:@"历史最高:%d",highScore];
    [self.alertview.historyScoreView setNumberWith:highScore fontWidth:self.alertview.historyScoreView.frame.size.height * 0.8 *FontWidthToHeight fontHeight:self.alertview.historyScoreView.frame.size.height * 0.8 prefix:@"pause_score" toLeft:YES];

}



#pragma mark - 点击按钮
-(void)clickButton:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(didClickGameOverButtonAtIndex:sender:)]) {
        [self.delegate didClickGameOverButtonAtIndex:(button.tag -1) sender:self];
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
//- (instancetype)initWithImage:(UIImage *)image rightButtonImage:(UIImage *)rightButtonImage
- (instancetype)init
{
    if (self = [super initWithFrame:[[UIApplication sharedApplication] keyWindow].frame]) {
//        self.image = image;
//        self.rightButtonImage = rightButtonImage;
        [self setupSubviews];
    }
    return self;
}
#pragma mark - 带参数初始化方法
- (instancetype)initWithScore:(int)score level:(int)level
{
    if (self = [super initWithFrame:[[UIApplication sharedApplication] keyWindow].frame]) {
        self.score = score;
        self.level = level;
        [self setupSubviews];
    }
    return self;
}



// 显示view方法
- (void)show
{
    // 这样会把弹窗直接加到window最前面,挡住其他view,下面是获取当前的view,然后再将弹窗加到当前view上
//    UIView * keywindow = [[UIApplication sharedApplication] keyWindow];
//    [keywindow addSubview:self];
    UIView *currentView = [[[UIApplication sharedApplication] keyWindow] subviews][0];
//    NSLog(@"%@",currentView);
    [currentView addSubview:self];
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    UISnapBehavior * sanp = [[UISnapBehavior alloc] initWithItem:self.alertview snapToPoint:self.center];
    sanp.damping = 0.7;
    [self.animator addBehavior:sanp];
}


@end
