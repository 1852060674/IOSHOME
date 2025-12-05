//
//  MGDefine.h
//  iFaceAnimation
//
//  Created by tangtaoyu on 15-1-13.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "Admob.h"

#ifndef iFaceAnimation_MGDefine_h
#define iFaceAnimation_MGDefine_h

typedef NS_ENUM(NSUInteger, LayoutPattern) {
  G1x2 = 0,
  G2x1,
  G1x3,
  G3x1,
  H2_2x1_1x1,
  V2_1x1_1x2,
  G1x4,
  G4x1,
  G1x5,
  G5x1,
  G1x6,
  G6x1,
  H2_3x1_1x1,
  V2_1x1_1x3,
  H2_3x1_2x1,
  V2_1x2_1x3,
  H3_2x1_1x1_1x1,
  V3_1x2_1x1_1x1,
  G2x2,
  LayoutPatternDiagonal,
  LayoutPatternShapeSx1,
  LayoutPatternShapeSx2,
  LayoutPatternDownArrowx1,
  LayoutPatternDownArrowx2,
  LayoutPatternLeftArrowx1,
  LayoutPatternLeftArrowx2,
  LayoutPatternCircle,
  LayoutPatternSquare,
  LayoutPatternTriangle,
  LayoutPatternHeart,
};

#define LastSimpleLineLayoutPattern LayoutPatternLeftArrowx2

#define curveApex 0.2


typedef NS_ENUM(NSUInteger, BlurDirection) {
  BlurDirectionNone = 0,
  BlurDirectionUp = 1,
  BlurDirectionRight = 2,
  BlurDirectionDown = 3,
  BlurDirectionLeft = 4,
  BlurDirectionTriangleTopLeft = 5,
  BlurDirectionTriangleBottomRight = 6,
  BlurDirectionTopLeft = 7,
};

#define IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define kDeviceModel   ([UIDevice currentDevice].model)

#define kSystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]
#define kScreenWidth   ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight  ([[UIScreen mainScreen] bounds].size.height)
#define kIsIphone35    ((kScreenHeight < 481.0f)?YES:NO)
#define kRetinaValue               ([[UIScreen mainScreen] scale])

#define kStatusBarHeight          20.0f
#define kNavigationBarHeight      44.0f
#define kTabbarHeight             (IS_IPAD?60.0f:48.0f)
#define kAdHeight                 ((IS_IPAD?90:50))

#define MG_GAD_SIZE_SMART             CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait)
#define kSmartHeight               MG_GAD_SIZE_SMART.height

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

//Colors
#define ArtsBGCOLOR [[UIColor alloc] initWithRed:55.0f/255 green:148.0f/255 blue:211.0f/255 alpha:1.0]
#define BGCOLOR [UIColor colorWithRed:32.0f/255 green:44.0f/255 blue:56.0f/255 alpha:1.0]

#define HEXCOLOR(c)      [UIColor colorWithRed:((c>>24)&0xFF)/255.0f green:((c>>16)&0xFF)/255.0f blue:((c>>8)&0xFF)/255.0f alpha:(c&0xFF)/255.0f]
#define COLOR(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

#define MGTBCtlColor HEXCOLOR(0x464646ff)
#define MGTBBgColor  [UIColor blackColor]
#define CameraBgColor COLOR(29,29,29,255)
//#define CameraBgColor COLOR(255,0,0,255)

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

#define kToolBarH  (IS_IPAD?80:60)

#define kAviaryAPIKey   @"b5ff9c6b373685b4"
#define kAviarySecret   @"64606edabe8ea1dd"

#define khide1Notice   @"hide1Notice"
#define khide2Notice   @"hide2Notice"
#define kshow2Notice   @"show2Notice"
#define kdeleteNotice   @"deleteNotice"

#define kBundlePathBundle(x)  ([NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:x ofType:@"bundle"]])

#define kLocalPath(name,type)  [[NSBundle mainBundle] pathForResource:name ofType:type]]

#define kLocalizable(str)  NSLocalizedString(str, nil)




#endif
