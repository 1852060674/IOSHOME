//
//  AdmobRewardAdWrapper.m
//  Unity-iPhone
//
//  Created by 昭 陈 on 2019/3/18.
//

#import <Foundation/Foundation.h>
#import "AdmobRewardAdWrapper.h"

//#ifndef LOG_USER_ACTION
//#define LOG_USER_ACTION
//#endif

#ifdef LOG_USER_ACTION
@import Flurry_iOS_SDK;
#endif

@implementation AdmobRewardAdWrapper
{
    NSString* reward_id;
    
    GADRewardedAd * rewardedAd;
    
    int curr_ad_place;
    
    int rewardAdRetryCount;
    BOOL isloading;
    BOOL isshowing;
}

@synthesize RootViewController;

#pragma mark -
#pragma mark  admob init

- (id)initWithRootView:(AdmobViewController*) rootview adid:(NSString* )adid
{
    self = [super init];
    
    if(self)
    {
        RootViewController = rootview;
        reward_id = adid;
        curr_ad_place = 0;
        
//        [[GADRewardBasedVideoAd sharedInstance] setDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    rewardedAd.fullScreenContentDelegate = nil;
    rewardedAd = nil;
    NSLog(@"Are zzx");
}

-(GADRequest*) getADRequest {
    GADRequest* request = [GADRequest request];
//    request.testDevices = @[ kGADSimulatorID ];
    return request;
}

-(void) init_reward_ad {
    NSLog(@" lai la5");
    if(rewardedAd != nil) {
        rewardedAd.fullScreenContentDelegate = nil;
        rewardedAd = nil;
        NSLog(@"Are zzx");
    }
    
    if([reward_id isEqualToString:@""])
        return;
    
    rewardAdRetryCount = 0;
    [self _rewardAdReload];
}

#pragma mark -
#pragma mark  admob reward

-(BOOL) showRewardAd:(UIViewController*)viewController placeid:(int)place
{
    // 当广告还没就绪的时候，不增加显示次数
    if (rewardedAd != NULL) {
        curr_ad_place = place;
        
        [rewardedAd presentFromRootViewController:viewController userDidEarnRewardHandler:^{
            GADAdReward *reward = rewardedAd.adReward;
#ifdef LOG_USER_ACTION
            [Flurry logEvent:[self adPosition] withParameters:@{@"id": reward_id, @"status": @"reward"}];
#endif
            NSLog(@"[ADUNION] Admob reward ad rewarded");
            
            if(self.delegate) {
                [self.delegate RewardVideoAdDidRewardUserWithReward:self rewardType:reward.type amount:reward.amount.doubleValue];
            }
        }];
        NSLog(@"[ADUNION] Show Admob reward Ad :%@", reward_id);
        
#ifdef LOG_USER_ACTION
        [Flurry logEvent:[self adPosition] withParameters:@{@"id": reward_id, @"status": @"show"}];
#endif
        isshowing = true;
        return YES;
    }
    
    return NO;
}

-(BOOL) isRewardAdReady:(int)place
{
    if(rewardedAd != NULL)
        return YES;
    
    if(!isloading && !isshowing)
    {
        [self _rewardAdReload];
    }
    return FALSE;
}

-(void) _rewardAdReload {
    isloading = true;
    isshowing = false;
    
    [GADRewardedAd loadWithAdUnitID:reward_id request:[self getADRequest] completionHandler:^(GADRewardedAd *ad, NSError *error) {
            if (error) {
                NSLog(@"[ADUNION] Admob rewarded ad failed to load with error: %@", [error localizedDescription]);
                if(self.delegate) {
                    [self.delegate RewardVideoAdFailToReceivedWithError:self error:[error localizedFailureReason]];
                }
                
            #ifdef LOG_USER_ACTION
                [Flurry logEvent:[self adPosition] withParameters:@{@"id": reward_id, @"status": @"failed"}];
            #endif
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(rewardAdRetryCount < 3) {
                        rewardAdRetryCount++;
                        [self _rewardAdReload];
                        
                        NSLog(@"[ADUNION] retry admob reward ad %d!", rewardAdRetryCount);
                    }
                    else {
                        rewardAdRetryCount = 0;
                        isloading = false;
                    }
                });
                
                return;
            } else {
                rewardAdRetryCount = 0;
                isloading = false;
            
                rewardedAd = ad;
                NSLog(@"zzx Are rewardedAd");
                rewardedAd.fullScreenContentDelegate = self;
                
                if(self.delegate) {
                    [self.delegate RewardVideoAdDidReceive:self];
                }
            
                
                NSLog(@"[ADUNION] admob reward ad ready, wait to show!");
            #ifdef LOG_USER_ACTION
                [Flurry logEvent:[self adPosition] withParameters:@{@"id": reward_id, @"status": @"loaded"}];
            #endif
            }
        }];
#ifdef LOG_USER_ACTION
    [Flurry logEvent:[self adPosition] withParameters:@{@"id": reward_id, @"status": @"load"}];
#endif
}

#pragma mark -
#pragma mark  admob remove

-(void)removeAllAds:(UIView *)rootView
{
}

#pragma mark -
#pragma mark admob delegate

- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
#ifdef LOG_USER_ACTION
    [Flurry logEvent:[self adPosition]  withParameters:@{@"id": reward_id, @"status": @"show"}];
#endif
    
    if(self.delegate) {
        [self.delegate RewardVideoAdDidOpen:self];
    }
}

/// Tells the delegate that a click has been recorded for the ad.
- (void)adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>)ad {
#ifdef LOG_USER_ACTION
    [Flurry logEvent:[self adPosition] withParameters:@{@"id": reward_id, @"status": @"click"}];
#endif

    if(self.delegate) {
        [self.delegate RewardVideoAdWillLeaveApplication:self];
    }
}

/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    rewardedAd = nil;
    NSLog(@"Are zzx");
    
    if(self.delegate) {
        [self.delegate RewardVideoAdDidClose:self];
    }
    isshowing = false;
    
#ifdef LOG_USER_ACTION
    [Flurry logEvent:[self adPosition] withParameters:@{@"id": reward_id, @"status": @"closed"}];
#endif
    
    [self init_reward_ad];
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    if(self.delegate) {
        [self.delegate RewardVideoAdDidStartPlaying:self];
    }
}

/// Tells the delegate that the ad will dismiss full screen content.
- (void)adWillDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    rewardedAd = nil;
    NSLog(@"Are zzx");
    if(self.delegate) {
        [self.delegate RewardVideoAdDidClose:self];
    }
    isshowing = false;
    
#ifdef LOG_USER_ACTION
    [Flurry logEvent:[self adPosition] withParameters:@{@"id": reward_id, @"status": @"closed"}];
#endif
    
    [self init_reward_ad];
}

- (NSString *) adPosition {
    return [NSString stringWithFormat:@"RewardAd%d", curr_ad_place];
}

@end
