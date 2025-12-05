//
//  Config.h
//  WordSearch
//
//  Created by apple on 13-9-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#ifndef WordSearch_Config_h
#define WordSearch_Config_h

#define VERSION_NO 100001    ///新版本数据有差异，需要用此版本号覆盖老版本数据

#define TIMECNT_FOR_AD 2                        ///玩多少把弹全屏广告一次

#define FREE_HINTS_SETTING_KEY @"freehints"


#define RGB(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];

#define kPlatformSupportsViewControllerHeirarchy ([self respondsToSelector:@selector(childViewControllers)] && [self.childViewControllers isKindOfClass:[NSArray class]])

#endif
