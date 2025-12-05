//
//  PriorityRewardAdWrapper.m
//  Unity-iPhone
//
//  Created by 昭 陈 on 2019/3/18.
//

#import <Foundation/Foundation.h>
#import "PriorityRewardAdWrapper.h"
#import "AdmobRewardAdWrapper.h"

@implementation PriorityRewardAdWrapper {
    NSMutableArray* adlist;
}

@synthesize delegate;

- (id)initWithRootView:(AdmobViewController*) rootview adlist:(NSArray* )ads {
    self = [super init];
    
    if(self)
    {
        //add ads
        adlist = [[NSMutableArray alloc] init];
        self.RootViewController = rootview;
        
        for(int i=0; i<ads.count; i++) {
            [adlist addObject:ads[i]];
            ((RewardAdWrapper*)ads[i]).delegate = self;
        }
    }
    
    return self;
}

-(void) init_reward_ad {
    for(RewardAdWrapper* ad in adlist)
    {
        [ad init_reward_ad];
    }
}

/* 加载广告 */
//-(void) loadRewardAd {
//    for(RewardAdWrapper* ad in adlist)
//    {
//        [ad loadRewardAd];
//    }
//}

-(RewardAdWrapper* ) getFirstRewardAd:(int) place
{
    if([adlist count] == 0)
        return nil;
    
    for(int i =0; i < [adlist count]; i++)
    {
        if([[adlist objectAtIndex:i] isRewardAdReady:place])
        {
            NSLog(@"[ADUNION] -------Show Priority Reward Ad %d", i);
            return [adlist objectAtIndex:i];
        }
    }
    return nil;
}

/* 展示广告 */
-(BOOL) showRewardAd:(UIViewController*)viewController placeid:(int)place {
    RewardAdWrapper* ad = [self getFirstRewardAd:place];
    if(ad != nil)
        return [ad showRewardAd:viewController placeid:place];
    return NO;
}

-(BOOL) isRewardAdReady:(int)place {
    for(int i =0; i < [adlist count]; i++)
    {
        if([[adlist objectAtIndex:i] isRewardAdReady:place])
            return TRUE;
    }
    return FALSE;
}

/* 删除广告 */
-(void)removeAllAds {
    for(RewardAdWrapper* ad in adlist)
    {
        [ad removeAllAds];
    }
}

- (void) delayInitAfterNetworkFinish {
    for(RewardAdWrapper* ad in adlist) {
        [ad delayInitAfterNetworkFinish];
    }
}

#pragma mark -
#pragma mark RewardAdWrapperDelegate

- (void)RewardVideoAdDidClose:(RewardAdWrapper*) rewardad {
    if(delegate != nil) {
        [delegate RewardVideoAdDidClose: rewardad];
    }
}

- (void)RewardVideoAdDidOpen:(RewardAdWrapper*) rewardad {
    if(delegate != nil) {
        [delegate RewardVideoAdDidOpen: rewardad];
    }
}

- (void)RewardVideoAdDidReceive:(RewardAdWrapper*) rewardad {
    if(delegate != nil) {
        [delegate RewardVideoAdDidReceive: rewardad];
    }
}

- (void)RewardVideoAdDidRewardUserWithReward:(RewardAdWrapper*) rewardad rewardType:(NSString *)rewardtype amount:(double)rewardamount {
    if(delegate != nil) {
        [delegate RewardVideoAdDidRewardUserWithReward: rewardad rewardType:rewardtype amount: rewardamount];
    }
}

- (void)RewardVideoAdFailToReceivedWithError:(RewardAdWrapper*) rewardad error:(NSString *)error {
    if(delegate != nil) {
        [delegate RewardVideoAdFailToReceivedWithError: rewardad error:error];
    }
}

- (void)RewardVideoAdWillLeaveApplication:(RewardAdWrapper*) rewardad {
    if(delegate != nil) {
        [delegate RewardVideoAdWillLeaveApplication: rewardad];
    }
}

- (void)RewardVideoAdDidStartPlaying:(RewardAdWrapper *)rewardad {
    if(self.delegate) {
        [self.delegate RewardVideoAdDidStartPlaying:rewardad];
    }
}

@end
