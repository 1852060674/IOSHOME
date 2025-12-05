//
//  GlobalSettingManger.m
//  eyeColorPlus
//
//  Created by shen on 14-7-22.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import "UserSettingManger.h"
#import "ZBCommonDefine.h"
#import <UIKit/UIKit.h>

#define RESOLUTION @"resolution.setting.cutmein.zb.com"
#define AUTOSAVE @"autosave.setting.cutmein.zb.com"
#define FEATHER @"feather.setting.cutmein.zb.com"
#define SMOOTH_EDGE @"smoothedge.setting.cutmein.zb.com"
#define ACCURATE_CUT @"accuratecut.setting.cutmein.zb.com"
#define AUTO_SAVE_CUT_SYSTEM @"savecutsystem.setting.cutmein.zb.com"
#define AUTO_SAVE_CUT_APP @"savecutapp.setting.cutmein.zb.com"

#define USENETWORK @"usenetwork.setting.cutmein.zb.com"
#define USENETWORKWIFIONLY @"usenetworkwifionly.setting.cutmein.zb.com"

@interface UserSettingManger ()
@property (nonatomic, strong) NSUserDefaults *userDefault;
@end

@implementation UserSettingManger
+(UserSettingManger *)defaultManger
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

-(float)getRealResolution
{
    NSArray *resolutions = @[@(HIGH_RESOLUTION), @(MEDIAN_RESOLUTION), @(LOW_RESOLUTION)];
    
    return [resolutions[[self resolution]] floatValue];
}

-(BOOL)autoSave
{
    if ([self.userDefault objectForKey:AUTOSAVE] == nil) {
        return YES;
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

-(BOOL)accurateCut
{
    if ([self.userDefault objectForKey:ACCURATE_CUT] == nil) {
        return YES;
    }
    else
    {
        return [self.userDefault boolForKey:ACCURATE_CUT];
    }
}

-(void)setAccurateCut:(BOOL)accurateCut
{
    [self.userDefault setBool:accurateCut forKey:ACCURATE_CUT];
    [self.userDefault synchronize];
}

-(BOOL)autoSaveCutSystem
{
    if ([self.userDefault objectForKey:AUTO_SAVE_CUT_SYSTEM] == nil) {
        return YES;
    }
    else
    {
        return [self.userDefault boolForKey:AUTO_SAVE_CUT_SYSTEM];
    }
}

-(void)setAutoSaveCutSystem:(BOOL)autoSaveCutSystem
{
    [self.userDefault setBool:autoSaveCutSystem forKey:AUTO_SAVE_CUT_SYSTEM];
    [self.userDefault synchronize];
}

-(BOOL)autoSaveCutApp
{
    if ([self.userDefault objectForKey:AUTO_SAVE_CUT_APP] == nil) {
        return YES;
    }
    else
    {
        return [self.userDefault boolForKey:AUTO_SAVE_CUT_APP];
    }
}

-(void)setAutoSaveCutApp:(BOOL)autoSaveCutApp
{
    [self.userDefault setBool:autoSaveCutApp forKey:AUTO_SAVE_CUT_APP];
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

@end
