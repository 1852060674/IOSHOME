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

#define CFGCENTER_VERSION @"3.4.9"
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
#define kAppID                    1117720431              // app的唯一标识
#define FEEDBACK_MAIL             @"wkf2016@qq.com"
/***********************************************************************************/

/*************    2.   [ admob 广告系统配置 ]       ****************************************/
#define AD_ADMOB
#define AD_APPLOVIN_MAX

#ifdef AD_ADMOB
#define kBannerID                 @"ca-app-pub-7041144744294548/2177092512"
#define kInterstitialID           @"ca-app-pub-7041144744294548/3653825718"
#define kNativeID                 @""
#define kBannerID3                @""
#endif

#define MAX_BANNER_ID                 @"20dcc4ea2ec0e26b"
#define MAX_INTERSTITIAL_ID           @"db7bb06a36d08421"
#define MAX_REWARD_ID                 @""

// end


#define AD_SMART                  YES

/*************************************************************************************/

/*************    3.   [ app 广告墙配置]              *******************************************/
#define kOtherApp                 true                 // 是否可显示广告墙
/***************************************************************************************/
#define kInAppPaid                @"UpgradeInApp"
#define kRemoveAd                 @"com.iosfunny02.AniIconFree.pro"

#define kUnlockAll                kRemoveAd

#define kMaxLoginTimes            5
#define LOGIN_DAYS                5
/*************    4.   [ app 唤醒配置]              *******************************************/
#define kWakeUpMode               1           // 0 关闭提醒 1 打开提醒
#define kWakeUpDays               1           // 第一次通知的延后时间

#define kWakeUpNotiName           @"1117720431-WakeUpNoti"

#define kWakeUpFirstTime          @"19:10:00" //  日期以打开本app的当天，时间可以配置
/* 可配置的是星期/天/分钟  分钟： NSMinuteCalendarUnit   星期：NSWeekCalendarUnit 天：NSDayCalendarUnit*/
#define kWakeUpFreq               NSWeekCalendarUnit // 每星期弹1次，后面的通知的周期时间
#define kWakeUpMsg                @"Hi, New challenge is waiting for you!"
/***************************************************************************************/

#define kNavBarHeight  44.0f

#endif
