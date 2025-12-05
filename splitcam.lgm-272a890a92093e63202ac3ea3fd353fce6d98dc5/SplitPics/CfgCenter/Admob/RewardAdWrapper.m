//
//  RewardAdWrapper.m
//  Unity-iPhone
//
//  Created by 昭 陈 on 2019/3/18.
//

#import <Foundation/Foundation.h>
#import "CfgCenter.h"
#import "RewardAdWrapper.h"
#import "PriorityRewardAdWrapper.h"
#import <DTBiOSSDK/DTBiOSSDK.h>
#ifdef AD_ADMOB
#import "AdmobRewardAdWrapper.h"
#endif
#ifdef AD_FACEBOOK
#import "FacebookRewardAdWrapper.h"
#endif
#ifdef AD_APPLOVIN_MAX
#import "ApplovinMaxRewardWrapper.h"
#import "MaxApsAdLoaderCallback.h"
MaxApsAdLoaderCallback* rewardCallback;
#endif

@implementation RewardAdWrapper

+(RewardAdWrapper*) createAD:(NSDictionary*) config vc: (AdmobViewController*)vc {
    NSString* type = config[@"type"];
    RewardAdWrapper * ad = nil;
    
    if([type isEqualToString:@"priority"]) {
        ad = [self createPriorityAd: config vc:vc];
#ifdef AD_ADMOB
    } else if ([type isEqualToString:@"admob"]) {
        ad = [self createAdmobAd: config vc:vc];
#endif
#ifdef AD_FACEBOOK
    } else if ([type isEqualToString:@"facebook"]) {
        ad = [self createFacebookAd: config vc:vc];
#endif
#ifdef AD_APPLOVIN_MAX
    } else if ([type isEqualToString:@"maxwrap"]) {
        ad = [self createApplovinAd: config vc:vc];
#endif
    }
    
    return ad;
}

+(RewardAdWrapper*) createPriorityAd:(NSDictionary*) config vc: (AdmobViewController*)vc {
    
    NSArray* adlist = [config objectForKey:@"ads"];
    
    NSMutableArray* ads = [self createAdFromList:adlist vc:vc];
    
    if(ads.count == 0)
        return nil;
    
    PriorityRewardAdWrapper* sequence = [[PriorityRewardAdWrapper alloc] initWithRootView:vc adlist:ads];
    return sequence;
}

+(NSMutableArray*) createAdFromList:(NSArray*) config vc: (AdmobViewController*)vc {
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    
    for(int i=0; i<config.count; i++) {
        RewardAdWrapper* ad = [self createAD:config[i] vc: vc];
        if(ad != NULL) {
            [ret addObject:ad];
        }
    }
    return ret;
}

#ifdef AD_ADMOB
+(RewardAdWrapper*) createAdmobAd:(NSDictionary*) config vc: (AdmobViewController*)vc {
    NSString* adid = config[@"id"];
    
    if([adid length] == 0) {
        return nil;
    }
    
    AdmobRewardAdWrapper* admob = [[AdmobRewardAdWrapper alloc] initWithRootView:vc adid:adid];
    return admob;
}

#endif

#ifdef AD_FACEBOOK
+(RewardAdWrapper*) createFacebookAd:(NSDictionary*) config vc: (AdmobViewController*)vc {
    NSString* adid = config[@"id"];
    
    if([adid length] == 0) {
        return nil;
    }
    
    FacebookRewardAdWrapper* facebook = [[FacebookRewardAdWrapper alloc] initWithRootView:vc adid:adid];
    return facebook;
}
#endif

#ifdef AD_APPLOVIN_MAX
+(RewardAdWrapper*) createApplovinAd:(NSDictionary*) config vc: (AdmobViewController*)vc {
    NSString* adid = config[@"id"];
    
    if([adid length] == 0) {
        return nil;
    }
    
    ApplovinMaxRewardWrapper* applovin = [[ApplovinMaxRewardWrapper alloc] initWithRootView:vc adid:adid];
    if(rewardCallback == nil) {
        rewardCallback = [[MaxApsAdLoaderCallback alloc] init];
        [rewardCallback setAdType:3];
    }
    [rewardCallback addMaxaAdwardAdObj:applovin];
    return applovin;
}
#endif

-(void) init_reward_ad {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

//-(void) loadRewardAd {
//    @throw [NSException exceptionWithName:NSInternalInconsistencyException
//                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
//                                 userInfo:nil];
//}

/* 展示广告 */
-(BOOL) showRewardAd:(UIViewController*)viewController placeid:(int)place {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(BOOL) isRewardAdReady:(int)place {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

/* 删除广告 */
-(void)removeAllAds {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void) delayInitAfterNetworkFinish {
    
}

@end
