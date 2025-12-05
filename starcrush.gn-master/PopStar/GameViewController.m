//
//  GameViewController.m
//  PopStar
//
//  Created by apple air on 15/12/8.
//  Copyright (c) 2015年 zhongbo network. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"// 游戏
#import "MainScene.h"// 首页
#import "PauseAlertView.h"//暂停
#import "IAPManager.h"//内购
// 内购
#import "IAPManager.h"
#import "MBProgressHUD.h"
#import "BuyAlertView.h"//购买view
//#import "BuyView.h"// 购买view
#import "GameOverAlertView.h"// 游戏结束
#import "PrizeView.h"// 登陆领奖
#import "AVFoundation/AVFoundation.h"// 音乐

#import "ShareRateAlertView.h"// 分享评价
#import "ContinueGameAlertView.h"
@import GoogleMobileAds;
#import "Admob.h"
//@import Flurry_iOS_SDK;

#define kPrizeViewTag 120
#define kMaskViewTag 130

@interface GameViewController () <PauseAlertViewDelegate,GameOverAlertViewDelegate,ShareRateAlertViewDelegate,ContinueGameAlertViewDelegate,BuyAlertViewDelegate,RewardAdWrapperDelegate, AdmobViewControllerDelegate>
{
    SKView * skView;
    GameScene *gameScene;
    MainScene *mainScene;
    MBProgressHUD *nethud;
//    BuyView *buyView;
    AVAudioPlayer * mainBGMPlayer;
    AVAudioPlayer * gameBGMPlayer;
    bool initialedAfterLoad;
}

@property (weak, nonatomic) IBOutlet UIView *adview;
@property (weak, nonatomic) IBOutlet SKView *gameView;

@end

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    initialedAfterLoad = false;
    [AdmobViewController shareAdmobVC].delegate = self;
    [[AdmobViewController shareAdmobVC] decideShowRT:self];
}

- (void)viewDidLayoutSubviews
{
    if(initialedAfterLoad) {
        return;
    }
    
    initialedAfterLoad = true;
    
    // 通过通知来检测按钮点击进行事件传递
    // 进入游戏
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"gamescene" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toGameScene:) name:@"gamescene" object:nil];
    
    // 新游戏(重新开始)
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"restartGame" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartGame:) name:@"restartGame" object:nil];
    // 开始新游戏还是继续游戏
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"continueOrRestartGame" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueOrRestartGame:) name:@"continueOrRestartGame" object:nil];
    
    // 回到首页
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"mainscene" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toMainScene:) name:@"mainscene" object:nil];
    // 暂停
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pause" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseClick:) name:@"pause" object:nil];
//    // 领奖
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"prize" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prizeClick) name:@"prize" object:nil];
    // 评价
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"jduge" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareToRate) name:@"jduge" object:nil];
    // 分享
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"share" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareToShare) name:@"share" object:nil];
    // 内购
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"buy" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareToBuy) name:@"buy" object:nil];
    // 游戏结束gameover
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"gameover" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameover:) name:@"gameover" object:nil];
    // 继续游戏
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"continue" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueGame:) name:@"continue" object:nil];
    // 显示广告
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showad" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAd:) name:@"showad" object:nil];
    // 声音
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"soundchange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(soundchange:) name:@"soundchange" object:nil];
    // 背景音乐:主界面
    NSURL * mainBGMURL = [[NSBundle mainBundle] URLForResource:@"music0" withExtension:@"wav"];
    // 背景音乐:游戏界面
    NSURL * gameBGMURL = [[NSBundle mainBundle] URLForResource:@"music" withExtension:@"wav"];
    NSError *error;
    mainBGMPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:mainBGMURL error:&error];
    gameBGMPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:gameBGMURL error:&error];
    mainBGMPlayer.numberOfLoops = -1;
    [mainBGMPlayer prepareToPlay];
    gameBGMPlayer.numberOfLoops = -1;
    [gameBGMPlayer prepareToPlay];
//    BOOL sound = [[NSUserDefaults standardUserDefaults] boolForKey:@"sound"];
//    if (sound) {
//        [gameBGMPlayer play];
//    }
    // Configure the view.
    skView = self.gameView;//(SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
//    GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
    // 游戏
    gameScene = [GameScene sceneWithSize:skView.bounds.size];
    gameScene.scaleMode = SKSceneScaleModeAspectFill;
    gameScene.viewController = self;
    
    // 首页
    mainScene = [MainScene sceneWithSize:skView.bounds.size];
    mainScene.scaleMode = SKSceneScaleModeAspectFill;
//    [[AdmobViewController shareAdmobVC] setRewardClient:self];
//    //[GADRewardBasedVideoAd sharedInstance].delegate = self;
//    [self loadRewardAd];
    
    // Present the scene.
//    [skView presentScene:gameScene];
//    [skView presentScene:mainScene];
    // 先显示首页,在首页上显示领奖页面
    [skView presentScene:mainScene];
    // 是否要弹登陆领奖页面
    [self checkShowLoginPrize];
    
    if(IS_IPAD) {
        [self.adview setFrame:CGRectMake(self.adview.frame.origin.x, ScreenHeight-90, self.adview.frame.size.width, 90)];
    }
    
   
}


- (void) loadRewardAd {
    NSLog(@"try load reward");
//    GADRequest* request = [GADRequest request];
//    request.testDevices = @[ kGADSimulatorID ];
//    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request withAdUnitID:kRewardID];
    [[AdmobViewController shareAdmobVC] init_reward_ad];
}

-(void)viewWillAppear:(BOOL)animated {
    [[AdmobViewController shareAdmobVC] show_admob_banner:self.adview placeid:@"homepage"];
}
-(void)viewDidAppear:(BOOL)animated
{
//    [[AdmobViewController shareAdmobVC] setRewardAdClient:(RewardAdWrapperDelegate *)self];
//    [[AdmobViewController shareAdmobVC] setDelegate:self];
}
- (BOOL) isVideoAdLoaded {
    return [[AdmobViewController shareAdmobVC] isRewardAdLoaded:0];
}

#pragma mark 显示视频广告
- (BOOL)showVideoAd
{
    if([self showHint]) {
        return NO;
    }
    
    return   [[AdmobViewController shareAdmobVC] showRewardAd:self placeid:0];
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

#pragma mark - 是否要弹登陆领奖页面
- (void)checkShowLoginPrize
{
    // 检查登陆情况,根据结果来判断如何显示领奖窗口
    int result = [self checkContinuousLogin];
    switch (result) {
            // 不弹出领奖窗口,直接进入游戏
        case 0:
//            [skView presentScene:mainScene];
            break;
            // 弹出领奖窗口,从第一天开始
        case 1:
            [self showPrizeViewWithType:1];
            break;
            // 弹出领奖窗口,连续登陆领奖
        case 2:
            [self showPrizeViewWithType:2];
            break;
            
        default:
            break;
    }
    
}


#pragma mark - 显示领奖界面
- (void)showPrizeViewWithType:(int)type
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    // 正在领奖标志位置为YES
    mainScene.isShowingPrizeView = YES;
    // type:
    // 1 从第一天开始
    // 2 连续登陆领奖
    // 添加一个蒙版吧
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0.6;
    maskView.tag = kMaskViewTag;
    [self.view addSubview:maskView];
    // 领奖界面
    PrizeView *prizeView = [[[NSBundle mainBundle] loadNibNamed:@"PrizeView" owner:nil options:nil] lastObject];
    // 高度按照宽度乘以比例
    prizeView.frame = CGRectMake(0, 0, ScreenWidth*0.9, ScreenWidth*0.9 *681.0/564.0);
    prizeView.center = self.view.center;
    [self.view addSubview:prizeView];
    prizeView.tag = kPrizeViewTag;
    [prizeView.receiveBtn addTarget:self action:@selector(getPrize) forControlEvents:UIControlEventTouchUpInside];
    if (type == 1) {
        // 从第一天开始
        // 将times置为0
        [settings setInteger:0 forKey:@"times"];
    } else if (type == 2) {
        // 连续登陆
        // 已经领奖的次数
        int times = (int)[settings integerForKey:@"times"];
        times = times%7;
        for (UIImageView *view in prizeView.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                if (view.tag <= times) {
                    // 已经领奖过的图片改为金色的,从第一天到第七天,tag分别为1-7
                    view.image = [UIImage imageNamed:[NSString stringWithFormat:@"day%ldGold",(long)view.tag]];
                }
            }
        }
    }
}


#pragma mark - 领取奖励
- (void)getPrize
{
    // 页面要停留一会,那么这个时候就不能再点领取按钮了
    for (UIView *view in [self.view viewWithTag:kPrizeViewTag].subviews) {
        view.userInteractionEnabled = NO;
    }
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    // 已经领奖的次数
    int times = (int)[settings integerForKey:@"times"];
    int prizeCoin = 0;
    // 根据领奖的天数判断加多少金币
    switch (times) {
        case 0:
            prizeCoin = 20;
            break;
        case 1:
            prizeCoin = 40;
            break;
        case 2:
            prizeCoin = 80;
            break;
        case 3:
            prizeCoin = 100;
            break;
        case 4:
            prizeCoin = 120;
            break;
        case 5:
            prizeCoin = 140;
            break;
        case 6:
            prizeCoin = 200;
            break;
            
        default:
            break;
    }
//    NSLog(@"领奖");
    // 1.首先得知道现在是领哪一天的奖励
    // 获取目前的金币数量
    int coin = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"coin"];
    coin += prizeCoin;
    times++;
    times %= 7;
    [settings setInteger:coin forKey:@"coin"];
    [settings setInteger:times forKey:@"times"];
    // 刷新金币显示数量
    [mainScene updateSomething];
    [gameScene updateSomething];
    for (UIImageView *view in [self.view viewWithTag:kPrizeViewTag].subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            if (view.tag <= times) {
                // 已经领奖过的图片改为金色的,从第一天到第七天,tag分别为1-7
                view.image = [UIImage imageNamed:[NSString stringWithFormat:@"day%ldGold",(long)view.tag]];
            }
        }
    }
    [self performSelector:@selector(removePrizeView) withObject:nil afterDelay:0.5];
//    // 点击领取之后移除领奖页面
//    [[self.view viewWithTag:kPrizeViewTag] removeFromSuperview];
//    // 移除蒙版
//    [[self.view viewWithTag:kMaskViewTag] removeFromSuperview];
//    // 正在领奖标志位置为NO
//    mainScene.isShowingPrizeView = NO;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *todayString = [NSString stringWithFormat:@"%@",[formatter stringFromDate:[NSDate date]]];
    [settings setObject:todayString forKey:@"dateString"];
//    NSLog(@"%@",todayString);
//    [skView presentScene:mainScene];
}

#pragma mark - 移除领奖界面,因为要延迟,所以写了一个方法
- (void)removePrizeView
{
    // 点击领取之后移除领奖页面
    [[self.view viewWithTag:kPrizeViewTag] removeFromSuperview];
    // 移除蒙版
    [[self.view viewWithTag:kMaskViewTag] removeFromSuperview];
    // 正在领奖标志位置为NO
    mainScene.isShowingPrizeView = NO;
}

#pragma mark - 判断两天是不是相差一天(是不是连续登陆)
- (int)checkContinuousLogin
{
    // 有三种情况:
    // 1.是连续登陆,返回2
    // 2.中间漏登陆了,再从第一天开始,返回1
    // 3.在同一天登陆,不显示,返回0
    // 判断今天是否已经领奖, 是则转主页面,否则先领奖
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    // 设定格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    // 获取上次领奖时存储的日期字符串
    NSString *dateString = [settings objectForKey:@"dateString"];
    // 获取当天的日期字符串
    NSString *todayString = [NSString stringWithFormat:@"%@",[formatter stringFromDate:[NSDate date]]];
    NSRange range = NSMakeRange(4, 2);
    int dateYear = [[dateString substringToIndex:4] intValue];
    int dateMonth = [[dateString substringWithRange:range] intValue];
    int dateDay = [[dateString substringFromIndex:6] intValue];
    int todayYear = [[todayString substringToIndex:4] intValue];
    int todayMonth = [[todayString substringWithRange:range] intValue];
    int todayDay = [[todayString substringFromIndex:6] intValue];
    if (dateYear == todayYear && dateMonth == todayMonth) {
        int diff = todayDay - dateDay;
        if (diff == 0) {// 同一天登陆,返回0,不显示
            return 0;
        } else if (diff == 1) {// 是连续登陆,返回2
            return 2;
        } else {// 再从头开始
            return 1;
        }
    } else if (dateYear == todayYear) {
        int daysBefore = [self caculateDaysWithYear:dateYear month:dateMonth day:dateDay];
        int daysToday = [self caculateDaysWithYear:todayYear month:todayMonth day:todayDay];
        int diff = daysToday -  daysBefore;
        if (diff == 0) {// 同一天登陆,返回0,不显示
            return 0;
        } else if (diff == 1) {// 是连续登陆,返回2
            return 2;
        } else {// 再从头开始
            return 1;
        }
    } else if (dateYear != todayYear) {
        // 从头开始
        // 超过一年了肯定不是连续登陆
        if (todayYear - dateYear > 1) {
            return 1;
        }
        // 如果年份不相等要相差一天的话,那么必须是12月31号和01月01号
        if (dateMonth != 12 || dateDay != 31 || todayMonth != 1 || todayDay != 1) {
            return 1;
        }
    }
    return 1;
}

#pragma mark - 计算这一年过了多少天了
- (int)caculateDaysWithYear:(int)year month:(int)month day:(int)day
{
    NSMutableArray *dayArray = [NSMutableArray arrayWithObjects:@31,@28,@31,@30,@31,@30,@31,@31,@30,@31,@30,@31, nil];
    if (((year%4 == 0) && (year%100 != 0)) || (year%400 == 0)) {
        [dayArray replaceObjectAtIndex:1 withObject:@29];
    }
    for (int i=0;i<month-1;++i) {
        day += [[dayArray objectAtIndex:i] intValue];
    }
//    NSLog(@"%d",day);
    return day;
}

#pragma mark - 增加广告条
- (void)addAdView
{
    /*
    CGFloat scale = ScreenWidth / 320.0;
    CGFloat bannerH = 50.0 * scale;
    if (IS_IPAD) {
        scale = ScreenWidth / 728.0;
        bannerH = 90.0 * scale;
    }
    CGFloat bannerW = ScreenWidth;
    CGFloat bannerY = ScreenHeight - bannerH;
    
    bannerView_.frame = CGRectMake(0,bannerY,bannerW,bannerH);
     */
}
#pragma mark - 显示全屏广告
- (void)showAd:(NSNotification*)notifacation
{
    [[AdmobViewController shareAdmobVC] show_admob_interstitial:self placeid:1];
}

#pragma mark - 进入游戏
- (void)toGameScene:(NSNotification*)notify
{
    [gameScene updateSomething];
    // 设定过场动画
    SKTransition *transition = [SKTransition fadeWithDuration:0.3];
    // 跳转到游戏场景
    [skView presentScene:gameScene transition:transition];
}

#pragma mark - 新游戏,重新开始
- (void)restartGame:(NSNotification*)notify
{
    [[AdmobViewController shareAdmobVC] ifNeedShowNext:self];
    [[AdmobViewController shareAdmobVC] checkConfigUD];
    BOOL sound = [[NSUserDefaults standardUserDefaults] boolForKey:@"sound"];
    if (sound) {
        [gameBGMPlayer play];
    }
    [gameScene restartGame];
    // 设定过场动画
    SKTransition *transition = [SKTransition fadeWithDuration:0.3];
    // 跳转到游戏场景
    [skView presentScene:gameScene transition:transition];
}


#pragma mark - 点击开始游戏时选择新游戏还是继续游戏
- (void)continueOrRestartGame:(NSNotification*)notify
{
    ContinueGameAlertView *continueAlert = [[ContinueGameAlertView alloc] init];
    continueAlert.delegate = self;
    [continueAlert show];
}

#pragma mark 点击开始游戏时选择新游戏还是继续游戏
- (void)didClickContinueGameButtonAtIndex:(NSUInteger)index sender:(id)sender
{
    switch (index) {
        case 0: // 继续游戏
            [self continueGame:nil];
            break;
        case 1: // 重新开始
            [self restartGame:nil];
            break;
            
        default:
            break;
    }
}


#pragma mark - 进入游戏
- (void)toMainScene:(NSNotification*)notify
{
    [gameBGMPlayer stop];
    [mainScene updateSomething];
    // 设定过场动画
    SKTransition *transition = [SKTransition fadeWithDuration:0.4];
    // 跳转到游戏场景
    [skView presentScene:mainScene transition:transition];
}

#pragma mark - 暂停
- (void)pauseClick:(NSNotification*)notify
{
    NSMutableArray *receiveArray = [notify object];
    int level = [[receiveArray objectAtIndex:0] intValue];
    int score = [[receiveArray objectAtIndex:1] intValue];
    PauseAlertView *pause = [[PauseAlertView alloc] initWithLevel:level score:score];
    pause.delegate = self;
    [pause show];
    // 正在显示暂停窗口
    gameScene.isShowingPauseView = YES;

}

#pragma mark - 暂停点击代理
- (void)didClickPauseButtonAtIndex:(NSUInteger)index sender:(id)sender
{
    // 已经不显示暂停窗口
    gameScene.isShowingPauseView = NO;
    switch (index) {
        case 0:
            [self toMainScene:nil];// 返回首页
            break;
        case 1:
            [gameScene restartGame];// 重新开始
            break;
        case 2: // 继续
            break;
        default:
            break;
    }
}

#pragma mark - 准备分享
- (void)prepareToShare
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:kLocalString(@"ShareMeesage") delegate:self cancelButtonTitle:kLocalString(@"Cancel") otherButtonTitles:kLocalString(@"OK"), nil];
//    alert.tag = 121;
//    [alert show];
    if (YES) {
//        [self share];
        return;
    }
// 判断今天是不是已经分享过了
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    // 设定格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    // 获取上次领奖时存储的日期字符串
    NSString *sharedDateString = [settings objectForKey:@"sharedDateString"];
    // 获取当天的日期字符串
    NSString *todayString = [NSString stringWithFormat:@"%@",[formatter stringFromDate:[NSDate date]]];
    NSString *imageName;
    if ([todayString isEqualToString:sharedDateString]) {
        imageName = @"shared_comment";
    } else {
        imageName = @"share_comment";
    }
    
    ShareRateAlertView *shareAlert = [[ShareRateAlertView alloc] initWithImage:[UIImage imageNamed:imageName] buttonImage:[UIImage imageNamed:@"to_share"]];
    shareAlert.tag = 520;
    shareAlert.delegate = self;
    [shareAlert show];
}

#pragma mark - 准备评价
- (void)prepareToRate
{
    [[[AdmobViewController shareAdmobVC] rtService] doRT];
    /*
    NSUserDefaults *users = [NSUserDefaults standardUserDefaults];
    BOOL bRated = [users boolForKey:@"already-rated"];
    UIImage *buttonImage = [UIImage imageNamed:@"to_rate"];
    if (bRated) {
        buttonImage = [UIImage imageNamed:@"rated"];
    }
    ShareRateAlertView *rateAlert = [[ShareRateAlertView alloc] initWithImage:[UIImage imageNamed:@"rate_comment"] buttonImage:buttonImage];
    rateAlert.tag = 521;
    rateAlert.delegate = self;
    [rateAlert show];
     */
}


#pragma mark - 点击了分享或评价
- (void)didClickShareRateButtonAtIndex:(NSUInteger)index sender:(id)sender
{
    switch (index) {
        case 0:
            break;
        case 1:
            if ([sender tag] == 520) {// 分享
//                [self share];
            }
            break;
            
        default:
            break;
    }
}


#pragma mark - 分享,还有问题
/*- (void)share
{
    //1、创建分享参数
    NSArray* imageArray = @[[UIImage imageNamed:@"share-icon.png"]];
    NSString* shareurl = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/id%d?ls=1&mt=8", kAppID];
//    （注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupSinaWeiboShareParamsByText:[NSString stringWithFormat:@"%@%@",kLocalString(@"ShareText"),shareurl]
                                                   title:kLocalString(@"ShareTitle")
                                                   images:[UIImage imageNamed:@"share-icon-sina.png"]
                                                   video:nil
                                                     url:[NSURL URLWithString:shareurl]
                                                latitude:22.02454411766735
                                               longitude:112.76367125000003
                                                objectID:@"分享"
                                          isShareToStory:FALSE
                                                    type:SSDKContentTypeAuto];
        [shareParams SSDKSetupFacebookParamsByText:[NSString stringWithFormat:@"%@%@",kLocalString(@"ShareText"),shareurl]
                                             image:[UIImage imageNamed:@"share-icon-sina.png"]
                                               url:[NSURL URLWithString:shareurl]
                                          urlTitle:kLocalString(@"ShareTitle")
                                           urlName:nil
                                    attachementUrl:nil
                                           hashtag:@"#StarCrush"
                                             quote:@""
                                              type:SSDKContentTypeAuto];
        [shareParams SSDKSetupTwitterParamsByText:[NSString stringWithFormat:@"%@%@",kLocalString(@"ShareText"),shareurl]
                                           images:[UIImage imageNamed:@"share-icon-sina.png"]
                                         latitude:22.02454411766735
                                            longitude:112.76367125000003
                                             type:SSDKContentTypeAuto];
//    [shareParams SSDKSetupWeChatParamsByText:kLocalString(@"ShareText") title:kLocalString(@"ShareTitle") url:[NSURL URLWithString:kRatingUrl] thumbImage:[UIImage imageNamed:@"share-icon.png"] image:nil musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeAuto forPlatformSubType:SSDKPlatformSubTypeWechatTimeline];
        [shareParams SSDKSetupShareParamsByText:kLocalString(@"ShareText")
                                         images:imageArray
                                            url:[NSURL URLWithString:shareurl]
                                          title:kLocalString(@"ShareTitle")
                                           type:SSDKContentTypeAuto];
    
//    [shareParams SSDKSetupShareParamsByText:@"分享内容http://www.baidu.com"
//                                     images:@[@"http://img1.bdstatic.com/img/image/67037d3d539b6003af38f5c4c4f372ac65c1038b63f.jpg"]
//
//
//                                        url:[NSURL URLWithString:@"http://www.baidu.com"]
//                                      title:@"分享标题"
//                                       type:SSDKContentTypeAuto];
    
    //1+、创建弹出菜单容器（iPad应用必要，iPhone应用非必要）
    CGFloat bannerH = ScreenWidth * 50.0/320.0;
    if (IS_IPAD) {
        bannerH = ScreenWidth * 90.0/728.0;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - bannerH, ScreenWidth, bannerH)];
    [self.view addSubview:view];
        //2、分享（可以弹出我们的分享菜单和编辑界面）
        [ShareSDK showShareActionSheet:view //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       switch (state) {
                           case SSDKResponseStateSuccess:
                           {

                               // 分享成功加金币, 不在审核期才加金币
                               if (NO) {
                                   NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
                                   // 分享成功了图片说明要换,这里标记一下,存下日期
                                   NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                   [formatter setDateFormat:@"yyyyMMdd"];
                                   // 获取上次领奖时存储的日期字符串
                                   NSString *sharedDateString = [settings objectForKey:@"sharedDateString"];
                                   NSString *todayString = [NSString stringWithFormat:@"%@",[formatter stringFromDate:[NSDate date]]];
                                   // 判断今天有没有分享过
                                   if ([todayString isEqualToString:sharedDateString]) {
                                       // 已经分享过了,不加金币
                                   } else {
                                       // 今天是第一次分享,加金币
                                       // 加金币
                                       int coin = (int)[settings integerForKey:@"coin"];
                                       coin += 150;
                                       [settings setInteger:coin forKey:@"coin"];
                                       [mainScene updateSomething];
                                   }
                                   [settings setObject:todayString forKey:@"sharedDateString"];
                               }
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kLocalString(@"ShareSuccess")
                                                                                   message:nil
                                                                                  delegate:nil
                                                                         cancelButtonTitle:kLocalString(@"OK")
                                                                         otherButtonTitles:nil];
                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                                 NSLog(@"%@",[error description]);
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLocalString(@"ShareFailed")
                                                                               message:[NSString stringWithFormat:@"%@",error]
                                                                              delegate:nil
                                                                     cancelButtonTitle:kLocalString( @"OK")
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           default:
                               break;
                       }
                       
                   }];
}*/

- (BOOL)checkInAppSupported
{
    if (![[IAPManager sharedIAPManager] canPurchase])
    {
        UIAlertView *thanks = [[UIAlertView alloc] initWithTitle:kLocalString(@"Sorry")
                  message:kLocalString(@"IapNot")
                 delegate:nil
        cancelButtonTitle:kLocalString(@"OK")
        otherButtonTitles:nil];
        [thanks show];
        return NO;
    }
    else
        return YES;
}

#pragma mark - 内购金币
- (void)prepareToBuy
{
    BuyAlertView *buyAlert = [[BuyAlertView alloc] init];
    buyAlert.delegate = self;
    [buyAlert show];
}


- (void)didClickBuyButtonAtIndex:(NSUInteger)index sender:(id)sender
{
    switch (index) {
            // 1 - 6 分别是金币购买
        case 1:
            [self payFor:PRODUCT_1_ID type:1];
            break;
        case 2:
            [self payFor:PRODUCT_2_ID type:2];
            break;
        case 3:
            [self payFor:PRODUCT_3_ID type:3];
            break;
        case 4:
            [self payFor:PRODUCT_4_ID type:4];
            break;
        case 5:
            [self payFor:PRODUCT_5_ID type:5];
            break;
        case 6:
            [self payFor:PRODUCT_6_ID type:6];
            break;
        case 7:
            // 看广告得金币
            [self showVideoAd];
            break;
        default:
            break;
    }
}


#pragma mark - 根据产品和类型支付并进行支付回调
- (void)payFor:(NSString*)productid type:(int)proptype
{
    ///
    nethud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    nethud.label.text = kLocalString(@"Loading");
    [[IAPManager sharedIAPManager] purchaseProductForId:productid
                                             completion:^(SKPaymentTransaction *transaction) {
                                                 ///
                                            [nethud setHidden:YES];
                                                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
          // 根据类型来决定加多少金币
                                                 [self addCoinByType:proptype];
                                             } error:^(NSError *err) {
                                                 ///
                                                 [nethud setHidden:YES];
                                                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

                                             }];

}

#pragma mark - 根据购买的类型来加金币
- (void)addCoinByType:(int)type
{
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    int coin = (int)[settings integerForKey:@"coin"];
    int plusCoin = 0;
    // 根据类型来判定购买了多少金币
    switch (type) {
        case 1:
            plusCoin = PROPS_1_NUM;
            break;
        case 2:
            plusCoin = PROPS_2_NUM;
            break;
        case 3:
            plusCoin = PROPS_3_NUM;
            break;
        case 4:
            plusCoin = PROPS_4_NUM;
            break;
        case 5:
            plusCoin = PROPS_5_NUM;
            break;
        case 6:
            plusCoin = PROPS_6_NUM;
            break;
            
        default:
            break;
    }
    // 2016年01月05日15:20:00
    // 首冲翻倍
    // 是否购买过
    BOOL buyed= [settings boolForKey:@"buyed"];
    if (!buyed) {
        // 如果还没有购买过,即现在是首次,那么要翻倍
        plusCoin *= 2;
        // 然后将购买置为已购买
        [settings setBool:YES forKey:@"buyed"];
    }
    // 将购买的金币加上
    coin += plusCoin;
    [settings setInteger:coin forKey:@"coin"];
    // 加完了要刷新金币显示数量
    [mainScene updateSomething];
    [gameScene updateSomething];
    
    // 2016年01月08日09:52:17
    // 在金币数变化之后更新道具可用状态
    [gameScene checkCoinsEnoughTobuy];
}

#pragma mark - 游戏结束
- (void)gameover:(NSNotification*)notify
{
    NSMutableArray *receiveArray = [notify object];
    int level = [[receiveArray objectAtIndex:0] intValue];
    int score = [[receiveArray objectAtIndex:1] intValue];
//    int level = 1;
//      int score = 10;
//    NSLog(@"%d,%d",level,score);
//    NSLog(@"gameover");
    GameOverAlertView *gameover = [[GameOverAlertView alloc] initWithScore:score level:level];
    gameover.delegate = self;
    [gameover show];
    //
    [self performSelector:@selector(showAd:) withObject:self afterDelay:0.5];
    //[self showAd:nil];

    // 正在显示游戏结束窗口
    gameScene.isShowingGameOverView = YES;
}

#pragma mark - gameover的代理
- (void)didClickGameOverButtonAtIndex:(NSUInteger)index sender:(id)sender
{
    // 已经不显示游戏结束窗口
    gameScene.isShowingGameOverView = NO;
    switch (index) {
        case 0:
            [self toMainScene:nil];// 返回首页
            break;
        case 1:
            [gameScene restartGame];// 重新开始
            break;
        default:
            break;
    }
}



#pragma mark - 继续游戏
- (void)continueGame:(NSNotification*)notify
{
    [[AdmobViewController shareAdmobVC] checkConfigUD];
    
    BOOL sound = [[NSUserDefaults standardUserDefaults] boolForKey:@"sound"];
    if (sound) {
        [gameBGMPlayer play];
    }
//    NSLog(@"继续游戏按钮");
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSMutableArray *starNodesArray = [settings objectForKey:@"starNodes"];
    int level = [[settings objectForKey:@"level"] intValue];
    int score = [[settings objectForKey:@"currentScoreGlobal"] intValue];
    [gameScene continueGameWithScore:score level:level starsArray:starNodesArray];
    // 设定过场动画
    SKTransition *transition = [SKTransition fadeWithDuration:0.3];
    // 跳转到游戏场景
    [skView presentScene:gameScene transition:transition];

}

#pragma mark - 声音改变
- (void)soundchange:(NSNotification*)notify
{
//    BOOL sd = [notify.object boolValue];
//    if (sd) {
//        [gameBGMPlayer play];
//    }
//    else
//        [gameBGMPlayer stop];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark -
#pragma mark reward video delegate

- (void) RewardVideoAdDidReceive:(RewardAdWrapper*) rewardad {
    NSLog(@"reward loaded");
}

- (void) RewardVideoAdFailToReceivedWithError:(RewardAdWrapper*) rewardad error:(NSString*)error {
    NSLog(@"failed to load reward");
//    [Flurry logEvent:@"RewardVideo" withParameters:@{@"status":@"failed"}];

    //retry after 30s
//    [self performSelector:@selector(loadRewardAd) withObject:self afterDelay:30];
}

- (void) RewardVideoAdDidOpen:(RewardAdWrapper*) rewardad {
//    [Flurry logEvent:@"RewardVideo" withParameters:@{@"status":@"open"}];
}

- (void) RewardVideoAdDidStartPlaying:(RewardAdWrapper*) rewardad {
    
}

- (void) RewardVideoAdDidClose:(RewardAdWrapper*) rewardad {
    
}

- (void) RewardVideoAdWillLeaveApplication:(RewardAdWrapper*) rewardad {
//    [Flurry logEvent:@"RewardVideo" withParameters:@{@"status":@"click"}];
}

- (void) RewardVideoAdDidRewardUserWithReward:(RewardAdWrapper*) rewardad rewardType:(NSString*) rewardtype amount:(double) rewardamount {
//    [Flurry logEvent:@"RewardVideo" withParameters:@{@"status":@"watched"}];

    // 看完广告之后调用,如果skipped is false则给奖励
    // 看完广告加金币
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    int coin = (int)[settings integerForKey:@"coin"];
    coin += 50;
    [settings setInteger:coin forKey:@"coin"];
    // 更新金币显示
    [gameScene updateSomething];
    [mainScene updateSomething];

    // 2016年01月08日09:52:17
    // 在金币数变化之后更新道具可用状态
    [gameScene checkCoinsEnoughTobuy];
}

//- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didFailToLoadWithError:(NSError *)error {
//    NSLog(@"failed to load reward");
//    [Flurry logEvent:@"RewardVideo" withParameters:@{@"status":@"failed"}];
//
//    //retry after 30s
//    [self performSelector:@selector(loadRewardAd) withObject:self afterDelay:30];
//}
//
//- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
//    [Flurry logEvent:@"RewardVideo" withParameters:@{@"status":@"open"}];
//}
//
//- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
//    [Flurry logEvent:@"RewardVideo" withParameters:@{@"status":@"click"}];
//}
//
//- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
//    //reload
//    [self loadRewardAd];
//}
//
//-(void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(GADAdReward *)reward {
//    [Flurry logEvent:@"RewardVideo" withParameters:@{@"status":@"watched"}];
//
//    // 看完广告之后调用,如果skipped is false则给奖励
//    // 看完广告加金币
//    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
//    int coin = (int)[settings integerForKey:@"coin"];
//    coin += 50;
//    [settings setInteger:coin forKey:@"coin"];
//    // 更新金币显示
//    [gameScene updateSomething];
//    [mainScene updateSomething];
//
//    // 2016年01月08日09:52:17
//    // 在金币数变化之后更新道具可用状态
//    [gameScene checkCoinsEnoughTobuy];
//}

#pragma mark - AdmobViewControler delegate

- (void)adMobVCDidCloseInterstitialAd:(AdmobViewController *)adMobVC {
    if(gameScene.view.paused) {
        gameScene.view.paused = NO;
    }
}

@end
