//
//  AdUtility.h
//  Plastic Surgeon
//
//  Created by ZB_Mac on 15/6/23.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Admob.h"
#import "ZBCommonMethod.h"
@interface AdUtility : NSObject
+(BOOL)hasAd;
+(BOOL)tryShowBannerInView:(UIView *)view placeid:(NSString*) placeid;
+(BOOL)tryShowInterstitialInVC:(UIViewController *)VC placeid:(int)place ignoreTimeInterval:(BOOL)ignore;
+(BOOL)tryShowInterstitialInVC:(UIViewController *)VC placeid:(int)place;

@end
