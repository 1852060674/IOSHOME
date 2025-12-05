//
//  AdCenter.m
//  version 3.3
//
//  Created by 昭 陈 on 2016/11/24.
//  Copyright © 2016年 昭 陈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SequenceAdWrapper.h"

@implementation SequenceAdWrapper {
    NSMutableArray* adlist;
    
    int currbanner;
    int currinter;
    int currnative;
    
    UIView* currentBannerRoot;
    UIView* currentNativeRoot;
    
    //异步banner更新
    NSInteger lastbannertime;
    NSInteger lastnativetime;
    BOOL exit;
    
    NSString* curr_banner_placeid;
    NSString* curr_native_placeid;
}

@synthesize RootViewController;
@synthesize bannerReady = _bannerReady;
@synthesize nativeReady = _nativeReady;
@synthesize idx;

-(id) init
{
    self = [super init];
    
    adlist = [[NSMutableArray alloc] init];
    currbanner = -1;
    currinter = -1;
    currnative = -1;
    
    return self;
}

- (id)initWithRootView:(AdmobViewController*) rootview AdWrap:(ADWrapper* )ad, ...
{
    self = [super init];
    
    if(self)
    {
        //add ads
        adlist = [[NSMutableArray alloc] init];
        _bannerReady = AD_NOTSURPORT;
        currbanner = -1;
        currinter = -1;
        currnative = -1;
        
        [adlist addObject:ad];
        
        ADWrapper* objAd;
        va_list arg_list;
        va_start(arg_list, ad);
        while ((objAd = va_arg(arg_list, ADWrapper*))) {
            [adlist addObject:objAd];
            objAd.delegate = self;
            
            if(objAd.bannerReady != AD_NOTSURPORT) {
                _bannerReady = AD_NOTINIT;
            }
        }
        va_end(arg_list);
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
        _bannerReady = AD_NOTSURPORT;
        currbanner = -1;
        currinter = -1;
        currnative = -1;
        
        for(int i=0; i<ads.count; i++) {
            [adlist addObject:ads[i]];
            ((ADWrapper*)ads[i]).delegate = self;
            
            if(((ADWrapper*)ads[i]).bannerReady != AD_NOTSURPORT) {
                _bannerReady = AD_NOTINIT;
            }
        }
    }
    
    return self;
}

- (void)dealloc
{
    exit = true;
}


- (BOOL) hasBannerChildAd:(ADWrapper*) ad
{
    if(currbanner >= 0 && currnative < adlist.count && ad == [adlist objectAtIndex:currbanner])
        return YES;
    return NO;
}

- (BOOL) hasNativeChildAd:(ADWrapper*) ad
{
    if(currnative >= 0 && currnative < adlist.count && ad == [adlist objectAtIndex:currnative])
        return YES;
    return NO;
}

#pragma mark -
#pragma mark Properties

- (void) setBannerReady:(ADStatus)ready {
}
//Getter method
- (ADStatus) bannerReady {
    if([adlist count] == 0 || _bannerReady == AD_NOTSURPORT)
        return AD_NOTSURPORT;
    
    int firstinit = -1;
    for(int i =0; i < [adlist count]; i++)
    {
        ADStatus status = [[adlist objectAtIndex:i] bannerReady];
        if(status == AD_LOADED)
        {
            //有成功的ad 返回成功
            return AD_LOADED;
        }
        else if((status == AD_NOTINIT || status == AD_LOADING) && firstinit == -1) {
            firstinit = i;
        }
    }
    
    if(firstinit != -1)
    {
        //有未初始化的ad，返回未初始化
        return AD_NOTINIT;
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

#pragma mark -
#pragma mark ADWrapper

-(void) init_first_time {
    for(ADWrapper* ad in adlist)
    {
        [ad init_first_time];
    }
}

-(void) init_admob_banner {
    
}
-(void) init_admob_banner:(float)width height:(float)height {
    
}
-(void) init_admob_interstitial {
    for(ADWrapper* ad in adlist)
    {
        [ad init_admob_interstitial];
    }

    //auto switch banner
    if([adlist count] > 1)
        [self startAsyncBannerSwitch];
}

-(void) init_admob_native:(float)width height:(float)height {
    
}

/* 显示banner, 所有的view公用一个banner实例，切换view的时候修改banner的父view */
-(void) show_admob_banner:(UIView*)view placeid:(NSString *)place {
    if([adlist count] == 0)
        return;
    
    if(currbanner == -1)
        currbanner = [self getNextBanner];
    
    [self remove_banner:view];
    if(currentBannerRoot != nil && currentBannerRoot != view)
        [self remove_banner:currentBannerRoot];
    
    curr_banner_placeid = place;
    
    [[adlist objectAtIndex:currbanner] show_admob_banner:view placeid:place];
    
    currentBannerRoot = view;
}

-(void) setBannerAlign:(ADAlignment) align {
    for(int i=0;i<adlist.count;i++) {
        [adlist[i] setBannerAlign:align];
    }
}

/* 显示原生广告 */
-(void) show_admob_native:(float)posx posy:(float)posy width:(float)width height:(float)height view:(UIView*)view placeid:(NSString *)place{
    if([adlist count] == 0)
        return;
    
    if(currnative == -1)
        currnative = [self getNextNative];
    
    [self remove_native:view];
    if(currentNativeRoot != nil && currentNativeRoot != view)
        [self remove_native:currentNativeRoot];
    
    [[adlist objectAtIndex:currnative] show_admob_native:posx posy:posy width:width height:height view:view placeid:place];
    
    lastnativetime = [[NSDate date] timeIntervalSince1970];
    
    currentNativeRoot = view;
    curr_native_placeid = place;
}

/* 展示全屏 */
-(BOOL) show_admob_interstitial:(UIViewController*)viewController placeid:(int)place {
    currinter = [self getNextInter:place];
    if(currinter != -1)
    {
        return [[adlist objectAtIndex:currinter] show_admob_interstitial:viewController placeid:place];
    }
    return NO;
}

-(BOOL) admob_interstial_ready:(int) place{
    for(ADWrapper* ad in adlist)
    {
        if([ad admob_interstial_ready: place])
            return YES;
    }
    return NO;
}

/* 删除banner和全屏 */
-(void)remove_all_ads:(UIView *)rootView {
    if(rootView == currentBannerRoot)
        currentBannerRoot = nil;
    if(rootView == currentNativeRoot)
        currentNativeRoot = nil;
    for(ADWrapper* ad in adlist)
    {
        [ad remove_all_ads:rootView];
    }
}
-(void)remove_banner:(UIView*)rootView {
    if(rootView == currentBannerRoot)
        currentBannerRoot = nil;
    for(ADWrapper* ad in adlist)
    {
        [ad remove_banner:rootView];
    }
}
-(void)remove_native:(UIView*)rootView {
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

-(void) bannerDidLoaded:(ADWrapper*) banner {
    
}

-(void)bannerDidFailedLoad:(ADWrapper *)banner error:(NSError*) error
{
    if(currbanner < 0) {
        return;
    }
    if(banner == [adlist objectAtIndex:currbanner])
    {
        NSLog(@"Current Banner Failed");
        //switch to next
        [self switchToNextBanner];
    } else if(self.delegate != NULL) {
        [self.delegate bannerDidFailedLoad:self error:error];
    }
}

-(void) nativeDidFailedLoad:(ADWrapper *)native error:(NSError*) error
{
    if(currnative < 0) {
        return;
    }
    if(native == [adlist objectAtIndex:currnative])
    {
        NSLog(@"Current Native Failed");
        //switch to next
        [self switchToNextNative];
    } else if(self.delegate != NULL) {
        [self.delegate nativeDidFailedLoad:self error:error];
    }
}

#pragma mark -
#pragma mark auto switch

-(void) startAsyncBannerSwitch
{
    exit = FALSE;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        while(!exit)
        {
            //wait 30s
            [NSThread sleepForTimeInterval:10.0];
            NSInteger now = [[NSDate date] timeIntervalSince1970];
            if(now - lastbannertime > 20)
            {
                if(currentBannerRoot != nil && !currentBannerRoot.isHidden && currentBannerRoot.superview != nil)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"Banner Switch");
                        [self switchToNextBanner];
                    });
                }
            }
            
            if(now - lastnativetime > 20)
            {
                if(currentNativeRoot != nil && !currentNativeRoot.isHidden && currentNativeRoot.superview != nil)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"Native Switch");
                        [self switchToNextNative];
                    });
                }
            }
        }
    });
}

-(void) switchToNextBanner
{
    if([adlist count] == 0)
        return;
    
    currbanner = [self getNextBanner];
    
    [self remove_banner:currentBannerRoot];
    
    [[adlist objectAtIndex:currbanner] show_admob_banner:currentBannerRoot placeid:curr_banner_placeid];
    
    lastbannertime = [[NSDate date] timeIntervalSince1970];
}

-(int) getNextBanner
{
    if([adlist count] == 0)
        return -1;
    
    int nextbanner = currbanner+1;
    nextbanner = nextbanner % [adlist count];
    int start = nextbanner;
    
    while (TRUE) {
        ADStatus status = [[adlist objectAtIndex:nextbanner] bannerReady];
        if(status != AD_FAILED && status != AD_NOTSURPORT)
        {
            return nextbanner;
        }
        nextbanner ++;
        nextbanner = nextbanner % [adlist count];
        
        if(nextbanner == start)
        {
            return nextbanner;
        }
    }
}

-(void) switchToNextNative
{
    if([adlist count] == 0)
        return;
    
    int newnative = [self getNextNative];
    //    if(newnative == currnative)
    //        return;
    currnative = newnative;
    
    [self remove_native:currentNativeRoot];
    
    [[adlist objectAtIndex:currnative] show_admob_native:0 posy:0 width:0 height:0 view:currentNativeRoot placeid:curr_native_placeid];
    
    lastnativetime = [[NSDate date] timeIntervalSince1970];
}

-(int) getNextNative
{
    if([adlist count] == 0)
        return -1;
    
    int nextnative = currnative+1;
    nextnative = nextnative % [adlist count];
    int start = nextnative;
    
    while (TRUE) {
        if([[adlist objectAtIndex:nextnative] nativeReady] != 0)
        {
            return nextnative;
        }
        nextnative ++;
        nextnative = nextnative % [adlist count];
        
        if(nextnative == start)
        {
            return nextnative;
        }
    }
}

-(int) getNextInter:(int) place
{
    if([adlist count] == 0)
        return -1;
    
    int nextinter = currinter+1;
    nextinter = nextinter % [adlist count];
    int start = nextinter;
    
    while (TRUE) {
        if([[adlist objectAtIndex:nextinter] admob_interstial_ready: place])
        {
            return nextinter;
        }
        nextinter ++;
        nextinter = nextinter % [adlist count];
        
        if(nextinter == start)
        {
            return -1;
        }
    }
}


@end
