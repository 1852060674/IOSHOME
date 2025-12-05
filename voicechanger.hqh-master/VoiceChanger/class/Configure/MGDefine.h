//
//  MGDefine.h
//  iFaceAnimation
//
//  Created by tangtaoyu on 15-1-13.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#ifndef iFaceAnimation_MGDefine_h
#define iFaceAnimation_MGDefine_h

#import <GoogleMobileAds/GoogleMobileAds.h>
//#define LandScape


#define IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define kDeviceModel   ([UIDevice currentDevice].model)
#define kSystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]

#define kMinMin      (([[UIScreen mainScreen] bounds].size.width < [[UIScreen mainScreen] bounds].size.height) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define kMaxMax      (([[UIScreen mainScreen] bounds].size.width > [[UIScreen mainScreen] bounds].size.height) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)

#ifdef LandScape
    #define kScreenWidth   ((kSystemVersion>=8.0)?([[UIScreen mainScreen] bounds].size.width):(kMaxMax))
    #define kScreenHeight  ((kSystemVersion>=8.0)?([[UIScreen mainScreen] bounds].size.height):(kMinMin))
    #define kIsIphone35    ((kScreenWidth < 481.0f)?YES:NO)
#else
    #define kScreenWidth   ((kSystemVersion>=8.0)?([[UIScreen mainScreen] bounds].size.width):(kMinMin))
    #define kScreenHeight  ((kSystemVersion>=8.0)?([[UIScreen mainScreen] bounds].size.height):(kMaxMax))
    #define kIsIphone35    ((kScreenHeight < 481.0f)?YES:NO)
#endif

#define kRetinaValue               ([[UIScreen mainScreen] scale])

#define kStatusBarHeight          20.0f
#define kNavigationBarHeight      44.0f
#define kTabbarHeight             (IS_IPAD?60.0f:48.0f)
//#define kAdHeight                 ((IS_IPAD?90.:50.))
#define GAD_SIZE_SMART   CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait)
#define kSmartAdHeight   (GAD_SIZE_SMART.height)

#define ISUpgrade                  NO
#define APPID_HAVEADS               @"986695287"
#define APPID_REMOVEADS             @"986695287"

#define naviBarBgName          (IS_IPAD?(@"navibar_bg.png"):(@"navibar_bg.png"))
#define naviBarBack            @"navi_back.png"
#define naviBarHome            @"navi_home.png"
#define naviBarUpgrade         @"navi_upgrade.png"
#define naviBarAdd             @"navi_add.png"
#define naviBarHelp            @"navi_help.png"
#define naviBarShare           @"navi_share.png"
#define naviBarFront           @"navi_front.png"
#define naviBarEdit            @"navi_edit.png"
#define naviBarUndo            @"navi_undo.png"
#define naviBarCamera          @"navi_camera"

//Colors
#define ArtsBGCOLOR [[UIColor alloc] initWithRed:55.0f/255 green:148.0f/255 blue:211.0f/255 alpha:1.0]
#define BGCOLOR [UIColor colorWithRed:32.0f/255 green:44.0f/255 blue:56.0f/255 alpha:1.0]

#define HEXCOLOR(c)      [UIColor colorWithRed:((c>>24)&0xFF)/255.0f green:((c>>16)&0xFF)/255.0f blue:((c>>8)&0xFF)/255.0f alpha:(c&0xFF)/255.0f]
#define COLOR(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A/255.0]

#define MGTBCtlColor HEXCOLOR(0x464646ff)
#define MGTBBgColor  [UIColor blackColor]
#define CameraBgColor COLOR(29,29,29,255)

#define kDevice3(x,y,z)   (IS_IPAD? (z) : (kIsIphone35 ? (x) : (y)))
#define kDevice2(x,y)   (IS_IPAD? (y) : (x))

#define kW(v)  v.frame.size.width
#define kH(v)  v.frame.size.height
#define kX(v)  v.frame.origin.x
#define kY(v)  v.frame.origin.y

#define kRW(r)  r.size.width
#define kRH(r)  r.size.height
#define kRX(r)  r.origin.x
#define kRY(r)  r.origin.y

#define MGStr(x) [NSString stringWithFormat:@"%i", (int)x]

#define kToolBarH  (IS_IPAD?80:60)

#define kAviaryAPIKey   @"b5ff9c6b373685b4"
#define kAviarySecret   @"64606edabe8ea1dd"

#define khide1Notice   @"hide1Notice"
#define khide2Notice   @"hide2Notice"
#define kshow2Notice   @"show2Notice"
#define kdeleteNotice  @"deleteNotice"

#define kRefreshNotice @"refreshNotice"
#define kRefreshNotice2 @"refreshNotice2"
#define kCloseVoiceNotice @"closeVoiceNotice"

#define kBundlePathBundle(x)  ([NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:x ofType:@"bundle"]])

#define kLocalPath(name,type)  [[NSBundle mainBundle] pathForResource:name ofType:type]
#define kLocalizable(str)  NSLocalizedString(str, nil)

//test
#define kTestLayer(v)   v.layer.borderWidth = 2.0; \
                        v.layer.borderColor = [UIColor redColor].CGColor

#endif
