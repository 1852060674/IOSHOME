//
//  Config.h
//  Pyramid
//
//  Created by apple on 13-9-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#ifndef Pyramid_Config_h
#define Pyramid_Config_h

#define TIMECNT_FOR_AD 1     ///玩多少把弹一次广告
#define RATE_POP_CNT 4       ///评价最多弹几次

/// 定义此宏则广告居上，注释此宏则广告居下
//#define AD_POS_UP

/// 是否显示广告
#define SHOW_AD YES

/// iphone下默认不打开Classic Card
#define CLASSIC_CARD YES

/// iphone下默认锁住横屏（其中横屏还需要通过xcode配置）
#define IPHONE_LANDSCAPE NO

/// 是否打开tap move
#define TAP_MOVE YES




#define win_animate_key @"win-animation"

#define pause_time_key @"pause_time_key"


#ifndef __OPTIMIZE__
#define __pftime__(A) NSLog(@"step %d",A);
#else
#define __pftime__(A) {}
#endif

#define screen_bounds  [[UIScreen mainScreen] bounds]
#define screen_scale  [[UIScreen mainScreen] scale]
#define screen_nativeScale  [[UIScreen mainScreen] nativeScale]
#define screen_width  CGRectGetWidth(screen_bounds)
#define screen_height  CGRectGetHeight(screen_bounds)


#define customCardBgListKey @"customCardBgList"
#define customDeskBgListKey @"customDeskBgList"

#define stockOnRight_key @"stockOnRight_key"
#define freecellOnTop_key @"freecellOnTop_key"

#define card_will_move_to_f_key @"cardWillMoveToFoundation"

#define LocalizedGameStr(A)   NSLocalizedStringFromTable(@ #A, @"Language", nil)
#define LocalizedGameStr2(A)   NSLocalizedStringFromTable(@ #A, @"SoCommon", nil)

#ifndef __OPTIMIZE__

#define debug_victory

//#define debug_land

#else

#endif

#endif
