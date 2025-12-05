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

//#define ENABLE_ADJUST
//#define ENABLE_FIREBASE
#ifdef ENABLE_ADJUST
#import "Adjust.h"
#endif
#ifdef ENABLE_FIREBASE
#import "Firebase.h"
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
    rewardedAd.paidEventHandler = nil;
    rewardedAd = nil;
}

-(GADRequest*) getADRequest {
    GADRequest* request = [GADRequest request];
//    request.testDevices = @[ kGADSimulatorID ];
    return request;
}

-(void) init_reward_ad {
    if(rewardedAd != nil) {
        rewardedAd.fullScreenContentDelegate = nil;
        rewardedAd.paidEventHandler = nil;
        rewardedAd = nil;
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
                rewardedAd.fullScreenContentDelegate = self;
                
                __weak AdmobRewardAdWrapper *weakSelf = self;
                rewardedAd.paidEventHandler = ^(GADAdValue * _Nonnull advalue) {
                    AdmobRewardAdWrapper *strongSelf = weakSelf;
                    // Extract the impression-level ad revenue data.
                    NSDecimalNumber *value = advalue.value;
                    NSString *currencyCode = advalue.currencyCode;
                    
                    [strongSelf logPaidAdRevenue:value currency:currencyCode responseInfo:strongSelf->rewardedAd.responseInfo.loadedAdNetworkResponseInfo unitId:strongSelf->reward_id];
                };
                
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

- (void) logPaidAdRevenue:(NSDecimalNumber*)revenue currency:(NSString*) currencyCode responseInfo:(GADAdNetworkResponseInfo*) info unitId:(NSString*)unitid {
    NSString *adSourceName = info.adSourceName;
    NSString *adSourceInstanceName = info.adSourceInstanceName;
#ifdef ENABLE_ADJUST
    ADJAdRevenue *adRevenue = [[ADJAdRevenue alloc] initWithSource:ADJAdRevenueSourceAppLovinMAX];
    // pass revenue and currency values
    [adRevenue setRevenue:revenue.doubleValue currency:currencyCode];
    // pass optional parameters
//    [adRevenue setAdImpressionsCount:adImpressionsCount];
    [adRevenue setAdRevenueNetwork:adSourceName];
    [adRevenue setAdRevenueUnit:unitid];
    [adRevenue setAdRevenuePlacement:adSourceInstanceName];
    
    // attach callback and/or partner parameter if needed
//    [adRevenue addCallbackParameter:key value:value];
//    [adRevenue addPartnerParameter:key value:value];

    // track ad revenue
    [Adjust trackAdRevenue:adRevenue];
#endif
    
    
#ifdef ENABLE_FIREBASE
    [FIRAnalytics logEventWithName:@"ad_impression_revenue" parameters:@{
        kFIRParameterValue:@(revenue.doubleValue),
        kFIRParameterCurrency:currencyCode,
        kFIRParameterAdSource:adSourceName,
        kFIRParameterAdFormat:adSourceInstanceName,
        kFIRParameterAdUnitName:unitid,
        kFIRParameterAdPlatform:@"Admob"
    }];
    [FIRAnalytics logEventWithName:kFIREventAdImpression parameters:@{
        kFIRParameterValue:@(revenue.doubleValue),
        kFIRParameterCurrency:currencyCode,
        kFIRParameterAdSource:adSourceName,
        kFIRParameterAdFormat:adSourceInstanceName,
        kFIRParameterAdUnitName:unitid,
        kFIRParameterAdPlatform:@"Admob"
    }];
    
    //log taichi 3.0
    double currentImpressionRevenue = revenue.doubleValue;
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    
    float previousTaichiTroasCache = [settings floatForKey:@"TaichiTroasCache"]; //App本地存储用于累计tROAS的缓存值
    float currentTaichiTroasCache = (float) (previousTaichiTroasCache + currentImpressionRevenue);//累加tROAS的缓存值
    //check是否应该发送TaichitROAS事件
    if (currentTaichiTroasCache >= 0.01) {//如果超过0.01就触发一次tROAS taichi事件
        [self LogTaichiTroasFirebaseAdRevenueEvent:currentTaichiTroasCache];
        [settings setFloat:0 forKey:@"TaichiTroasCache"];//重新清零，开始 计算
    } else {
        [settings setFloat:currentTaichiTroasCache forKey:@"TaichiTroasCache"];//先存着直到超过0.01才发送
    }
    [settings synchronize];
#endif
}

- (void) LogTaichiTroasFirebaseAdRevenueEvent:(float)TaichiTroasCache {
#ifdef ENABLE_FIREBASE
    //(Required)tROAS事件必须带Double类型的Value
    //(Required)tROAS事件必须带Currency的币种，如果是USD的话，就写USD，如果不是USD，务必把其他币种换算成USD
    [FIRAnalytics logEventWithName:@"Total_Ads_Revenue_001" parameters:@{
        kFIRParameterValue:@(TaichiTroasCache),
        kFIRParameterCurrency:@"USD"
    }];
#endif
}

@end
