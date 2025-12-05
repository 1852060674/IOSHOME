//
//  Config.h
//  PopStar
//
//  Created by apple air on 15/12/9.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//

#ifndef Config_h
#define Config_h

#define xSize 10
#define ySize 10
// 是否IPAD
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
// 屏幕宽度 长度
#define ScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define ScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define Iphone4 ([UIScreen mainScreen].bounds.size.height < 500)
// 字体
#define FONTNAME @"BDZongYi-A001"
//#define FONTNAME @"Felt"
// 字体大小
#define FONTSIZE 20
#define FONTSIZEIPAD 40
// 图片数字的宽高比
#define FontWidthToHeight 0.537

// 道具金币
#define PRODUCT_1_ID @"com.gn.star.coin1"
#define PROPS_1_NUM 420
#define PRODUCT_2_ID @"com.gn.star.coin2"
#define PROPS_2_NUM 1000
#define PRODUCT_3_ID @"com.gn.star.coin3"
#define PROPS_3_NUM 2200
#define PRODUCT_4_ID @"com.gn.star.coin4"
#define PROPS_4_NUM 3500
#define PRODUCT_5_ID @"com.gn.star.coin5"
#define PROPS_5_NUM 6300
#define PRODUCT_6_ID @"com.gn.star.coin6"
#define PROPS_6_NUM 15000


// 多语言
#define kLocalString(str) NSLocalizedString(str, nil)
#endif /* Config_h */
