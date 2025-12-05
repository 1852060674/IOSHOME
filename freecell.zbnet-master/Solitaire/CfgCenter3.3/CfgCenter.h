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

#define CFGCENTER_VERSION @"3.5.0"
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
#define kAppID                 696399985              // app的唯一标识
#define FEEDBACK_MAIL          @"zss215@foxmail.com"
/***********************************************************************************/

/*************    4.   [ admob 广告系统配置 ]       ****************************************/
//#define AD_CHARTBOOST
//#define AD_BAIDU
#define AD_ADMOB
#define AD_APPLOVIN_MAX

#ifdef AD_ADMOB
#define kBannerID                 @"ca-app-pub-3929304872235645/5948346210"
#define kBannerID2                @"ca-app-pub-3929304872235645/9771843930"
#define kBannerID3                @"ca-app-pub-3929304872235645/6059829635"
#define kBannerID4                @"ca-app-pub-3929304872235645/4805445950"
#define kBannerID5                @"ca-app-pub-3929304872235645/5926955932"
//#define kInterstitialID           @"ca-app-pub-3929304872235645/2204839419"
//#define kInterstitialID2          @"ca-app-pub-3929304872235645/3697390178"
//#define kInterstitialID3          @"ca-app-pub-3929304872235645/7061920113"
//#define kInterstitialID4          @"ca-app-pub-3929304872235645/4954631524"
//#define kInterstitialID5          @"ca-app-pub-3929304872235645/1677607784"
#define kNativeID                 @""
#endif

#define MAX_BANNER_ID                 @"94c2d6e5a342fc81"
#define MAX_INTERSTITIAL_ID           @"16a5b4ccb5ab42a5"
#define MAX_REWARD_ID                 @""

#define APS_APP_ID                @"6663bdba-0140-48dc-8a0f-d0d5045699df"
#define APS_BANNER_ID             @"a5899554-6367-4e01-894b-48a5795331ec"
#define APS_LEADER_ID             @"b4b03f0e-8d54-4d12-becb-92df3a88da41"
#define APS_INTER_ID              @"5872ecbb-d9f0-47d2-bb10-c369c52ea7a0"

#define AD_SMART                  YES

/*************************************************************************************/

/*************    6.   [ app 广告墙配置]              *******************************************/
#define kOtherApp                        true                 // 是否可显示广告墙
/***************************************************************************************/
#define kInAppPaid               @"UpgradeInApp"
#define kRemoveAd              @"com.iosfunny02.AniIconFree.pro"

#define kUnlockAll                  kRemoveAd

#define kMaxLoginTimes         5
#define LOGIN_DAYS          5
/*************    7.   [ app 唤醒配置]              *******************************************/
#define kWakeUpMode                                 1           // 0 关闭提醒 1 打开提醒
#define kWakeUpDays                                  1           // 第一次通知的延后时间

#define kWakeUpNotiName                          @"696399985-WakeUpNoti"

#define kWakeUpFirstTime                           @"19:10:00" //  日期以打开本app的当天，时间可以配置
/* 可配置的是星期/天/分钟  分钟： NSMinuteCalendarUnit   星期：NSWeekCalendarUnit 天：NSDayCalendarUnit*/
#define kWakeUpFreq                                  NSWeekCalendarUnit // 每星期弹1次，后面的通知的周期时间
#define kWakeUpMsg                                  @"Play a round of Freecell for rest!"
/***************************************************************************************/

#endif
