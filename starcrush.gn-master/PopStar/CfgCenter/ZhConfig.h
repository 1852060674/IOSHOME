//
//  ZhConfig.h
//  SecretGarden
//
//  Created by IOS2 on 2024/1/31.
//  Copyright © 2024 awt. All rights reserved.
//

#ifndef ZhConfig_h
#define ZhConfig_h

#define WIDTH (([[UIScreen mainScreen] bounds].size.width) <( [[UIScreen mainScreen] bounds].size.height )? ([[UIScreen mainScreen] bounds].size.width) : ([[UIScreen mainScreen] bounds].size.height))
#define HEIGHT  (([[UIScreen mainScreen] bounds].size.width) > ( [[UIScreen mainScreen] bounds].size.height )? ([[UIScreen mainScreen] bounds].size.width) : ([[UIScreen mainScreen] bounds].size.height))
#define admobHeight1 MAAdFormat.banner.adaptiveSize.height
#define opbarHeightpianyi 33 

//#define IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define buttomLiuhaiPianyiY 34
#define admobHeight MAAdFormat.banner.adaptiveSize.height

#define ZH_IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define IS_IPHONE4 ([[UIScreen mainScreen] bounds].size.height == 480)
#define IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height == 568)
#define IS_IPHONE6 ([[UIScreen mainScreen] bounds].size.height == 667)
#define IS_IPHONE6PLUS ([[UIScreen mainScreen] bounds].size.height == 736)
#define VISION (@"vision")
#define CURRENT_VISION (@"currentVision")
#define REVIEW_SIGN (@"reviewSign")
#define REVIEW_TIME (@"reviewTimeOfMy")
#define CURRENT_VISION (@"currentVision")
#define PURCHASE_SIGN (@"purcharseSign")
#define LOCALISE (@"Localise")

#endif /* ZhConfig_h */
