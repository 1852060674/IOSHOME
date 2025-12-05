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

#define CFGCENTER_VERSION @"4.0.0"     //after 4.0 use applovin max
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
#define kAppID                 952657464              // app的唯一标识
#define FEEDBACK_MAIL          @"zss215@foxmail.com"
/***********************************************************************************/

/*************    4.   [ admob 广告系统配置 ]       ****************************************/
//#define AD_CHARTBOOST
//#define AD_BAIDU
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
#define kRewardAd                 @"ca-app-pub-7041144744294548/1678962492"
#endif

#define MAX_BANNER_ID                 @"c7f2f2e00fd27702"
#define MAX_INTERSTITIAL_ID           @"a27d8b537e291a14"
#define MAX_REWARD_ID                 @"7fa5997024bd8d9f"


#define APS_APP_ID                @"c3311977-1d1d-4dab-bcea-42258fbfaa88"
#define APS_BANNER_ID             @"852842fc-47c5-4a8a-a0ea-76cf3e9ec8de"
#define APS_LEADER_ID             @"8f7aa982-56ce-4272-8963-e2f038e4c0af"
#define APS_INTER_ID              @"efadffa5-8501-4eaf-9143-8e98f0f5bd95"
#define APS_REWARDAD_ID              @"2ce66753-c6da-40c1-ab11-f6634a24ea30"

#define AD_SMART                  NO

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

#define kWakeUpNotiName                          @"952657464-WakeUpNoti"

#define kWakeUpFirstTime                           @"19:10:00" //  日期以打开本app的当天，时间可以配置
/* 可配置的是星期/天/分钟  分钟： NSMinuteCalendarUnit   星期：NSWeekCalendarUnit 天：NSDayCalendarUnit*/
#define kWakeUpFreq                                  NSWeekCalendarUnit // 每星期弹1次，后面的通知的周期时间
#define kWakeUpMsg                                  @"Hi, How about play a round of majhong for rest!"
/***************************************************************************************/


#endif
