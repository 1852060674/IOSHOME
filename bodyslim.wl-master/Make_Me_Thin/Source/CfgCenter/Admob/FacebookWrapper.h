//
//  FacebookWrapper.h
//  SplitPics
//
//  Created by 昭 陈 on 2017/7/10.
//  Copyright © 2017年 ZBNetWork. All rights reserved.
//

#ifndef FacebookWrapper_h
#define FacebookWrapper_h

#import "ADWrapper.h"
@import FBAudienceNetwork;

@interface FacebookWrapper : ADWrapper<FBAdViewDelegate, FBInterstitialAdDelegate>

- (id)initWithRootView:(AdmobViewController*) rootview BannerId:(NSString* )bannerid InterstitialId:(NSString* )interid NativeId:(NSString* )nativeid;

@end

#endif /* FacebookWrapper_h */
