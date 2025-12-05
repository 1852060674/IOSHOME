//
//  CommonSet.h
//  why you lying
//
//  Created by awt on 15/10/25.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#ifndef why_you_lying_CommonSet_h
#define why_you_lying_CommonSet_h

#ifndef IS_IPAD
#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad)
#endif
#define IS_IPHONE4 ([[UIScreen mainScreen] bounds].size.height == 480)
#define IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height == 568)
#define IS_IPHONE6 ([[UIScreen mainScreen] bounds].size.height == 667)
#define IS_IPHONE6PLUS ([[UIScreen mainScreen] bounds].size.height == 736)

#define WIDTH (([[UIScreen mainScreen] bounds].size.width) <( [[UIScreen mainScreen] bounds].size.height )? ([[UIScreen mainScreen] bounds].size.width) : ([[UIScreen mainScreen] bounds].size.height))
#define HEIGHT (([[UIScreen mainScreen] bounds].size.width) >( [[UIScreen mainScreen] bounds].size.height )? ([[UIScreen mainScreen] bounds].size.width) : ([[UIScreen mainScreen] bounds].size.height))
#define IS_13 (@"is13")
#endif
