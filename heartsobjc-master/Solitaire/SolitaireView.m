//
//  SolitaireView.m
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved. 
//

#import <QuartzCore/QuartzCore.h>
#import "SolitaireView.h"
#import "Solitaire.h"
#import "CardView.h"
#import "MoveAction.h"
#import "UIApplication+Size.h"
#import "Config.h"
#import "TheSound.h"
#import "Toast+UIView.h"
#import "ScoreInfoView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ZhConfig.h"
#include "ApplovinMaxWrapper.h"
#import "Admob.h"
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

@implementation SolitaireView {
    NSMutableDictionary *cards;
    NSMutableArray *collectCVs;
    
    CGFloat _s;
    CGFloat _w;
    CGFloat _h;
    CGFloat _d;
    CGFloat _f;
    CGFloat _o;
    CGFloat _fs;
    
    CGPoint touchStartPoint;
    CGPoint startCenter;
    Card *touchedCard;
    NSArray *touchedFan;
    
    CGFloat _sc_width;
    CGFloat _sc_height;
    
    CGFloat MARGINY;
    CGFloat MARGINX;
    CGFloat BUFFER_WIDTH;
    CGFloat TABLE_SPACE;
    
    /// 
    BOOL moveFlag;
    
    ///
    int lastState;
    int lastCnt;
    BOOL finishFlag;
    BOOL turnFlag;
    BOOL liuhai;
    BOOL testzzxcbg;
    
    //
    /// angle
    CGFloat GAP_ANGLE;
    CGFloat YOUR_ANGEL;
    
    /// other radius
    CGFloat OTHER_RADIUS;
    
    /// your radius
    CGFloat YOUR_RADIUS;
    
    /// select diff radius
    CGFloat SELECT_DIFF_RADIUS;
    
    ///
    NSString* hintstr;
    
    ///
    CGFloat INFO_WIDTH;
    CGFloat INFO_HEIGHT;
    
    AVAudioSession *audioSession;
    
    BOOL oldman;
    
    ///
ScoreInfoView* northInfo;
ScoreInfoView* westInfo;
ScoreInfoView* eastInfo;
ScoreInfoView* yourInfo;
}

@synthesize game = _game;
@synthesize delegate = _delegate;

@synthesize rightHand;
@synthesize hinting;
@synthesize topCards;
@synthesize anaCnt;
@synthesize anaIdx;
@synthesize autoOn;
@synthesize complete;
@synthesize needAuto;
@synthesize speed;

@synthesize sound = _sound;
@synthesize shuffleSound = _shuffleSound;
@synthesize clickSound = _clickSound;
@synthesize clickQuickSound = _clickQuickSound;

@synthesize savedOri = _savedOri;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;  //主要用于alapha
        /// tap to hide/display opbar
        self.hideOp = NO;
    }
    return self;
}

- (void)updateCardBack
{
    for (Card* c in cards) {
        [[cards objectForKey:c] setNeedsDisplay];
    }
}

- (void)updateCardForground
{
    for (Card* c in cards) {
        CardView* cv = [cards objectForKey:c];
        [cv updateClassic:c];
        [cv setNeedsDisplay];
    }
}

- (void)heartDone
{
    self.heartView.hidden = YES;
}

- (void)heartBroken {
    [TheSound playBrokenSound];
    self.heartView.hidden = NO;
    self.heartView.animationImages =  [NSArray arrayWithObjects:
                                       [UIImage imageNamed:@"broken01"],
                                       [UIImage imageNamed:@"broken02"],
                                       [UIImage imageNamed:@"broken03"],
                                       [UIImage imageNamed:@"broken04"],
                                       [UIImage imageNamed:@"broken05"],
                                       [UIImage imageNamed:@"broken06"],nil];
    [self.heartView setAnimationDuration:1.0f];
    [self.heartView setAnimationRepeatCount:1];
    [self.heartView startAnimating];
    [self performSelector:@selector(heartDone) withObject:nil afterDelay:1.0];
}

- (void)hideOrDisplayOpBar
{   
    int opbarIPd = IS_IPAD ? 10 :0;
    int opbarHeightpianyi1 = liuhai  ? [self isLandscape] ? 20 : opbarHeightpianyi : opbarIPd;
    NSLog(@
          "zzx hideror");
    self.hideOp = !self.hideOp;
    if (self.hideOp) {
        [UIView beginAnimations:@"Hide" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
#ifndef AD_POS_UP
//        [self.admobView setFrame:CGRectMake(self.admobView.frame.origin.x, self.frame.size.height - self.admobView.frame.size.height, self.admobView.frame.size.width, self.admobView.frame.size.height)];
#endif
       
        [self.opBar setFrame:CGRectMake(0.0, self.frame.size.height, self.opBar.frame.size.width, self.opBar.frame.size.height)];
        self.admobView.center = CGPointMake(_sc_width/2, _sc_height - opbarHeightpianyi1 -(admobHeight1)/2);
        [UIView commitAnimations];
    }
    else
    {
        [UIView beginAnimations:@"Display" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
#ifndef AD_POS_UP
//        [self.admobView setFrame:CGRectMake(self.admobView.frame.origin.x, self.frame.size.height- self.admobView.frame.size.height - self.opBar.frame.size.height, self.admobView.frame.size.width, self.admobView.frame.size.height)];
#endif
        [self.opBar setFrame:CGRectMake(0.0, self.frame.size.height- self.opBar.frame.size.height -opbarHeightpianyi1, self.frame.size.width, self.opBar.frame.size.height)];
        self.admobView.center = CGPointMake(_sc_width/2, _sc_height - opbarHeightpianyi1 -self.opBar.frame.size.height -(admobHeight1)/2);
        [UIView commitAnimations];
    }
    [self computeCardLayout:0.4 destPos:POS_TABEAU destIdx:-1];
}

- (void)loadGameUI
{
    
//    NSUserDefaults* settings1 = [NSUserDefaults standardUserDefaults];
//    id obj = [settings1 objectForKey:New_Boy_Comming];
    oldman =false;
    [self IsOldman];
    NSLog(@"zzxxxxx");
    
    /// 根据当前屏幕状态调整ui
    self.hintLabel.alpha = 0;
    self.gameBg.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.gameDecoration.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.gameDecoration.image = [UIImage imageNamed:@"Decoration"];
//    self.opBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.admobView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    ///
   if ( oldman || Open_Old) {
        self.opBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        northInfo = [[ScoreInfoView alloc] initWithFrame:CGRectMake(-100, -100, INFO_WIDTH, INFO_HEIGHT)];
        yourInfo = [[ScoreInfoView alloc] initWithFrame:CGRectMake(-100, -100, INFO_WIDTH, INFO_HEIGHT)];
        westInfo = [[ScoreInfoView alloc] initWithFrame:CGRectMake(-100, -100, INFO_WIDTH, INFO_HEIGHT)];
        eastInfo = [[ScoreInfoView alloc] initWithFrame:CGRectMake(-100, -100, INFO_WIDTH, INFO_HEIGHT)];
    }else{
        // 第一部分修改计分器
        northInfo = [[ScoreInfoView alloc] initWithFrame:CGRectMake(-100, -100, INFO_WIDTH, INFO_HEIGHT) withIntValue:1 ];
        yourInfo = [[ScoreInfoView alloc] initWithFrame:CGRectMake(-100, -100, INFO_WIDTH, INFO_HEIGHT) withIntValue:3 ];
        westInfo = [[ScoreInfoView alloc] initWithFrame:CGRectMake(-100, -100, INFO_WIDTH, INFO_HEIGHT) withIntValue:2];
        eastInfo = [[ScoreInfoView alloc] initWithFrame:CGRectMake(-100, -100, INFO_WIDTH,INFO_HEIGHT) withIntValue:4];
        // 第二部分修改主题 和spades 类似
        
    }


    
    [self addSubview:northInfo];
    [self addSubview:yourInfo];
    [self addSubview:westInfo];
    [self addSubview:eastInfo];
    
    
    float theseX=0;
    if (kScreenWidth >kScreenHeight) {
        theseX =kScreenWidth/2;
        NSLog(@"test1 zzx land %lf",theseX);
    }else{
        theseX =kScreenWidth/2;
        NSLog(@"test1 zzx shu %lf",theseX);
    }
    
  
    // 如果新人直接进，如何老人，进老版本
    ///20240307 添加themes 按钮以及完善起功能
    // 第一步添加themes按钮 按钮图片名称为cardback，名字为Teheme
    // 按钮的位置高度和seetting同高，水平剧中
    // 创建themes按钮
    _themesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // 设置图片
    [_themesButton setImage:[UIImage imageNamed:@"cardback"] forState:UIControlStateNormal];
    // 设置标题
    [_themesButton setTitle:@"Themes" forState:UIControlStateNormal];

    // 设置按钮的位置和大小
    CGRect buttonFrame = _themesButton.frame;
    buttonFrame.size.height = self.btnSettings.frame.size.height; // 设置和settings按钮的高度一样
    buttonFrame.size.width =  self.btnSettings.frame.size.width;
    // 设置和settings按钮的高度一样
    
//    buttonFrame.origin.x = (kScreenWidth - buttonFrame.size.width) / 2; // 水平居中 0311
    if ([self isLandscape]) {
        buttonFrame.origin.x = kScreenHeight/2-_themesButton.frame.size.width/2;
        buttonFrame.origin.x = kScreenWidth/2-_themesButton.frame.size.width/2;
    }else{
        buttonFrame.origin.x = kScreenWidth/2-_themesButton.frame.size.width/2;
        buttonFrame.origin.x = kScreenHeight/2-_themesButton.frame.size.width/2;
    }
    NSLog(@"self.frame.size.width = %lf",  self.frame.size.width );
    buttonFrame.origin.y = 8; // 根据你的需求设置Y坐标
    _themesButton.frame = buttonFrame;
//    themesButton.backgroundColor=[UIColor redColor];
    // 1507
//    [_themesButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    // 11.48
    // 下面的代码是为了确保按钮的标题和图片垂直居中
    // 获取图片和标题的尺寸
//    CGSize imageSize = _themesButton.imageView.frame.size;
//    CGSize titleSize = _themesButton.titleLabel.frame.size;
    // 计算需要的边距
//    CGFloat totalHeight = (imageSize.height + titleSize.height);
    // 设置image偏移
    [_themesButton setImageEdgeInsets:UIEdgeInsetsMake(-2, 5, 24, 5)];
//    [_themesButton setImageEdgeInsets:UIEdgeInsetsMake(-2, 4, 21, 5)];

    if (ZH_IS_IPAD) {
        [_themesButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 35, 10)];
    }
    // 设置title偏移
    if (ZH_IS_IPAD) {
        [_themesButton setTitleEdgeInsets:UIEdgeInsetsMake(40,-55,0,0.0)];
    }else{
        [_themesButton setTitleEdgeInsets:UIEdgeInsetsMake(33,-42,4,0.0)];
    }
    CGRect buttonFramelabel = _themesButton.titleLabel.frame;
    buttonFramelabel.size.width =buttonFramelabel.size.width +30;
    _themesButton.titleLabel.frame =buttonFramelabel;
    _themesButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    if (ZH_IS_IPAD) {
        _themesButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    }
    [self bringSubviewToFront:_themesButton];
    
    // 此部分对opbar 的按钮剧中进行修正 计划为左侧0.25 0.5 0.75
    
    CGRect frame_Srtting= self.btnSettings.frame;
    frame_Srtting.origin.x=self.opBar.frame.size.width*0.25-self.btnSettings.frame.size.width;
    frame_Srtting.origin.y=self.btnSettings.frame.origin.y;
    CGFloat titleLabelWidth = _themesButton.titleLabel.frame.size.width;
//    [themesButton addTarget:self
//                      action:@selector(skinPicker:)
//            forControlEvents:UIControlEventTouchUpInside];
    
    CGRect framePlay = self.btnSettings.frame;
    framePlay.origin.x=self.opBar.frame.size.width*0.75;
    framePlay.origin.y=self.btnSettings.frame.origin.y;
    self.btnSettings.frame=frame_Srtting;
    self.btnPlay.frame=framePlay;
    
    
    
    // end 11.48
    if (!oldman && !(Open_Old)) {
            [self.opBar addSubview:_themesButton];
    }
}

//- (void)closeButtonClicked {
//    // 按钮点击事件处理逻辑
//    NSLog(@"zzx 按钮被点击了");
//    if (self.gameView.hinting) {
//      return;
//    }
//    UIView * view = [self themeView];
//    [self.view addSubview:view];
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.hinting) {
        [self stopHintAnamiation];
        return;
    }
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 1) {
        [self hideOrDisplayOpBar];
    }
}

- (void)awakeFromNib {
    
    NSLog(@"test first1 coming second");
    // zzx update 20240301 add
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    
    liuhai = [self isNotchScreen] && (kScreenHeight > 811 || kScreenWidth >811) && kScreenWidth + kScreenHeight <1500;
    self.rightHand = NO;
    self.hinting = NO;
    //self.autoOn = YES;
    self.needAuto = YES;
    self.savedOri = 0;
    MARGINY = 25;
    MARGINX = 5;
    BUFFER_WIDTH = 4;
    self.topCards = nil;
    lastState = -1;
    lastCnt = 0;
    finishFlag = YES;
    self.winLabel.hidden = YES;
    hintstr = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        INFO_WIDTH = 100;
        INFO_HEIGHT = 60;
    }
    else
    {
        INFO_WIDTH = 50;
        INFO_HEIGHT = 30;
    }
    NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"shuffle" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &_shuffleSound);
    NSURL *clickUrl = [[NSBundle mainBundle] URLForResource:@"click" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)clickUrl, &_clickSound);
    NSURL *clickQuickUrl = [[NSBundle mainBundle] URLForResource:@"click_quick" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)clickQuickUrl, &_clickQuickSound);
    ///
    [self loadGameUI];
    /*
    ///
    [self computeSizes:YES];
     */
}

- (void)firstInCompute
{
    ///
    [self computeSizes:YES];
}

#pragma mark Initialization

- (void)setGame:(Solitaire *)game {
    /// shuffle sound
    //if (self.sound) {
    //    AudioServicesPlaySystemSound(_shuffleSound);
    //}
    
    ///
    _game = game;
    cards = [[NSMutableDictionary alloc] init];
    collectCVs = [[NSMutableArray alloc] init];
    
    /// delete 
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:[CardView class]]) {
            [view removeFromSuperview];
        }
    }
    self.btnPass.hidden = YES;
    self.dealBtn.hidden = YES;

    /// add bottom cards
    [self addBottomCardsToSubview];
    
    /// add game card
    [self iterateGameWithBlock:^(Card *c) {
        [self addToSubViewForCard:c];
    }];
    
    /// show
    [self computeBottomCardLayout];
    [self computeCardLayout:0.8 destPos:-1 destIdx:-1];
    
    ///
    //[self updateUndoBtn];
    //[self updateAutoBtn];
    if (_game.won) {
        if ([_game gameOver] != 0) {
            self.winLabel.text = @"You Lost!";
        }
        else
        {
            self.winLabel.text = @"You Won!";
        }
        self.winLabel.hidden = NO;
    }
    else
        self.winLabel.hidden = YES;
    //
    if (self.sound  &&  [self getCurrentSound]) {
        AudioServicesPlaySystemSound(_shuffleSound);
    }
    ///
    srand(time(NULL));
}

- (void)addToSubViewForCard:(Card *)c {
    // If card is not already in our view
    if ( ![cards objectForKey:c] ) {
        CardView *cv = [[CardView alloc] 
                        initWithFrame:CGRectMake(MARGINX, MARGINY, _w, _h)
                        andCard:c];
        cv.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [cards setObject:cv forKey:c];
        cv.hidden = NO;
        [self addSubview:cv];
    }
}

- (void)addBottomCardsToSubview {
    // Create bottom card images
}

#pragma mark Helper Functions

// Thanks Travis!
- (void)iterateGameWithBlock:(void (^)(Card *c))block { 

    for (int i = 0; i < NUM_PLAYERS; i++) {
        for (Card* c in [_game playerCards:i]) {
            block(c);
        }
    }
}

#pragma mark Layout Functions

- (void)rotateLayout:(UIInterfaceOrientation)toInterfaceOrientation{
    CGSize fs = [UIApplication sizeInOrientation:toInterfaceOrientation];
    _sc_width = fs.width;
    _sc_height = fs.height;
    [self computeSizes:NO];
    [self computeBottomCardLayout];
    [self anamiationDone];
    [self computeCardLayout:0.2 destPos:-1 destIdx:-1];
    [[AdmobViewController shareAdmobVC] willOrientationChangeTo:toInterfaceOrientation];
    [[AdmobViewController shareAdmobVC] onOrientationChanged];
    /*
    if (!oldman) {
        CGRect frame_Srtting= self.btnSettings.frame;
        frame_Srtting.origin.x=self.opBar.frame.size.width*0.25-self.btnSettings.frame.size.width;
        frame_Srtting.origin.y=self.btnSettings.frame.origin.y;
    //    [themesButton addTarget:self
    //                      action:@selector(skinPicker:)
    //            forControlEvents:UIControlEventTouchUpInside];
        
        CGRect framePlay = self.btnSettings.frame;
        framePlay.origin.x=self.opBar.frame.size.width*0.75;
        framePlay.origin.y=self.btnPlay.frame.origin.y;
        self.btnSettings.frame=frame_Srtting;
        self.btnPlay.frame=framePlay;
        _
    }
     
     */
    if (!oldman && !(Open_Old)) {//0311
        if ([self isLandscape] && kScreenWidth >kScreenHeight) {
            CGRect frame_themes=_themesButton.frame;
            frame_themes.origin.x= kScreenWidth/2-_themesButton.frame.size.width/2;
            NSLog(@"test ans = %lf",frame_themes.origin.x );
            NSLog(@"test kScreenWidth = %lf",kScreenWidth);
            _themesButton.frame=frame_themes;
            // 横屏调整一下 几个info的ui 需要调整的只有把youinfo左移动一点点
        }else{
            NSLog(@"test kScreenWidth1 = %lf",kScreenWidth);
            CGRect frame_themes=_themesButton.frame;
            frame_themes.origin.x= kScreenHeight/2-_themesButton.frame.size.width/2;
            NSLog(@"test ans = %lf",frame_themes.origin.x );
            NSLog(@"test kScreenWidth = %lf",kScreenWidth);
            _themesButton.frame=frame_themes;
        }
        
        if (![self isLandscape] && kScreenWidth < kScreenHeight) {
            CGRect frame_themes=_themesButton.frame;
            frame_themes.origin.x= kScreenWidth/2-_themesButton.frame.size.width/2;
            NSLog(@"test ans = %lf",frame_themes.origin.x );
            NSLog(@"test kScreenWidth = %lf",kScreenWidth);
            _themesButton.frame=frame_themes;
        }

    }
    
//    [self updateInfoList];
    
    NSLog(@"test updateInfoList zzx 1 = %lf",kScreenWidth);
   
}
-(void)updateInfoList{
    NSLog(@"test updateInfoList zzx = %lf",kScreenWidth);
    [northInfo removeFromSuperview];
    [yourInfo removeFromSuperview];
    [westInfo removeFromSuperview];
    [eastInfo removeFromSuperview];
    // 第一部分修改计分器
    if ( oldman || Open_Old) {
         self.opBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
         northInfo = [[ScoreInfoView alloc] initWithFrame:CGRectMake(-100, -100, INFO_WIDTH, INFO_HEIGHT)];
         yourInfo = [[ScoreInfoView alloc] initWithFrame:CGRectMake(-100, -100, INFO_WIDTH, INFO_HEIGHT)];
         westInfo = [[ScoreInfoView alloc] initWithFrame:CGRectMake(-100, -100, INFO_WIDTH, INFO_HEIGHT)];
         eastInfo = [[ScoreInfoView alloc] initWithFrame:CGRectMake(-100, -100, INFO_WIDTH, INFO_HEIGHT)];
     }else{
         // 第一部分修改计分器
         northInfo = [[ScoreInfoView alloc] initWithFrame:CGRectMake(-100, -100, INFO_WIDTH, INFO_HEIGHT) withIntValue:1 ];
         yourInfo = [[ScoreInfoView alloc] initWithFrame:CGRectMake(-100, -100, INFO_WIDTH, INFO_HEIGHT) withIntValue:3 ];
         westInfo = [[ScoreInfoView alloc] initWithFrame:CGRectMake(-100, -100, INFO_WIDTH, INFO_HEIGHT) withIntValue:2];
         eastInfo = [[ScoreInfoView alloc] initWithFrame:CGRectMake(-100, -100, INFO_WIDTH,INFO_HEIGHT) withIntValue:4];
         // 第二部分修改主题 和spades 类似
         // 3.1418
         NSLog(@"northInfo anything wid = %lf het =%lf",northInfo.frame.origin.x,northInfo.frame.origin.x);
     }
    [northInfo setHidden:YES];
    [yourInfo setHidden:YES];
    [westInfo setHidden:YES];
    [eastInfo setHidden:YES];
    [self addSubview:northInfo];
    [self addSubview:yourInfo];
    [self addSubview:westInfo];
    [self addSubview:eastInfo];
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));

    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        // 在这里执行锁释放的操作
        [northInfo setHidden:NO];
        [yourInfo setHidden:NO];
        [westInfo setHidden:NO];
        [eastInfo setHidden:NO];
    });

    // 顺便更新
    
}
-(void)updateThemesButtonStatus{
    if (!oldman && !(Open_Old)) {
        [self.opBar addSubview:_themesButton];
        [self.IpdownBackView setHidden:YES];
        self.opBar.backgroundColor=[UIColor clearColor];
    }else{
        [_themesButton removeFromSuperview];
        [self.IpdownBackView setHidden:NO];
    }
    //11
    // 0328 add oldman show
    if (oldman) {
        // 获取按钮的图片
        UIImage *settingBtnImage = [UIImage imageNamed:@"Settingss"];
        [self.btnSettings setImage:settingBtnImage forState:UIControlStateNormal];
        UIImage *newgame = [UIImage imageNamed:@"New"];
        [self.btnPlay setImage:newgame forState:UIControlStateNormal];
    }else{
        // 加载新的图片
        UIImage *settingbutn = [UIImage imageNamed:@"settings"];
        [self.btnSettings setImage:settingbutn forState:UIControlStateNormal];
        UIImage *newgame = [UIImage imageNamed:@"newgame"];
        [self.btnPlay setImage:newgame forState:UIControlStateNormal];
    }
}

- (void)uiAdjust
{
    int opbarIPd = IS_IPAD ? 10 :0;
    int opbarHeightpianyi1 = liuhai ? [self isLandscape] ? 20 : opbarHeightpianyi : opbarIPd;
    self.opBar.center = CGPointMake(_sc_width/2, _sc_height - self.opBar.frame.size.height/2-opbarHeightpianyi1);
    self.admobView.center = CGPointMake(_sc_width/2, _sc_height - opbarHeightpianyi1 -self.opBar.frame.size.height - (admobHeight1)/2);
    NSLog(@"zzx _sc_width= %lf",_sc_width);
#ifdef AD_POS_UP
        self.admobView.center = CGPointMake(_sc_width/2, self.admobView.frame.size.height/2-0.1);
#else
    if (self.hideOp) {
        //        self.admobView.center = CGPointMake(_sc_width/2, _sc_height - self.admobView.frame.size.height/2);
        
        [self.opBar setFrame:CGRectMake(0.0, self.frame.size.height, self.opBar.frame.size.width, self.opBar.frame.size.height)];
        self.admobView.center = CGPointMake(_sc_width/2, _sc_height - opbarHeightpianyi1 -(admobHeight1)/2);
        NSLog(@"zzx hideOp %lf",0.00);
    }
    else
    {
        if ([self isLandscape] && kScreenWidth >kScreenHeight) {
            
            CGRect opbarFrame=self.opBar.frame;
            opbarFrame.size.width=self.frame.size.width;
            self.opBar.frame=opbarFrame;
            NSLog(@"zzx _sc_width opBar.frame1 %lf",opbarFrame.size.width);
        }else{

            CGRect opbarFrame=self.opBar.frame;
            opbarFrame.size.width=kScreenWidth;
            self.opBar.frame=opbarFrame; NSLog(@"zzx _sc_width opBar.frame2%lf",opbarFrame.size.width);
        }
        self.opBar.center = CGPointMake(_sc_width/2, _sc_height - self.opBar.frame.size.height/2-opbarHeightpianyi1);
//        self.admobView.center = CGPointMake(_sc_width/2, _sc_height - -admobHeight1/2-opbarHeightpianyi1-self.opBar.frame.size.height);
    }
#endif
}

- (void)computeSizes:(BOOL)flag {
    if (flag) {
        CGSize fs = [UIApplication currentSize];
        _sc_width = fs.width;
        _sc_height = fs.height;
    }
    GLfloat width = _sc_width;
    GLfloat height = _sc_height;
    ////
    if ( width > height ) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            MARGINX = 40;
            MARGINY = 5;
        }
        else
        {
            MARGINX = 40;
            MARGINY = 5;
        }
        _h = ((height - MARGINY - (SHOW_AD ? self.admobView.frame.size.height : 0) - self.opBar.frame.size.height)/5);
        _w = _h*ASPECT_RATIO_X;
        _d = (width - 2*MARGINX - _w) / (KING-1);
    } else {
        MARGINY = 5;
        MARGINX = 10;
        _w = ((width - 2*MARGINX) / 10);
        _d = (width - 2*MARGINX - _w) / (KING-1);;
        _h = _w * ASPECT_RATIO_Y;
    }

    _s = _h/5.0;
    _f = _h/12.0;
    _o = _h/4.0;
    _fs = (height - (SHOW_AD ? self.admobView.frame.size.height : 0) - self.opBar.frame.size.height - 3*_h - 3*_s)/(KING)
                                                                                            ;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (width > height)
        {
            GAP_ANGLE = 15;
            YOUR_ANGEL = 3;
            OTHER_RADIUS = 90;
            YOUR_RADIUS = 1450;
            SELECT_DIFF_RADIUS = 40;
        }
        else
        {
            GAP_ANGLE = 15;
            YOUR_ANGEL = 3;
            OTHER_RADIUS = 90;
            YOUR_RADIUS = 1000;
            SELECT_DIFF_RADIUS = 40;
        }
    }
    else
    {
        if ( width > height ){
            GAP_ANGLE = 15;
            YOUR_ANGEL = 2;
            OTHER_RADIUS = 30;
            YOUR_RADIUS = 1000;
            SELECT_DIFF_RADIUS = 20;
        }
        else
        {
            GAP_ANGLE = 15;
            YOUR_ANGEL = 2;
            OTHER_RADIUS = 30;
            YOUR_RADIUS = 650;
            SELECT_DIFF_RADIUS = 20;
        }
    }
    
#ifdef AD_POS_UP
    MARGINY += (SHOW_AD ? self.admobView.frame.size.height : 0);
#endif
}

- (void)computeBottomCardLayout {
    [UIView animateWithDuration:0.1 animations:^{
        //CardView *cv;
        /// port
        if (_sc_width < _sc_height) {
         }
        /// land
        else
        {
        }
    }];
}

- (void)computeCardLayout:(float)duation destPos:(int)pos destIdx:(int)idx{
    float x=0;
    if ([_game isYourTurn]) {
        NSArray* canMoves = [_game yourCanDiscards];
        for (Card* c in [_game playerCards:0]) {
            CardView* cv = [cards objectForKey:c];
            if (![canMoves containsObject:c]) {
                cv.alpha = 0.5;
                c.hidden = YES;
                //cv.userInteractionEnabled = NO;
            }
            else
            {
                cv.alpha = 1;
                c.hidden = NO;
            }
        }
    }
    else
    {
        [self alphaBack];
    }
    [UIView animateWithDuration:duation animations:^{
        //NSLog(@"%d", [[UIDevice currentDevice] orientation]);
        CardView *cv;
        CGFloat baseX, baseY;
        int idx = 0;
        int cardleft = 0;
        CGFloat rangle = 0;
        CGFloat user1IpdX=0;
        CGFloat user2IpdY=0;
        CGFloat user3IpdX=0;
        CGFloat user02IpdX=0;//让左右再缩进去20
        if (kScreenWidth + kScreenHeight >1500 && ZH_IS_IPAD) {
            user1IpdX =30;user2IpdY=30;
            user3IpdX =30;user02IpdX=40;
        }
        int yourInfoDown=0;
        if (oldman) {
            yourInfoDown =30;
        }
        ///
        /// port
        if (_sc_width < _sc_height) {
            ///play 1
            baseX = MARGINX -user02IpdX;
            baseY = _sc_height*2/5;
            idx = 0;
            cardleft = [[_game playerCards:1] count];
            for (Card* c in [_game playerCards:1]) {
                rangle = ((KING - cardleft)/2.0 + idx)*GAP_ANGLE;
                cv = [cards objectForKey:c];
                if (c.selected) {
                    cv.center = CGPointMake(baseX + (OTHER_RADIUS+SELECT_DIFF_RADIUS*0.5)*sin(rangle*M_PI/180.0), baseY - (OTHER_RADIUS+SELECT_DIFF_RADIUS*0.5)*cos(rangle*M_PI/180.0));
                }
                else
                    cv.center = CGPointMake(baseX + OTHER_RADIUS*sin(rangle*M_PI/180.0), baseY - OTHER_RADIUS*cos(rangle*M_PI/180.0));
                
                [cv rotateAngle:rangle animation:NO];
                [self bringSubviewToFront:cv];
                idx++;
            }
            westInfo.center = CGPointMake(BUFFER_WIDTH + INFO_WIDTH/2, baseY + _h*5/3);
            [westInfo setNeedsDisplay];
            ///play 2
//            baseX = _sc_width/2 +user1IpdX;
//            baseY = liuhai ? MARGINY + 44 -user2IpdY  :MARGINY - user2IpdY;
            baseX = _sc_width/2 +user1IpdX;
            baseY = liuhai ? MARGINY + 44 -user02IpdX :MARGINY -user02IpdX;
            idx = 0;
            cardleft = [[_game playerCards:2] count];
            for (Card* c in [_game playerCards:2]) {
                rangle = ((KING - cardleft)/2.0 + idx)*GAP_ANGLE + 90;
                cv = [cards objectForKey:c];
                if (c.selected) {
                    cv.center = CGPointMake(baseX + (OTHER_RADIUS+SELECT_DIFF_RADIUS*0.5)*sin(rangle*M_PI/180.0), baseY - (OTHER_RADIUS+SELECT_DIFF_RADIUS*0.5)*cos(rangle*M_PI/180.0));
                }
                else
                    cv.center = CGPointMake(baseX + OTHER_RADIUS*sin(rangle*M_PI/180.0), baseY - OTHER_RADIUS*cos(rangle*M_PI/180.0));
                
                [cv rotateAngle:rangle animation:NO];
                [self bringSubviewToFront:cv];
                idx++;
            }
            if (ZH_IS_IPAD && kScreenWidth + kScreenHeight >1500 )
                northInfo.center = CGPointMake(baseX -30, baseY + _h*5/3);
            else
                northInfo.center = CGPointMake(baseX, baseY + _h*5/3);
            
            [northInfo setNeedsDisplay];
            ///play 3
            baseX = _sc_width - MARGINX +user02IpdX;
            baseY = _sc_height*2/5 ;
            idx = 0;
            cardleft = [[_game playerCards:3] count];
            for (Card* c in [_game playerCards:3]) {
                rangle = ((KING - cardleft)/2.0 + idx)*GAP_ANGLE + 180;
                cv = [cards objectForKey:c];
                if (c.selected) {
                    cv.center = CGPointMake(baseX + (OTHER_RADIUS+SELECT_DIFF_RADIUS*0.5)*sin(rangle*M_PI/180.0), baseY - (OTHER_RADIUS+SELECT_DIFF_RADIUS*0.5)*cos(rangle*M_PI/180.0));
                }
                else
                    cv.center = CGPointMake(baseX + OTHER_RADIUS*sin(rangle*M_PI/180.0), baseY - OTHER_RADIUS*cos(rangle*M_PI/180.0));
                
                [cv rotateAngle:rangle animation:NO];
                [self bringSubviewToFront:cv];
                idx++;
            }
            eastInfo.center = CGPointMake(_sc_width - BUFFER_WIDTH - INFO_WIDTH/2, baseY + _h*5/3);
            [eastInfo setNeedsDisplay];
            ///play 0
            baseX = _sc_width/2;
#ifndef AD_POS_UP//zzx
            baseY = _sc_height - (SHOW_AD ? self.admobView.frame.size.height : 0) - (self.hideOp ? 0 : self.opBar.frame.size.height) - _h - (liuhai ? 33 : 0);
#else
            baseY = _sc_height - (self.hideOp ? 0 : self.opBar.frame.size.height) - _h;
#endif
            idx = 0;
            cardleft = [[_game playerCards:0] count];
            for (Card* c in [_game playerCards:0]) {
                rangle = ((KING - cardleft)/2.0 + idx)*YOUR_ANGEL - 6*YOUR_ANGEL;
                cv = [cards objectForKey:c];
                if (c.selected) {
                    // 点击牌牌的移动
                    cv.center = CGPointMake(baseX + (YOUR_RADIUS+SELECT_DIFF_RADIUS)*sin(rangle*M_PI/180.0), baseY + YOUR_RADIUS - (YOUR_RADIUS+SELECT_DIFF_RADIUS)*cos(rangle*M_PI/180.0));
                }
                else
                    cv.center = CGPointMake(baseX + YOUR_RADIUS*sin(rangle*M_PI/180.0), baseY + YOUR_RADIUS - YOUR_RADIUS*cos(rangle*M_PI/180.0));
                
                //[cv rotateAngle:rangle animation:NO];
                [cv rotateScale:rangle animation:NO rate:1.5];
                [self bringSubviewToFront:cv];
                idx++;
            }
            
            yourInfo.center = CGPointMake(baseX, baseY - 6*_h/5- (liuhai ? 0 : 0)+30-yourInfoDown);
            [yourInfo setNeedsDisplay];
         }
        /// land
        else
        {
            ///play 1 zzx
            baseX = ZH_IS_IPAD && kScreenWidth + kScreenHeight > 1500 ? MARGINX -40 -user02IpdX : MARGINX -20;
            baseY = _sc_height*2/5;
            idx = 0;
            cardleft = [[_game playerCards:1] count];
            for (Card* c in [_game playerCards:1]) {
                rangle = ((KING - cardleft)/2.0 + idx)*GAP_ANGLE;
                cv = [cards objectForKey:c];
                if (c.selected) {
                    cv.center = CGPointMake(baseX + (OTHER_RADIUS+SELECT_DIFF_RADIUS*0.5)*sin(rangle*M_PI/180.0), baseY - (OTHER_RADIUS+SELECT_DIFF_RADIUS*0.5)*cos(rangle*M_PI/180.0));
                }
                else
                    cv.center = CGPointMake(baseX + OTHER_RADIUS*sin(rangle*M_PI/180.0), baseY - OTHER_RADIUS*cos(rangle*M_PI/180.0));
                
                [cv rotateAngle:rangle animation:NO];
                [self bringSubviewToFront:cv];
                idx++;
            }
            if (ZH_IS_IPAD && kScreenWidth + kScreenHeight > 1500) {
                westInfo.center = CGPointMake(MARGINX + _h*5/3 -50, baseY);
            }
            else
                westInfo.center = CGPointMake(MARGINX + _h*7/4-20, baseY);
            [westInfo setNeedsDisplay];
            ///play 2
            baseX = _sc_width/2;
            baseY =ZH_IS_IPAD && kScreenWidth + kScreenHeight > 1500 ? MARGINY*3/5 -40 : MARGINY*3/5+10;
            idx = 0;
            cardleft = [[_game playerCards:2] count];
            for (Card* c in [_game playerCards:2]) {
                rangle = ((KING - cardleft)/2.0 + idx)*GAP_ANGLE + 90;
                cv = [cards objectForKey:c];
                if (c.selected) {
                    cv.center = CGPointMake(baseX + (OTHER_RADIUS+SELECT_DIFF_RADIUS*0.5)*sin(rangle*M_PI/180.0), baseY - (OTHER_RADIUS+SELECT_DIFF_RADIUS*0.5)*cos(rangle*M_PI/180.0));
                }
                else
                    cv.center = CGPointMake(baseX + OTHER_RADIUS*sin(rangle*M_PI/180.0), baseY - OTHER_RADIUS*cos(rangle*M_PI/180.0));
                
                [cv rotateAngle:rangle animation:NO];
                [self bringSubviewToFront:cv];
                idx++;
            }
            if (ZH_IS_IPAD && kScreenWidth + kScreenHeight > 1500) {
                northInfo.center = CGPointMake(baseX - _h*2+10, baseY+_h);
            }
            else
                northInfo.center = CGPointMake(baseX - _h*2, baseY+_h);
            [northInfo setNeedsDisplay];
            ///play 3
            baseX =  ZH_IS_IPAD && kScreenWidth + kScreenHeight > 1500 ? _sc_width - MARGINX +40 +user02IpdX :_sc_width - MARGINX+20;//update0326
            baseY = _sc_height*2/5;
            idx = 0;
            cardleft = [[_game playerCards:3] count];
            for (Card* c in [_game playerCards:3]) {
                rangle = ((KING - cardleft)/2.0 + idx)*GAP_ANGLE + 180;
                cv = [cards objectForKey:c];
                if (c.selected) {
                    cv.center = CGPointMake(baseX + (OTHER_RADIUS+SELECT_DIFF_RADIUS*0.5)*sin(rangle*M_PI/180.0), baseY - (OTHER_RADIUS+SELECT_DIFF_RADIUS*0.5)*cos(rangle*M_PI/180.0));
                }
                else
                    cv.center = CGPointMake(baseX + OTHER_RADIUS*sin(rangle*M_PI/180.0), baseY - OTHER_RADIUS*cos(rangle*M_PI/180.0));
                
                [cv rotateAngle:rangle animation:NO];
                [self bringSubviewToFront:cv];
                idx++;
            }
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                eastInfo.center = CGPointMake(baseX - _h*5/3, baseY);
            }
            else
                eastInfo.center = CGPointMake(baseX - _h*7/4, baseY);
            [eastInfo setNeedsDisplay];
            ///play 0
            baseX = _sc_width/2;
#ifndef AD_POS_UP
            baseY = _sc_height - (SHOW_AD ? self.admobView.frame.size.height : 0) - (self.hideOp ? 0 : self.opBar.frame.size.height) - _h - (liuhai ? 20 : 0);
#else
            baseY = _sc_height - (self.hideOp ? 0 : self.opBar.frame.size.height) - _h;
#endif
            idx = 0;
            cardleft = [[_game playerCards:0] count];
            for (Card* c in [_game playerCards:0]) {
                rangle = ((KING - cardleft)/2.0 + idx)*YOUR_ANGEL - 6*YOUR_ANGEL;
                cv = [cards objectForKey:c];
                if (c.selected) {
                    cv.center = CGPointMake(baseX + (YOUR_RADIUS+SELECT_DIFF_RADIUS)*sin(rangle*M_PI/180.0), baseY + YOUR_RADIUS - (YOUR_RADIUS+SELECT_DIFF_RADIUS)*cos(rangle*M_PI/180.0));
                }
                else
                    cv.center = CGPointMake(baseX + YOUR_RADIUS*sin(rangle*M_PI/180.0), baseY + YOUR_RADIUS - YOUR_RADIUS*cos(rangle*M_PI/180.0));
                
                //[cv rotateAngle:rangle animation:NO];
                [cv rotateScale:rangle animation:NO rate:1.5];
                [self bringSubviewToFront:cv];
                idx++;
            }
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                yourInfo.center = CGPointMake(baseX + _h*3, baseY - _h*2/3 - (liuhai ? 20 : 0));
            }
            else
                yourInfo.center = CGPointMake(baseX + _h*3, baseY - _h - (liuhai ? 0 : 0) +30 -yourInfoDown);
            [yourInfo setNeedsDisplay];
        }
        ///
        CGFloat centerX = _sc_width/2;
        CGFloat centerY = _sc_height*2/5;
        ///
        if ([_game discardingState] || _game.currentstate == STATE_COLLECTCARD) {
            for (int i = 0; i < [_game.fourcards count]; i++)
            {
                Card* c = [_game.fourcards objectAtIndex:i];
                cv = [cards objectForKey:c];
                if (cv == nil) {
                    CardView *nv = [[CardView alloc]
                                    initWithFrame:CGRectMake(centerX, centerY, _w, _h)
                                    andCard:c];
                    [cards setObject:nv forKey:c];
                    [self addSubview:nv];
                }
                float gap =_h*1;
                switch ((_game.firstplay+i)%4) {
                        // update 0401
                        
                    case 0:
                        cv.center = CGPointMake(centerX, centerY + gap);
                        break;
                    case 1:
                        cv.center = CGPointMake(centerX - gap, centerY);
                        break;
                    case 2:
                        cv.center = CGPointMake(centerX, centerY - gap);
                        break;
                    case 3:
                        cv.center = CGPointMake(centerX + gap, centerY);
                        break;
                    default:
                        break;
                }
                
                //if (!cv.rotatedFlag)
                //    [cv rotateAngle:rand()%180 animation:YES];
                if (!cv.rotatedFlag)
                    [cv rotateScale:rand()%100 animation:YES rate:1.2];
                [cv setNeedsDisplay];
               
                [self bringSubviewToFront:cv];
            }
        }
        else if (_game.currentstate == STATE_COLLECTDONE)
        {
            for (Card* c in _game.fourcards) {
                cv = [cards objectForKey:c];
                cv.center = [self pos2CollectPos:_game.firstplay];
                [cv setNeedsDisplay];
                [self bringSubviewToFront:cv];
            }
        }
        /// surface
        if (self.topCards != nil) {
            for (Card* card in self.topCards) {
                [[cards objectForKey:card] setNeedsDisplay];
                [self bringSubviewToFront:[cards objectForKey:card]];
            }
        }
        self.topCards = nil;
        /// fresh
        for (int i = 0; i < NUM_PLAYERS; i++) {
            for (Card* card in [_game playerCards:i]) {
                [[cards objectForKey:card] setNeedsDisplay];
            }
        }
        /// opbar to top
        [self bringSubviewToFront:self.opBar];
        [self bringSubviewToFront:self.admobView];
        /// update score
        [self updateScoresDisplay];
    } completion:^(BOOL finished){
        moveFlag = NO;
        if (hintstr != nil) {
            [self makeToast:hintstr duration:0.4 position:@"center"];
        }
        for (CardView* v in collectCVs) {
            v.hidden = YES;
            [v setNeedsDisplay];
        }
        
        if (pos != -1) {
            self.anaIdx++;
            finishFlag = YES;
            if (_game.currentstate == STATE_GAMEEND) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"autoCompleteDone" object:@"done"];
            }
            if (_game.currentstate == STATE_STANDING) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"standing" object:@"standing"];
            }
            if (self.anaIdx < self.anaCnt) {
                [self anamiationDone];
            }
            else
                [self stopHintAnamiation];
            [UIView animateWithDuration:HINTINFO_TIME
                             animations:^{
                                 self.hintLabel.alpha = 0.0;
         }];
        }
        else
        {
            if ([self.game alreadyDone]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"autoCompleteDone" object:@"done"];
                [self setUserInteractionEnabled:YES];
            }
        }
    }];
}

- (CGFloat)speedTime
{
    CGFloat baseTime = SPEED_TIME;
    if (self.speed == 0) {
        baseTime *= 2;
    }
    else if (self.speed == 2)
    {
        baseTime /= 2;
    }
    return baseTime;
}

#pragma mark Touch Events

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView {
    if (self.game.won) {
        return;
    }
    touchStartPoint = [[touches anyObject] locationInView:self];
    startCenter = cardView.center;
    moveFlag = NO;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView {
    if (self.game.won) {
        return;
    }
    if (self.hinting) {
        [self stopHintAnamiation];
        return;
    }
    if (![_game isYourTurn]) {
        return;
    }
    if (![_game isYourCard:cardView.card]) {
        return;
    }
    if (cardView.card.hidden) {
        return;
    }
    // Pick up the fan and move it
    CGPoint touchPoint = [[touches anyObject] locationInView:self]; 
    CGPoint delta = CGPointMake(touchPoint.x - touchStartPoint.x, touchPoint.y - touchStartPoint.y);
    CGPoint newCenter = CGPointMake(startCenter.x + delta.x, startCenter.y + delta.y);
    
    cardView.center = CGPointMake(newCenter.x, newCenter.y);

    moveFlag = YES;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView  {
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView  {
    if (self.game.won) {
        return;
    }
    Card* c = cardView.card;
    if (![_game isYourCard:cardView.card]) {
        return;
    }
    if (![_game isYourTurn] && _game.currentstate != STATE_SELECTCONFIRM) {
        return;
    }
    if (cardView.card.hidden) {
        return;
    }
    if (((UITouch*)[touches anyObject]).tapCount == 1
        && moveFlag == NO
        && _game.currentstate == STATE_SELECTCONFIRM)
    {
        c.selected = !c.selected;
        [self updatePassBtn];
        [self computeCardLayout:[self speedTime] destPos:-1 destIdx:-1];
        return;
    }
    ///
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (moveFlag
        && _game.currentstate >= STATE_DISCARDONE
        && _game.currentstate <= STATE_DISCARDFOUR
        && touchStartPoint.y - touchPoint.y > _h/2
        )
    {
        BOOL oldbroken = _game.broken;
        [_game discardYourCard:c];
        [TheSound playDealSound];
        if (!oldbroken && _game.broken) {
            [self heartBroken];
        }
        if ([_game.fourcards count] > 0) {
            Card* fc = [_game.fourcards lastObject];
            if (fc.rank == QUEEN
                && fc.suit == SPADES) {
                [TheSound playSpadeSound];
            }
        }
    }
    ///
    moveFlag = NO;
    [self computeCardLayout:[self speedTime] destPos:-1 destIdx:-1];
}

- (void)anamiationDone
{
    self.hintLabel.alpha = 0;
}

- (void)stopHintAnamiation
{
    [_delegate cancelDelay];
    [self anamiationDone];
    self.hinting = NO;
}

- (void)alphaBack
{
    for (Card* c in cards) {
        CardView* cv = [cards objectForKey:c];
        cv.alpha = 1;
        c.hidden = NO;
        //cv.userInteractionEnabled = YES;
    }
}

- (void)updatePassBtn
{
    if (_game.handcnt%4 == 0)
        return;
    if (_game.currentstate == STATE_SELECTPASSCARD) {
        switch (_game.handcnt%4) {
            case 1:
                [self.btnPass setBackgroundImage:[UIImage imageNamed:@"arrow-left"] forState:UIControlStateNormal];
                break;
            case 2:
                [self.btnPass setBackgroundImage:[UIImage imageNamed:@"arrow-right"] forState:UIControlStateNormal];
                break;
            case 3:
                [self.btnPass setBackgroundImage:[UIImage imageNamed:@"arrow-across"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        self.btnPass.hidden = NO;
        self.btnPass.enabled = YES;
    }
    else if (_game.currentstate == STATE_EXCHANGE)
    {
        self.btnPass.hidden = YES;
    }
    else if (_game.currentstate == STATE_SELECTCONFIRM)
    {
        switch (_game.handcnt%4) {
            case 1:
                [self.btnPass setBackgroundImage:[UIImage imageNamed:@"arrow-left"] forState:UIControlStateNormal];
                break;
            case 2:
                [self.btnPass setBackgroundImage:[UIImage imageNamed:@"arrow-right"] forState:UIControlStateNormal];
                break;
            case 3:
                [self.btnPass setBackgroundImage:[UIImage imageNamed:@"arrow-across"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        self.btnPass.hidden = NO;
        int selcnt = 0;
        for (Card* c in [_game playerCards:0]) {
            if (c.selected) {
                selcnt++;
            }
        }
        if (selcnt == 3) {
            self.btnPass.enabled = YES;
        }
        else
            self.btnPass.enabled = NO;
    }
    else
    {
        self.btnPass.hidden = YES;
    }
}

- (CGPoint)pos2CollectPos:(int)pos
{
    switch (pos) {
        case 0:
            return CGPointMake(_sc_width/2, _sc_height + _h);
            break;
        case 1:
            return CGPointMake(-_w, _sc_height*2/5);
            break;
        case 2:
            return CGPointMake(_sc_width/2, -_h);
            break;
        case 3:
            return CGPointMake(_sc_width + _w, _sc_height*2/5);
            break;
        default:
            break;
    }
    return CGPointMake(-_w, -_h);
}

- (void)turn
{
    if (turnFlag || moveFlag) {
        return;
    }
    turnFlag = YES;
    hintstr = nil;
    if (finishFlag) {
        finishFlag = NO;
        [self updatePassBtn];
        ///
        switch (_game.currentstate) {
            case STATE_BEGIN:
                if (_game.handcnt%4==0) {
                    _game.firstplay = [_game whoHasClubs2];
                    _game.currentstate = STATE_DISCARDONE;
                }
                else
                    _game.currentstate = STATE_SELECTPASSCARD;
                break;
            case STATE_SELECTPASSCARD:
                [_game selectPassCards];
                [TheSound playCollectSound];
                _game.currentstate = STATE_SELECTCONFIRM;
                break;
            case STATE_SELECTCONFIRM:
                ;
                break;
            case STATE_EXCHANGE:
                [_game exchangeCards];
                [TheSound playCollectSound];
                _game.currentstate = STATE_INSERT;
                break;
            case STATE_INSERT:
                [_game insertPassCards];
                [TheSound playCollectSound];
                _game.firstplay = [_game whoHasClubs2];
                _game.currentstate = STATE_DISCARDONE;
                break;
            case STATE_DISCARDONE:
            case STATE_DISCARDTWO:
            case STATE_DISCARDTHREE:
            case STATE_DISCARDFOUR:
            {
                BOOL oldbroken = _game.broken;
                if ([_game aiDiscard]) {
                    if (!oldbroken && _game.broken) {
                        [self heartBroken];
                    }
                    if ([_game.fourcards count] > 0) {
                        Card* fc = [_game.fourcards lastObject];
                        if (fc.rank == QUEEN
                            && fc.suit == SPADES) {
                            [TheSound playSpadeSound];
                        }
                    }
                    [TheSound playDealSound];
                }
            }
                break;
            case STATE_COLLECTCARD:
                _game.firstplay = [_game whoCollect];
                _game.currentstate = STATE_COLLECTDONE;
                [TheSound playCollectSound];
                break;
            case STATE_COLLECTDONE:
                if ([[_game playerCards:0] count] == 0) {
                    if ([_game check26]) {
                        [self makeToast:@"Shooting the Moon!" duration:0.3 position:@"center"];
                    }
                    [_game addCurrentToTotal];
                    [self updateScoresDisplay];
                    _game.currentstate = STATE_STANDING;
                }
                else
                {
                    _game.currentstate = STATE_DISCARDONE;
                }
                for (Card *c in _game.fourcards) {
                    CardView* v = [cards objectForKey:c];
                    if (v != nil)
                        [collectCVs addObject:v];
                }
                [_game.fourcards removeAllObjects];
                break;
            case STATE_STANDING:
                if ([_game gameOver] >= 0) {
                    _game.currentstate = STATE_GAMEEND;
                }
                else
                {
                    _game.currentstate = STATE_DEALEND;
                    self.dealBtn.hidden = NO;
                }
                break;
            case STATE_DEALEND:
            {
                if ([_game gameOver] >= 0) {
                    _game.currentstate = STATE_GAMEEND;
                }
                else
                {
                    self.dealBtn.hidden = NO;
                }
            }
                break;
            case STATE_GAMEEND:
                break;
            default:
                break;
        }
        ///
        if (_game.currentstate == lastState) {
            lastCnt++;
        }
        else
        {
            lastCnt = 1;
        }
        lastState = _game.currentstate;
        ///give hint
        if (lastCnt >= HINT_TIME_INTERNAL/[self speedTime]) {
            hintstr = @"It's your turn!";
            switch (_game.currentstate) {
                case STATE_SELECTCONFIRM:
                    hintstr = @"Tap to select 3 cards to pass!";
                    break;
                case STATE_DISCARDONE:
                case STATE_DISCARDTWO:
                case STATE_DISCARDTHREE:
                case STATE_DISCARDFOUR:
                    hintstr = @"Move a card to discard!";
                    break;
                case STATE_DEALEND:
                    hintstr = @"Click 'Deal' to start a new hand!";
                    break;
                case STATE_GAMEEND:
                    hintstr = @"Tap 'play' menu to start a new game!";
                    break;
                default:
                    break;
            }
            lastCnt = 0;
        }
        ///zzx 0308
        [self computeCardLayout:[self speedTime] destPos:POS_TABEAU destIdx:-1];
    }
    turnFlag = NO;
}

- (void)updateScoresDisplay
{
    [yourInfo setInfo:@"You" curscore:[[_game.currentscores objectAtIndex:0] integerValue] totalscore:[[_game.totalscores objectAtIndex:0] integerValue]];
    [westInfo setInfo:@"West" curscore:[[_game.currentscores objectAtIndex:1] integerValue] totalscore:[[_game.totalscores objectAtIndex:1] integerValue]];
    [northInfo setInfo:@"North" curscore:[[_game.currentscores objectAtIndex:2] integerValue] totalscore:[[_game.totalscores objectAtIndex:2] integerValue]];
    [eastInfo setInfo:@"East" curscore:[[_game.currentscores objectAtIndex:3] integerValue] totalscore:[[_game.totalscores objectAtIndex:3] integerValue]];
}

//- (void)layoutSubviews {
//
//}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//}

- (IBAction)passConfirm:(id)sender {
    _game.currentstate = STATE_EXCHANGE;
    [self updatePassBtn];
    [self turn];
}
- (IBAction)newHand:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closestanding" object:self];
}

- (void)newDeal
{
    self.dealBtn.hidden = YES;
    [_game newDeal:nil];
    [self setGame:_game];
    _game.currentstate = STATE_BEGIN;
}

- (BOOL)getCurrentSound{
    //    获取当前音量
    CGFloat volume = audioSession.outputVolume;
    if (volume*100<1) {
        return false;
    }else{
        return true;
    }
}
- (BOOL)isNotchScreen {
    
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets;
        if (safeAreaInsets.left>0) {
            NSLog(@"这是safeAreaInsets.left>0屏");
            return YES;
        }
        if (safeAreaInsets.right>0) {
            NSLog(@"这是safeAreaInsets.right>0屏");
            return YES;
        }
        if (safeAreaInsets.bottom>0) {
            NSLog(@"这是safeAreaInsets.bottom>0屏");
            return YES;
        }
        if (safeAreaInsets.top > 0) {
            // 是刘海屏
            NSLog(@"这是刘海屏");
            return YES;
        }
    }
    NSLog(@"zzx have not hair");
    return NO;
}

- (BOOL)isLandscape {
    // 横屏
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return UIDeviceOrientationIsLandscape(orientation);
}

//-(void) preSetFreeHints {
//   NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
//   id obj = [settings objectForKey:New_Boy_Comming];
//   if(obj == nil) {
//       long opencount = [[[AdmobViewController shareAdmobVC] getAppUseStats] getAppOpenCountTotal];
//       if(opencount > 3) {
//       }
//       [settings synchronize];
//   }
//}
- (void) IsOldman{
    // New_Boy_Comming 是判断第一次是老用户还是薪用户
    NSUserDefaults* settings1 = [NSUserDefaults standardUserDefaults];
    id obj = [settings1 objectForKey:New_Boy_Comming];
    id obj1 = [settings1 objectForKey:@"changetoNewMan"];
    BOOL NewMan =[settings1 boolForKey:@"changetoNewMan"];
    if (obj == nil) {
        // 说嘛此前已经进入过了是老用户
        oldman =true;
    }
    if (obj1 == nil) {
        // 说明此前没有改变新老用户状态
        return;
    }
    if (NewMan) {
        oldman =false;
        return;
    }else{
        oldman =true;
        return;
    }
}

- (BOOL)isPortrait {
    return _sc_width < _sc_height;
}

@end
