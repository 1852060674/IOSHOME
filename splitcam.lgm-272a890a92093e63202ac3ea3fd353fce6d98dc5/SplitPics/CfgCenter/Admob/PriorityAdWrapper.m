//
//  PriorityAdWrapper.m
//  version 3.3
//
//  Created by 昭 陈 on 16/6/6.
//  Copyright © 2016年 macbook. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Admob.h"
#import "PriorityAdWrapper.h"

@implementation PriorityAdWrapper
{
    NSMutableArray* adlist;
    int currentBannerShow;
    int currentNativeShow;
    
    int lastposx;
    int lastposy;
    UIView* currentBannerRoot;
    
    int lastNativeX;
    int lastNativeY;
    int lastNativeWidth;
    int lastNativeHeight;
    UIView* currentNativeRoot;
    
    NSString* curr_banner_placeid;
    NSString* curr_native_placeid;
}

@synthesize bannerReady = _bannerReady;
@synthesize nativeReady = _nativeReady;
@synthesize idx;

#pragma mark -
#pragma mark  admob init

- (id)initWithRootView:(AdmobViewController*) rootview BannerAd1:(ADWrapper* )bannerad1 BannerAd2:(ADWrapper* )bannerad2;
{
    self = [super init];
    
    if(self)
    {
        self.RootViewController = rootview;
        _bannerReady = AD_NOTSURPORT;
        currentBannerShow = -1;
        currentNativeShow = -1;
        
        adlist = [[NSMutableArray alloc] init];
        [adlist addObject:bannerad1];
        [adlist addObject:bannerad2];
        
        bannerad1.delegate = self;
        bannerad2.delegate = self;
        
        if(bannerad1.bannerReady == AD_NOTSURPORT && bannerad2.bannerReady == AD_NOTSURPORT) {
            _bannerReady = AD_NOTSURPORT;
        }
    }
    return self;
}

- (id)initWithRootView:(AdmobViewController*) rootview adlist:(NSArray* )ads
{
    self = [super init];
    
    if(self)
    {
        //add ads
        adlist = [[NSMutableArray alloc] init];
        self.RootViewController = rootview;
        _bannerReady = AD_NOTSURPORT;
        currentBannerShow = -1;
        currentNativeShow = -1;
        
        
        for(int i=0; i<ads.count; i++) {
            [adlist addObject:ads[i]];
            ((ADWrapper*)ads[i]).delegate = self;
            ((ADWrapper*)ads[i]).idx = i;
            
            if(((ADWrapper*)ads[i]).bannerReady != AD_NOTSURPORT) {
                _bannerReady = AD_NOTINIT;
            }
        }
    }
    
    return self;
}

- (void)dealloc
{
}

- (void) setBannerReady:(ADStatus)ready {
    //do nothing
}
//Getter method
- (ADStatus) bannerReady {
    if([adlist count] == 0
       || _bannerReady == AD_NOTSURPORT)
        return AD_NOTSURPORT;
    
    int firstinit = -1;
    int firstSuccessed = -1;
    for(int i =0; i < [adlist count]; i++)
    {
        ADStatus status = [[adlist objectAtIndex:i] bannerReady];
        if(status == AD_LOADED)
        {
            //有成功的ad 返回成功
            return AD_LOADED;
        }
        else if((status == AD_NOTINIT
                || status == AD_LOADING) && firstinit == -1)
            firstinit = i;
        if(firstSuccessed == -1 && [[adlist objectAtIndex:i] isBannerHaveSuccessBefore]) {
            firstSuccessed = i;
        }
    }
    
    if(firstinit != -1)
    {
        //有未初始化的ad，返回未初始化
        return AD_NOTINIT;
    }
    if(firstSuccessed != -1) {
        return AD_LOADED;
    }
    //都不成功，也没有未初始化的，返回不成功
    return AD_FAILED;
}

- (void) setNativeReady:(int)ready {
    //do nothing
}
//Getter method
- (int) nativeReady {
    if([adlist count] == 0)
        return 0;
    
    int firstinit = -1;
    for(int i =0; i < [adlist count]; i++)
    {
        int status = [[adlist objectAtIndex:i] nativeReady];
        if(status == 1)
        {
            //有成功的ad 返回成功
            return 1;
        }
        else if(status == -1 && firstinit == -1)
            firstinit = i;
    }
    
    if(firstinit != -1)
    {
        //有未初始化的ad，返回未初始化
        return -1;
    }
    //都不成功，也没有未初始化的，返回不成功
    return 0;
}

-(void) init_first_time {
    for(ADWrapper* ad in adlist)
    {
        [ad init_first_time];
    }
}

-(void)init_admob_banner
{
}

-(void) init_admob_banner:(float)width height:(float)height
{
}

-(void) init_admob_interstitial
{
    for(ADWrapper* ad in adlist)
    {
        [ad init_admob_interstitial];
    }
}

- (BOOL) hasBannerChildAd:(ADWrapper*) ad
{
    if(currentBannerShow >= 0 && currentBannerShow < adlist.count && ad == [adlist objectAtIndex:currentBannerShow])
        return TRUE;
    return FALSE;
}
- (BOOL) hasNativeChildAd:(ADWrapper*) ad
{
    if(currentNativeShow >= 0 && currentNativeShow < adlist.count && ad == [adlist objectAtIndex:currentNativeShow])
        return TRUE;
    return FALSE;
}

#pragma mark -
#pragma mark  admob banner


-(int) getFirstBannerAd
{
    if([adlist count] == 0
       || _bannerReady == AD_NOTSURPORT)
        return -1;
    
    int firstinit = -1;
    int firstsupport = -1;
    int firstSuccessedBefore = -1;
    double maxrevenue = -1;
    int maxrevenueIdx = -1;
    for(int i =0; i < [adlist count]; i++)
    {
        ADStatus status = [[adlist objectAtIndex:i] bannerReady];
        if(status == AD_LOADED)
        {
            double revenue = [[adlist objectAtIndex:i] getBannerRevenue];
            if(revenue > maxrevenue) {
                maxrevenue = revenue;
                maxrevenueIdx = i;
            }
        }
        else if((status == AD_NOTINIT || status == AD_LOADING) && firstinit == -1) {
            firstinit = i;
        }
        
        if([[adlist objectAtIndex:i] isBannerHaveSuccessBefore] && firstSuccessedBefore == -1) {
            firstSuccessedBefore = i;
        }
        
        if(status != AD_NOTSURPORT && firstsupport == -1) {
            firstsupport = i;
        }
    }
    
    if(maxrevenueIdx != -1) {
        NSLog(@"[ADUNION] idx %d -------Show Priority Banenr Ad %d, with revenue %.2f", idx, maxrevenueIdx, maxrevenue);
        return maxrevenueIdx;
    }
    
    if(firstinit != -1)
    {
        NSLog(@"[ADUNION] idx %d-------Show Priority Banner Ad %d", idx, firstinit);
        return firstinit;
    }
    if(firstSuccessedBefore != -1)
    {
        NSLog(@"[ADUNION] idx %d-------Show Priority Banner Ad %d [all failed & choose success before]", idx, firstSuccessedBefore);
        return firstSuccessedBefore;
    }
    
    if(firstsupport != -1) {
        NSLog(@"[ADUNION] idx %d-------Show Priority Banner Ad %d [all failed]", idx, firstsupport);
        return firstsupport;
    }
    return -1;
}

/* 显示banner, 所有的view公用一个banner实例，切换view的时候修改banner的父view */
-(void) show_admob_banner:(UIView*)view placeid:(NSString *)place
{
    int adidx = [self getFirstBannerAd];
    if(adidx < 0)
        return;
    
    [self remove_banner:view];
    if(currentBannerRoot != nil && currentBannerRoot != view)
        [self remove_banner:currentBannerRoot];
    
    curr_banner_placeid = place;
    
    ADWrapper* ad = adlist[adidx];
    currentBannerShow = adidx;
    [ad show_admob_banner:view placeid:place];
    
    lastposx = 0;
    lastposy = 0;
    currentBannerRoot = view;
    
    //update last ad's background status
    if(currentBannerShow != [adlist count]-1) {
        ADWrapper* lastad = adlist[[adlist count]-1];
        lastad->isBannerBackground = TRUE;
    }
    
    [self printCurrentBackgroundStatus];
}

-(void) setBannerAlign:(ADAlignment) align {
    for(int i=0;i<adlist.count;i++) {
        [adlist[i] setBannerAlign:align];
    }
}

#pragma mark -
#pragma mark  native
- (void)init_admob_native:(float)width height:(float)height
{
}

-(ADWrapper* ) getFirstNativeAd
{
    if([adlist count] == 0)
        return nil;
    
    int firstinit = -1;
    for(int i =0; i < [adlist count]; i++)
    {
        int status = [[adlist objectAtIndex:i] nativeReady];
        if(status == 1)
        {
            NSLog(@"[ADUNION] -------Show Priority Native Ad %d", i);
            currentNativeShow = i;
            return [adlist objectAtIndex:i];
        }
        else if(status == -1 && firstinit == -1)
            firstinit = i;
    }
    
    if(firstinit != -1)
    {
        NSLog(@"[ADUNION] -------Show Priority Ad Native %d", firstinit);
        currentNativeShow = firstinit;
        return [adlist objectAtIndex:firstinit];
    }
    return [adlist objectAtIndex:0];
}

-(void)show_admob_native:(float)posx posy:(float)posy width:(float)width height:(float)height view:(UIView *)view placeid:(NSString *)place
{
    ADWrapper* ad = [self getFirstNativeAd];
    
    [self remove_native:view];
    if(currentNativeRoot != nil && currentNativeRoot != view)
        [self remove_native:currentNativeRoot];
    
    curr_native_placeid = place;
    
    [ad show_admob_native:posx posy:posy width:width height:height view:view placeid:place];
    
    lastNativeX = posx;
    lastNativeY = posy;
    lastNativeWidth = width;
    lastNativeHeight = height;
    currentNativeRoot = view;
}

#pragma mark -
#pragma mark  admob interstitial

-(ADWrapper* ) getFirstInterstitialAd:(int) place
{
    if([adlist count] == 0)
        return nil;
    
    for(int i =0; i < [adlist count]; i++)
    {
        if([[adlist objectAtIndex:i] admob_interstial_ready:place])
        {
            NSLog(@"[ADUNION] -------Show Priority Inter Ad %d", i);
            return [adlist objectAtIndex:i];
        }
    }
    return nil;
}


-(BOOL) show_admob_interstitial:(UIViewController*)viewController placeid:(int)place
{
    ADWrapper* ad = [self getFirstInterstitialAd:place];
    if(ad != nil)
        return [ad show_admob_interstitial:viewController placeid:place];
    return NO;
}

-(BOOL) admob_interstial_ready:(int)place
{
    for(int i =0; i < [adlist count]; i++)
    {
        if([[adlist objectAtIndex:i] admob_interstial_ready:place])
            return TRUE;
    }
    return FALSE;
}


#pragma mark -
#pragma mark  admob remove

-(void)remove_all_ads:(UIView *)rootView
{
    if(rootView == currentBannerRoot)
        currentBannerRoot = nil;
    if(rootView == currentNativeRoot)
        currentNativeRoot = nil;
    for(ADWrapper* ad in adlist)
    {
        [ad remove_all_ads:rootView];
    }
}

-(void)remove_banner:(UIView*)rootView
{
    if(rootView == currentBannerRoot)
        currentBannerRoot = nil;
    for(ADWrapper* ad in adlist)
    {
        [ad remove_banner:rootView];
    }
    
    //如果所有banner均失败，至少保留一个banner为前台banner刷新
    if([self bannerReady] != AD_LOADED && [adlist count]>0) {
        ADWrapper* ad = adlist[[adlist count]-1];
        ad->isBannerBackground = FALSE;
    }
    
    [self printCurrentBackgroundStatus];
}

-(void)remove_native:(UIView *)rootView
{
    if(rootView == currentNativeRoot)
        currentNativeRoot = nil;
    for(ADWrapper* ad in adlist)
    {
        [ad remove_native:rootView];
    }
}

#pragma mark -
#pragma mark AdWrapper delegate

-(void) interstitialDidReceiveAd {
    if(self.delegate != NULL)
       [self.delegate interstitialDidReceiveAd];
}

-(BOOL) interstitialDidDismissScreen {
    if(self.delegate != NULL)
        return [self.delegate interstitialDidDismissScreen];
    else
        return TRUE;
}

-(void) interstitialWillDismissScreen {
    if(self.delegate != NULL)
        [self.delegate interstitialWillDismissScreen];
}

-(void)interstitialDidFailed
{
    if (self.delegate != NULL) {
        [self.delegate interstitialDidFailed];
    }
}

-(void)interstitialDidShow
{
    if (self.delegate != NULL) {
        [self.delegate interstitialDidShow];
    }
}

-(void)interstitialDidClick
{
    if (self.delegate != NULL) {
        [self.delegate interstitialDidClick];
    }
}

-(void) bannerDidLoaded:(ADWrapper *)banner {
    //switch ad to show
    [self switchToNextBanner];
    
    //update last ad's background status
    if(currentBannerShow != [adlist count]-1) {
        ADWrapper* lastad = adlist[[adlist count]-1];
        lastad->isBannerBackground = TRUE;
    }
    
    if(self.delegate != NULL)
        [self.delegate bannerDidLoaded:self];
    
    [self printCurrentBackgroundStatus];
}

-(void) bannerDidFailedLoad:(ADWrapper *)banner error:(NSError*) error
{
    if(currentBannerShow < 0) {
        return;
    }
    if(banner == adlist[currentBannerShow]) {
        ADStatus currStatus = [self bannerReady];
        if(currStatus != AD_NOTSURPORT) {
            [self switchToNextBanner];
        } else if( self.delegate != NULL) {
            [self.delegate bannerDidFailedLoad:self error:error];
        }
    }
}

- (void)bannerDidClick:(ADWrapper *)banner {
    if( self.delegate != NULL) {
        [self.delegate bannerDidClick:self];
    }
}


-(void) nativeDidFailedLoad:(ADWrapper *)native error:(NSError*) error
{
    if(currentNativeShow < 0) {
        return;
    }
    if(native == adlist[currentNativeShow]) {
        if ([self nativeReady] != 0) {
            [self switchToNextNative];
        } else if( self.delegate != NULL) {
            [self.delegate nativeDidFailedLoad:self error:error];
        }
    }
}

-(void)switchToNextBanner {
    int adidx = [self getFirstBannerAd];
    if(adidx < 0) {
        return;
    }
    
    if(currentBannerRoot != nil) {
        //已经显示当前ad，就不再重新显示
        if(currentBannerShow == adidx) {
            ADWrapper* oldad = adlist[currentBannerShow];
            [oldad updateImpression:currentBannerRoot];
            return;
        }
        
        if(currentBannerShow >= 0) {
            ADWrapper* oldad = adlist[currentBannerShow];
            [oldad remove_banner:currentBannerRoot];
        }
        
        ADWrapper* ad = adlist[adidx];
        currentBannerShow = adidx;
        [ad show_admob_banner:currentBannerRoot placeid:curr_banner_placeid];
    } else {
        currentBannerShow = -1;
    }
    
    [self printCurrentBackgroundStatus];
}

-(void) printCurrentBackgroundStatus {
    NSMutableString* str = [NSMutableString string];
    int forecount = 0;
    for(int i =0; i < [adlist count]; i++)
    {
        ADWrapper* ad = adlist[i];
        if(!ad->isBannerBackground) {
            [str appendString:[NSString stringWithFormat:@"%d,", i]];
            forecount ++;
        }
    }
    NSLog(@"[ADUNION] Banner count %ld, %d个前台:%@", [adlist count], forecount, str);
    
}

-(void)switchToNextNative {
    ADWrapper* ad = [self getFirstNativeAd];
    [ad show_admob_native:lastNativeX posy:lastNativeY width:lastNativeWidth height:lastNativeHeight view:currentNativeRoot placeid:curr_native_placeid];
}


- (void) delayInitAfterNetworkFinish {
    for(ADWrapper* ad in adlist) {
        [ad delayInitAfterNetworkFinish];
    }
}

@end
