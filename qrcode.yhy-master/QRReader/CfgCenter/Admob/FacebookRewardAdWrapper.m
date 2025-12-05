//
//  FacebookRewardAdWrapper.m
//  Unity-iPhone
//
//  Created by 昭 陈 on 2019/3/18.
//

#import <Foundation/Foundation.h>
#import "FacebookRewardAdWrapper.h"

//#ifndef LOG_USER_ACTION
//#define LOG_USER_ACTION
//#endif

#ifdef LOG_USER_ACTION
@import Flurry_iOS_SDK;
#endif

@implementation FacebookRewardAdWrapper {
    NSString* reward_id;
    
    FBRewardedVideoAd *rewardedVideoAd;
    
    int rewardAdRetryCount;
    BOOL isloading;
    BOOL isshowing;
}

@synthesize RootViewController;

- (id)initWithRootView:(AdmobViewController*) rootview adid:(NSString* )adid {
    self = [super init];
    
    if(self)
    {
        RootViewController = rootview;
        reward_id = adid;
        
#ifdef DEBUG
        [FBAdSettings setLogLevel:FBAdLogLevelLog];
        [FBAdSettings addTestDevice:@"5f119ec97f8dafcac12ec2d2373807e0e8ef01f7"];
#endif
    }
    return self;
}

- (void)dealloc
{
    rewardedVideoAd.delegate = nil;
    rewardedVideoAd = nil;
}

-(void) init_reward_ad
{
    if(rewardedVideoAd != nil) {
        rewardedVideoAd.delegate = nil;
        rewardedVideoAd = nil;
    }
    
    rewardedVideoAd = [[FBRewardedVideoAd alloc] initWithPlacementID:reward_id];
    rewardedVideoAd.delegate = self;
    
    rewardAdRetryCount = 0;
    
    [self _rewardAdReload];
}

#pragma mark -
#pragma mark facebook rewardad

-(BOOL) showRewardAd:(UIViewController*)viewController placeid:(int)place
{
    // 当广告还没就绪的时候，不增加显示次数
    if (rewardedVideoAd && rewardedVideoAd.isAdValid) {
        BOOL show = [rewardedVideoAd showAdFromRootViewController:viewController];
        NSLog(@"[ADUNION] Show FB reward Ad :%@", reward_id);
        
#ifdef LOG_USER_ACTION
        [Flurry logEvent:@"FBLoadReward" withParameters:@{@"id": reward_id, @"status": @"show"}];
#endif
        if(show) {
            isshowing = true;
        }
        
        return show;
    }
    return NO;
}

-(BOOL) isRewardAdReady:(int) place
{
    if(rewardedVideoAd && rewardedVideoAd.isAdValid)
        return YES;
    
    if(!isloading && !isshowing)
    {
        [self init_reward_ad];
    }
    return FALSE;
}

-(void) _rewardAdReload {
    isloading = true;
    isshowing = false;
    [rewardedVideoAd loadAd];
    
#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"FBLoadReward" withParameters:@{@"id": reward_id, @"status": @"load"}];
#endif
}

#pragma mark -
#pragma mark  admob remove

-(void)removeAllAds {
}

// 全屏就绪后的，admob调用的回调函数
-(void) rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd {
    rewardAdRetryCount = 0;
    isloading = false;
    
    if(self.delegate != NULL) {
        [self.delegate RewardVideoAdDidReceive:self];
    }
    
    NSLog(@"[ADUNION] FB reward ad ready, wait to show!");
#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"FBLoadReward" withParameters:@{@"id": reward_id, @"status": @"loaded"}];
#endif
}

// 关闭全屏后调用的回调函数
-(void) rewardedVideoAdDidClose:(FBInterstitialAd *)rewardedVideoAd {
#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"FBLoadReward" withParameters:@{@"id": reward_id, @"status": @"closed"}];
#endif
    isshowing = false;
    
    if(self.delegate != NULL) {
        [self.delegate RewardVideoAdDidClose:self];
    }
    [self init_reward_ad];
}

-(void) rewardedVideoAdWillClose:(FBInterstitialAd *)rewardedVideoAd {
}

-(void) rewardedVideoAd:(FBInterstitialAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    
#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"FBLoadReward" withParameters:@{@"id": reward_id, @"status": @"failed"}];
#endif
    
    if(self.delegate) {
        [self.delegate RewardVideoAdFailToReceivedWithError:self error:@""];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(rewardAdRetryCount < 3) {
            rewardAdRetryCount++;
            [self _rewardAdReload];
            
            NSLog(@"[ADUNION] retry FB reward ad %d!", rewardAdRetryCount);
        }
        else {
            rewardAdRetryCount = 0;
            isloading = false;
        }
    });
    
    NSLog(@"[ADUNION] FB reward ad failed");
}

- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd {
    if(self.delegate) {
        [self.delegate RewardVideoAdWillLeaveApplication:self];
    }
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd {
    if(self.delegate) {
        [self.delegate RewardVideoAdDidRewardUserWithReward:self rewardType:@"" amount:1];
    }
}

@end
