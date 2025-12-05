//
//  CfgCenter.h
//
//  Created by cloudxiong on 14-7-9.
//  Copyright (c) 2014年 ZB. All rights reserved.
//
//  version 3.3
//

#ifndef _CfgCenter_h
#define _CfgCenter_h

#define CFGCENTER_VERSION @"4.0.0"     //after 4.0 use applovin max for ad mediation
#define LOG_USER_ACTION

/******* 打开一些组件的配置 ******************************/
//#define ENABLE_IAP                                    // 打开IAP，如果没有IAP，请注释此句
//#define ENABLE_OTHERAPP                               // 打开ADWALL，如果没有adwall，请注释此句
#define ENABLE_WAKEUP                                   // 打开唤醒机制, 定时通知用户激活app
#define ENABLE_AD                                       // 打开广告, 如果没有广告，请注释此句; add by mxchen
//#define ADRT
/*********************************************************/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*************    1.   [ app 相关的配置 ]            ****************************************/
#define kAppID                 684121362              // app的唯一标识
#define FEEDBACK_MAIL          @"manyapps@163.com"
/***********************************************************************************/

/*************    2.   [ admob 广告系统配置 ]       ****************************************/

#define AD_ADMOB
#define AD_APPLOVIN_MAX

#ifdef AD_ADMOB
#define kBannerID                 @"ca-app-pub-2418305250646075/7361524783"
#define kBannerID2                @"ca-app-pub-2418305250646075/9959767960"
#define kBannerID3                @"ca-app-pub-2418305250646075/6217232993"
#define kBannerID4                @"ca-app-pub-2418305250646075/4099347872"
#define kBannerID5                @"ca-app-pub-2418305250646075/6306585101"
#define kInterstitialID           @"ca-app-pub-2418305250646075/7750862439"
#define kInterstitialID2          @"ca-app-pub-2418305250646075/5755254486"
#define kInterstitialID3          @"ca-app-pub-2418305250646075/5473728047"
#define kInterstitialID4          @"ca-app-pub-2418305250646075/3428474040"
#define kInterstitialID5          @"ca-app-pub-2418305250646075/3236902357"
#define kNativeID                 @""
#define kRewardAd                 @""
#endif

#ifdef AD_CHARTBOOST
#define kCharboostAPPid           @"4f21c409cd1cb2fb7000001b"
#define kCharboostSignature       @"92e2de2fd7070327bdeb54c15a5295309c6fcd2d"
#endif

#ifdef AD_BAIDU
#define kBaiduAppID               @"ccb60059"
#define kBaiduBannerID            @"2015347"
#define kBaiduInterstitialID      @"2058554"
#endif

#ifdef AD_FACEBOOK
#define kFBBannerID               @"1709840552678335_1830913843904338"
#define kFBInterstitialID         @"1709840552678335_1830979857231070"
#define kFBNativeID               @""
#endif
// start mabay need update 10.16
#define MAX_BANNER_ID             @"72db7efc089caf45"
#define MAX_INTERSTITIAL_ID       @"e38706bf5d4a59fe"
#define MAX_REWARD_ID             @""
// end

#define AD_SMART                  YES

/*************************************************************************************/

/*************    3.   [ app 广告墙配置]              *******************************************/
#define kOtherApp                        true                 // 是否可显示广告墙
/***************************************************************************************/
#define kInAppPaid               @"UpgradeInApp"
#define kRemoveAd              @"com.emoji.Solitaire.removead"

#define kUnlockAll                  kRemoveAd

#define kMaxLoginTimes         5
#define LOGIN_DAYS          5
#define kResourceStateChanged   @"ResourceStateChanged"
#define kInterstitialNotification   @"kInterstitialNotification"
/*************    4.   [ app 唤醒配置]              *******************************************/
#define kWakeUpMode                                 1           // 0 关闭提醒 1 打开提醒
#define kWakeUpDays                                  1           // 第一次通知的延后时间

#define kWakeUpNotiName                          @"684121362-WakeUpNoti"

#define kWakeUpFirstTime                           @"19:10:00" //  日期以打开本app的当天，时间可以配置
/* 可配置的是星期/天/分钟  分钟： NSMinuteCalendarUnit   星期：NSWeekCalendarUnit 天：NSDayCalendarUnit*/
#define kWakeUpFreq                                  NSWeekCalendarUnit // 每星期弹1次，后面的通知的周期时间
#define kWakeUpMsg                                  (NSLocalizedStringFromTable(@"pushmsg", @"Language", nil))
/***************************************************************************************/

//#define kNavBarHeight  44.0f

#endif
