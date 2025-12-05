//
//  GlobalSettingManger.m
//  eyeColorPlus
//
//  Created by shen on 14-7-22.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import "GlobalSettingManger.h"

#define RESOLUTION @"resolution.bighead.zb.com"
#define AUTOSAVE @"autosave.bighead.zb.com"
#define FEATHER @"feather.easerphoto2.zb.com"
#define SMOOTH_EDGE @"smoothedge.easerphoto2.zb.com"

#define USENETWORK @"usenetwork.bighead.zb.com"
#define USENETWORKWIFIONLY @"usenetworkwifionly.bighead.zb.com"
#define LANCHCNT @"lanchcnt.bighead.zb.com"
#define CUTHELPCNT @"cutcnt.bighead.zb.com"

#define THINFACEHELPCNT @"thinfacehelpcnt.bighead.zb.com"
#define THINHEADHELPCNT @"thinheadhelpcnt.bighead.zb.com"
#define THINCHINHELPCNT @"thinchinhelpcnt.bighead.zb.com"
#define SLIMHELPCNT @"slimhelpcnt.bighead.zb.com"
#define MANUALHELPCNT @"manualhelpcnt.bighead.zb.com"
#define CREATE_COLOR_USED_CNT @"createcolorusedcnt.bighead.zb.com"
#define MATCH_COLOR_USED_CNT @"matchcolorusedcnt.bighead.zb.com"

#define USECNT @"faceageusecnt.bighead.zb.com"

#define EVER_SHOW_GUIDE @"everguide.mysketch.zb.com"
#define EVER_AUTO_SHOW_HELP @"everautohelp.mysketch.zb.com"

@interface GlobalSettingManger ()
@property (nonatomic, strong) NSUserDefaults *userDefault;
@end

@implementation GlobalSettingManger
+(GlobalSettingManger *)defaultManger
{
    static dispatch_once_t once;
    static GlobalSettingManger* manger = nil;
    dispatch_once(&once, ^{
        manger = [[self alloc] init];
    });
    return manger;
}
-(GlobalSettingManger*)init
{
    self.userDefault = [NSUserDefaults standardUserDefaults];
    return self;
}

-(NSInteger)resolution
{
    if ([self.userDefault objectForKey:RESOLUTION] == nil) {
        return 0;
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



-(BOOL)feather
{
    if ([self.userDefault objectForKey:FEATHER] == nil) {
        return YES;
    }
    else
    {
        return [self.userDefault boolForKey:FEATHER];
    }
}

-(void)setFeather:(BOOL)feather
{
    [self.userDefault setBool:feather forKey:FEATHER];
    [self.userDefault synchronize];
}

-(BOOL)smoothEdge
{
    if ([self.userDefault objectForKey:SMOOTH_EDGE] == nil) {
        return YES;
    }
    else
    {
        return [self.userDefault boolForKey:SMOOTH_EDGE];
    }
}

-(void)setSmoothEdge:(BOOL)smoothEdge
{
    [self.userDefault setBool:smoothEdge forKey:SMOOTH_EDGE];
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

-(NSInteger)thinFaceHelpCnt
{
    if ([self.userDefault objectForKey:THINFACEHELPCNT] == nil) {
        return 0;
    }
    else
    {
        return [self.userDefault integerForKey:THINFACEHELPCNT];
    }
}

-(void)setThinFaceHelpCnt:(NSInteger)thinFaceHelpCnt
{
    [self.userDefault setInteger:thinFaceHelpCnt forKey:THINFACEHELPCNT];
    [self.userDefault synchronize];
}

-(NSInteger)thinHeadHelpCnt
{
    if ([self.userDefault objectForKey:THINHEADHELPCNT] == nil) {
        return 0;
    }
    else
    {
        return [self.userDefault integerForKey:THINHEADHELPCNT];
    }
}

-(void)setThinHeadHelpCnt:(NSInteger)thinHeadHelpCnt
{
    [self.userDefault setInteger:thinHeadHelpCnt forKey:THINHEADHELPCNT];
    [self.userDefault synchronize];
}

-(NSInteger)thinChinHelpCnt
{
    if ([self.userDefault objectForKey:THINCHINHELPCNT] == nil) {
        return 0;
    }
    else
    {
        return [self.userDefault integerForKey:THINCHINHELPCNT];
    }
}

-(void)setThinChinHelpCnt:(NSInteger)thinChinHelpCnt
{
    [self.userDefault setInteger:thinChinHelpCnt forKey:THINCHINHELPCNT];
    [self.userDefault synchronize];
}

-(NSInteger)slimHelpCnt
{
    if ([self.userDefault objectForKey:SLIMHELPCNT] == nil) {
        return 0;
    }
    else
    {
        return [self.userDefault integerForKey:SLIMHELPCNT];
    }
}

-(void)setSlimHelpCnt:(NSInteger)slimHelpCnt
{
    [self.userDefault setInteger:slimHelpCnt forKey:SLIMHELPCNT];
    [self.userDefault synchronize];
}

-(NSInteger)manualHelpCnt
{
    if ([self.userDefault objectForKey:MANUALHELPCNT] == nil) {
        return 0;
    }
    else
    {
        return [self.userDefault integerForKey:MANUALHELPCNT];
    }
}

-(void)setManualHelpCnt:(NSInteger)manualHelpCnt
{
    [self.userDefault setInteger:manualHelpCnt forKey:MANUALHELPCNT];
    [self.userDefault synchronize];
}

-(NSInteger)cutHelpCnt
{
    if ([self.userDefault objectForKey:CUTHELPCNT] == nil) {
        return 0;
    }
    else
    {
        return [self.userDefault integerForKey:CUTHELPCNT];
    }
}

-(void)setCutHelpCnt:(NSInteger)cutHelpCnt
{
    [self.userDefault setInteger:cutHelpCnt forKey:CUTHELPCNT];
    [self.userDefault synchronize];
}

-(NSInteger)createColorUsedCnt
{
    if ([self.userDefault objectForKey:CREATE_COLOR_USED_CNT] == nil) {
        return 0;
    }
    else
    {
        return [self.userDefault integerForKey:CREATE_COLOR_USED_CNT];
    }
}

-(void)setCreateColorUsedCnt:(NSInteger)createColorUsedCnt
{
    [self.userDefault setInteger:createColorUsedCnt forKey:CREATE_COLOR_USED_CNT];
    [self.userDefault synchronize];
}


-(NSInteger)matchColorUsedCnt
{
    if ([self.userDefault objectForKey:MATCH_COLOR_USED_CNT] == nil) {
        return 0;
    }
    else
    {
        return [self.userDefault integerForKey:MATCH_COLOR_USED_CNT];
    }
}

-(void)setMatchColorUsedCnt:(NSInteger)matchColorUsedCnt
{
    [self.userDefault setInteger:matchColorUsedCnt forKey:MATCH_COLOR_USED_CNT];
    [self.userDefault synchronize];
}
-(NSInteger)useCnt
{
    if ([self.userDefault objectForKey:USECNT] == nil) {
        return 0;
    }
    else
    {
        return [self.userDefault integerForKey:USECNT];
    }
}

-(void)setUseCnt:(NSInteger)useCnt
{
    [self.userDefault setInteger:useCnt forKey:USECNT];
    [self.userDefault synchronize];
}

-(BOOL)everShowGuide
{
    if ([self.userDefault objectForKey:EVER_SHOW_GUIDE] == nil) {
        return NO;
    }
    else
    {
        return [self.userDefault boolForKey:EVER_SHOW_GUIDE];
    }
}

-(void)setEverShowGuide:(BOOL)everShowGuide
{
    [self.userDefault setBool:everShowGuide forKey:EVER_SHOW_GUIDE];
    [self.userDefault synchronize];
}

-(BOOL)everAutoShowHelp
{
    if ([self.userDefault objectForKey:EVER_AUTO_SHOW_HELP] == nil) {
        return NO;
    }
    else
    {
        return [self.userDefault boolForKey:EVER_AUTO_SHOW_HELP];
    }
}

-(void)setEverAutoShowHelp:(BOOL)everAutoShowHelp
{
    [self.userDefault setBool:everAutoShowHelp forKey:EVER_AUTO_SHOW_HELP];
    [self.userDefault synchronize];
}


@end
