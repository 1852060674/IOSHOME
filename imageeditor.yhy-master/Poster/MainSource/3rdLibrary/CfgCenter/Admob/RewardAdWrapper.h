//
//  RewardAdWrapper.h
//  Unity-iPhone
//
//  Created by 昭 陈 on 2019/3/18.
//

#ifndef RewardAdWrapper_h
#define RewardAdWrapper_h

@class AdmobViewController;
@class RewardAdWrapper;

@protocol RewardAdWrapperDelegate <NSObject>

//reward ad wrapper回调的函数
- (void) RewardVideoAdDidReceive:(RewardAdWrapper*) rewardad;
- (void) RewardVideoAdFailToReceivedWithError:(RewardAdWrapper*) rewardad error:(NSString*)error;
- (void) RewardVideoAdDidOpen:(RewardAdWrapper*) rewardad;
- (void) RewardVideoAdDidStartPlaying:(RewardAdWrapper*) rewardad;
- (void) RewardVideoAdDidClose:(RewardAdWrapper*) rewardad;
- (void) RewardVideoAdWillLeaveApplication:(RewardAdWrapper*) rewardad;
- (void) RewardVideoAdDidRewardUserWithReward:(RewardAdWrapper*) rewardad rewardType:(NSString*) rewardtype amount:(double) rewardamount;

@end

@interface RewardAdWrapper : NSObject

+(RewardAdWrapper*) createAD:(NSDictionary*) config vc: (AdmobViewController*)vc;

@property (nonatomic, retain) AdmobViewController* RootViewController;

@property (nonatomic, retain) id<RewardAdWrapperDelegate> delegate;

-(void) init_reward_ad;

/* 加载广告 */
//-(void) loadRewardAd;

/* 展示广告 */
-(BOOL) showRewardAd:(UIViewController*)viewController placeid:(int)place;
-(BOOL) isRewardAdReady:(int)place;

/* 删除广告 */
-(void)removeAllAds;

- (void) delayInitAfterNetworkFinish;

@end

#endif /* RewardAdWrapper_h */
