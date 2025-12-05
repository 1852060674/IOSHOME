//
//  AdmobOpenAdWrapper.m
//  Unity-iPhone
//
//  Created by 昭 陈 on 2025/10/18.
//

#import <Foundation/Foundation.h>
#import "CfgCenter.h"
#import "AdmobOpenAdWrapper.h"

#if defined(LOG_USER_ACTION) || defined(ENABLE_FIREBASE_ADIMP)
#import "Firebase.h"
#endif

#ifdef ENABLE_ADJUST
#import <AdjustSdk/AdjustSdk.h>
#endif

@implementation AdmobOpenAdWrapper
{
    NSString* ad_id;
    
    GADAppOpenAd * openAd;
    
    int curr_ad_place;
    
    int adRetryCount;
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
        ad_id = adid;
        curr_ad_place = 0;
    }
    return self;
}

- (void)dealloc
{
    openAd.fullScreenContentDelegate = nil;
    openAd.paidEventHandler = nil;
    openAd = nil;
}

-(GADRequest*) getADRequest {
    GADRequest* request = [GADRequest request];
//    request.testDevices = @[ kGADSimulatorID ];
    return request;
}

-(void) init_ad {
    if(openAd != nil) {
        openAd.fullScreenContentDelegate = nil;
        openAd.paidEventHandler = nil;
        openAd = nil;
    }
    
    if([ad_id isEqualToString:@""])
        return;
    
    adRetryCount = 0;
    [self _adReload];
}

#pragma mark -
#pragma mark  admob open

-(BOOL) showAd:(UIViewController*)viewController placeid:(int)place
{
    // 当广告还没就绪的时候，不增加显示次数
    if (openAd != NULL) {
        curr_ad_place = place;
        
        [openAd presentFromRootViewController:viewController];
        NSLog(@"[ADUNION] Show Admob open Ad :%@", ad_id);
        
#ifdef LOG_USER_ACTION
        [FIRAnalytics logEventWithName:[self adPosition] parameters:@{@"id": ad_id, @"status": @"show"}];
#endif
        isshowing = true;
        return YES;
    }
    
    return NO;
}

-(BOOL) isAdReady:(int)place
{
    if(openAd != NULL)
        return YES;
    
    if(!isloading && !isshowing)
    {
        [self _adReload];
    }
    return FALSE;
}

-(void) _adReload {
    isloading = true;
    isshowing = false;

    [GADAppOpenAd loadWithAdUnitID:ad_id request:[self getADRequest] completionHandler:^(GADAppOpenAd *ad, NSError *error) {
            if (error) {
                NSLog(@"[ADUNION] Admob open ad failed to load with error: %@", [error localizedDescription]);
                if(self.delegate) {
                    [self.delegate AdFailToReceivedWithError:self error:[error localizedFailureReason]];
                }
                
            #ifdef LOG_USER_ACTION
                [FIRAnalytics logEventWithName:[self adPosition] parameters:@{@"id": self->ad_id, @"status": @"failed"}];
            #endif
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(self->adRetryCount < 3) {
                        self->adRetryCount++;
                        [self _adReload];
                        
                        NSLog(@"[ADUNION] retry admob open ad %d!", self->adRetryCount);
                    }
                    else {
                        self->adRetryCount = 0;
                        self->isloading = false;
                    }
                });
                
                return;
            } else {
                self->adRetryCount = 0;
                self->isloading = false;
            
                self->openAd = ad;
                self->openAd.fullScreenContentDelegate = self;
                
                __weak AdmobOpenAdWrapper *weakSelf = self;
                self->openAd.paidEventHandler = ^(GADAdValue * _Nonnull advalue) {
                    AdmobOpenAdWrapper *strongSelf = weakSelf;
                    // Extract the impression-level ad revenue data.
                    NSDecimalNumber *value = advalue.value;
                    NSString *currencyCode = advalue.currencyCode;
                    
                    [strongSelf logPaidAdRevenue:value currency:currencyCode responseInfo:strongSelf->openAd.responseInfo.loadedAdNetworkResponseInfo unitId:strongSelf->ad_id];
                };
                
                if(self.delegate) {
                    [self.delegate AdDidReceive:self];
                }
            
                
                NSLog(@"[ADUNION] admob open ad ready, wait to show!");
            #ifdef LOG_USER_ACTION
                [FIRAnalytics logEventWithName:[self adPosition] parameters:@{@"id": self->ad_id, @"status": @"loaded"}];
            #endif
            }
        }];
#ifdef LOG_USER_ACTION
    [FIRAnalytics logEventWithName:[self adPosition] parameters:@{@"id": ad_id, @"status": @"load"}];
#endif
}

#pragma mark -
#pragma mark admob delegate

- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
#ifdef LOG_USER_ACTION
    [FIRAnalytics logEventWithName:[self adPosition] parameters:@{@"id": ad_id, @"status": @"show"}];
#endif
    
    if(self.delegate) {
        [self.delegate AdDidOpen:self];
    }
}

/// Tells the delegate that a click has been recorded for the ad.
- (void)adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>)ad {
#ifdef LOG_USER_ACTION
    [FIRAnalytics logEventWithName:[self adPosition] parameters:@{@"id": ad_id, @"status": @"click"}];
#endif

    if(self.delegate) {
        [self.delegate AdWillLeaveApplication:self];
    }
}

/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    openAd = nil;
    
    if(self.delegate) {
        [self.delegate AdDidClose:self];
    }
    isshowing = false;
    
#ifdef LOG_USER_ACTION
    [FIRAnalytics logEventWithName:[self adPosition] parameters:@{@"id": ad_id, @"status": @"closed"}];
#endif
    
    [self init_ad];
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    openAd = nil;
    if(self.delegate) {
        [self.delegate AdDidClose:self];
    }
    isshowing = false;
    
#ifdef LOG_USER_ACTION
    [FIRAnalytics logEventWithName:[self adPosition] parameters:@{@"id": ad_id, @"status": @"closed"}];
#endif
    
    [self init_ad];
}

- (NSString *) adPosition {
    return [NSString stringWithFormat:@"OpenAd%d", curr_ad_place];
}

- (void) logPaidAdRevenue:(NSDecimalNumber*)revenue currency:(NSString*) currencyCode responseInfo:(GADAdNetworkResponseInfo*) info unitId:(NSString*)unitid {
    NSString *adSourceName = info.adSourceName;
    NSString *adSourceInstanceName = info.adSourceInstanceName;
#ifdef ENABLE_ADJUST
    ADJAdRevenue *adRevenue = [[ADJAdRevenue alloc] initWithSource:@"admob_sdk"];
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
    
    
#ifdef ENABLE_FIREBASE_ADIMP
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
#ifdef ENABLE_FIREBASE_ADIMP
    //(Required)tROAS事件必须带Double类型的Value
    //(Required)tROAS事件必须带Currency的币种，如果是USD的话，就写USD，如果不是USD，务必把其他币种换算成USD
    [FIRAnalytics logEventWithName:@"Total_Ads_Revenue_001" parameters:@{
        kFIRParameterValue:@(TaichiTroasCache),
        kFIRParameterCurrency:@"USD"
    }];
#endif
}

@end
