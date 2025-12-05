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
#define kAppID                 986695287              // app的唯一标识
#define FEEDBACK_MAIL          @"hfcoolman@126.com"
/***********************************************************************************/

/*************    4.   [ admob 广告系统配置 ]       ****************************************/
//#define AD_CHARTBOOST
//#define AD_BAIDU
#define AD_ADMOB
#define AD_APPLOVIN_MAX

#ifdef AD_ADMOB
#define kBannerID                 @"ca-app-pub-2418305250646075/5016305549"
#define kBannerID2                @"ca-app-pub-2418305250646075/6019957649"
#define kBannerID3                @"ca-app-pub-2418305250646075/9758702733"

//#define kInterstitialID           @"ca-app-pub-2418305250646075/9446505140"
//#define kInterstitialID12         @"ca-app-pub-2418305250646075/8930149870"
//#define kInterstitialID13         @"ca-app-pub-2418305250646075/1546483870"
//
//#define kInterstitialID2          @"ca-app-pub-2418305250646075/9156102740"
//#define kInterstitialID22         @"ca-app-pub-2418305250646075/5645510984"
//#define kInterstitialID23         @"ca-app-pub-2418305250646075/1514694286"
//
//#define kInterstitialID3          @"ca-app-pub-2418305250646075/4586302347"
//#define kInterstitialID32         @"ca-app-pub-2418305250646075/9476944783"
//#define kInterstitialID33         @"ca-app-pub-2418305250646075/9285373090"
//
//#define kInterstitialID4          @"ca-app-pub-2418305250646075/6063035548"
//
//#define kNativeID                 @""
#endif

//#ifdef AD_FACEBOOK
//#define kFBBannerID               @"101426273851933_101432937184600"
//#define kFBInterstitialID         @"101426273851933_101431133851447"
//#define kFBInterstitialID2        @"101426273851933_101435340517693"
//#define kFBInterstitialID3        @"101426273851933_101439117183982"
//#define kFBInterstitialID4        @"101426273851933_101440257183868"
//#define kFBNativeID               @""
//#endif

#define MAX_BANNER_ID                 @"e2f2800a2c77ee0d"
#define MAX_INTERSTITIAL_ID           @"a7093916c68a13cf"
#define MAX_REWARD_ID                 @""

#define APS_APP_ID                @"64b5a76c-2b90-49ff-96e6-f9e1b1c51d1e"
#define APS_BANNER_ID             @"190ac905-158e-4e15-8b79-d2ade5dafe92"
#define APS_LEADER_ID             @"d5693e41-2862-4a19-9df6-0522c120ac20"
#define APS_INTER_ID              @"4196d278-d38b-4581-afde-fbff1f40e86c"

#define AD_SMART                  YES

/*************************************************************************************/

/*************    6.   [ app 广告墙配置]              *******************************************/
#define kOtherApp                        true                 // 是否可显示广告墙
/***************************************************************************************/
#define kInAppPaid               @"UpgradeInApp"
#define kRemoveAd              @"com.lgm.split.pro"

#define kUnlockAll                  kRemoveAd

#define kMaxLoginTimes         5
#define LOGIN_DAYS          5
/*************    7.   [ app 唤醒配置]              *******************************************/
#define kWakeUpMode                                 1           // 0 关闭提醒 1 打开提醒
#define kWakeUpDays                                  1           // 第一次通知的延后时间

#define kWakeUpNotiName                          @"SplitCamera-WakeUpNoti"

#define kWakeUpFirstTime                           @"19:10:00" //  日期以打开本app的当天，时间可以配置
/* 可配置的是星期/天/分钟  分钟： NSMinuteCalendarUnit   星期：NSWeekCalendarUnit 天：NSDayCalendarUnit*/
#define kWakeUpFreq                                  NSWeekCalendarUnit // 每星期弹1次，后面的通知的周期时间
#define kWakeUpMsg                                  @"Make funny pics with awesome layouts!"
/***************************************************************************************/

#endif
