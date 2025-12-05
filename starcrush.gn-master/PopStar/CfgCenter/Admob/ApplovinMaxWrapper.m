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
#import "ApplovinMaxRevenueDelegate.h"
@import AppLovinSDK;

//#ifndef LOG_USER_ACTION
//#define LOG_USER_ACTION
//#endif

#ifdef LOG_USER_ACTION
//@import Flurry_iOS_SDK;
//#import "Flurry.h"
#endif

@implementation ApplovinMaxWrapper
{
    NSString* banner_id;
    NSString* inter_id;
    
    MAAdView *adView;
    
    MAInterstitialAd *interstitialAd;
    NSInteger inter_retryAttempt;
    
    ADAlignment bannerAlign;
    
    __weak UIView* banner_parent;
    
    BOOL banner_delay_init;
    BOOL inter_delay_init;
    
    CGFloat admobX;
    CGFloat admobY;
    CGFloat admobWidth;
    CGFloat admobHeight;
    
    double currentBannerRevenue;
    NSString* currentBannerNetwork;
    NSString* currentBannerPlacementId;
}

@synthesize RootViewController;
@synthesize bannerReady;
@synthesize idx;

#pragma mark -
#pragma mark  admob init
- (id)initWithRootView:(AdmobViewController*) rootview bannerid:(NSString*)bannerid interid:(NSString*)interid;
{
    self = [super init];
    
    if(self)
    {
        RootViewController = rootview;
        banner_id = bannerid;
        inter_id = interid;
        
        if(banner_id == nil || [banner_id isEqualToString:@""]) {
            bannerReady = AD_NOTSURPORT;
        } else {
            bannerReady = AD_NOTINIT;
        }
        bannerAlign = AD_TOP;
        banner_delay_init = NO;
        inter_delay_init = NO;
        currentBannerRevenue = 0;
        
        self->isBannerBackground = TRUE;
        _revenueDelegate = [[ApplovinMaxRevenueDelegate alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self remove_all_ads:adView.superview];
}

-(void) init_first_time {
    [self init_admob_interstitial];
    if(bannerReady != AD_NOTSURPORT) {
        [self init_admob_banner];
        
        //start time task watch refresh every 30s
//        [NSTimer scheduledTimerWithTimeInterval: 10.0 target: self
//                                       selector: @selector(checkManulRefresh) userInfo: nil repeats: YES];
    }
}

- (void) delayInitAfterNetworkFinish {
    if(banner_delay_init && ![banner_id isEqualToString:@""]) {
        [self createBannerAd];
        banner_delay_init = false;
    }
    
    if(inter_delay_init && ![inter_id isEqualToString:@""]) {
        [self createInterstitialAd];
        inter_delay_init = false;
    }
}

- (void) createInterstitialAd {
    interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier: inter_id];
    interstitialAd.delegate = self;
    interstitialAd.revenueDelegate = _revenueDelegate;

    // Load the first ad
    [self _interstitial_reload];
}

- (void) createBannerAd {
    adView = [[MAAdView alloc] initWithAdUnitIdentifier: banner_id];
    adView.delegate = self;
    adView.revenueDelegate = _revenueDelegate;

//    // Banner height on iPhone and iPad is 50 and 90, respectively
//    CGFloat height = (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 90 : 50;
//
//    // Stretch to the width of the screen for banners to be fully functional
//    CGFloat width = CGRectGetWidth(UIScreen.mainScreen.bounds);
//
//    adView.frame = CGRectMake(0, 0, width, height);
    
    // Get the adaptive banner height
    CGFloat height = MAAdFormat.banner.adaptiveSize.height;
    
    // Stretch to the width of the screen for banners to be fully functional
    CGFloat width = CGRectGetWidth(UIScreen.mainScreen.bounds);
    
    adView.frame = CGRectMake(0, 0, width, height);
    [adView setExtraParameterForKey: @"adaptive_banner" value: @"true"];

    // Set background or background color for banner ads to be fully functional
//    adView.backgroundColor = UIColor.blackColor;

    // Load the ad
    bannerReady = AD_LOADING;
    [adView loadAd];
    
    [self send_flurry_report:banner_id status:@"load"];
}



-(void) reloadBannerView {
    //raload in max
}

-(void)init_admob_banner {
    if(applovin_initialized) {
        if(adView == nil && !banner_delay_init) {
            if(bannerReady != AD_NOTSURPORT) {
                [self createBannerAd];
            }
        }
    } else {
        banner_delay_init = YES;
    }
}

- (void)init_admob_banner:(float)width height:(float)height {
    //ignore width and height
    [self init_admob_banner];
}

-(void) init_admob_interstitial
{
    if(applovin_initialized) {
        if(interstitialAd == nil && !inter_delay_init) {
            if(inter_id && ![inter_id isEqualToString:@""]) {
                [self createInterstitialAd];
            }
        }
    } else {
        inter_delay_init = YES;
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
        NSLog(@"[ADUNION] Applovin banner start auto refresh");
        return;
    }
    
    [self init_admob_banner];
    
    if(adView == nil) {
        return;
    }
    
    //  将banner的view加入到父view中
    [view addSubview:adView];
    
    [self updateBannerPos];
    
    self->isBannerBackground = FALSE;
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
                if ([[UIScreen mainScreen] bounds].size.height >811 && [[UIScreen mainScreen] bounds].size.height + [[UIScreen mainScreen] bounds].size.width <1500) {
                    [adView setCenter:CGPointMake(size.width/2, size.height-ourSize.height/2-34)];
                }
                if ([[UIScreen mainScreen] bounds].size.height + [[UIScreen mainScreen] bounds].size.width >1500) {
                    [adView setCenter:CGPointMake(size.width/2, size.height-ourSize.height/2-20)];
                }
                [parent addConstraint:[NSLayoutConstraint
                constraintWithItem:parent
                attribute:NSLayoutAttributeBottom
                relatedBy:NSLayoutRelationEqual
                toItem:adView
                attribute:NSLayoutAttributeBottom
                multiplier:1.0 constant:-34.0]];
                break;
            default:
                break;
        }
    }
    admobX=adView.frame.origin.x;
    admobY=adView.frame.origin.y;
    admobWidth=adView.frame.size.width;
    admobHeight=adView.frame.size.height;
    NSLog(@"zzx adView x=%lf,adView y=%lf with=%lf",adView.frame.origin.x,adView.frame.origin.y,adView.frame.size.width);
}
- (CGFloat)getAdmobX{
    return admobX;
}
- (CGFloat) getAdmobY{
    return admobY;
}
- (CGFloat) getAdmobWidth{
    return admobWidth;
}
- (CGFloat) getAdmobHeight{
    return admobHeight;
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
    NSLog(@"[ADUNION] Applovin banner stop auto refresh");
}

- (double)getBannerRevenue {
    return currentBannerRevenue;
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

#pragma mark -
#pragma mark  remove

-(void)remove_all_ads:(UIView *)rootView
{
    [self remove_banner:rootView];
    [self remove_native:rootView];
    
    banner_parent = nil;
    if(adView != nil) {
        adView.delegate = nil;
        [adView stopAutoRefresh];
        NSLog(@"[ADUNION] Applovin banner stop auto refresh permentally");
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
    if(rootView == banner_parent) {
        banner_parent = nil;
    }
    self->isBannerBackground = TRUE;
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
        NSLog(@"[ADUNION] Applovin Load banner ok! idx %d", idx);
        currentBannerRevenue = [ad revenue]*1000;
        currentBannerNetwork = [ad networkName];
        currentBannerPlacementId = [ad adValueForKey:@"network_placement" defaultValue:@""];
        
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
        
        NSLog(@"[ADUNION] Applovin round ad ready, wait to show!");
        [self send_flurry_report:inter_id status:@"loaded"];

        // Interstitial ad is ready to be shown. '[self.interstitialAd isReady]' will now return 'YES'

        // Reset retry attempt
        inter_retryAttempt = 0;
    }
}

- (void)didFailToLoadAdForAdUnitIdentifier:(nonnull NSString *)adUnitIdentifier withError:(nonnull MAError *)error {
    if([adUnitIdentifier isEqualToString: banner_id]) {
        currentBannerRevenue = 0.01;
        if(bannerReady != AD_LOADED) {  //if has loaded then alway can show
            bannerReady = AD_FAILED;
            NSLog(@"[ADUNION] Failed to receive Applovin banner idx %d with error: %ld", idx, error.code);
            
            if(self.delegate != NULL) {
                NSError *error;
                if(error == nil) {
                    error = [NSError errorWithDomain:@"adwraper" code:-100000 userInfo:nil];
                } else {
                    error = [NSError errorWithDomain:@"adwraper" code:error.code userInfo:nil];
                }
                [self.delegate bannerDidFailedLoad:self error:error];
            }
        } else {
            NSLog(@"[ADUNION] Failed to refresh Applovin banner idx %d with error: %ld", idx, error.code);
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
        
        if(self.delegate != NULL) {
            [self.delegate interstitialDidFailed];
        }
    }
}

- (void)didDisplayAd:(MAAd *)ad {
    if([ad.adUnitIdentifier isEqualToString: inter_id]) {
        [self send_flurry_report:inter_id status:@"display"];
        
        if(self.delegate != NULL) {
            [self.delegate interstitialDidShow];
        }
    }
}

- (void)didClickAd:(MAAd *)ad {
    if([ad.adUnitIdentifier isEqualToString: banner_id]) {
        [self send_flurry_report:banner_id status:@"click"];
        
        if(self.delegate != NULL) {
            [self.delegate bannerDidClick:self];
        }
    } else if([ad.adUnitIdentifier isEqualToString: inter_id]) {
        [self send_flurry_report:inter_id status:@"click"];
        
        if(self.delegate != NULL) {
            [self.delegate interstitialDidClick];
        }
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
    }
}

- (void)didFailToDisplayAd:(nonnull MAAd *)ad withError:(nonnull MAError *)error {
    if([ad.adUnitIdentifier isEqualToString: inter_id]) {
        // Interstitial ad failed to display. We recommend loading the next ad
        [self _interstitial_reload];
        
        [self send_flurry_report:inter_id status:@"failed_display"];
        
        if(self.delegate != NULL) {
            [self.delegate interstitialWillDismissScreen];
            [self.delegate interstitialDidDismissScreen];
        }
    }
}


- (void) send_flurry_report:(NSString*)adunit status:(NSString*) status {
#ifdef LOG_USER_ACTION
    [Flurry logEvent:[self adPosition] withParameters:@{@"id": adunit, @"status": status}];
#endif
}

- (void)didCollapseAd:(nonnull MAAd *)ad {
    //pass
}

- (void)didExpandAd:(nonnull MAAd *)ad {
    //pass
}

@end
