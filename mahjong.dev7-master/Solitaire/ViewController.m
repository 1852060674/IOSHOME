//
//  ViewController.m
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ViewController.h"
#import "UIApplication+Size.h"
#import "Config.h"
#import "Toast+UIView.h"
#import "TheSound.h"
#import "PicView.h"
#import "MBProgressHUD.h"
#include "ApplovinMaxWrapper.h"
#import "ProtocolAlerView.h"
#import <SafariServices/SafariServices.h>
#include "ApplovinMaxWrapper.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
@import Flurry_iOS_SDK;
extern Solitaire* game;

@interface ViewController ()
{
    __weak IBOutlet NSLayoutConstraint *LeftOPBarTrall;
    __weak IBOutlet NSLayoutConstraint *RightOPBarlead;
    __weak IBOutlet NSLayoutConstraint *admobHeight;
    __weak IBOutlet UIView *LeftOPBar;
    __weak IBOutlet UIView *RightOPBar;
    __weak IBOutlet NSLayoutConstraint *topHeight;
    __weak IBOutlet NSLayoutConstraint *topwith;
    __weak IBOutlet UIView *BackView;
    __weak IBOutlet UILabel *hintBadge;
    NSTimer *timer;
    BOOL undoFlag;
    BOOL shuffleFlag;
    BOOL firstIn;
    //
    MBProgressHUD* nethud;
    
    long show_banner;
    BOOL ad_show_last_round_end;
    
    BOOL ad_before_win;
    int last_full_ad_pos;
    BOOL ShowAdward;
    int freehintsTop;// 放在头顶的
    int freehints;// 获取用户是否为老用户
    BOOL ShowSetting;
    NSUserDefaults* settingss;
}

@end

@implementation ViewController

- (void)loadSettings
{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    //sound
    self.gameView.sound = [settings boolForKey:@"sound"];
    [self.gameView.btnShuffle bringSubviewToFront:hintBadge];

    /////
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reset_banner_downcount];
    
    self.gameView.delegate = self;
    
    //free hints
    
    
    ShowSetting=NO;
    //
    ///
    nethud = [MBProgressHUD showHUDAddedTo:self.gameView animated:YES];
    nethud.labelText = @"loading ...";
    //
    [self setBackImage];
    self.scoreBg.image = self.timeBg.image = [UIImage imageNamed:[NSString stringWithFormat:@"textarea_%d",game.groupId]];
    self.matchBg.image = [UIImage imageNamed:[NSString stringWithFormat:@"match_%d",game.groupId]];
    self.leftBg.image = [UIImage imageNamed:[NSString stringWithFormat:@"left_%d",game.groupId]];
    self.rightBg.image = [UIImage imageNamed:[NSString stringWithFormat:@"right_%d",game.groupId]];
    self.helpBgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bg%d.jpg",game.groupId]];
    [self.gameView.btnBack setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"gameback_%d",game.groupId]] forState:UIControlStateNormal];
    [self.gameView.btnShuffle setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"shuffle_%d",game.groupId]] forState:UIControlStateNormal];
    [self.gameView.btnHint setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"hint_%d",game.groupId]] forState:UIControlStateNormal];
    [self.gameView.btnReplay setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"replay_%d",game.groupId]] forState:UIControlStateNormal];
    [self.gameView.btnUndo setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"undo_%d",game.groupId]] forState:UIControlStateNormal];
    [self.gameView.btnPause setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"pause_%d",game.groupId]] forState:UIControlStateNormal];
    [self.gameView.btnHelp setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"help_%d",game.groupId]] forState:UIControlStateNormal];
    //
    //nethud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //nethud.labelText = @"loading ...";
	// Do any additional setup after loading the view, typically from a nib.
    //[CardView initRes:game.groupId];
    /// settings
    [self loadSettings];
    ///
    srand(time(NULL));
    //[game freshGame:nil];
    //self.gameView.game = _game;
    firstIn = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    [timer setFireDate:[NSDate distantFuture]];
    ///
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"autoCompleteDone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoCompleteDone:) name:@"autoCompleteDone" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"controlTimer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTimer:) name:@"controlTimer" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"gameWin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameWin:) name:@"gameWin" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hidehud" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidehud:) name:@"hidehud" object:nil];
    ///
    undoFlag = NO;
    shuffleFlag = NO;
    //
    
    [[AdmobViewController shareAdmobVC] ifNeedShowNext:self];
    ad_show_last_round_end = NO;
    [self updateAdTime];
    
    last_full_ad_pos = 0;
    
    [Flurry logEvent:@"Start" withParameters:@{@"level":[NSNumber numberWithInteger:game.layoutid]}];
    
    NSLog(@"level1111111%ld",game.layoutid);
    [self performSelectorInBackground:@selector(loadgame) withObject:self];
    
    [self.gameView.admobView setAlpha:1];
    
    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];
    CGFloat admobHeight1 = [applovinWrapper getAdmobHeight];
    if ([self isNotchScreen]) {
        topHeight.constant=60;
        topwith.constant=300;
    }
    NSLog(@"3 admobHeight1=%f",admobHeight1);
    admobHeight.constant=admobHeight1;
    
    // add zh alert admob something
    NSLog(@"Admobwidth = %lf,AdmobHeight = %lf",self.gameView.admobView.frame.size.width,self.gameView.admobView.frame.size.height);
    [self reloadHintsBadge];
    [self preSetFreeHints];
    [self updateHintsBadge];
}

- (void)adMobVCDidCloseInterstitialAd:(AdmobViewController *)adMobVC
{
    //
    if(last_full_ad_pos == 1)
        [self.gameView showOver];
}

- (void)enableTimer:(BOOL)flag
{
    if (flag) {
        [self reset_banner_downcount];
        [timer setFireDate:[NSDate distantPast]];
    } else
        [timer setFireDate:[NSDate distantFuture]];
}

- (void)controlTimer:(NSNotification*)notifycation
{
    BOOL flag = [notifycation.object boolValue];
    [self enableTimer:flag];
}

- (void)gameWin:(NSNotification*)notifycation
{
    NSLog(@"win .........");
    if(ad_before_win) {
        [self showFullAds];
    } else {
        [self.gameView showOver];
    }
}

- (void)updateTime
{
    [self update_admob_banner_status];
    
    if (game.won || game.lose || self.gameView.overflag) {
        return;
    }
    ///
    game.times++;
    self.gameView.timeLabel.text = [NSString stringWithFormat:@"Time : %d:%02d",game.times/60,game.times%60];
    if (game.times%15 == 0) {
        game.scores -= 50;
        if (game.scores < 0) {
            game.scores = 0;
        }
        self.gameView.scoreLabel.text = [NSString stringWithFormat:@"Score : %d",game.scores];
    }
}

- (IBAction)shuffle:(id)sender {
    if (game.won || game.lose || self.gameView.overflag) {
        return;
    }
    if (self.gameView.hinting) {
        return;
    }
    if (undoFlag || shuffleFlag)
        return;
    // zzx add adward
    if(freehintsTop == 0) {
        if([self showHint]) {
            return;
        }
        [[AdmobViewController shareAdmobVC] showRewardAd:self placeid:0];
        return ;
    } else {
        if (freehints< 99) {
            freehintsTop -= 1;
            [self updateHintsBadge];
        }
    }
    ///
    shuffleFlag = YES;
    [TheSound playTapSound];
    [self.gameView clearSelectedState];
    [game shuffleCurrent];
    game.scores -= 200;
    if (game.scores < 0) {
        game.scores = 0;
    }
    [self.gameView computeCardLayout:0.2 destPos:-1 destIdx:-1];
    shuffleFlag = NO;
    [Flurry logEvent:@"Shuffle" withParameters:@{@"level":[NSNumber numberWithInteger:game.layoutid]}];
    
}

- (IBAction)update:(id)sender {
}

- (IBAction)replayGame:(id)sender {
    [self preSetFreeHints];
    [self updateHintsBadge];
    if (self.gameView.hinting) {
        return;
    }
    if (undoFlag || shuffleFlag)
        return;
    [TheSound playTapSound];
    [game replayGame];
    self.gameView.game = game;
    [self enableTimer:NO];
    //
    //[self showFullAds];
    
    if(!game.won && !self.gameView.overflag) {
        long count = [[[AdmobViewController shareAdmobVC] getAppUseStats] getAppOpenCountTotal];
        NSLog(@"%d",count);
        if(count > 5) {
            last_full_ad_pos = 0;
            [self tryCallFullAds:NO];
        }
        [Flurry logEvent:@"Replay" withParameters:@{@"level":[NSNumber numberWithInteger:game.layoutid]}];
    }
}

- (IBAction)pauseGame:(id)sender {
    if (game.won || game.lose || self.gameView.overflag) {
        return;
    }
    [TheSound playTapSound];
    [self enableTimer:NO];
    [self.gameView onPause];
    [self.gameView.LeftOPBar setAlpha:0];
    [self.gameView.RightOPBar setAlpha:0];
}
//11.20
- (IBAction)mahjongHelp:(id)sender {
    [TheSound playTapSound];
    [self.gameView onHelp];
    [self.gameView.LeftOPBar setAlpha:0];
    [self.gameView.RightOPBar setAlpha:0];
    [self.gameView.admobView setAlpha:0];
    [BackView setAlpha:0];
}

- (IBAction)onBack:(id)sender {
    [TheSound playTapSound];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"autoCompleteDone" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"controlTimer" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"gameWin" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hidehud" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
    if(!game.won && !self.gameView.overflag) {
        long count = [[[AdmobViewController shareAdmobVC] getAppUseStats] getAppOpenCountTotal];
        if(count > 5) {
            last_full_ad_pos = 0;
            [self tryCallFullAds:NO];
        }
        [Flurry logEvent:@"Quit" withParameters:@{@"level":[NSNumber numberWithInteger:game.layoutid]}];
    }
}

- (IBAction)undo:(id)sender {
    // add zh alert admob something
    NSLog(@"Admobwidth = %lf,AdmobHeight = %lf",self.gameView.admobView.frame.size.width,self.gameView.admobView.frame.size.height);
    [self.gameView bringSubviewToFront:self.gameView.admobView];
    
    if (game.won || game.lose || self.gameView.overflag) {
        return;
    }
    ///
    if (self.gameView.hinting) {
        return;
    }
    if (undoFlag)
        return;
    undoFlag = YES;
    [TheSound playTapSound];
    [self.gameView clearSelectedState];
    self.gameView.topCards = [game undoAction];
    if ([self.gameView.topCards count] > 0) {
        game.moves++;
        game.scores -= 100;
        if (game.scores < 0) {
            game.scores = 0;
        }
        [self.gameView computeCardLayout:0.2 destPos:-1 destIdx:-1];
    }
    if (![game canUndo]) {
        self.gameView.btnUndo.enabled = NO;
    }
    else
    {
        self.gameView.btnUndo.enabled = YES;
    }
    [self.gameView undoEffect:self.gameView.topCards];
    undoFlag = NO; 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated. 
}

- (NSString*)getRealBackImgName:(NSString*)name
{
    if ([name hasPrefix:@"userdefined"])
        return name;
    CGSize fs = [UIApplication currentSize];
    NSString* landscapeBack = [name stringByAppendingString:@"_landscape"];
    NSString *appDirectory = [[NSBundle mainBundle] bundlePath];
    NSString *checkExist = [appDirectory stringByAppendingPathComponent:[landscapeBack stringByAppendingString:@".png"]];
    NSString *checkExist2 = [appDirectory stringByAppendingPathComponent:[landscapeBack stringByAppendingString:@"@2x.png"]];
    if (fs.width > fs.height
        && ([[NSFileManager defaultManager] fileExistsAtPath:checkExist]
            || [[NSFileManager defaultManager] fileExistsAtPath:checkExist2])) {
            return landscapeBack;
        }
    else
    {
        return name;
    }
    ///
    return name;
}

- (void)changeFontColorByBg
{
    UIColor* scb = [UIColor whiteColor];
    switch (game.groupId) {
        case 0:
            scb = [UIColor colorWithRed:1 green:1 blue:0.94 alpha:1];
            break;
        case 1:
            scb = [UIColor colorWithRed:0.06 green:0.3 blue:0.41 alpha:1];
            break;
        case 2:
            scb = [UIColor colorWithRed:1 green:0.98 blue:0.88 alpha:1];
            break;
        case 3:
            scb = [UIColor colorWithRed:0.25 green:0.44 blue:0.47 alpha:1];
            break;
        default:
            break;
    }
    self.gameView.scoreLabel.textColor = self.gameView.timeLabel.textColor = self.gameView.matchLabel.textColor = scb;
}

- (void)setBackImage
{
    //background
    self.gameView.gameBg.image = [UIImage imageNamed:[NSString stringWithFormat:@"bg%d.jpg",game.groupId]];
    //
    [self changeFontColorByBg];
}

- (void)viewWillAppear:(BOOL)animated
{
    // hide navigate bar
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    ///
    NSString* path = [NSString stringWithFormat:@"%@/Documents/game.dat",NSHomeDirectory()];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:game];
    [data writeToFile:path atomically:YES];
    ///User Settings
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    //sound
    [settings setBool:self.gameView.sound forKey:@"sound"];
    ///
    [settings synchronize];
    //
    [self pauseGame:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [AdmobViewController shareAdmobVC].delegate = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
 
    if(!game.won && !self.gameView.overView) {
        [self tapOnDesktop];
    }
    
    //[nethud setHidden:YES];
//    [[AdmobViewController shareAdmobVC] show_admob_banner:0 posy:0 width:self.gameView.admobView.frame.size.width height:self.gameView.admobView.frame.size.height view:self.gameView.admobView];
    
    [[AdmobViewController shareAdmobVC] show_admob_banner_smart:0.0 posy:0.0 view:self.gameView.admobView];
    [AdmobViewController shareAdmobVC].delegate = self;
//    
//    [[AdmobViewController shareAdmobVC] show_admob_banner:self.gameView.admobView placeid:@"mainpage"];
    //
    // zzx 2023.11.13 .15.26 del
//    if (!firstIn) {
//        return;
//    }
    ///ios7   zzx11.8
//    [self performSelectorInBackground:@selector(loadgame) withObject:self];
    //
    NSLog(@"zzx 1111111");
  
    [self.gameView bringSubviewToFront:LeftOPBar];
    [self.gameView bringSubviewToFront:RightOPBar];
    [self.gameView bringSubviewToFront:BackView];
    [self.gameView.btnShuffle bringSubviewToFront:hintBadge];
    
    [self.gameView bringSubviewToFront:self.gameView.admobView];
//    [self.gameView bringSubviewToFront:self.gameView.opBar];
}

- (void)loadgame
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    [CardView initRes:game.groupId];
    if (firstIn) {
        [game freshGame:nil];
        self.gameView.game = game;
        firstIn = NO;
    }
    
        [self.gameView initHelp];
    });
//    [self.gameView initHelp];
    
    [[AdmobViewController shareAdmobVC] setRewardAdClient:(RewardAdWrapperDelegate *)self];
}

- (void)hidehud:(NSNotification*)notify
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [nethud removeFromSuperview];
        [nethud setHidden:YES];
    });
//    [nethud removeFromSuperview];
//    [nethud setHidden:YES];
}

#pragma mark game protocal
- (void)viewDidUnload {
    [self setGameView:nil];
    [super viewDidUnload];
}

- (IBAction)newGame:(id)sender {
    if (self.gameView.hinting) {
        return;
    }
    if (undoFlag || shuffleFlag)
        return;
    [TheSound playTapSound];
    //
    [game freshGame:nil];
    self.gameView.game = game;
    [self enableTimer:NO];
    //
    //[self showFullAds];
}

- (IBAction)showHint:(id)sender {
    NSLog(@"zzzzzx1");
    if (game.won || game.lose || self.gameView.overflag) {
        return;
    }
    if (self.gameView.hinting) {
        return;
    }
    if (undoFlag || shuffleFlag)
        return;
    self.gameView.hinting = YES;
    // mababy add reward
//    [self addRewrad];
    
    [TheSound playTapSound];
    [self.gameView hint:[game hintActions:[self.gameView selectedCard]]];
    self.gameView.hinting = NO;
    
    [Flurry logEvent:@"Hint" withParameters:@{@"level":[NSNumber numberWithInteger:game.layoutid]}];
    
    
}

- (IBAction)onOverBack:(id)sender {
    [TheSound playTapSound];
    if (self.gameView.nextlock)
        game.unlockone = game.layoutid+1;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"autoCompleteDone" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"controlTimer" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"gameWin" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hidehud" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
    [self afterCloseOverView];
}

- (IBAction)onOverNext:(id)sender {
    
    [LeftOPBar setAlpha:1];
    [RightOPBar setAlpha:1];
    LeftOPBarTrall.constant=0;
    RightOPBarlead.constant=0;
    [self preSetFreeHints];
    [self updateHintsBadge];
    NSLog(@"next");
    //[TheSound playTapSound]; sound play in gameView's onCloseOver
    [self.gameView onCloseOver:nil];
    //
    game.layoutid++;
    [game freshGame:nil];
    self.gameView.game = game;
    [self enableTimer:NO];
}

- (void) afterCloseOverView {
    if(!ad_before_win) {
        [AdmobViewController shareAdmobVC].status = 2;
        last_full_ad_pos = 2;
        [self tryCallFullAds:YES];
    }
}

- (void)showFullAds
{
    ///cnt for show ad
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    int timecnt = (int)[settings integerForKey:@"cnt"];
    timecnt++;
    [settings setInteger:timecnt forKey:@"cnt"];
    [settings synchronize];
    if (timecnt % TIMECNT_FOR_AD == 0) {
        [AdmobViewController shareAdmobVC].status = 1;
        last_full_ad_pos = 1;
        if (![self tryCallFullAds:YES]){
            [self.gameView showOver];
        }
    }
    else
    {
        [self.gameView showOver];
    }
}

- (BOOL) tryCallFullAds:(BOOL) ignore {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if([settings boolForKey:@"cz_remove_ad"]) {
        return FALSE;
    }
    
    if([self show_ad]) {
        return FALSE;
    }
    
    return [[AdmobViewController shareAdmobVC] try_show_admob_interstitial:self.navigationController ignoreTimeInterval:ignore];
}

- (void)autoCompleteDone:(NSNotification*)notifacation
{
    NSLog(@"zzx .........");
    /// update stat
    if (game.won == NO) {
        ;
    }
    ///
    game.won = YES;
}

#pragma mark -
#pragma mark show admob bannershuffleFlag
- (void) reset_banner_downcount {
    show_banner = time(NULL);
}

- (void)tapOnDesktop {
    NSLog(@"zzzzzx");
    if (![self.gameView.overView isHidden]) {
        return;
    }
    [self.gameView hideOrDisplayOpBar];
    [self reset_banner_downcount];
//    if(self.gameView.hideOp) {
//        [self.gameView hideOrDisplayOpBar];
//    }
}

- (void) update_admob_banner_status {
    if(show_banner > 0) {
//        NSLog(@"self.leftopbar hidden%d",LeftOPBar.hidden);
        long now = time(NULL);
        if(now - show_banner > 3.8) {
//            NSLog(@"self.leftopbar hidden%d",LeftOPBar.hidden);
            if(!self.gameView.hideOp) {
//                [self.gameView hideOrDisplayOpBar];
                
            }
            
            if(self.gameView.hideOp){
                show_banner = 0;
            }
        }
    }
}

-(BOOL) show_ad {
    AdmobViewController* admobview = [AdmobViewController shareAdmobVC];
    if([admobview hasInAppPurchased]) {
        return false;
    }
    
    GRTService* service = (GRTService*)admobview.rtService;
    if([service isRT] || [service isGRT]) {
        return false;
    }
    
    NSString* msg = @"remove all full-screen ads";
    NSInteger language = [service getCurrentLanguageType];
    if(language == 1) {
        msg = @"去除所有全屏广告";
    }
    
    return [admobview getRT:self isLock:false rd:msg cb:^() {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setBool:YES forKey:@"cz_remove_ad"];
        [settings synchronize];
    }];
}

- (void) updateAdTime {
    NSDictionary* ex = [[[AdmobViewController shareAdmobVC] configCenter] getExConfig];
    long count = 0;
    @try {
        count = [ex[@"adtime"] integerValue];
    } @catch(NSException*) {
        count = 0;
    } @finally {
        
    }
    
    ad_before_win = (count == 0);
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


- (void) updateHintsBadge {
    // 按钮变化每次在数值变化后执行
    if(freehintsTop == 0) {
        hintBadge.text = @"Ad";
    } else {
        hintBadge.text = [NSString stringWithFormat:@"%d", freehintsTop];
    }
    if(freehints > 99) {
        hintBadge.hidden = YES;
    }
}

- (void)RewardVideoAdDidRewardUserWithReward:(RewardAdWrapper*) rewardad rewardType:(NSString*) rewardtype amount:(double) rewardamount {
    dispatch_async(dispatch_get_main_queue(), ^{
        freehintsTop += 3;
        NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
        [settings synchronize];
        [self updateHintsBadge];
    });
}

- (BOOL) showHint {
    AdmobViewController* vc = [AdmobViewController shareAdmobVC];
    if([vc hasInAppPurchased])
        return FALSE;
    GRTService* ser = (GRTService*)[vc rtService];
    if([ser isRT] || [ser isGRT]) {
        return FALSE;
    }
    
    NSDictionary* ex = [[[AdmobViewController shareAdmobVC] configCenter] getExConfig];
    long count = 0;
    @try {
        if(ex != nil && [ex valueForKey:@"lt"] != nil) {
            count = [ex[@"lt"] integerValue];
        }
    } @catch(NSException*) {
        count = 0;
    } @finally {
        
    }
    
    if(count <= 0) {
        return [vc getRT:self isLock:true rd:@"unlock hint" cb:^(){}];
    }
    return FALSE;
}
- (void) reloadHintsBadge {
    // 获取是否为老用户只赋值一次
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    id obj = [settings objectForKey:FREE_HINTS_SETTING_KEY];
    long opencount  = (int)[obj integerValue];
    if (opencount > 3) {
        freehints = 10000;
    }
    NSLog(@"opencount = %ld,%d",opencount,freehints);
}

- (void) admobHeightUpdate1 :(id)sender {
//    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];
//    CGFloat admobHeight1 = [applovinWrapper getAdmobHeight];
//    [self.adView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.equalTo(@(admobHeight1)).priorityHigh(); // 更新约束的值
//            }];
//    admobHeightIph.constant=admobHeight1;
}

-(void) preSetFreeHints {
    // 如果不为老用户赋值为3
    if(freehints  < 10000) {
        freehintsTop = 3;
    }else{
        freehintsTop = 999;
    }
}
@end
