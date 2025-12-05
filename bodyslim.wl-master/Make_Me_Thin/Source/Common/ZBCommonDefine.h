//
//  ZBCommonDefine.h
//  Collage
//
//  Created by shen on 13-6-24.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#ifndef Collage_ZBCommonDefine_h
#define Collage_ZBCommonDefine_h

#import "CfgCenter.h"

#define kSystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]
#define kScreenWidth   ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight  ([[UIScreen mainScreen] bounds].size.height)

// for ad
/**********************/
#define PRO_VERSION NO

/**********************/

#define APP_URL [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%d",kAppID]

#define HIGHLIGHT_COLOR [UIColor colorWithRed:255.0/255.0 green:116.0/255.0 blue:160.0/255.0 alpha:1.0]
#define NORMAL_COLOR [UIColor whiteColor]


#define HIGH_RESOLUTION 1600
#define MEDIUM_RESOLUTION 1280
#define LOW_RESOLUTION 640

#endif
