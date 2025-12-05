//
//  AdmobRewardVideoClient.h
//  Unity-iPhone
//
//  Created by 昭 陈 on 2017/12/11.
//

#ifndef AdmobVCDelegate_h
#define AdmobVCDelegate_h

#import <Foundation/Foundation.h>
#import "Admob.h"

typedef void (*AdmobVCDidReceiveInterstitialAdCallback)();
typedef void (*AdmobVCDidCloseInterstitialAdCallback)();
typedef void (*AdmobVCDidFailedToLoadInterstitialAdCallback)();
typedef void (*AdmobVCDidShowInterstitialAdCallback)();
typedef void (*AdmobVCDidClickInterstitialAdCallback)();

@interface AdmobVCDelegate : NSObject<AdmobViewControllerDelegate>

- (id) initWithCallbackReceive:(AdmobVCDidReceiveInterstitialAdCallback) didReceive
                         close:(AdmobVCDidCloseInterstitialAdCallback) didClose
                        failed:(AdmobVCDidFailedToLoadInterstitialAdCallback) didFailed
                          show:(AdmobVCDidShowInterstitialAdCallback) didShow
                         click:(AdmobVCDidClickInterstitialAdCallback) didClick;

@end

#endif /* AdmobVCDelegate_h */
