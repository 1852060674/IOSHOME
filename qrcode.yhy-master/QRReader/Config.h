//
//  Config.h
//  QRReader
//
//  Created by awt on 15/7/20.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#ifndef QRReader_Config_h
#define QRReader_Config_h
#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define DEVIECE_INFO ([[UIDevice currentDevice] name])


#define WIDTH (([[UIScreen mainScreen] bounds].size.width) <( [[UIScreen mainScreen] bounds].size.height )? ([[UIScreen mainScreen] bounds].size.width) : ([[UIScreen mainScreen] bounds].size.height))
#define HEIGHT  (([[UIScreen mainScreen] bounds].size.width) > ( [[UIScreen mainScreen] bounds].size.height )? ([[UIScreen mainScreen] bounds].size.width) : ([[UIScreen mainScreen] bounds].size.height))
#define CELL_WIDTH (WIDTH/(20.0f))

// add zh 2024.1.20 start unit
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define buttomLiuhaiPianyiY 34
#define admobHeight MAAdFormat.banner.adaptiveSize.height //
#define  stanardSizeWidth    37*1.2 // 20240122 update allbtn  stanard size for iphone
#define  stanardSizeHeight   29*1.2

#define  IpdStanardSizeWidth    37*1.2*1.5 // 20240123 update allbtn  stanard size for ipd
#define  IpdStanardSizeHeight   29*1.2*1.5


//#define IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//#define Ipone11 kScreenHeight == 812 || kScreenWidth == 812
//#define Ipone14 kScreenHeight == 844 || kScreenWidth == 844
//#define Ipone15 kScreenHeight == 852 || kScreenWidth == 852
//#define IsLandscape kScreenHeight < kScreenWidth

// add zh 2024.1.20 end

#define IS_IPHONE4 (kScreenHeight == 480)
#define IS_IPHONE5 (kScreenHeight == 568)
#define IS_IPHONE6 (kScreenHeight == 667)
#define IS_IPHONE6PLUS (kScreenHeight == 736)


//#define kRatingUrl  @"https://itunes.apple.com/us/app/id1005580973?ls=1&mt=8"
#endif
