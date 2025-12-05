//
//  BaiduWrapper.h
//  EbookReader
//
//  Created by 昭 陈 on 2017/4/10.
//  Copyright © 2017年 apple. All rights reserved.
//

#ifndef BaiduWrapper_h
#define BaiduWrapper_h

#import "ADWrapper.h"
#import "BaiduMobAdView.h"
#import "BaiduMobAdInterstitial.h"

@class AdmobViewController;

@interface BaiduWrapper : ADWrapper<BaiduMobAdViewDelegate, BaiduMobAdInterstitialDelegate>

@property (weak, nonatomic) NSString* app_id;         // appid
@property (weak, nonatomic) NSString* banner_id;         // banner
@property (weak, nonatomic) NSString* interstitial_id;   // full screen

- (id)initWithRootView:(AdmobViewController*) rootview appid:(NSString* )appid BannerId:(NSString* )bannerid InterstitialId:(NSString* )interid;
@end

#endif /* BaiduWrapper_h */
