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
#define kAppID                 706729886              // app的唯一标识
#define FEEDBACK_MAIL          @"zss215@foxmail.com"
/***********************************************************************************/

/*************    2.   [ admob 广告系统配置 ]       ****************************************/

#define AD_ADMOB
#define AD_APPLOVIN_MAX

#ifdef AD_ADMOB
#define kBannerID                 @"ca-app-pub-3929304872235645/4251287012"
#define kBannerID2                @"ca-app-pub-3929304872235645/8783616779"
#define kBannerID3                @"ca-app-pub-3929304872235645/9119670458"
#define kBannerID4                @"ca-app-pub-3929304872235645/7806588781"
#define kBannerID5                @"ca-app-pub-3929304872235645/2554262109"
#define kInterstitialID           @"ca-app-pub-3929304872235645/6941249015"
#define kInterstitialID2          @"ca-app-pub-3929304872235645/6655490343"
#define kInterstitialID3          @"ca-app-pub-3929304872235645/5824133712"
#define kInterstitialID4          @"ca-app-pub-3929304872235645/3257680125"
#define kInterstitialID5          @"ca-app-pub-3929304872235645/9160743494"
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
#define kFBBannerID               @"1709840552678335_1830979857231070"
#define kFBInterstitialID         @"1709840552678335_1830913843904338"
#define kFBNativeID               @""
#endif

#define MAX_BANNER_ID             @"85fb8ed76aaa8a78"
#define MAX_INTERSTITIAL_ID       @"fb5e38b88c647c8f"
#define MAX_REWARD_ID             @""

#define AD_SMART                  YES

/*************************************************************************************/

/*************    3.   [ app 广告墙配置]              *******************************************/
#define kOtherApp                        true                 // 是否可显示广告墙
/***************************************************************************************/
#define kInAppPaid               @"UpgradeInApp"
#define kRemoveAd              @"com.iosfunny02.AniIconFree.pro"

#define kUnlockAll                  kRemoveAd

#define kMaxLoginTimes         5
#define LOGIN_DAYS          5
#define kResourceStateChanged   @"ResourceStateChanged"
#define kInterstitialNotification   @"kInterstitialNotification"
/*************    4.   [ app 唤醒配置]              *******************************************/
#define kWakeUpMode                                 1           // 0 关闭提醒 1 打开提醒
#define kWakeUpDays                                  1           // 第一次通知的延后时间

#define kWakeUpNotiName                          @"706729886-WakeUpNoti"

#define kWakeUpFirstTime                           @"19:10:00" //  日期以打开本app的当天，时间可以配置
/* 可配置的是星期/天/分钟  分钟： NSMinuteCalendarUnit   星期：NSWeekCalendarUnit 天：NSDayCalendarUnit*/
#define kWakeUpFreq                                  NSWeekCalendarUnit // 每星期弹1次，后面的通知的周期时间
#define kWakeUpMsg                                  @"come play a round of solitaire!"
/***************************************************************************************/

#define kNavBarHeight  44.0f

#endif
