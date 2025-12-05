//
//  ZBCommonMethod.h
//  SwapFace
//
//  Created by shen on 13-7-30.
//  Copyright (c) 2013年 ZBNetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBCommonDefine.h"
#import <UIKit/UIKit.h>

typedef enum {
    // iPhone 1,3,3GS 标准分辨率(320x480px)
    UIDevice_iPhoneStandardRes      = 1,
    // iPhone 4,4S 高清分辨率(640x960px)
    UIDevice_iPhoneHiRes            = 2,
    // iPhone 5 高清分辨率(640x1136px)
    UIDevice_iPhoneTallerHiRes      = 3,
    // iPad 1,2 标准分辨率(1024x768px)
    UIDevice_iPadStandardRes        = 4,
    // iPad 3 High Resolution(2048x1536px)
    UIDevice_iPadHiRes              = 5
}UIDeviceType;

typedef enum
{
    ChangTypeIncrease,
    ChangTypeDecrease
}ChangType;

typedef enum {
    LanguageTypeZH_hans,
    LanguageTypeZH_hant,
    LanguageTypeEn,
}LanguageType;

@interface ZBCommonMethod : NSObject

+ (UIDeviceType)currentResolution;

+ (LanguageType)getCurrentLanguageType;

+ (NSString*)getCurrentTimeStr;

+ (NSString*)getDeviceName;

+ (NSString*)getDevicePlatform;

+ (NSString*)getDeviceModelIdentifier;

+ (BOOL)isIpad;

+ (BOOL)isIpadBigWithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIpad1WithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIpad2WithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIpad3WithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIpad4WithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIpadAirWithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIpadAir2WithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIpadProWithDeviceModelIdentifier:(NSString *)identifier;

+ (BOOL)isIpadMinWithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIpadMin1WithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIpadMin2WithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIpadMin3WithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIpadMin4WithDeviceModelIdentifier:(NSString *)identifier;

+ (BOOL)isIphoneWithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIphone2WithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIphone3GWithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIphone3GSWithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIphone4WithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIphone4SWithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIphone5WithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIphone5CWithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIphone5SWithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIphone6WithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIphone6PWithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIphone6SWithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIphone6SPWithDeviceModelIdentifier:(NSString *)identifier;

+ (BOOL)isIPodWithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIPod1WithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIPod2WithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIPod3WithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIPod4WithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIPod5WithDeviceModelIdentifier:(NSString *)identifier;
+ (BOOL)isIPod6WithDeviceModelIdentifier:(NSString *)identifier;

+(BOOL)isIWatchWithDeviceModelIdentifier:(NSString *)identifier;

+(BOOL)isAboveIpod4;

+ (BOOL)isAboveIphone4S;

+ (BOOL)isAboveIpad3;

+(CGFloat) systemVersion;

+(CGFloat) screenWidth;

+(CGFloat) screenHeight;
@end
