//
//  AdmobOpenAdWrapper.h
//  Unity-iPhone
//
//  Created by 昭 陈 on 2019/3/18.
//

#ifndef AdmobOpenAdWrapper_h
#define AdmobOpenAdWrapper_h

#import "OpenAdWrapper.h"
@import GoogleMobileAds;

@class GADRequest;

@class AdmobViewController;

@interface AdmobOpenAdWrapper : OpenAdWrapper<GADFullScreenContentDelegate>

-(GADRequest*) getADRequest;

- (id)initWithRootView:(AdmobViewController*) rootview adid:(NSString* )adid;

@end

#endif /* AdmobOpenAdWrapper_h */
