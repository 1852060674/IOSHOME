//
//  MaxOpenAdWrapper.h
//  Unity-iPhone
//
//  Created by 昭 陈 on 2025/10/18.
//

#ifndef MaxOpenAdWrapper_h
#define MaxOpenAdWrapper_h

#import "OpenAdWrapper.h"
@import AppLovinSDK;
#import "ApplovinMaxRevenueDelegate.h"

@class AdmobViewController;

@interface MaxOpenAdWrapper : OpenAdWrapper<MAAdDelegate>

@property (nonatomic, strong) ApplovinMaxRevenueDelegate *revenueDelegate;

- (id)initWithRootView:(AdmobViewController*) rootview adid:(NSString*)rewardid;
@end

#endif /* MaxOpenAdWrapper_h */
