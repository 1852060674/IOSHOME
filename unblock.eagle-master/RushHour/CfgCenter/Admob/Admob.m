//
//  Admob.h
//  2014-06-23
//
//  version 3.3

#import <unistd.h>
#import <string.h>
#import <sys/time.h>
#import <sys/types.h>
#import <pwd.h>

#import <mach/mach.h>
#include <mach/task_info.h>
#import <mach/mach_host.h>
#include <sys/sysctl.h>

#import <MessageUI/MFMailComposeViewController.h>

#import "XMLParser.h"
#import "Admob.h"

#import "CfgCenterSettings.h"
#import "RewardAdWrapper.h"

#ifdef LOG_USER_ACTION
#import <FirebaseAnalytics/FirebaseAnalytics.h>
#endif

#ifdef ENABLE_OTHERAPP
#import "OtherAppViewCtrl.h"
#endif

#ifdef ENABLE_IAP
#import "IAPViewController.h"
#endif

#ifdef ENABLE_AD
#import "ADWrapper.h"
#endif

#ifdef AD_ADMOB
@import GoogleMobileAds;
#endif

#ifdef AD_APPLOVIN_MAX
@import AppLovinSDK;
#endif

#define AD_DEFAULT_PLACEID @"default"

@implementation AdmobViewController
{
    long app_id;                   // app的id
    int appType;
    
    CfgCenterSettings* settings;
    
#ifdef ENABLE_AD
    ADWrapper* adcenter;
    ADWrapper* adcenter_land;
    UIView* currentBannerRoot;
    NSString* currentBannerPlace;
    ADAlignment lastBannerAlign;
    //    UIView* currentNativeRoot;
    
    RewardAdWrapper* rewardad;
#endif
    
    /* 物理设备信息 */
    float widthScreen;        // 屏幕宽度
    float heightScreen;       // 屏幕高度
    float scaleScreen;        // 屏幕的清晰度比例，retina为2
    int   deviceType;          // 设备类型，ipad，iphone4， iphone5
    
    /* 开发者信息 */
    NSString* supportMail;      // app服务邮箱
    
    UIView *landscapeView;
    
    long lastShowInerstitialAd;
    
#ifdef ENABLE_OTHERAPP
    OtherAppViewCtrl *otherAppViewController;
    bool bOtherApp;
#endif
    
    bool bInApp;                    // 是否已经购买过in-app，缺省是false;
#ifdef ENABLE_IAP
    int  login_cnt;
#endif
    
#ifdef ENABLE_WAKEUP
    bool bWakeUp;
#endif
    
    //new target app
    NSString* ntappid;
    UIViewController* ntviewcontroller;
    
    //only used on unity
    UIInterfaceOrientation lastOrientation;
}

@synthesize rootViewController;
@synthesize landscape;
@synthesize configCenter;

#pragma mark -

+(AdmobViewController *) shareAdmobVC
{
    static dispatch_once_t once;
    static AdmobViewController *VC = nil;
    dispatch_once(&once, ^{
        VC = [[self alloc] init];
    });
    return VC;
}

-(void) InitVar
{
#ifdef LOG_USER_ACTION
    [FIRAnalytics logEventWithName:@"Active User" parameters:@{@"Open Times": [NSString stringWithFormat:@"Opens:%ld", [settings getAppOpenCountTotal]]}];
#endif
    
#ifdef ENABLE_IAP
    bInApp =[self getKeyTimes:@"be-inapp" default:false];
#else
    bInApp = false;
#endif
    
    
#ifdef ENABLE_IAP
    long now = time(NULL);
    
    // 连续登陆次数
    login_cnt = (int)[self getKeyTimes:@"login-cnt" default:1];
    
    long login_time_last = [self getKeyTimes:@"login-times" default:[settings getAppFirstInTime]];
    
    if ( (![self isSameDay:now date2:login_time_last]) && now > login_time_last) { // 不是同一天，且后登陆
        login_cnt++;
    }
    if (now >= login_time_last) { // 时间只能前进
        [self setKeyTimes:@"login-times" keyTimes:now];
    }else  if ( now < login_time_last - 36000){    //  如果比最后1次时间还少1天，这个有问题了(允许10个小时时差)
        login_cnt = 1;
        [self setKeyTimes:@"login-times" keyTimes:now];
    }
    
#ifdef LOG_USER_ACTION
    [FIRAnalytics logEventWithName:@"Active User" parameters:@{@"Login Days": [NSString stringWithFormat:@"Days:%d", login_cnt]}];
#endif
    [self setKeyTimes:@"login-cnt" keyTimes:login_cnt];
#endif
    
    
#ifdef ENABLE_OTHERAPP
    bOtherApp =[self getKeyTimes:@"be-otherapp" default:kOtherApp];
#endif
    
    
#ifdef ENABLE_WAKEUP
    bWakeUp = [self getKeyTimes:@"be-wakeup" default:kWakeUpMode];
#endif
}

-(BOOL)isSameDay:(long)date1 date2:(long)date2
{
    long interval = date1-date2;
    if(interval < 0)
        interval = -interval;
    return interval < 24*3600;
}

-(int) loginTimes
{
#ifdef  ENABLE_IAP
    return login_cnt;
#else
    return 0;
#endif
}

#ifdef  ENABLE_IAP
-(void) resetInApp
{
    if ([self isUnlocked:kUnlockAll]) {
        bInApp = true;
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle: proTitle
        //                                                message: @"Congratulations!! You've unlocked all packs and removed all ads."
        //                                               delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        //[alert show];
        
    }
    //    else if ( openTimes == 1){
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Tips"
    //                                                        message: [NSString stringWithFormat:@"If you use this app 30 days, \nAll Packs will be unlocked and all the ads will be removed.\n(you've used it %d days)", login_cnt]
    //                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //        [alert show];
    //    }
}
#endif

#ifdef ENABLE_OTHERAPP
-(void) initOtherApp
{
    NSMutableArray *app_logo_name = [[NSMutableArray alloc] initWithObjects:
                                     @"Emoji Art",
                                     
                                     @"Cut Me In",
                                     @"Eye Color",
                                     @"Mahjong",
                                     
                                     @"Change Face",
                                     @"Word Search",
                                     @"Number Link",
                                     
                                     @"Water Effect",
                                     @"Thin Booth",
                                     @"Zombie",
                                     
                                     @"Solitaire",
                                     @"2048",
                                     @"Splash",
                                     
                                     nil];
    
    NSMutableArray *app_name = [[NSMutableArray alloc] initWithObjects:
                                @"EmojiArt.png",
                                
                                @"CutMe.png",
                                @"EyeColor.png",
                                @"Mahjong.png",
                                
                                @"ChangeFace.png",
                                @"WordSearch.png",
                                @"NumberLink.jpg",
                                
                                @"WaterEffect.png",
                                @"Thin.png",
                                @"Zombie.png",
                                
                                @"Solitaire.png",
                                @"2048.png",
                                @"SplashEffect.png",
                                
                                nil];
    
    NSMutableArray *app_url = [[NSMutableArray alloc] initWithObjects:
                               @"https://itunes.apple.com/us/app/id511700298",
                               
                               @"https://itunes.apple.com/us/app/id897823665",
                               @"https://itunes.apple.com/us/app/id881415445",
                               @"https://itunes.apple.com/us/app/id952657464",
                               
                               @"https://itunes.apple.com/us/app/id631885241",
                               @"https://itunes.apple.com/us/app/id910819688",
                               @"https://itunes.apple.com/us/app/id935605766",
                               
                               @"https://itunes.apple.com/us/app/id660533690",
                               @"https://itunes.apple.com/us/app/id909195475",
                               @"https://itunes.apple.com/us/app/id718022002",
                               
                               @"https://itunes.apple.com/us/app/id684121362",
                               @"https://itunes.apple.com/us/app/id849600010",
                               @"https://itunes.apple.com/us/app/id633096599",
                               nil];
    
    
    NSMutableArray *app_str_id = [[NSMutableArray alloc] initWithObjects:
                                  @"511700298",  // emoji art
                                  
                                  @"897823665", // cut me in
                                  @"881415445", // eye color
                                  @"952657464",  // fat
                                  
                                  @"631885241",  // change face
                                  @"910819688",  // word search
                                  @"935605766",  // number link
                                  
                                  @"660533690",  // water effect
                                  @"909195475",  // thin
                                  @"718022002",  // zombie
                                  
                                  @"684121362", // solitaire
                                  @"849600010", // 2048
                                  @"633096599",  // splash
                                  
                                  nil];
    
    otherAppViewController = [[OtherAppViewCtrl alloc] init];
    
    int app_num = [app_name count];
    otherAppViewController.app_num = app_num;
    
    for (int idx = 0; idx < app_num; idx++) {
        NSString *app_name_tmp = [app_name objectAtIndex:idx];
        NSString *app_file_tmp = [[NSBundle mainBundle] pathForResource:app_name_tmp ofType:nil];
        [otherAppViewController.app_name insertObject: app_file_tmp  atIndex:idx];
        [otherAppViewController.app_logo_name insertObject:[app_logo_name objectAtIndex:idx] atIndex:idx];
        [otherAppViewController.app_url insertObject:[app_url objectAtIndex:idx] atIndex:idx];
        [otherAppViewController.app_id insertObject:[app_str_id objectAtIndex:idx] atIndex:idx];
    }
}
#endif

- (id) init
{
    self = [super init];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:(float)235/255
                                                  green:(float)235/255 blue:(float)235/255 alpha:1.0]];
    
    // 屏幕宽度和高度
    widthScreen = [UIScreen mainScreen].bounds.size.width;
    heightScreen = [UIScreen mainScreen].bounds.size.height;
    
    // 检查是普通屏幕还是retina屏幕
    scaleScreen = 2.0;
    if([[UIScreen mainScreen]respondsToSelector:@selector(scale)])
    {
        CGFloat tmp = [[UIScreen mainScreen] scale];
        if (tmp < 1.1)
            scaleScreen = 1.0;
    }
    
    // app id, cfg路径，是否从xml更新这3个配置是发布之后就是固定的
    app_id = kAppID;
    supportMail = FEEDBACK_MAIL;
    
    settings = [[CfgCenterSettings alloc] init];
    [settings onAppLoaded];
    
#ifdef ENABLE_OTHERAPP
    [self initOtherApp];
#endif
    
#ifdef ENABLE_IAP
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setInApp:) name:kInAppPaid object:nil];
#endif
    
    //NSString* buildin = [NSString stringWithFormat:@"{\"retcode\":\"1\",\"ad\":{\"type\":\"priority\",\"ads\":[{\"type\":\"admob\",\"banner\":\"%@\",\"interstitial\":\"%@\",\"native\":\"%@\"},{\"type\":\"chartboost\",\"appid\":\"%@\",\"signature\":\"%@\"}]},\"rt\":{\"s\":1,\"fi\":-172800,\"op\":3,\"ts\":3,\"tao\":60,\"wt\":false,\"it\":0},\"vd\":86400,\"t\":0}", kBannerID, kInterstitialID, @"", kCharboostAPPid, kCharboostSignature];
    NSString* wt = @"true";
    if([[ConfigCenter getContryCode] isEqual:@"US"])
        wt = @"false";
    
    NSString* buildin = [NSString stringWithFormat:@"{\"retcode\":\"1\",\"ad\":{\"type\":\"priority\",\"ads\":["
                         "{\"type\":\"maxwrap\",\"banner\":\"%@\",\"interstitial\":\"%@\", \"fg\":300, \"bg\":600},"
                         //                         "{\"type\":\"admob\",\"banner\":\"%@\",\"interstitial\":\"%@\",\"native\":\"%@\"},"
                         //                         "{\"type\":\"admob\",\"banner\":\"%@\",\"interstitial\":\"%@\",\"native\":\"%@\"},"
                         "{\"type\":\"admob\",\"banner\":\"%@\",\"interstitial\":\"%@\",\"native\":\"%@\"},"
                         "{\"type\":\"admob\",\"banner\":\"%@\",\"interstitial\":\"%@\",\"native\":\"%@\"}]},"
                         "\"_config\":[{\"type\":\"max_aps\",\"appid\":\"%@\",\"bannerad\":\"%@\",\"leaderad\":\"%@\",\"interad\":\"%@\",\"rewardad\":\"%@\"}],"
                         "\"rt\":{\"s\":0,\"fi\":-172800,\"op\":3,\"ts\":3,\"tao\":30,\"wt\":%@,\"it\":0},\"vd\":86400,\"t\":0,"
                         "\"rewardad\":{\"type\":\"priority\",\"ads\":["
                         //                         "{\"type\":\"facebook\",\"id\":\"%@\"},"
                         "{\"type\":\"maxwrap\",\"id\":\"%@\"}"
                         "]}}"
                         ,MAX_BANNER_ID, MAX_INTERSTITIAL_ID,
                         kBannerID3, @"", @"",
                         kBannerID, @"", @"",
                         APS_APP_ID, APS_BANNER_ID, APS_LEADER_ID, APS_INTER_ID,APS_REWARDAD_ID,//aps
                         wt,MAX_REWARD_ID];
    
//    NSString* buildin = [NSString stringWithFormat:@"{\"retcode\":\"1\",\"ad\":{\"type\":\"priority\",\"ads\":["
//                             "{\"type\":\"maxwrap\",\"banner\":\"%@\",\"interstitial\":\"%@\", \"fg\":300, \"bg\":600},"
//                             "{\"type\":\"admob\",\"banner\":\"%@\",\"interstitial\":\"%@\",\"native\":\"%@\", \"fg\":300, \"bg\":600}"
//                             "]},"
//                             "\"rt\":{\"s\":0,\"fi\":-172800,\"op\":3,\"ts\":3,\"tao\":30,\"wt\":%@,\"it\":0},\"vd\":86400,\"t\":0,"
//                             "\"rewardad\":{\"type\":\"priority\",\"ads\":["
//                             "{\"type\":\"maxwrap\",\"id\":\"%@\"},"
//                             "{\"type\":\"admob\",\"id\":\"%@\"}"
//                             "]}}",
//                             MAX_BANNER_ID, MAX_INTERSTITIAL_ID,
//                             kBannerID, kInterstitialID, @"",
//                             wt,
//                             MAX_REWARD_ID,
//                             kRewardAd
//        ];
    
    
    configCenter = [[ConfigCenter alloc] initWithDefault:buildin appid:app_id];
    
    // 检查是否有新版本，用于提升是否升级
    //[self performSelectorInBackground:@selector(checkNewVersion) withObject:nil];
    
    //    关闭下载
    //    if (bUpdateFromXml) {
    //        [self performSelectorInBackground:@selector(downloadConfigFromServer) withObject:nil];
    //        [NSThread sleepForTimeInterval:2.0];
    //    }
    
    [self InitVar];
    
    
#ifdef ENABLE_IAP
    if (![self isADRemoved]) {
#endif
        
#ifdef ENABLE_AD
        // create ad object before initial Network
        ADWrapper* adwrapper = [self getAdWrapperInUse];
        //11.16
        [self init_reward_ad];
        //init ad network
        [ADWrapper initAdNetwork:[configCenter getAdConfigList:true] withCallback:^(){
            if(adcenter != nil) {
                [adcenter delayInitAfterNetworkFinish];
            }
            if(adcenter_land != nil) {
                [adcenter_land delayInitAfterNetworkFinish];
            }
            if(rewardad != nil) {
                [rewardad delayInitAfterNetworkFinish];
            }
        }];
        [self load_reward_ad];
        [adwrapper init_first_time];
//        [self getAdWrapperInUse];
#endif
        
#ifdef ENABLE_IAP
    }
#endif
    
#ifdef ENABLE_WAKEUP
    // 提醒功能
    [self initWakeUp];
#endif
    
    // 横屏的时候，action sheet需要
    landscapeView = nil;
    landscape = 0;
    
    
    _rtService = [[GRTService alloc] initWithAppid:app_id FeedbackEmail:supportMail];
    //_rtService = [[RTService alloc] initWithAppid:app_id FeedbackEmail:supportMail];
    [self rtReloadConfig];
    if([settings isNewVersionUpdate]) {
        [_rtService resetOpenCount];
    }
    
    return self;
}

-(void) load_reward_ad {
    rewardad.delegate = _rewardAdClient;
    [rewardad init_reward_ad];
}

- (void) rtReloadConfig {
    NSDictionary* config = [configCenter getRtConfig:false];
    if(config != nil)
        [_rtService udconfig:config];
    else
        [_rtService udconfig:[configCenter getRtConfig:true]];
}

//-(BOOL) checkNewVersion
//{
//    // 是否有新版本等
//    bHasNewVersion = [self onCheckVersion];
//    [self setKeyTimes:@"has-new-version" keyTimes:bHasNewVersion];
//    return bHasNewVersion;
//}


- (NSString*) getAppUrl {
    return [NSString stringWithFormat:@"%@%ld", @"https://itunes.apple.com/cn/app/id", app_id];
}

- (CfgCenterSettings *)getAppUseStats {
    return settings;
}

#pragma mark -
#pragma mark in-app purchase

#ifdef ENABLE_IAP
-(void) setInApp:(NSNotification*)noti
{
    bInApp = true;
    [self setKeyTimes:@"be-inapp" keyTimes:bInApp];
    
    NSString *product = [noti object];
    [self setKeyTimes:product keyTimes:true];
#ifdef ENABLE_AD
    if([product isEqualToString:kRemoveAd] || [product isEqualToString:kUnlockAll]) {
        if(currentBannerRoot != nil)
            [self remove_all_ads:currentBannerRoot];
    }
#endif
}
#endif


-(void) doUpgradeInApp:(UIViewController*)viewCtrl
{
#ifdef ENABLE_IAP
    viewCtrl.parentViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    IAPViewController* iapv = [[IAPViewController alloc] init];
    iapv.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [viewCtrl presentViewController:iapv animated:YES completion:^{
        ;
    }];
#endif
}
-(void) doUpgradeInApp:(UIViewController*)viewCtrl product:(NSString*)productID
{
#ifdef ENABLE_IAP
    viewCtrl.parentViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    IAPViewController* iapv = [[IAPViewController alloc] initWithProductID:productID login:login_cnt];
    iapv.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [viewCtrl presentViewController:iapv animated:YES completion:^{
        ;
    }];
#endif
}

-(bool) IsPaid:(NSString*)product_id
{
    bool bPaid = [self getKeyTimes:product_id default:false];
    if (!bPaid) {
        bPaid = [self getKeyTimes:kUnlockAll default:false];
    }
    
    return bPaid;
}

-(BOOL) isUnlocked:(NSString*)product_id
{
    if ([self IsPaid:kUnlockAll]) {
        return  YES;
    }
    
    if ([self IsPaid:product_id]) {
        return YES;
    }
    
    return NO;
}

-(BOOL) hasInAppPurchased {
    return bInApp;
}

-(BOOL) isADRemoved {
    return [self IsPaid:kRemoveAd] || [self IsPaid:kUnlockAll];
}

#ifdef ENABLE_WAKEUP
-(void) initWakeUp
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *localArr = [app scheduledLocalNotifications];
    if (!localArr) {
        return;
    }
    
    /*  看通知是否已经存在 */
    UILocalNotification *localNoti = nil;
    for (UILocalNotification *noti in localArr) {
        NSDictionary *dict = noti.userInfo;
        if (dict) {
            NSString *inKey = [dict objectForKey:kWakeUpNotiName];
            if ([inKey isEqualToString:kWakeUpNotiName]) {
                localNoti = noti;
                break;
            }
        }
    }
    /* 如果已经存在，先删除通知 */
    if (localNoti) {
        [app cancelLocalNotification:localNoti];
    }
    app.applicationIconBadgeNumber = 0;
    /*如果关闭了通知*/
    if (!bWakeUp) {
        return;
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationSettings *notisettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notisettings];
    }
    
    /* 设定起始时间 */
    NSDate *after_days =[NSDate dateWithTimeIntervalSinceNow:kWakeUpDays*86400];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                    | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:after_days];
    long day = [components day];
    long month= [components month];
    long year= [components year];
    NSString *now = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %@", year, month, day, kWakeUpFirstTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:now];
    
    /* 创建local通知 */
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    if (noti) {
        noti.fireDate = date;
        noti.timeZone = [NSTimeZone defaultTimeZone];
        noti.repeatInterval = kWakeUpFreq;
        noti.soundName = UILocalNotificationDefaultSoundName;
        noti.alertBody = kWakeUpMsg;
        noti.applicationIconBadgeNumber = 1;
        
        NSDictionary *infoDic = [NSDictionary dictionaryWithObject:kWakeUpNotiName forKey:kWakeUpNotiName];
        noti.userInfo = infoDic;
        
        [app scheduleLocalNotification:noti];
    }
}
#endif

-(bool)onCheckVersion
{
    // 当前版本
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDic objectForKey:@"CFBundleVersion"];
    
    // 从itune上取最新版本
    NSString *Url = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%ld", app_id];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:Url]];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *error;
    if (response == nil) {  //网络不通的时候
        return false;
    }
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response
                                                        options:NSJSONReadingMutableLeaves error:&error];
    NSArray *infoArray = [dic objectForKey:@"results"];
    if (![infoArray count])
        return false;
    
    NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
    NSString *lastVersion = [releaseInfo objectForKey:@"version"];
    
    if ([lastVersion compare:currentVersion] == NSOrderedDescending)
        return true;
    return false;
}

#ifdef ENABLE_OTHERAPP
-(bool) canShowOtherApp
{
    return bOtherApp;
}

-(void)otherApp:(UIViewController *)viewCtrl
{
    otherAppViewController.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    viewCtrl.parentViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [viewCtrl presentViewController:otherAppViewController animated:YES completion:^{
        ;
    }];
}
#endif

#pragma mark -
#pragma mark admob banner

#ifdef ENABLE_AD

-(void) init_adcenter_port {
    @try {
        adcenter = [ADWrapper createAD:[configCenter getAdConfig:false] vc:self];
    } @catch (NSException *exception) {
    } @finally {
    }
    
    //consider the build in value is alway valid
    if(adcenter == nil)
        adcenter = [ADWrapper createAD:[configCenter getAdConfig:true] vc:self];
    
    adcenter.delegate = self;
    
    [adcenter init_first_time];
}

-(void) init_adcenter_land {
    @try {
        adcenter_land = [ADWrapper createAD:[configCenter getAdConfig:false] vc:self];
    } @catch (NSException *exception) {
    } @finally {
    }
    
    //consider the build in value is alway valid
    if(adcenter_land == nil)
        adcenter_land = [ADWrapper createAD:[configCenter getAdConfig:true] vc:self];
    
    adcenter_land.delegate = self;
    
    [adcenter_land init_first_time];
}

-(void) init_reward_ad {
    @try {
        rewardad = [RewardAdWrapper createAD:[configCenter getRewardAdConfig:false] vc:self];
    } @catch (NSException *exception) {
    } @finally {
    }
    
    //consider the build in value is alway valid
    if(rewardad == nil)
        rewardad = [RewardAdWrapper createAD:[configCenter getRewardAdConfig:true] vc:self];
    
    rewardad.delegate = _rewardAdClient;
    
    [rewardad init_reward_ad];
}

- (void)setRewardAdClient:(id<RewardAdWrapperDelegate> )AdClient {
    rewardad.delegate = AdClient;
    _rewardAdClient = AdClient;
}

-(void) willOrientationChangeTo:(UIInterfaceOrientation) to {
    UIInterfaceOrientation current = [UIApplication sharedApplication].statusBarOrientation;
    if((UIInterfaceOrientationIsPortrait(current) && UIInterfaceOrientationIsPortrait(to))
       || (UIInterfaceOrientationIsLandscape(current) && UIInterfaceOrientationIsLandscape(to))) {
        return;
    }
    
    if(currentBannerRoot != nil) {
        if(UIInterfaceOrientationIsPortrait(current)) {
            if(adcenter) {
                [adcenter remove_all_ads:currentBannerRoot];
            }
        } else {
            if(adcenter_land) {
                [adcenter_land remove_all_ads:currentBannerRoot];
            }
        }
        [[currentBannerRoot subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    if(UIInterfaceOrientationIsPortrait(current)) {
        adcenter.delegate = nil;
    } else {
        adcenter_land.delegate = nil;
    }
}

-(void) onOrientationChangeFrom:(UIInterfaceOrientation) from {
    UIInterfaceOrientation current = [UIApplication sharedApplication].statusBarOrientation;
    if((UIInterfaceOrientationIsPortrait(current) && UIInterfaceOrientationIsPortrait(from))
       || (UIInterfaceOrientationIsLandscape(current) && UIInterfaceOrientationIsLandscape(from))) {
        return;
    }
    
    if(currentBannerRoot != nil) {
        [[self getAdWrapperInUse] show_admob_banner:currentBannerRoot placeid:currentBannerPlace];
    }
    [self getAdWrapperInUse].delegate = self;
}

-(void) onOrientationChanged {
    UIInterfaceOrientation current = [UIApplication sharedApplication].statusBarOrientation;
    if ((UIInterfaceOrientationIsPortrait(current) && UIInterfaceOrientationIsPortrait(lastOrientation))
        || (UIInterfaceOrientationIsLandscape(current) && UIInterfaceOrientationIsLandscape(lastOrientation))) {
        return;
    }
    
    if(currentBannerRoot != nil) {
        if(UIInterfaceOrientationIsPortrait(lastOrientation)) {
            [adcenter remove_all_ads:currentBannerRoot];
        } else {
            [adcenter_land remove_all_ads:currentBannerRoot];
        }
        [[currentBannerRoot subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [[self getAdWrapperInUse] show_admob_banner:currentBannerRoot placeid:currentBannerPlace];
    }
    if(UIInterfaceOrientationIsPortrait(current)) {
        adcenter.delegate = nil;
    } else {
        adcenter_land.delegate = nil;
    }
    [self getAdWrapperInUse].delegate = self;
}

-(ADWrapper*) getAdWrapperInUse {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    lastOrientation = orientation;
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        if(adcenter_land == nil) {
            [self init_adcenter_land];
            
            if(lastBannerAlign != AD_TOP) {
                [adcenter_land setBannerAlign:lastBannerAlign];
            }
        }
        return adcenter_land;
    } else {
        if(adcenter == nil) {
            [self init_adcenter_port];
            
            if(lastBannerAlign != AD_TOP) {
                [adcenter setBannerAlign:lastBannerAlign];
            }
        }
        return adcenter;
    }
}

-(BOOL) useSmartBannerInLandscape {
    return AD_SMART;
}

-(void) show_admob_banner:(float)posx posy:(float)posy view:(UIView*)view
{
    [self show_admob_banner:view placeid:AD_DEFAULT_PLACEID];
}

-(void) show_admob_banner_smart:(float)posx posy:(float)posy view:(UIView*)view
{
    [self show_admob_banner:view placeid:AD_DEFAULT_PLACEID];
}

// 缺省显示在屏幕的底部
-(void) show_admob_banner:(UIView*)view
{
    [self show_admob_banner:view placeid:AD_DEFAULT_PLACEID];
}

// 缺省显示在屏幕的底部
-(void) show_admob_banner:(UIView*)view placeid:(NSString*)place
{
    currentBannerRoot = view;
    currentBannerPlace = place;
    [[self getAdWrapperInUse] show_admob_banner:currentBannerRoot placeid:currentBannerPlace];
}

-(void) setBannerAlign:(ADAlignment) align {
    lastBannerAlign = align;
    [adcenter setBannerAlign:align];
    if(adcenter_land != nil) {
        [adcenter_land setBannerAlign:align];
    }
}
-(void) hide_banner {
    [[self getAdWrapperInUse] hide_banner];
}

-(BOOL) bannerAdLoaded:(int)place {
    return [[self getAdWrapperInUse] bannerReady] == AD_LOADED;
}

#pragma mark -
#pragma mark admob native

-(void) show_admob_native:(float)posx posy:(float)posy width:(float)width height:(float)height view:(UIView*)view
{
    [self show_admob_native:posx posy:posy width:width height:height view:view placeid:AD_DEFAULT_PLACEID];
}

-(void) show_admob_native:(float)posx posy:(float)posy width:(float)width height:(float)height view:(UIView*)view placeid:(NSString *)place
{
    [[self getAdWrapperInUse] show_admob_native:posx posy:posy width:width height:height view:view placeid:place];
}

#endif //ENABLE_AD

#pragma mark -
#pragma mark  admob interstitial

#ifdef ENABLE_AD

-(BOOL) _show_admob_interstitial:(UIViewController*)viewController placeid:(int)place
{
#ifdef ADRT
    GRTService* grt = (GRTService*)_rtService;
    if(![grt isGRT])
    {
        NSString* str = @"full screen Ad removed";
        if([grt getCurrentLanguageType] == 1)
            str = @"去除全屏广告";
        [self rtReloadConfig];
        bool show = [grt getRT:viewController settings:settings isLock:false rd:str cb:^(void){}];
        if(!show)
        {
            [[self getAdWrapperInUse] show_admob_interstitial:viewController placeid:place];
            lastShowInerstitialAd = time(NULL);
            return YES;
        }
    }
    return NO;
#else
    [[self getAdWrapperInUse] show_admob_interstitial:viewController placeid:place];
    lastShowInerstitialAd = time(NULL);
    return YES;
#endif
}

// 动作触发调用的显示全屏的函数
-(BOOL) show_admob_interstitial:(UIViewController*)viewController
{
    return [self show_admob_interstitial:viewController placeid:0];
}

-(BOOL) try_show_admob_interstitial:(UIViewController *)viewController ignoreTimeInterval:(BOOL)ignore
{
    return [self try_show_admob_interstitial:viewController placeid:0 ignoreTimeInterval:ignore];
}

-(BOOL) admob_interstial_ready
{
    return [self admob_interstial_ready:0];
}

-(BOOL) show_admob_interstitial:(UIViewController*)viewController placeid:(int) place {
    if ([self isADRemoved] || ![self admob_interstial_ready:place]) {
        return NO;
    }
    
    return [self _show_admob_interstitial:viewController placeid:place];
}

-(BOOL) try_show_admob_interstitial:(UIViewController *)viewController placeid:(int) place ignoreTimeInterval:(BOOL)ignore  {
    if ([self isADRemoved] || ![self admob_interstial_ready:place]) {
        return NO;
    }
    
    long now = time(NULL);
    if (now - lastShowInerstitialAd > 30 || ignore) {
        return [self _show_admob_interstitial:viewController placeid:place];
    }
    return NO;
}

-(BOOL) admob_interstial_ready:(int)place {
    return [[self getAdWrapperInUse] admob_interstial_ready:place];
}

#pragma mark -
#pragma mark remove ads

// 停止全屏广告定时器和删除banner
-(void)remove_banner:(UIView*)rootView
{
    [[self getAdWrapperInUse] remove_banner:rootView];
}

-(void)remove_native:(UIView *)rootView
{
    [[self getAdWrapperInUse] remove_native:rootView];
}

-(void) removeAds:(BOOL) paid
{
}

// 删除全屏和banner
- (void)remove_all_ads:(UIView*)rootView
{
    [[self getAdWrapperInUse] remove_all_ads:rootView];
}
#endif //ENABLE_AD


#pragma mark -
#pragma mark ADWrapperDelegate

- (void)interstitialDidReceiveAd
{
#ifdef  ENABLE_IAP
    if ([self isADRemoved]) {
        return;
    }
#endif
    
    if ([self.delegate respondsToSelector:@selector(adMobVCDidReceiveInterstitialAd:)]) {
        [self.delegate adMobVCDidReceiveInterstitialAd:self];
    }
}

-(BOOL)interstitialDidDismissScreen
{
    if ([self.delegate respondsToSelector:@selector(adMobVCDidCloseInterstitialAd:)]) {
        [self.delegate adMobVCDidCloseInterstitialAd:self];
    }
    
#ifdef  ENABLE_IAP
    if ([self isADRemoved]) {
        return FALSE;
    }
#endif
    return TRUE;
}

-(void)interstitialWillDismissScreen
{
    if ([self.delegate respondsToSelector:@selector(adMobVCWillCloseInterstitialAd:)]) {
        [self.delegate adMobVCWillCloseInterstitialAd:self];
    }
}

-(void)interstitialDidFailed
{
    if ([self.delegate respondsToSelector:@selector(adMobVCDidFailedInterstitialAd:)]) {
        [self.delegate adMobVCDidFailedInterstitialAd:self];
    }
}

-(void)interstitialDidShow
{
    if ([self.delegate respondsToSelector:@selector(adMobVCDidShowInterstitialAd:)]) {
        [self.delegate adMobVCDidShowInterstitialAd:self];
    }
}

-(void)interstitialDidClick
{
    if ([self.delegate respondsToSelector:@selector(adMobVCDidClickInterstitialAd:)]) {
        [self.delegate adMobVCDidClickInterstitialAd:self];
    }
}

-(void) bannerDidLoaded:(ADWrapper *)banner {
    if([self.bannerClient respondsToSelector:@selector(adMobVCBannerAdLoaded:)]) {
        [self.bannerClient adMobVCBannerAdLoaded:banner];
    }
}

-(void) bannerDidFailedLoad:(ADWrapper *)banner error:(NSError *)error {
    if([self.bannerClient respondsToSelector:@selector(adMobVCBannerAdFailedLoaded:error:)]) {
        [self.bannerClient adMobVCBannerAdFailedLoaded:banner error:error];
    }
}

-(void) bannerDidClick:(ADWrapper *)banner {
    if([self.bannerClient respondsToSelector:@selector(adMobVCBannerAdClick:)]) {
        [self.bannerClient adMobVCBannerAdClick:banner];
    }
}

-(void) nativeDidFailedLoad:(ADWrapper *)banner error:(NSError *)error {
    //do nothing
}

#pragma mark -
#pragma mark RewardedAd

-(BOOL) isRewardAdLoaded:(int)place {
    if(rewardad != nil) {
        return [rewardad isRewardAdReady:place];
    }
    return FALSE;
}

-(BOOL) showRewardAd:(UIViewController*) rootview placeid:(int)place {
    if(rewardad != nil) {
        return [rewardad showRewardAd:rootview placeid:place];
    }
    return FALSE;
}

#pragma mark -

- (void)loadView
{
    [super loadView];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)dealloc
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark rating & config update

- (BOOL) ifNeedShowNext:(UIViewController*) viewCtrl {
    NSDictionary* nt =[configCenter getNtConfig];
    if(nt == nil)
        return NO;
    @try {
        NSString* appid = nt[@"a"];
        if([appid length] != 0) {
            ntappid = appid;
            ntviewcontroller = viewCtrl;
            
            //弹出对话框
            NSString* message = [NSString stringWithFormat:@"This version is out of data.\nTry the new version of this app now, enjoy more newer features!"];
            NSString* c = @"Cancel";
            NSString* d = @"Try now";
            
            int type = [_rtService getCurrentLanguageType];
            if(type == 1)
            {
                message = [NSString stringWithFormat:@"您使用的这个版本已经过期了. 快来体验我们的最新版本吧，享受更多新的特性"];
                c = @"取消";
                d = @"去体验";
            }
            UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* confirm = [UIAlertAction actionWithTitle:d style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self openAppWithId:ntappid viewCtrl:ntviewcontroller];
            }];
            UIAlertAction* cancel = [UIAlertAction actionWithTitle:c style:UIAlertActionStyleCancel handler:nil];
            [ac addAction:confirm];
            [ac addAction:cancel];
            [viewCtrl presentViewController:ac animated:YES completion:nil];
            return YES;
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    return NO;
}

- (void) checkConfigUD {
    [configCenter checkUD:settings];
}

- (void) recordValidUseCount {
    [settings recordValidUseCount];
}

- (long) getValidUseCount {
    return [settings getValidUseCount];
}

- (BOOL) decideShowRT:(UIViewController*)viewctrl {
    return [self.rtService decideShowRT:viewctrl settings:settings];
}

- (BOOL) getRT:(UIViewController*)viewctrl isLock:(BOOL)lock rd:(NSString*)rd cb: (CBFUNC)cb {
    [self rtReloadConfig];
    return [((GRTService*)self.rtService) getRT:viewctrl settings:settings isLock:lock rd:rd cb:cb];
}

#pragma mark -
#pragma mark open app

- (void)openAppWithId:(NSString *)_appId viewCtrl:(UIViewController*) viewCtrl
{
    Class storeVC = NSClassFromString(@"SKStoreProductViewController");
    if (storeVC != nil)
    {
        SKStoreProductViewController *_SKSVC = [[SKStoreProductViewController alloc] init];
        _SKSVC.delegate = self;
        [_SKSVC loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: _appId}
                          completionBlock:^(BOOL result, NSError *error) {
                          }];
        [viewCtrl presentViewController:_SKSVC animated:YES completion:nil];
    }
    else
    {
        //低于iOS6没有这个类
        NSString *_idStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8",_appId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_idStr]];
    }
}

// 应用内打开app store所需要的
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark set/get
// 设置某个key，value是NSString类型
-(void) setKeyTimes:(NSString*)strKey str:(NSString *)strValue
{
    NSUserDefaults *saveStrDefaults = [NSUserDefaults standardUserDefaults];
    [saveStrDefaults setObject:strValue forKey:strKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 设置某个key值，value是int类型
-(void) setKeyTimes:(NSString*) strKey keyTimes:(long)keyTimes
{
    NSString* strTimes = [NSString stringWithFormat:@"%ld", keyTimes];
    [self setKeyTimes:strKey str:strTimes];
}

// 得到某个key值，value是str
-(NSString *) getStrKey:(NSString*)strKey
{
    NSUserDefaults* diskDefaults = [NSUserDefaults standardUserDefaults];
    return [diskDefaults objectForKey:strKey];
}

// 得到某个key值，value是str，如果key不存在，则将default设置进去，
// 并返回default
-(NSString *) getStrKey:(NSString*)strKey default:(NSString *)str
{
    NSUserDefaults* diskDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tmpStr = [diskDefaults objectForKey:strKey];
    if (tmpStr != nil) {
        return tmpStr;
    }
    else {
        [diskDefaults setObject:str forKey:strKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return str;
    }
}

// value是int，如果key不存在，返回def，并将def存入进去
-(long) getKeyTimes:(NSString *)strKey default:(long)def
{
    NSString* defStr = [NSString stringWithFormat:@"%ld", def];
    NSString* strTimes = [self getStrKey:strKey default:defStr];
    
    if (strTimes != nil) {
        return [strTimes intValue];
    }else  {
        return def;
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result2
{
    
    NSLog(@"send msg,%ld",(long)result2);
    switch (result2) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
        {
            UIAlertController* alertcontroller = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to send SMS!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //pass
            }];
            [alertcontroller addAction:ok];
            UIViewController* parent = [controller presentingViewController];
            [controller dismissViewControllerAnimated:YES completion:^(){
                [parent presentViewController:alertcontroller animated:YES completion:nil];
            }];
            return;
        }
        case MessageComposeResultSent:
            break;
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(CGFloat) getSafeAreaBottom {
    CGFloat bottomPadding = 0;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        bottomPadding = window.safeAreaInsets.bottom;
    }
    if(bottomPadding == 0)
        NSLog(@"[ADUNION] Safe area not supported or no bottom padding.");
    
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGFloat pixel = bottomPadding * screenScale;
    return pixel;
}

-(CGFloat) getSafeAreaTop {
    CGFloat topPadding = 0;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        topPadding = window.safeAreaInsets.top;
    }
    if(topPadding == 0)
        NSLog(@"[ADUNION] Safe area not supported or no bottom padding.");
    
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGFloat pixel = topPadding * screenScale;
    return pixel;
}

-(CGFloat) getSafeAreaLeft {
    CGFloat padding = 0;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        padding = window.safeAreaInsets.left;
    }
    if(padding == 0)
        NSLog(@"[ADUNION] Safe area not supported or no bottom padding.");
    
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGFloat pixel = padding * screenScale;
    return pixel;
}

-(CGFloat) getSafeAreaRight {
    CGFloat padding = 0;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        padding = window.safeAreaInsets.right;
    }
    if(padding == 0)
        NSLog(@"[ADUNION] Safe area not supported or no bottom padding.");
    
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGFloat pixel = padding * screenScale;
    return pixel;
}

-(CGFloat) getMaxBannerheight {
    CGFloat adHeight = MAAdFormat.banner.adaptiveSize.height;
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGFloat pixel = adHeight  * screenScale;
    return pixel;
}

-(float) getBannerAdHeight{
#ifdef UNITY_MODE
    return  MAAdFormat.banner.adaptiveSize.height * [UIScreen mainScreen].scale;
#endif
    return  MAAdFormat.banner.adaptiveSize.height;
}

#pragma mark -

-(NSString *) getLuxandKey
{
    return @"HmtTRcHkF92dedqGVJD74SQFvRSpXbhq1DPWoi6k7yuwuKPxx1vHcCxc5x6mPpQB0+g4uyQU+OrYdXBIWRAnQl6QBYQ1ZHan3qx7PAqlSCUcmKYsNpTJqCI436uBWGpIEWRAo2dHj+hLGqig1wU/V57kKGEREaX2v8vHvjXxrF8=";
}
@end
