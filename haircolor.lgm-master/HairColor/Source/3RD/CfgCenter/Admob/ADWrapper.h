//
//  ADWrapper.h
//  version 3.3
//
//  Created by 昭 陈 on 16/5/17.
//  Copyright © 2016年 昭 陈. All rights reserved.
//

#ifndef ADWrapper_h
#define ADWrapper_h
#import <UIKit/UIKit.h>

#define REFRESH_TIME_FOREGROUND 120
#define REFRESH_TIME_BACKGROUND 300
#define REFRESH_TIME_BACKGROUND_LOADED 3600
#define REFRESH_TIME_IMPRESSION 600

@class AdmobViewController;

typedef enum {
    AD_NOTINIT,
    AD_LOADING,
    AD_LOADED,
    AD_FAILED,
    AD_NOTSURPORT,
} ADStatus;

typedef enum {
    AD_PORTRAIT,
    AD_LANDSCAPE,
} ADOrientation;

typedef enum {
    AD_TOP,
    AD_BOTTOM,
    AD_CENTER,
} ADAlignment;

extern BOOL applovin_initialized;

@class ADWrapper;

@protocol ADWrapperDelegate <NSObject>

//ad wrapper回调的函数
-(void) interstitialDidReceiveAd;
-(BOOL) interstitialDidDismissScreen;
-(void) interstitialWillDismissScreen;
-(void) interstitialDidFailed;
-(void) interstitialDidShow;
-(void) interstitialDidClick;
-(void) bannerDidLoaded:(ADWrapper*) banner;
-(void) bannerDidFailedLoad:(ADWrapper *)banner error:(NSError*) error;
-(void) bannerDidClick:(ADWrapper *)banner;
-(void) nativeDidFailedLoad:(ADWrapper *)banner error:(NSError*) error;

@end

@interface ADWrapper : NSObject
{
    BOOL isBannerBackground;
}

+(ADWrapper*) createAD:(NSDictionary*) config vc: (AdmobViewController*)vc;
+(void) initAdNetwork:(void (^)())finishCallback;

@property (nonatomic, retain) AdmobViewController* RootViewController;
@property (nonatomic, assign) ADStatus bannerReady;
@property (nonatomic, assign) ADOrientation orientation;
@property (nonatomic, assign) double bannerRevenue;
@property (nonatomic, assign) int nativeReady;
@property (nonatomic, assign) int idx;
@property (nonatomic, assign) bool updateFailed;

@property (nonatomic, retain) id<ADWrapperDelegate> delegate;

-(void) init_first_time;

-(void) init_admob_banner;
-(void) init_admob_banner:(float)width height:(float)height;
-(void) init_admob_interstitial;
-(void) init_admob_native:(float)width height:(float)height;

/* 显示banner*/
-(void) show_admob_banner:(UIView*)view placeid:(NSString*) place;
-(void) setBannerAlign:(ADAlignment) align;
-(void) hide_banner;
-(double) getBannerRevenue;

/* 显示原生广告 */
-(void) show_admob_native:(float)posx posy:(float)posy width:(float)width height:(float)height view:(UIView*)view placeid:(NSString*) place;

/* 展示全屏 */
-(BOOL) show_admob_interstitial:(UIViewController*)viewController placeid:(int)place;
-(BOOL) admob_interstial_ready:(int)place;

/* 展示激励视频 */
-(BOOL) show_admob_reward:(UIViewController*)viewController placeid:(int)place;
-(BOOL) admob_reward_ready:(int)place;

/* 删除banner和全屏 */
-(void)remove_all_ads:(UIView *)rootView;
-(void)remove_banner:(UIView*)rootView;
-(void)remove_native:(UIView*)rootView;

- (void) setUpdateBannerFailed:(bool) update;
- (bool) isBannerHaveSuccessBefore;

- (void) updateImpression:(UIView*)rootView;

- (void) delayInitAfterNetworkFinish;

@end

#endif /* ADWrapper_h */
