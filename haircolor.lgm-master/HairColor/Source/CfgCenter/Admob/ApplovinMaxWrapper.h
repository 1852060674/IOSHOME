//
//  AdmobWrapper.h
//  version 4.0.0
//
//  Created by 昭 陈 on 01/3/21.
//  Copyright © 2016年 昭 陈. All rights reserved.
//

#ifndef ApplovinMaxWrapper_h
#define ApplovinMaxWrapper_h

#import "ADWrapper.h"
@import AppLovinSDK;

@class AdmobViewController;

@interface ApplovinMaxWrapper : ADWrapper<MARewardedAdDelegate, MAAdViewAdDelegate>

- (id)initWithRootView:(AdmobViewController*) rootview;
@end

#endif /* ApplovinMaxWrapper_h */
