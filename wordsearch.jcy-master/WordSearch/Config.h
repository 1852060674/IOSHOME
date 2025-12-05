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

#define GOOGLE_BANNER_ID @"ca-app-pub-3929304872235645/6705225819"
#define GOOGLE_FULLSCREEN_ID @"ca-app-pub-3929304872235645/3602425417"

#define TIMECNT_FOR_AD 1               ///玩多少把弹全屏广告一次

#define APP_ID @"694967269"
#define kLastReviewDate @"2015-07-15 00:00:00"

#define RGB(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];

#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#endif
