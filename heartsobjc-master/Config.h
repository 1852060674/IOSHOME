//
//  Config.h
//  Pyramid
//
//  Created by apple on 13-9-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#ifndef Pyramid_Config_h
#define Pyramid_Config_h

#define RGB(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];

#define TIMECNT_FOR_AD 1     ///玩多少把弹一次广告
#define RATE_POP_CNT 4

/// 定义此宏则广告居上，注释此宏则广告居下
//#define AD_POS_UP

/// 是否显示广告
#define SHOW_AD YES

/// iphone下默认不打开Classic Card
#define CLASSIC_CARD NO

/// iphone下默认锁住横屏（其中横屏还需要通过xcode配置）
#define IPHONE_LANDSCAPE YES

/// 是否打开tap move
#define TAP_MOVE YES

/// speed time
#define SPEED_TIME 0.3

/// hint time internal
#define HINT_TIME_INTERNAL 3

/// end score
#define END_SCORE 100

#define win_animate_key @"win-animation"

#define customCardBgListKey @"customCardBgList"
#define customDeskBgListKey @"customDeskBgList"

#define stockOnRight_key @"stockOnRight_key"
#define freecellOnTop_key @"freecellOnTop_key"

#define card_will_move_to_f_key @"cardWillMoveToFoundation"

#define LocalizedGameStr(A)   NSLocalizedStringFromTable(@ #A, @"Language", nil)
#define LocalizedGameStr2(A)   NSLocalizedStringFromTable(@ #A, @"SoCommon", nil)

/// 消息推送时间设置
#define MSG_PUSH_TIME 20
#define MSG_PUSH_MINUTE 5

#define New_Boy_Comming @"newboycomming"

#define Open_Old 0
#endif
