//
//  ApplovinMaxRewardWrapper.m
//  Unity-iPhone
//
//  Created by 昭 陈 on 2021/9/7.
//

#import <Foundation/Foundation.h>
#import "ApplovinMaxRewardWrapper.h"
#import "ApplovinMaxRevenueDelegate.h"

extern BOOL applovin_initialized;

@implementation ApplovinMaxRewardWrapper
{
    NSString* reward_id;
    
    MARewardedAd *rewardedAd;
    NSInteger reward_retryAttempt;
    
    int curr_ad_place;
    
    BOOL isloading;
    BOOL isshowing;
    
    BOOL reward_delay_init;
}


@synthesize RootViewController;

#pragma mark -
#pragma mark  admob init
- (id)initWithRootView:(AdmobViewController*) rootview adid:(NSString*)rewardid
{
    self = [super init];
    
    if(self)
    {
        RootViewController = rootview;
        reward_id = rewardid;
        reward_delay_init = NO;
        _revenueDelegate = [[ApplovinMaxRevenueDelegate alloc] init];
    }
    return self;
}

- (void)dealloc
{
    if(rewardedAd != nil) {
        rewardedAd.delegate = nil;
        rewardedAd = nil;
    }
}

- (void) createRewardAd {
    rewardedAd = [MARewardedAd sharedWithAdUnitIdentifier: reward_id];
    rewardedAd.delegate = self;
    rewardedAd.revenueDelegate = _revenueDelegate;

    // Load the first ad
    
    [self _reward_reload];
}

- (void) delayInitAfterNetworkFinish {
    if(reward_delay_init) {
        [self createRewardAd];
        reward_delay_init = false;
    }
}

-(void) init_reward_ad {
    if(applovin_initialized) {
        if(!reward_delay_init) {
            [self createRewardAd];
        }
    } else {
        reward_delay_init = true;
    }
}

-(void) _reward_reload {
    [rewardedAd loadAd];
    [self send_flurry_report:reward_id status: @"load"];
}

#pragma mark -
#pragma mark  show applovin reward

-(BOOL) showRewardAd:(UIViewController*)viewController placeid:(int)place
{
    if(rewardedAd == nil) {
        return NO;
    }
    if ( [rewardedAd isReady] ) {
        [rewardedAd showAd];
        [self send_flurry_report:reward_id status: @"show"];
        return YES;
    }
    return NO;
}

-(BOOL) isRewardAdReady:(int)place {
    if(rewardedAd != nil && [rewardedAd isReady]) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark  admob remove

-(void)removeAllAds:(UIView *)rootView
{
}


//- (void) send_flurry_report:(NSString*)adunit status:(NSString*) status {
//#ifdef LOG_USER_ACTION
//    [Flurry logEvent:[self adPosition] withParameters:@{@"id": adunit, @"status": status}];
//#else
//    NSLog(@"[ADUNION] %@: {id: %@, status: %@", [self adPosition], adunit, status);
//#endif
//}
-(void) send_flurry_report:(NSString*)adunit status:(NSString*) status {
#ifdef LOG_USER_ACTION
    [FIRAnalytics logEventWithName:[self adPosition] parameters:@{@"adunit_id": adunit, @"status": status}];
#else
    NSLog(@"[ADUNION] %@: {id: %@, status: %@", [self adPosition], adunit, status);
#endif
}

- (NSString *) adPosition {
    return [NSString stringWithFormat:@"MaxRewardAd%d", curr_ad_place];
}

#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad
{
    if([ad.adUnitIdentifier isEqualToString: reward_id]) {
        if(self.delegate != NULL) {
            [self.delegate RewardVideoAdDidReceive:self];
        }
        
        NSLog(@"[ADUNION] applovin reward ad ready, wait to show!");
        [self send_flurry_report:reward_id status:@"load"];
        reward_retryAttempt = 0;
    }
}

- (void)didFailToLoadAdForAdUnitIdentifier:(nonnull NSString *)adUnitIdentifier withError:(nonnull MAError *)error {
    if([adUnitIdentifier isEqualToString: reward_id]) {
        [self send_flurry_report:reward_id status:@"failed"];
        
        reward_retryAttempt++;
        NSInteger delaySec = pow(2, MIN(6, reward_retryAttempt));
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delaySec * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self _reward_reload];
        });
        
        if(self.delegate != NULL) {
            [self.delegate RewardVideoAdFailToReceivedWithError:self error:[@(error.code) stringValue]];
        }
    }

}

- (void)didDisplayAd:(MAAd *)ad {
    if([ad.adUnitIdentifier isEqualToString: reward_id]) {
        [self send_flurry_report:reward_id status:@"display"];
    }
    
    if(self.delegate != NULL) {
        [self.delegate RewardVideoAdDidOpen:self];
    }
}

- (void)didClickAd:(MAAd *)ad {
    if([ad.adUnitIdentifier isEqualToString: reward_id]) {
        [self send_flurry_report:reward_id status:@"click"];
    }
    
    if(self.delegate != NULL) {
        [self.delegate RewardVideoAdWillLeaveApplication:self];
    }
}

- (void)didHideAd:(MAAd *)ad
{
    if([ad.adUnitIdentifier isEqualToString: reward_id]) {
        // Rewarded ad is hidden. Pre-load the next ad
        [self _reward_reload];
        
        [self send_flurry_report:reward_id status:@"closed"];
        
        if(self.delegate != NULL) {
            [self.delegate RewardVideoAdDidClose:self];
        }
    }
}

- (void)didFailToDisplayAd:(nonnull MAAd *)ad withError:(nonnull MAError *)error {
    if([ad.adUnitIdentifier isEqualToString: reward_id]) {
        // Rewarded ad failed to display. We recommend loading the next ad
        [self _reward_reload];
        
        [self send_flurry_report:reward_id status:@"failed_display"];
        
        if(self.delegate != NULL) {
            [self.delegate RewardVideoAdDidClose:self];
        }
    }
}


#pragma mark - MARewardedAdDelegate Protocol

- (void)didStartRewardedVideoForAd:(MAAd *)ad {
    if(self.delegate != NULL) {
        [self.delegate RewardVideoAdDidStartPlaying:self];
    }
}

- (void)didCompleteRewardedVideoForAd:(MAAd *)ad {}

- (void)didRewardUserForAd:(MAAd *)ad withReward:(MAReward *)reward
{
    if(self.delegate != NULL) {
        [self.delegate RewardVideoAdDidRewardUserWithReward:self rewardType:reward.label amount:reward.amount];
    }
}


@end
