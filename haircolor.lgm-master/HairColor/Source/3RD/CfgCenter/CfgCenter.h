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

#define CFGCENTER_VERSION @"3.4.7"
#define LOG_USER_ACTION

/******* 打开一些组件的配置 ******************************/
#define ENABLE_IAP                                    // 打开IAP，如果没有IAP，请注释此句
//#define ENABLE_OTHERAPP                               // 打开ADWALL，如果没有adwall，请注释此句
#define ENABLE_WAKEUP                                   // 打开唤醒机制, 定时通知用户激活app
#define ENABLE_AD                                       // 打开广告, 如果没有广告，请注释此句; add by mxchen
//#define ADRT
/*********************************************************/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*************    1.   [ app 相关的配置 ]            ****************************************/
#define kAppID                    994835196              // app的唯一标识
#define FEEDBACK_MAIL             @"zlm2016@foxmail.com"
/***********************************************************************************/

/*************    2.   [ admob 广告系统配置 ]       ****************************************/
//#define AD_CHARTBOOST
//#define AD_BAIDU
#define AD_ADMOB
#define AD_APPLOVIN_MAX

#ifdef AD_ADMOB
#define kBannerID                 @"ca-app-pub-7103138417794188/9954154954"
#define kBannerID2                @"ca-app-pub-7103138417794188/5332267367"
#define kBannerID3                @"ca-app-pub-7103138417794188/1201450663"
//#define kInterstitialID           @"ca-app-pub-7103138417794188/2430888152"
//#define kInterstitialID2          @"ca-app-pub-7103138417794188/8047605201"
//#define kInterstitialID3          @"ca-app-pub-7103138417794188/5084855350"
#define kNativeID                 @""

#define kNativeMediumID           @"ca-app-pub-7103138417794188/3649749756"
//#define kNativeSmallID            @"ca-app-pub-3929304872235645/3830214210"
#endif

//TODO
#define MAX_BANNER_ID                 @"538a8dffb9e1f0e7"
#define MAX_INTERSTITIAL_ID           @"c3c7884d359d8d13"
#define MAX_REWARD_ID                 @""

#define AD_SMART                  YES

/*************************************************************************************/

/*************    3.   [ app 广告墙配置]              *******************************************/
#define kOtherApp                 true                 // 是否可显示广告墙
/***************************************************************************************/
#define kInAppPaid                @"UpgradeInApp"
#define kRemoveAd                 @"com.lgm.hair.pro"

#define kUnlockAll                kRemoveAd

#define kMaxLoginTimes            5
#define LOGIN_DAYS                5

#define kResourceStateChanged   @"ResourceStateChanged"
#define kInterstitialNotification   @"kInterstitialNotification"
/*************    4.   [ app 唤醒配置]              *******************************************/
#define kWakeUpMode               1           // 0 关闭提醒 1 打开提醒
#define kWakeUpDays               1           // 第一次通知的延后时间

#define kWakeUpNotiName           @"HairColor-WakeUpNoti"

#define kWakeUpFirstTime          @"19:00:00" //  日期以打开本app的当天，时间可以配置
/* 可配置的是星期/天/分钟  分钟： NSMinuteCalendarUnit   星期：NSWeekCalendarUnit 天：NSDayCalendarUnit*/
#define kWakeUpFreq               NSWeekCalendarUnit // 每星期弹1次，后面的通知的周期时间
#define kWakeUpMsg                @"Dozens of hair colors are waiting for you!"
/***************************************************************************************/

#endif
