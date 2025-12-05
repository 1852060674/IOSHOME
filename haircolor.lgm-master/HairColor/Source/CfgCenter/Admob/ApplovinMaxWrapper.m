//
//  ApplovinMaxWrapper.m
//  version 4.0
//
//  Created by Chris Chen on 2021/3/1.
//  Copyright © 2021 Chris Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Admob.h"
#import "ApplovinMaxWrapper.h"
#import "CfgCenter.h"
@import AppLovinSDK;

#ifndef LOG_USER_ACTION
#define LOG_USER_ACTION
#endif

#ifdef LOG_USER_ACTION
@import Flurry_iOS_SDK;
#endif

@implementation ApplovinMaxWrapper
{
    NSString* banner_id;
    NSString* inter_id;
    NSString* reward_id;
    
    MAAdView *adView;
    
    MAInterstitialAd *interstitialAd;
    NSInteger inter_retryAttempt;
    
    MARewardedAd *rewardedAd;
    NSInteger reward_retryAttempt;
    
    ADAlignment bannerAlign;
    bool initailized;
    
    __weak UIView* banner_parent;
}

@synthesize RootViewController;
@synthesize bannerReady;
@synthesize idx;

#pragma mark -
#pragma mark  admob init

- (id)initWithRootView:(AdmobViewController*) rootview
{
    self = [super init];
    
    if(self)
    {
        RootViewController = rootview;
        banner_id = MAX_BANNER_ID;
        inter_id = MAX_INTERSTITIAL_ID;
        reward_id = MAX_REWARD_ID;
        
        if(banner_id == nil || [banner_id isEqualToString:@""]) {
            bannerReady = AD_NOTSURPORT;
        } else {
            bannerReady = AD_NOTINIT;
        }
        bannerAlign = AD_TOP;
        initailized = false;
    }
    return self;
}

- (void)dealloc
{
    [self remove_all_ads:adView.superview];
    if(rewardedAd != nil) {
        rewardedAd.delegate = nil;
        rewardedAd = nil;
    }
}

-(void) init_first_time {
    [ALSdk shared].mediationProvider = @"max";
    [[ALSdk shared] initializeSdkWithCompletionHandler:^(ALSdkConfiguration *configuration) {
        initailized = true;
        if(![inter_id isEqualToString:@""]) {
            [self createInterstitialAd];
        }
        
        if(![banner_id isEqualToString:@""]) {
            [self createBannerAd];
        }
        
        if(![reward_id isEqualToString:@""]) {
            [self createRewardAd];
        }
        
//        [[ALSdk shared] showMediationDebugger];
    }];
}

- (void) createInterstitialAd {
    interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier: inter_id];
    interstitialAd.delegate = self;

    // Load the first ad
    [self _interstitial_reload];
}

- (void) createBannerAd {
    adView = [[MAAdView alloc] initWithAdUnitIdentifier: banner_id];
    adView.delegate = self;

    // Banner height on iPhone and iPad is 50 and 90, respectively
    CGFloat height = (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 90 : 50;

    // Stretch to the width of the screen for banners to be fully functional
    CGFloat width = CGRectGetWidth(UIScreen.mainScreen.bounds);

    adView.frame = CGRectMake(0, 0, width, height);

    // Set background or background color for banner ads to be fully functional
    adView.backgroundColor = UIColor.blackColor;

    // Load the ad
    bannerReady = AD_LOADING;
    [adView loadAd];
    
    [self send_flurry_report:banner_id status:@"load"];
}

- (void) createRewardAd {
    rewardedAd = [MARewardedAd sharedWithAdUnitIdentifier: reward_id];
    rewardedAd.delegate = self;

    // Load the first ad
    
    [self _reward_reload];
}

-(void) reloadBannerView {
    //raload in max
}

-(void)init_admob_banner {
    if(initailized && adView == nil) {
        if(bannerReady != AD_NOTSURPORT) {
            [self createBannerAd];
        }
    }
}

- (void)init_admob_banner:(float)width height:(float)height {
    //ignore width and height
    [self init_admob_banner];
}

-(void) init_admob_interstitial
{
    if(initailized && interstitialAd == nil) {
        if(inter_id && ![inter_id isEqualToString:@""]) {
            [self createInterstitialAd];
        }
    }
}

#pragma mark -
#pragma mark  admob banner

-(void) show_admob_banner:(UIView*)view placeid:(NSString *)place
{
    if(bannerReady == AD_NOTSURPORT) {
        return;
    }
    banner_parent = view;
    if(adView != nil && adView.isHidden) {
        adView.hidden = NO;
        [adView startAutoRefresh];
        return;
    }
    
    [self init_admob_banner];
    
    if(adView == nil) {
        return;
    }
    
    //  将banner的view加入到父view中
    [view addSubview:adView];
    
    [self updateBannerPos];
}

-(void) updateBannerPos {
    UIView* parent = [adView superview];
    if(parent != nil) {
        CGSize size = parent.frame.size;
        CGSize ourSize = adView.frame.size;
        
        for(NSLayoutConstraint* constraint in parent.constraints) {
            if(constraint.firstItem == adView || constraint.secondItem == adView) {
                [parent removeConstraint:constraint];
            }
        }
        
        //cneter horizen
        [parent addConstraint:[NSLayoutConstraint
                               constraintWithItem:parent
                               attribute:NSLayoutAttributeCenterX
                               relatedBy:NSLayoutRelationEqual
                               toItem:adView
                               attribute:NSLayoutAttributeCenterX
                               multiplier:1.0 constant:0.0]];
        
        switch (bannerAlign) {
            case AD_TOP:
                [adView setCenter:CGPointMake(size.width/2, ourSize.height/2)];
                [parent addConstraint:[NSLayoutConstraint
                                       constraintWithItem:parent
                                       attribute:NSLayoutAttributeTop
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:adView
                                       attribute:NSLayoutAttributeTop
                                       multiplier:1.0 constant:0.0]];
                break;
            case AD_CENTER:
                [adView setCenter:CGPointMake(size.width/2, size.height/2)];
                [parent addConstraint:[NSLayoutConstraint
                                       constraintWithItem:parent
                                       attribute:NSLayoutAttributeCenterY
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:adView
                                       attribute:NSLayoutAttributeCenterY
                                       multiplier:1.0 constant:0.0]];
                break;
            case AD_BOTTOM:
                [adView setCenter:CGPointMake(size.width/2, size.height-ourSize.height/2)];
                [parent addConstraint:[NSLayoutConstraint
                                       constraintWithItem:parent
                                       attribute:NSLayoutAttributeBottom
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:adView
                                       attribute:NSLayoutAttributeBottom
                                       multiplier:1.0 constant:0.0]];
                break;
            default:
                break;
        }
    }
}

-(void) setBannerAlign:(ADAlignment) align {
    if(bannerReady == AD_NOTSURPORT) {
        return;
    }
    bannerAlign = align;
    [self updateBannerPos];
}

- (void) hide_banner{
    if(bannerReady == AD_NOTSURPORT) {
        return;
    }
    adView.hidden = YES;
    [adView stopAutoRefresh];
}

#pragma mark -
#pragma mark admob native

-(void) init_admob_native:(float)width height:(float)height
{
}

/* 显示原生广告 */
-(void) show_admob_native:(float)posx posy:(float)posy width:(float)width height:(float)height view:(UIView*)view placeid:(NSString *)place
{
}

#pragma mark -
#pragma mark  admob interstitial

-(BOOL) show_admob_interstitial:(UIViewController*)viewController placeid:(int)place
{
    if(interstitialAd == nil) {
        return NO;
    }
    if ( [interstitialAd isReady] )
    {
        [interstitialAd showAd];
        [self send_flurry_report:inter_id status: @"show"];
        return YES;
    }
    return NO;
}

-(BOOL) admob_interstial_ready:(int)place
{
    if(interstitialAd == nil) {
        return NO;
    }
    
    if([interstitialAd isReady]) {
        return YES;
    }
    
    return FALSE;
}

-(void) _interstitial_reload {
    [interstitialAd loadAd];
    [self send_flurry_report:inter_id status: @"load"];
}

-(void) _reward_reload {
    [rewardedAd loadAd];
    [self send_flurry_report:reward_id status: @"load"];
}

-(BOOL) show_admob_reward:(UIViewController*)viewController placeid:(int)place {
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
-(BOOL) admob_reward_ready:(int)place {
    if(interstitialAd != nil && [interstitialAd isReady]) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark  admob remove

-(void)remove_all_ads:(UIView *)rootView
{
    [self remove_banner:rootView];
    [self remove_native:rootView];
    
    banner_parent = nil;
    if(adView != nil) {
        adView.delegate = nil;
        [adView stopAutoRefresh];
        adView = nil;
    }
    
    if(interstitialAd != nil) {
        interstitialAd.delegate = nil;
        interstitialAd = nil;
    }
}

-(void)remove_banner:(UIView*)rootView
{
    for (UIView *_subView in rootView.subviews) {
        if ([_subView isKindOfClass:[MAAdView class]]) {
            [_subView removeFromSuperview];
        }
    }
}

-(void)remove_native:(UIView*)rootView
{
}

- (NSString *) adPosition {
    return [NSString stringWithFormat:@"ApplovinMaxAd"];
}

#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad
{
    if([ad.adUnitIdentifier isEqualToString: banner_id]) {
        bannerReady = AD_LOADED;
        NSLog(@"Admob Load banner ok! idx %d", idx);
        
        if(self.delegate != NULL) {
            [self.delegate bannerDidLoaded:self];
        }
        [self send_flurry_report:banner_id status:@"loaded"];
        
        if(banner_parent != nil) {
            [self show_admob_banner:banner_parent placeid:0];
        }
    } else if([ad.adUnitIdentifier isEqualToString: inter_id]) {
        if(self.delegate != NULL) {
            [self.delegate interstitialDidReceiveAd];
        }
        
        NSLog(@"round ad ready, wait to show!");
        [self send_flurry_report:inter_id status:@"loaded"];

        // Interstitial ad is ready to be shown. '[self.interstitialAd isReady]' will now return 'YES'

        // Reset retry attempt
        inter_retryAttempt = 0;
    } else {
        if(self.delegate != NULL) {
            [self.delegate rewardDidReceiveAd];
        }
        
        NSLog(@"reward ad ready, wait to show!");
        [self send_flurry_report:reward_id status:@"load"];
        reward_retryAttempt = 0;
    }
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withErrorCode:(NSInteger)errorCode
{
    if([adUnitIdentifier isEqualToString: banner_id]) {
        if(bannerReady != AD_LOADED) {  //if has loaded then alway can show
            bannerReady = AD_FAILED;
            NSLog(@"Failed to receive banner idx %d with error: %ld", idx, errorCode);
            
            if(self.delegate != NULL) {
                NSError *error = [NSError errorWithDomain:@"adwraper" code:errorCode userInfo:nil];
                [self.delegate bannerDidFailedLoad:self error:error];
            }
        } else {
            NSLog(@"Failed to refresh banner idx %d with error: %ld", idx, errorCode);
        }

        [self send_flurry_report:banner_id status:@"failed"];
    } else if([adUnitIdentifier isEqualToString: inter_id]) {
        [self send_flurry_report:inter_id status:@"failed"];
        // Interstitial ad failed to load
        // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
        
        inter_retryAttempt++;
        NSInteger delaySec = pow(2, MIN(6, inter_retryAttempt));
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delaySec * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self _interstitial_reload];
        });
    } else {
        [self send_flurry_report:reward_id status:@"failed"];
        
        reward_retryAttempt++;
        NSInteger delaySec = pow(2, MIN(6, reward_retryAttempt));
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delaySec * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self _reward_reload];
        });
    }

}

- (void)didDisplayAd:(MAAd *)ad {
    if([ad.adUnitIdentifier isEqualToString: inter_id]) {
        [self send_flurry_report:inter_id status:@"display"];
    } else {
        [self send_flurry_report:reward_id status:@"display"];
    }
}

- (void)didClickAd:(MAAd *)ad {
    if([ad.adUnitIdentifier isEqualToString: banner_id]) {
        [self send_flurry_report:banner_id status:@"click"];
    } else if([ad.adUnitIdentifier isEqualToString: inter_id]) {
        [self send_flurry_report:inter_id status:@"click"];
    } else {
        [self send_flurry_report:reward_id status:@"click"];
    }
}

- (void)didHideAd:(MAAd *)ad
{
    if([ad.adUnitIdentifier isEqualToString: inter_id]) {
        // Interstitial ad is hidden. Pre-load the next ad
        [self _interstitial_reload];
        
        [self send_flurry_report:inter_id status:@"closed"];
        
        if(self.delegate != NULL) {
            [self.delegate interstitialWillDismissScreen];
            [self.delegate interstitialDidDismissScreen];
        }
    } else {
        // Rewarded ad is hidden. Pre-load the next ad
        [self _reward_reload];
        
        [self send_flurry_report:reward_id status:@"closed"];
        
        if(self.delegate != NULL) {
            [self.delegate rewardDidClose];
        }
    }
}

- (void)didFailToDisplayAd:(MAAd *)ad withErrorCode:(NSInteger)errorCode
{
    if([ad.adUnitIdentifier isEqualToString: inter_id]) {
        // Interstitial ad failed to display. We recommend loading the next ad
        [self _interstitial_reload];
        
        [self send_flurry_report:inter_id status:@"failed_display"];
        
        if(self.delegate != NULL) {
            [self.delegate interstitialWillDismissScreen];
            [self.delegate interstitialDidDismissScreen];
        }
    } else {
        // Rewarded ad failed to display. We recommend loading the next ad
        [self _reward_reload];
        
        [self send_flurry_report:reward_id status:@"failed_display"];
        
        if(self.delegate != NULL) {
            [self.delegate rewardDidClose];
        }
    }
}

#pragma mark - MARewardedAdDelegate Protocol

- (void)didStartRewardedVideoForAd:(MAAd *)ad {}

- (void)didCompleteRewardedVideoForAd:(MAAd *)ad {}

- (void)didRewardUserForAd:(MAAd *)ad withReward:(MAReward *)reward
{
    if(self.delegate != NULL) {
        [self.delegate rewardDidFinishWithReward];
    }
}


- (void) send_flurry_report:(NSString*)adunit status:(NSString*) status {
#ifdef LOG_USER_ACTION
    [Flurry logEvent:[self adPosition] withParameters:@{@"id": adunit, @"status": status}];
#endif
}

@end
