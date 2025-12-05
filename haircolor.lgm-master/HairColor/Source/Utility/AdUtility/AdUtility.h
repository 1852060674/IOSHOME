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

+(BOOL)allPurchased;
+(BOOL)hasAd;
+(BOOL)basicOrnamentAvailable;
+(BOOL)advanceOrnamentAvailable;
+(BOOL)frameFilterAvailable;
+(BOOL)advanceColorAvailable;
+(BOOL)advanceMaskAvailable;

+(BOOL)tryShowBannerInView:(UIView *)view;
+(BOOL)tryShowInterstitialInVC:(UIViewController *)VC ignoreTimeInterval:(BOOL)ignore;

@end
