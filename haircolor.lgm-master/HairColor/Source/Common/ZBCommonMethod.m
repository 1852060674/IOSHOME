//
//  ZBCommonMethod.m
//  SwapFace
//
//  Created by shen on 13-7-30.
//  Copyright (c) 2013年 ZBNetwork. All rights reserved.
//

#import "ZBCommonMethod.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation ZBCommonMethod

+ (NSString*)getCurrentTimeStr
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    now=[NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    
    NSInteger month = [comps month];
    NSInteger day = [comps day];
    NSInteger hour = [comps hour];
    NSInteger min = [comps minute];
    NSInteger sec = [comps second];
    
    return [NSString stringWithFormat:@"%ld%ld%ld%ld%ld",month,day,hour,min,sec];
}

+(UIDeviceType) currentResolution
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)])
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
            if (result.height <= 480.0f)
                return UIDevice_iPhoneStandardRes;
            return (result.height > 960 ? UIDevice_iPhoneTallerHiRes : UIDevice_iPhoneHiRes);
        } else
            return UIDevice_iPhoneStandardRes;
    } else
        return (([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) ? UIDevice_iPadHiRes : UIDevice_iPadStandardRes);
}

+(BOOL)isHightResolution
{
    NSUInteger _currentResolution = [ZBCommonMethod currentResolution];
    if (_currentResolution == UIDevice_iPhoneHiRes || _currentResolution == UIDevice_iPhoneTallerHiRes|| _currentResolution == UIDevice_iPadHiRes) {
        return YES;
    }
    return NO;
}

+(NSString*)currentLanguage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLang = [languages objectAtIndex:0];
    return currentLang;
}

+(LanguageType)getCurrentLanguageType
{
    LanguageType langType;
    if ([[self currentLanguage] compare:@"zh-Hant" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {
        langType = LanguageTypeZH_hant;
    }
    else if([[self currentLanguage] compare:@"zh-Hans" options:NSCaseInsensitiveSearch]==NSOrderedSame || [[self currentLanguage] rangeOfString:@"zh-Han"].location!=NSNotFound)
    {
        langType = LanguageTypeZH_hans;
    }
    else{
        langType = LanguageTypeEn;
    }
    return langType;
}

+ (NSString*)getDevicePlatform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    //NSString *platform = [NSStringstringWithUTF8String:machine];二者等效
    free(machine);
    return platform;
}

+ (NSString *)getDeviceModelIdentifier
{
    NSString *platform = [self getDevicePlatform];
    
    NSString *p = [self deviceModelForPlatformIdentifier:platform];
    
    return p;
}

+(NSString *)deviceModelForPlatformIdentifier:(NSString *)platform
{
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5C (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5C (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5S (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5S (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6S";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6S Plus";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    if ([platform isEqualToString:@"iPod7,1"])   return @"iPod Touch 6G";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad5,3"])   return @"iPad Air 2 (A1566)";
    if ([platform isEqualToString:@"iPad5,4"])   return @"iPad Air 2 (A1567)";
    if ([platform isEqualToString:@"iPad6,7"])   return @"iPad Pro (A1584)";
    if ([platform isEqualToString:@"iPad6,8"])   return @"iPad Pro (A1652)";
    
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    if ([platform isEqualToString:@"iPad4,7"])   return @"iPad Mini 2G (A1599)";
    if ([platform isEqualToString:@"iPad4,8"])   return @"iPad Mini 2G (A1600)";
    if ([platform isEqualToString:@"iPad4,9"])   return @"iPad Mini 2G (A1601)";
    if ([platform isEqualToString:@"iPad5,1"])   return @"iPad Mini 4G (A1538)";
    if ([platform isEqualToString:@"iPad5,2"])   return @"iPad Mini 4G (A1550)";
    
    if ([platform isEqualToString:@"Watch1,1"])   return @"Watch (A1553)";
    if ([platform isEqualToString:@"Watch1,2"])   return @"Watch (A1554/A1638)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    return nil;
}

+ (BOOL)isIpadBigWithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPad"] && ![identifier hasPrefix:@"iPad Mini"];
}
+ (BOOL)isIpad1WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPad 1G"];
}
+ (BOOL)isIpad2WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPad 2"];
}
+ (BOOL)isIpad3WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPad 3"];
    
}
+ (BOOL)isIpad4WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPad 4"];
}
+ (BOOL)isIpadAirWithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPad Air"] && ![identifier hasPrefix:@"iPad Air 2"];
}
+ (BOOL)isIpadAir2WithDeviceModelIdentifier:(NSString *)identifier{
    return [identifier hasPrefix:@"iPad Air 2"];
}
+ (BOOL)isIpadProWithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPad Pro"];
}

+ (BOOL)isIpadMinWithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPad Mini"];
    
}
+ (BOOL)isIpadMin1WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPad Mini 1G"];
    
}
+ (BOOL)isIpadMin2WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPad Mini 2G"];
    
}
+ (BOOL)isIpadMin3WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPad Mini 3G"];
    
}
+ (BOOL)isIpadMin4WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPad Mini 4G"];
    
}

+ (BOOL)isIphoneWithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPhone"];
}

+ (BOOL)isIphone2WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPhone 2G"];
    
}
+ (BOOL)isIphone3GWithDeviceModelIdentifier:(NSString *)identifier;
{
    return [identifier hasPrefix:@"iPhone 3G"] && ![identifier hasPrefix:@"iPhone 3GS"];
    
}
+ (BOOL)isIphone3GSWithDeviceModelIdentifier:(NSString *)identifier;
{
    return [identifier hasPrefix:@"iPhone 3GS"];
    
}
+ (BOOL)isIphone4WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPhone 4"] && ![identifier hasPrefix:@"iPhone 4S"];
}
+ (BOOL)isIphone4SWithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPhone 4S"];
    
}

+ (BOOL)isIphone5WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPhone 5"] && ![identifier hasPrefix:@"iPhone 5S"] && ![identifier hasPrefix:@"iPhone 5C"];
    
}

+ (BOOL)isIphone5CWithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPhone 5C"];
    
}

+ (BOOL)isIphone5SWithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPhone 5S"];
}
+ (BOOL)isIphone6WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPhone 6"] && ![identifier hasPrefix:@"iPhone 6 Plus"] && [identifier hasPrefix:@"iPhone 6S"];
    
}
+ (BOOL)isIphone6PWithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPhone 6 Plus"];
}
+ (BOOL)isIphone6SWithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPhone 6S"] && ![identifier hasPrefix:@"iPhone 6S Plus"];
}
+ (BOOL)isIphone6SPWithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPhone 6S Plus"];
}

+ (BOOL)isIPodWithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPod Touch"];
}
+ (BOOL)isIPod1WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPod Touch 1G"];
}
+ (BOOL)isIPod2WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPod Touch 2G"];
}
+ (BOOL)isIPod3WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPod Touch 3G"];
}
+ (BOOL)isIPod4WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPod Touch 4G"];
}
+ (BOOL)isIPod5WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPod Touch 5G"];
}
+ (BOOL)isIPod6WithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"iPod Touch 6G"];
}

+(BOOL)isIWatchWithDeviceModelIdentifier:(NSString *)identifier
{
    return [identifier hasPrefix:@"Watch"];
}

+ (NSString*)getDeviceName
{
    NSString *_deviceName = @"";
    [UIDevice currentDevice];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)])
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
            if (result.height <= 480.0f)
                return @"iphone4";
            return (result.height > 960 ? @"iphone5" : @"iphone4");
        }
        else
        {
            return @"iphone3";
        }
    }
    else
    {
        return @"ipad";
    }
    
    return _deviceName;
}

+(BOOL)isAboveIpod4
{
    NSString *platform = [self getDevicePlatform];
    
    if ([[self getDeviceTypeOfDevicePlatform:platform] isEqual:@"iPod"]) {
        NSInteger mainVersion = [self getMainVersionOfDevicePlatform:platform];
        
        return mainVersion > 4;
    }
    else
    {
        return NO;
    }
}

+(BOOL)isAboveIphone4S
{
    NSString *platform = [self getDevicePlatform];

    if ([[self getDeviceTypeOfDevicePlatform:platform] isEqual:@"iPhone"]) {
        NSInteger mainVersion = [self getMainVersionOfDevicePlatform:platform];

        return mainVersion > 4;
    }
    else
    {
        return NO;
    }
}

+(BOOL)isAboveIpad3
{
    NSString *platform = [self getDevicePlatform];
    
    if ([[self getDeviceTypeOfDevicePlatform:platform] isEqual:@"iPad"]) {
        NSInteger mainVersion = [self getMainVersionOfDevicePlatform:platform];
        
        return mainVersion > 3;
    }
    else
    {
        return NO;
    }
}

+(NSInteger)getMainVersionOfDevicePlatform:(NSString *)platform
{
    const char * buffer = [platform UTF8String];
    
    NSInteger start = 0;
    
    for (start = 0; start<platform.length; ++start) {
        if (buffer[start]>='0' && buffer[start]<='9') {
            break;
        }
    }
    
    NSInteger end = 0;
    for (end=start; end<platform.length; ++end) {
        if (buffer[end]<'0' || buffer[end]>'9') {
            break;
        }
    }
    
    NSRange range;
    range.location = start;
    range.length = end-start;
    NSString *mainVersion = [platform substringWithRange:range];
    
    return [mainVersion integerValue];
}

+(NSString *)getDeviceTypeOfDevicePlatform:(NSString *)platform
{
    const char * buffer = [platform UTF8String];
    
    NSInteger start = 0;
    
    for (start = 0; start<platform.length; ++start) {
        if ((buffer[start]<'a' || buffer[start]>'z') && (buffer[start]<'A' || buffer[start]>'Z')) {
            break;
        }
    }
    
    return [platform substringToIndex:start];
}

+(BOOL)isIpad
{
    return ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

+(CGFloat) systemVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+(CGFloat) screenWidth
{
    return ([[UIScreen mainScreen] bounds].size.width);
}

+(CGFloat) screenHeight
{
    return ([[UIScreen mainScreen] bounds].size.height);
}


@end
