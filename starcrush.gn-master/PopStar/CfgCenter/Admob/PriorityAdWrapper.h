//
//  PriorityAdWrapper.h
//  version 3.3
//
//  Created by 昭 陈 on 16/6/6.
//  Copyright © 2016年 macbook. All rights reserved.
//

#ifndef PriorityAdWrapper_h
#define PriorityAdWrapper_h

#import "ADWrapper.h"

@class AdmobViewController;

@interface PriorityAdWrapper : ADWrapper<ADWrapperDelegate>

- (id)initWithRootView:(AdmobViewController*) rootview BannerAd1:(ADWrapper* )bannerad1 BannerAd2:(ADWrapper* )bannerad2;
- (id)initWithRootView:(AdmobViewController*) rootview adlist:(NSArray* )ads;

- (BOOL) hasBannerChildAd:(ADWrapper*) ad;
- (BOOL) hasNativeChildAd:(ADWrapper*) ad;
@end

#endif /* PriorityAdWrapper_h */
