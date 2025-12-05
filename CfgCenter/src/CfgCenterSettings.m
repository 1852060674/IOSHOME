//
//  CfgCenterSettings.m
//  version 3.3
//
//  Created by 昭 陈 on 2017/3/27.
//  Copyright © 2017年 spring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CfgCenterSettings.h"

@implementation CfgCenterSettings
{
    NSUserDefaults* settings;
    
    long firstin;
    
    bool bOpenCounted;
    bool bNewVersion;
    bool validUseCounted;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        bOpenCounted = false;
        settings = [NSUserDefaults standardUserDefaults];
        bNewVersion = false;
        validUseCounted = false;
    }
    return self;
}

+(NSString*) getVersionStr {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

-(void) onAppLoaded {//update firstin
    if(bOpenCounted)
        return;
    bOpenCounted = true;
    
    //set first in
    NSInteger now_time = time(NULL);
    firstin = [settings integerForKey:@"cz_firstin"];
    if (firstin == 0) {
        [settings setInteger:now_time forKey:@"cz_firstin"];
        firstin = now_time;
    }

    NSString* appversion = [CfgCenterSettings getVersionStr];
    long allcount = [self getAppOpenCountTotal];
    long count = [self getAppOpenCount];
    if(allcount < count) {
        allcount = count;
    }
    
    NSString* lastversion = [settings stringForKey:@"cz_lastversion"];
    if([appversion isEqualToString:lastversion]) {
        [settings setInteger:++count forKey:@"cz_appopened"];
    } else {
        count = 1;
        [settings setInteger:count forKey:@"cz_appopened"];
        [settings setObject:appversion forKey:@"cz_lastversion"];
        bNewVersion = true;
    }
    
    allcount ++;
    [settings setInteger:allcount forKey:@"cz_appopened_total"];
    
    [settings synchronize];
}

-(long) getAppFirstInTime {
    return firstin;
}

-(long) getAppOpenCount {
    return [settings integerForKey:@"cz_appopened"];
}


-(long) getAppOpenCountTotal {
    return [settings integerForKey:@"cz_appopened_total"];
}

-(void) setLastUdTime:(long) time {
    [settings setInteger:time forKey:@"cz_lastgrttime"];
    [settings synchronize];
}

-(long) getLastUdTime {
    return [settings integerForKey:@"cz_lastgrttime"];
}

-(BOOL) isNewVersionUpdate {
    return bNewVersion;
}

- (void) recordValidUseCount {
//    if(validUseCounted) {
//        return;
//    }
//    validUseCounted = true;
    
    long oldcount = [self getValidUseCount];
    [settings setInteger:oldcount+1 forKey:@"cz_validuse"];
    [settings synchronize];
}

- (long) getValidUseCount {
    return [settings integerForKey:@"cz_validuse"];
}

@end
