//
//  Admob.h
//  2014-06-23
//
//  version 3.3

#import "CfgCenter.h"

#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

#ifdef ENABLE_AD
#import "ADWrapper.h"
#endif

#import "GRTService.h"
#import "ConfigCenter.h"
#import "AdmobRewardVideoClient.h"

typedef enum {
    AlertViewTypeUpdatePro = 1001, // 升级收费版本
    AlertViewTypeUpdateNew = 1002, // 升级最新版本
    AlertViewRT = 1003,
    AlertViewTypeOther = 1004,
} AdmobAlertViewType;

// ipad和iphone5，iphone4的判断
#define IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

// 广告条的高度
#define kAdHeight                  ((IS_IPAD?90:50))

// 系统的版本号
#define kSystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]

@class AdmobViewController;
@class AdmobVCDelegate;

@protocol AdmobViewControllerDelegate <NSObject>

-(void)adMobVCDidReceiveInterstitialAd:(AdmobViewController*)adMobVC;
-(void)adMobVCWillCloseInterstitialAd:(AdmobViewController*)adMobVC;
-(void)adMobVCDidCloseInterstitialAd:(AdmobViewController*)adMobVC;
-(void)adMobVCDidFailedInterstitialAd:(AdmobViewController*)adMobVC;
-(void)adMobVCDidShowInterstitialAd:(AdmobViewController*)adMobVC;
-(void)adMobVCDidClickInterstitialAd:(AdmobViewController*)adMobVC;

@end

@protocol AdmobVCBannerAdDelegate <NSObject>
#ifdef ENABLE_AD
-(void)adMobVCBannerAdLoaded:(ADWrapper*)bannerad;
-(void)adMobVCBannerAdFailedLoaded:(ADWrapper*)bannerad error:(NSError*)error;
-(void)adMobVCBannerAdClick:(ADWrapper*)bannerad;
#endif
@end

#ifdef ENABLE_AD
@interface AdmobViewController : UIViewController <UINavigationBarDelegate,UIAlertViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, SKStoreProductViewControllerDelegate, ADWrapperDelegate>
#else
@interface AdmobViewController : UIViewController <UINavigationBarDelegate,UIAlertViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, SKStoreProductViewControllerDelegate>
#endif

+(AdmobViewController *) shareAdmobVC;

@property (nonatomic,retain) UIViewController* rootViewController; /* 父窗口view controller, 全屏需要 */
@property (nonatomic) int landscape;           // 横屏还是竖屏，横 true, 在显示action sheet有用
@property (weak, nonatomic) id<AdmobViewControllerDelegate>delegate;
@property (nonatomic, strong) RTService* rtService;
@property (nonatomic, strong) ConfigCenter* configCenter;
@property int status;

@property (nonatomic, retain) id<AdmobVCBannerAdDelegate> bannerClient;
@property (nonatomic, retain) AdmobVCDelegate* interadClient;

#ifdef ENABLE_AD
@property (nonatomic, retain) AdmobRewardVideoClient* rewardAdClient;
#endif

- (NSString*) getAppUrl;

//统计信息
- (CfgCenterSettings*) getAppUseStats;

// 内购相关
//#ifdef ENABLE_IAP
-(void) doUpgradeInApp:(UIViewController*)viewCtrl;         // 执行升级操作
-(void) doUpgradeInApp:(UIViewController*)viewCtrl product:(NSString*)productID;
-(bool) IsPaid:(NSString*)product_id;
-(BOOL) isUnlocked:(NSString*)product_id;
-(BOOL) hasInAppPurchased;
-(BOOL) isADRemoved;

-(int)  loginTimes;
//#endif


// 推荐，应用墙功能
#ifdef  ENABLE_OTHERAPP
-(bool) canShowOtherApp;      // 检查是否显示广告墙
-(void) otherApp:(UIViewController*)viewCtrl;      //  推荐
#endif


// 广告
#ifdef ENABLE_AD
//解决设备旋转时banner广告显示
-(void) willOrientationChangeTo:(UIInterfaceOrientation) to;
-(void) onOrientationChangeFrom:(UIInterfaceOrientation) from;
-(void) onOrientationChanged;

-(BOOL) useSmartBannerInLandscape;
/* 显示banner, 所有的view公用一个banner实例，切换view的时候修改banner的父view */
-(void) show_admob_banner:(float)posx posy:(float)posy view:(UIView*)view __attribute__((deprecated("use show_admob_banner:(UIView*)view placeid:(NSString*) place instead")));
-(void) show_admob_banner_smart:(float)posx posy:(float)posy view:(UIView*)view __attribute__((deprecated("use show_admob_banner:(UIView*)view placeid:(NSString*) place instead")));
-(void) show_admob_banner:(UIView*)view __attribute__((deprecated("use show_admob_banner:(UIView*)view placeid:(NSString*) place instead"))); // 后台配置来展示广告的位置，但是实际上不能修改
//with placeid
-(void) show_admob_banner:(UIView*)view placeid:(NSString*) place;
-(void) setBannerAlign:(ADAlignment) align;
-(BOOL) admob_ever_recive_banner;
-(BOOL) bannerAdLoaded:(int)place;

/* 创建原生广告 */
-(void) show_admob_native:(float)posx posy:(float)posy width:(float)width height:(float)height view:(UIView*)view;
//with placeid
-(void) show_admob_native:(float)posx posy:(float)posy width:(float)width height:(float)height view:(UIView*)view placeid:(NSString*) place;

/* 创建全屏 */
-(BOOL) show_admob_interstitial:(UIViewController*)viewController __attribute__((deprecated("use show_admob_interstitial:(UIViewController*)viewController placeid:(int) placeid instead")));
-(BOOL) try_show_admob_interstitial:(UIViewController *)viewController ignoreTimeInterval:(BOOL)ignore __attribute__((deprecated("use try_show_admob_interstitial:(UIViewController *)viewController placeid:(int) place ignoreTimeInterval:(BOOL)ignore instead")));
-(BOOL) admob_interstial_ready __attribute__((deprecated("use admob_interstial_ready:(int) placeid instead")));
//with placeid
-(BOOL) show_admob_interstitial:(UIViewController*)viewController placeid:(int) place;
-(BOOL) try_show_admob_interstitial:(UIViewController *)viewController placeid:(int) place ignoreTimeInterval:(BOOL)ignore;
-(BOOL) admob_interstial_ready:(int)place;

/* 删除banner和全屏 */
-(void)remove_all_ads:(UIView *)rootView;
-(void)remove_banner:(UIView*)rootView;
-(void)remove_native:(UIView*)rootView;

-(void) removeAds:(BOOL) paid;

/* 激励视频 */
-(void) init_reward_ad;
-(BOOL) isRewardAdLoaded:(int)place;
-(BOOL) showRewardAd:(UIViewController*) rootview placeid:(int)place;
#endif


// 配置文件和评价
- (BOOL) ifNeedShowNext:(UIViewController*) viewCtrl;
- (void) checkConfigUD;
- (void) recordValidUseCount;
- (long) getValidUseCount;
- (BOOL) decideShowRT:(UIViewController*)viewctrl;
- (BOOL) getRT:(UIViewController*)viewctrl isLock:(BOOL)lock rd:(NSString*)rd cb: (CBFUNC)cb;


// 通用存储函数
// 一些固化存储，get函数在读取不到配置的时候，使用缺省值
-(NSString *) getStrKey:(NSString*)strKey;
-(NSString *) getStrKey:(NSString*)strKey default:(NSString*)str;
-(long) getKeyTimes:(NSString *)strKey default:(long)def;

-(void) setKeyTimes:(NSString*) strKey keyTimes:(long)keyTimes;
-(void) setKeyTimes:(NSString*)strKey str:(NSString *)strValue;

-(NSString *) getLuxandKey;
@end

