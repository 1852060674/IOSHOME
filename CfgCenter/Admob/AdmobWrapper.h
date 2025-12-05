//
//  AdmobWrapper.h
//  version 3.3
//
//  Created by 昭 陈 on 16/5/17.
//  Copyright © 2016年 昭 陈. All rights reserved.
//

#ifndef AdmobWrapper_h
#define AdmobWrapper_h

#import "ADWrapper.h"
@import GoogleMobileAds;

@class GADBannerView, GADRequest;

@class AdmobViewController;

@interface AdmobWrapper : ADWrapper<GADBannerViewDelegate, GADFullScreenContentDelegate>

@property (weak, nonatomic) NSString* banner_id;         // banner
@property (weak, nonatomic) NSString* interstitial_id;   // full screen
@property (weak, nonatomic) NSString* native_id;   // native ad

-(GADRequest*) getADRequest;

- (id)initWithRootView:(AdmobViewController*) rootview BannerId:(NSString* )bannerid InterstitialId:(NSString* )interid NativeId:(NSString* )nativeid;

- (void) setRefreshTimeLimitFG:(int) foreground BG:(int) background BGLoaded:(int) backgroundloaded;

@end

#endif /* AdmobWrapper_h */
