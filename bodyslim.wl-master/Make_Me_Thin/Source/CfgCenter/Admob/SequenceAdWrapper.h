//
//  AdCenter.h
//  version 3.3
//
//  Created by 昭 陈 on 2016/11/24.
//  Copyright © 2016年 昭 陈. All rights reserved.
//

#ifndef AdCenter_h
#define AdCenter_h
#import "ADWrapper.h"

@interface SequenceAdWrapper : ADWrapper<ADWrapperDelegate>

- (id)initWithRootView:(AdmobViewController*) rootview AdWrap:(ADWrapper* )ad, ...;
- (id)initWithRootView:(AdmobViewController*) rootview adlist:(NSArray* )ads;

- (BOOL) hasBannerChildAd:(ADWrapper*) ad;
- (BOOL) hasNativeChildAd:(ADWrapper*) ad;

@end

#endif /* AdCenter_h */
