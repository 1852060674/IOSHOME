//
//  GlobalSettingManger.m
//  eyeColorPlus
//
//  Created by shen on 14-7-22.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import "GlobalSettingManger.h"

#define RESOLUTION @"resolution.plastic.zb.com"
#define AUTOSAVE @"autosave.plastic.zb.com"
#define USENETWORK @"usenetwork.plastic.zb.com"
#define USENETWORKWIFIONLY @"usenetworkwifionly.plastic.zb.com"
#define LANCHCNT @"lanchcnt.plastic.zb.com"

#define CROP_USE_CNT @"cropusecnt.plastic.zb.com"
#define SURGERY_USE_CNT @"surgeryusecnt.plastic.zb.com"
#define FILTER_USE_CNT @"filterusecnt.plastic.zb.com"
#define AVIARY_USE_CNT @"aviarycnt.plastic.zb.com"

#define HAS_GIVEN_RATING @"hasrating.plastic.zb.com"
#define HASFORCEDSHARED @"hasforcedshare.plastic.zb.com"

#define EVERSHOWGUIDE @"evershowguide.zb.com"
@interface GlobalSettingManger ()
@property (nonatomic, strong) NSUserDefaults *userDefault;
@end

@implementation GlobalSettingManger
+(GlobalSettingManger *)defaultManger
{
    static dispatch_once_t once;
    static id manger = nil;
    dispatch_once(&once, ^{
        manger = [[self alloc] init];
    });
    return manger;
}
-(id)init
{
    self.userDefault = [NSUserDefaults standardUserDefaults];
    return self;
}

-(NSInteger)resolution
{
    if ([self.userDefault objectForKey:RESOLUTION] == nil) {
        return 1;
    }
    else
    {
        return [self.userDefault integerForKey:RESOLUTION];
    }
}
-(void)setResolution:(NSInteger)resolution
{
    [self.userDefault setInteger:resolution forKey:RESOLUTION];
    [self.userDefault synchronize];
}

-(BOOL)autoSave
{
    if ([self.userDefault objectForKey:AUTOSAVE] == nil) {
        return NO;
    }
    else
    {
        return [self.userDefault boolForKey:AUTOSAVE];
    }
}
-(void)setAutoSave:(BOOL)autoSave
{
    [self.userDefault setBool:autoSave forKey:AUTOSAVE];
    [self.userDefault synchronize];
}

-(BOOL)useNetwork
{
    if ([self.userDefault objectForKey:USENETWORK] == nil) {
        return YES;
    }
    else
    {
        return [self.userDefault boolForKey:USENETWORK];
    }
}
-(void)setUseNetwork:(BOOL)useNetwork
{
    [self.userDefault setBool:useNetwork forKey:USENETWORK];
    [self.userDefault synchronize];
}
-(BOOL)useNetworkUnderWifiOnly
{
    if ([self.userDefault objectForKey:USENETWORKWIFIONLY] == nil) {
        return YES;
    }
    else
    {
        return [self.userDefault boolForKey:USENETWORKWIFIONLY];
    }
}
-(void)setUseNetworkUnderWifiOnly:(BOOL)useNetworkUnderWifiOnly
{
    [self.userDefault setBool:useNetworkUnderWifiOnly forKey:USENETWORKWIFIONLY];
    [self.userDefault synchronize];
}

-(NSInteger)lanchCnt
{
    if ([self.userDefault objectForKey:LANCHCNT] == nil) {
        return 0;
    }
    else
    {
        return [self.userDefault boolForKey:LANCHCNT];
    }
}

-(void)setLanchCnt:(NSInteger)lanchCnt
{
    [self.userDefault setInteger:lanchCnt forKey:LANCHCNT];
    [self.userDefault synchronize];
}

-(NSTimeInterval)giveRatingTime
{
    if ([self.userDefault objectForKey:HAS_GIVEN_RATING] == nil) {
        return MAXFLOAT;
    }
    else
    {
        return [self.userDefault doubleForKey:HAS_GIVEN_RATING];
    }
}

-(void)setGiveRatingTime:(NSTimeInterval)giveRatingTime
{
    [self.userDefault setDouble:giveRatingTime forKey:HAS_GIVEN_RATING];
    [self.userDefault synchronize];
}

-(BOOL)hasRating
{
    NSTimeInterval ratingTime = [self giveRatingTime];
    NSTimeInterval later = [[NSDate dateWithTimeIntervalSinceNow:-10] timeIntervalSince1970];
    
    return later > ratingTime;
//    return YES;
}

-(BOOL)hasForceShared
{
    if ([self.userDefault objectForKey:HASFORCEDSHARED] == nil) {
        return NO;
    }
    else
    {
        return [self.userDefault boolForKey:HASFORCEDSHARED];
    }
}

-(void)setHasForceShared:(BOOL)hasForceShared
{
    [self.userDefault setBool:hasForceShared forKey:HASFORCEDSHARED];
    [self.userDefault synchronize];
}

-(BOOL)everShowGuide
{
    if ([self.userDefault objectForKey:EVERSHOWGUIDE] == nil) {
        return NO;
    }
    else
    {
        return [self.userDefault boolForKey:EVERSHOWGUIDE];
    }
}

-(void)setEverShowGuide:(BOOL)everShowGuide
{
    [self.userDefault setBool:everShowGuide forKey:EVERSHOWGUIDE];
    [self.userDefault synchronize];
}

-(NSInteger)cropUseCnt
{
    if ([self.userDefault objectForKey:CROP_USE_CNT] == nil) {
        return 0;
    }
    else
    {
        return [self.userDefault integerForKey:CROP_USE_CNT];
    }
}

-(void)setCropUseCnt:(NSInteger)cropUseCnt
{
    [self.userDefault setInteger:cropUseCnt forKey:CROP_USE_CNT];
    [self.userDefault synchronize];
}

-(NSInteger)surgeryUseCnt
{
    if ([self.userDefault objectForKey:SURGERY_USE_CNT] == nil) {
        return 0;
    }
    else
    {
        return [self.userDefault integerForKey:SURGERY_USE_CNT];
    }
}

-(void)setSurgeryUseCnt:(NSInteger)surgeryUseCnt
{
    [self.userDefault setInteger:surgeryUseCnt forKey:SURGERY_USE_CNT];
    [self.userDefault synchronize];
}

-(NSInteger)filterUseCnt
{
    if ([self.userDefault objectForKey:FILTER_USE_CNT] == nil) {
        return 0;
    }
    else
    {
        return [self.userDefault integerForKey:FILTER_USE_CNT];
    }
}

-(void)setFilterUseCnt:(NSInteger)filterUseCnt
{
    [self.userDefault setInteger:filterUseCnt forKey:FILTER_USE_CNT];
    [self.userDefault synchronize];
}

-(NSInteger)aviaryUseCnt
{
    if ([self.userDefault objectForKey:AVIARY_USE_CNT] == nil) {
        return 0;
    }
    else
    {
        return [self.userDefault integerForKey:AVIARY_USE_CNT];
    }
}

-(void)setAviaryUseCnt:(NSInteger)aviaryUseCnt
{
    [self.userDefault setInteger:aviaryUseCnt forKey:AVIARY_USE_CNT];
    [self.userDefault synchronize];
}

@end
