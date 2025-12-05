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

#endif /* ZhConfig_h */
