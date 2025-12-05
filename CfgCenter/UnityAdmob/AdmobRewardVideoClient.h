//
//  AdmobRewardVideoClient.h
//  Unity-iPhone
//
//  Created by 昭 陈 on 2017/12/11.
//

#ifndef AdmobRewardVideoClient_h
#define AdmobRewardVideoClient_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../Admob/RewardAdWrapper.h"

typedef void (*AdmobRewardVideoAdDidReceiveAdCallback)();
typedef void (*AdmobRewardVideoAdDidFailToReceiveAdWithErrorCallback)(const char* error);
typedef void (*AdmobRewardBasedVideoAdDidOpenCallback)();
typedef void (*AdmobRewardBasedVideoAdDidStartPlayingCallback)();
typedef void (*AdmobRewardBasedVideoAdDidCloseCallback)();
typedef void (*AdmobRewardBasedVideoAdWillLeaveApplicationCallback)();
typedef void (*AdmobRewardBasedVideoAdDidRewardUserWithRewardCallback)(const char *rewardType, double rewardAmount);


@interface AdmobRewardVideoClient : NSObject<RewardAdWrapperDelegate>

- (id) initWithCallbackReceive:(AdmobRewardVideoAdDidReceiveAdCallback) didReceive
                          failed:(AdmobRewardVideoAdDidFailToReceiveAdWithErrorCallback) didFailed
                          open:(AdmobRewardBasedVideoAdDidOpenCallback) didOpen
                       startPlay:(AdmobRewardBasedVideoAdDidStartPlayingCallback) didStartPlay
                           close:(AdmobRewardBasedVideoAdDidCloseCallback) didClose
                           leave:(AdmobRewardBasedVideoAdWillLeaveApplicationCallback) willLeave
                          reward:(AdmobRewardBasedVideoAdDidRewardUserWithRewardCallback) didReward;

- (void) load;
- (bool) isLoaded;
- (bool) show:(UIViewController*) view;

@end



#endif /* AdmobRewardVideoDelegate_h */
