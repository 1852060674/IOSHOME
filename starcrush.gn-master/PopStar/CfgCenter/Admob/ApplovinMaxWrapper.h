//
//  ApplovinMaxWrapper.h
//  version 4.0.0
//
//  Created by 昭 陈 on 01/3/21.
//  Copyright © 2016年 昭 陈. All rights reserved.
//

#ifndef ApplovinMaxWrapper_h
#define ApplovinMaxWrapper_h

#import "ADWrapper.h"
@import AppLovinSDK;
#import "ApplovinMaxRevenueDelegate.h"

@class AdmobViewController;

@interface ApplovinMaxWrapper : ADWrapper<MAAdViewAdDelegate>

@property (nonatomic, strong) ApplovinMaxRevenueDelegate *revenueDelegate;

- (id)initWithRootView:(AdmobViewController*) rootview bannerid:(NSString*)bannerid interid:(NSString*)interid;

- (CGFloat) getAdmobX;
- (CGFloat) getAdmobY;
- (CGFloat) getAdmobWidth;
- (CGFloat) getAdmobHeight;
@end

#endif /* ApplovinMaxWrapper_h */
