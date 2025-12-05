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
#define BANNER_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?90:50

/**********************/

#define APP_URL [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%d",kAppID]


#define HIGH_RESOLUTION [UIScreen mainScreen].bounds.size.height>480?1536:960
#define MEDIAN_RESOLUTION [UIScreen mainScreen].bounds.size.height>480?1280:768
#define LOW_RESOLUTION [UIScreen mainScreen].bounds.size.height>480?1024:640

#define RGBA_COLOR(r,g,b,a) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:(a/255.0)]
#define CUT_NORMAL_COLOR RGBA_COLOR(173, 173, 173, 255)
#define CUT_HIGHLIGHT_COLOR RGBA_COLOR(76, 127, 238, 255)

#endif
