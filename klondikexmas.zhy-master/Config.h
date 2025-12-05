//
//  Config.h
//  Pyramid
//
//  Created by apple on 13-9-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#ifndef Pyramid_Config_h
#define Pyramid_Config_h

#define TIMECNT_FOR_AD 1

//推荐app的id，从上往下(图标game1~game7)
#define MORE_APPID_1 @"706729886"
#define MORE_APPID_2 @"705158908"
#define MORE_APPID_3 @"696399985"
#define MORE_APPID_4 @"705773928"
#define MORE_APPID_5 @"700390938"
#define MORE_APPID_6 @"718764384"
#define MORE_APPID_7 @"725183862"

/// 定义此宏则广告居上，注释此宏则广告居下
//#define AD_POS_UP

/// 是否显示广告
//#define SHOW_AD YES

/// iphone下默认不打开Classic Card
#define CLASSIC_CARD YES

/// iphone下默认锁住横屏（其中横屏还需要通过xcode配置）
#define IPHONE_LANDSCAPE NO

/// 是否打开tap move
#define TAP_MOVE YES

/// 消息推送时间设置
#define MSG_PUSH_TIME 20
#define MSG_PUSH_MINUTE 5

#define kOpenTimes @"opentimes"

#endif
