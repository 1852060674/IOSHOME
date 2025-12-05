//
//  AdmobRewardVideoDelegate.m
//  Unity-iPhone
//
//  Created by 昭 陈 on 2017/12/11.
//


#import "AdmobRewardVideoClient.h"
#import "CfgCenter.h"
#import "../Admob/Admob.h"

@implementation AdmobRewardVideoClient {
    AdmobRewardVideoAdDidReceiveAdCallback didReceiveAdCallback;
    AdmobRewardVideoAdDidFailToReceiveAdWithErrorCallback didFailToReceiveAdWithErrorCallback;
    AdmobRewardBasedVideoAdDidOpenCallback didOpenCallback;
    AdmobRewardBasedVideoAdDidStartPlayingCallback didStartPlayingCallback;
    AdmobRewardBasedVideoAdDidCloseCallback didCloseCallback;
    AdmobRewardBasedVideoAdWillLeaveApplicationCallback willLeaveApplicationCallback;
    AdmobRewardBasedVideoAdDidRewardUserWithRewardCallback didRewardUserWithRewardCallback;
}

- (id) initWithCallbackReceive:(AdmobRewardVideoAdDidReceiveAdCallback) didReceive
                          failed:(AdmobRewardVideoAdDidFailToReceiveAdWithErrorCallback) didFailed
                            open:(AdmobRewardBasedVideoAdDidOpenCallback) didOpen
                       startPlay:(AdmobRewardBasedVideoAdDidStartPlayingCallback) didStartPlay
                           close:(AdmobRewardBasedVideoAdDidCloseCallback) didClose
                           leave:(AdmobRewardBasedVideoAdWillLeaveApplicationCallback) willLeave
                          reward:(AdmobRewardBasedVideoAdDidRewardUserWithRewardCallback) didReward {
    self = [super init];
    didReceiveAdCallback = didReceive;
    didFailToReceiveAdWithErrorCallback = didFailed;
    didOpenCallback = didOpen;
    didStartPlayingCallback = didStartPlay;
    didCloseCallback = didClose;
    willLeaveApplicationCallback = willLeave;
    didRewardUserWithRewardCallback = didReward;
    return self;
}

- (void) load {
    //reward ad is auto loaded after initialize, there is no need load manually
//    [[AdmobViewController shareAdmobVC] loadRewardAd];
}

- (bool) isLoaded {
    return [[AdmobViewController shareAdmobVC] isRewardAdLoaded:0];
}

- (bool) show:(UIViewController*) view {
    if(![self isLoaded]) {
        return false;
    }
    
    return [[AdmobViewController shareAdmobVC] showRewardAd:view placeid:0];
}

- (void)RewardVideoAdDidClose:(RewardAdWrapper *)rewardad {
    if(didCloseCallback != nil) {
        didCloseCallback();
    }
}

- (void)RewardVideoAdDidOpen:(RewardAdWrapper *)rewardad {
    if(didOpenCallback != nil) {
        didOpenCallback();
    }
}

- (void)RewardVideoAdDidReceive:(RewardAdWrapper *)rewardad {
    if(didReceiveAdCallback != nil) {
        didReceiveAdCallback();
    }
}

- (void)RewardVideoAdDidRewardUserWithReward:(RewardAdWrapper *)rewardad rewardType:(NSString *)rewardtype amount:(double)rewardamount {
    if(didRewardUserWithRewardCallback != nil) {
        didRewardUserWithRewardCallback([rewardtype cStringUsingEncoding:NSUTF8StringEncoding],
                                        rewardamount);
    }
}

- (void)RewardVideoAdFailToReceivedWithError:(RewardAdWrapper *)rewardad error:(NSString *)error {
    if(didFailToReceiveAdWithErrorCallback != nil) {
        didFailToReceiveAdWithErrorCallback([error cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

- (void)RewardVideoAdWillLeaveApplication:(RewardAdWrapper *)rewardad {
    if(willLeaveApplicationCallback != nil) {
        willLeaveApplicationCallback();
    }
}

- (void)RewardVideoAdDidStartPlaying:(RewardAdWrapper *)rewardad {
    if(didStartPlayingCallback != nil) {
        didStartPlayingCallback();
    }
}


@end
