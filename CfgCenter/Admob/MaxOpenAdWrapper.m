//
//  MaxOpenAdWrapper.m
//  Unity-iPhone
//
//  Created by 昭 陈 on 2025/10/18.
//

#import <Foundation/Foundation.h>
#import "CfgCenter.h"
#import "MaxOpenAdWrapper.h"
#import "ApplovinMaxRevenueDelegate.h"
#ifdef LOG_USER_ACTION
#import <FirebaseAnalytics/FirebaseAnalytics.h>
#endif
extern BOOL applovin_initialized;

@implementation MaxOpenAdWrapper
{
    NSString* ad_id;
    
    MAAppOpenAd *openAd;
    NSInteger ad_retryAttempt;
    
    int curr_ad_place;
    
    BOOL isloading;
    BOOL isshowing;
    
    BOOL delay_init;
}


@synthesize RootViewController;

#pragma mark -
#pragma mark  admob init
- (id)initWithRootView:(AdmobViewController*) rootview adid:(NSString*)adid
{
    self = [super init];
    
    if(self)
    {
        RootViewController = rootview;
        ad_id = adid;
        delay_init = NO;
        _revenueDelegate = [[ApplovinMaxRevenueDelegate alloc] init];
    }
    return self;
}

- (void)dealloc
{
    if(openAd != nil) {
        openAd.delegate = nil;
        openAd = nil;
    }
}

- (void) createOpenAd {
    openAd = [[MAAppOpenAd alloc] initWithAdUnitIdentifier: ad_id];
    openAd.delegate = self;
    openAd.revenueDelegate = _revenueDelegate;

    // Load the first ad
    
    [self _open_reload];
}

- (void) delayInitAfterNetworkFinish {
    if(delay_init) {
        [self createOpenAd];
        delay_init = false;
    }
}

-(void) init_ad {
    if(applovin_initialized) {
        if(!delay_init) {
            [self createOpenAd];
        }
    } else {
        delay_init = true;
    }
}

-(void) _open_reload {
    [openAd loadAd];
    [self send_flurry_report:ad_id status: @"load"];
}

#pragma mark -
#pragma mark  show applovin openad

-(BOOL) showAd:(UIViewController*)viewController placeid:(int)place
{
    if(openAd == nil) {
        return NO;
    }
    if ( [openAd isReady] ) {
        [openAd showAd];
        [self send_flurry_report:ad_id status: @"show"];
        return YES;
    }
    return NO;
}

-(BOOL) isAdReady:(int)place {
    if(openAd != nil && [openAd isReady]) {
        return YES;
    }
    return NO;
}

- (void) send_flurry_report:(NSString*)adunit status:(NSString*) status {
#ifdef LOG_USER_ACTION
    [FIRAnalytics logEventWithName:[self adPosition] parameters:@{@"id": adunit, @"status": status}];
#else
    NSLog(@"[ADUNION] %@: {id: %@, status: %@", [self adPosition], adunit, status);
#endif
}

- (NSString *) adPosition {
    return [NSString stringWithFormat:@"MaxOpenAd%d", curr_ad_place];
}

#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad
{
    if([ad.adUnitIdentifier isEqualToString: ad_id]) {
        if(self.delegate != NULL) {
            [self.delegate AdDidReceive:self];
        }
        
        NSLog(@"[ADUNION] applovin open ad ready, wait to show!");
        [self send_flurry_report:ad_id status:@"loaded"];
        ad_retryAttempt = 0;
    }
}

- (void)didFailToLoadAdForAdUnitIdentifier:(nonnull NSString *)adUnitIdentifier withError:(nonnull MAError *)error {
    if([adUnitIdentifier isEqualToString: ad_id]) {
        [self send_flurry_report:ad_id status:@"failed"];
        
        ad_retryAttempt++;
        NSInteger delaySec = pow(2, MIN(6, ad_retryAttempt));
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delaySec * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self _open_reload];
        });
        
        if(self.delegate != NULL) {
            [self.delegate AdFailToReceivedWithError:self error:[@(error.code) stringValue]];
        }
    }

}

- (void)didDisplayAd:(MAAd *)ad {
    if([ad.adUnitIdentifier isEqualToString: ad_id]) {
        [self send_flurry_report:ad_id status:@"display"];
    }
    
    if(self.delegate != NULL) {
        [self.delegate AdDidOpen:self];
    }
}

- (void)didClickAd:(MAAd *)ad {
    if([ad.adUnitIdentifier isEqualToString: ad_id]) {
        [self send_flurry_report:ad_id status:@"click"];
    }
    
    if(self.delegate != NULL) {
        [self.delegate AdWillLeaveApplication:self];
    }
}

- (void)didHideAd:(MAAd *)ad
{
    if([ad.adUnitIdentifier isEqualToString: ad_id]) {
        // open ad is hidden. Pre-load the next ad
        [self _open_reload];
        
        [self send_flurry_report:ad_id status:@"closed"];
        
        if(self.delegate != NULL) {
            [self.delegate AdDidClose:self];
        }
    }
}

- (void)didFailToDisplayAd:(nonnull MAAd *)ad withError:(nonnull MAError *)error {
    if([ad.adUnitIdentifier isEqualToString: ad_id]) {
        // open ad failed to display. We recommend loading the next ad
        [self _open_reload];
        
        [self send_flurry_report:ad_id status:@"failed_display"];
        
        if(self.delegate != NULL) {
            [self.delegate AdDidClose:self];
        }
    }
}

@end
