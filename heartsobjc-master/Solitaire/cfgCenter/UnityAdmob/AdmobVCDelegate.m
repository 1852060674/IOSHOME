//
//  AdmobRewardVideoDelegate.m
//  Unity-iPhone
//
//  Created by 昭 陈 on 2017/12/11.
//


#import "AdmobVCDelegate.h"
#import "CfgCenter.h"

@implementation AdmobVCDelegate {
    AdmobVCDidReceiveInterstitialAdCallback didReceiveCallback;
    AdmobVCDidCloseInterstitialAdCallback didCloseCallback;
    AdmobVCDidFailedToLoadInterstitialAdCallback didFailedCallback;
    AdmobVCDidShowInterstitialAdCallback didShowCallback;
    AdmobVCDidClickInterstitialAdCallback didClickCallback;
}

- (id) initWithCallbackReceive:(AdmobVCDidReceiveInterstitialAdCallback) didReceive
                         close:(AdmobVCDidCloseInterstitialAdCallback) didClose
                        failed:(AdmobVCDidFailedToLoadInterstitialAdCallback) didFailed
                          show:(AdmobVCDidShowInterstitialAdCallback) didShow
                         click:(AdmobVCDidClickInterstitialAdCallback) didClick;{
    self = [super init];
    didReceiveCallback = didReceive;
    didCloseCallback = didClose;
    didFailedCallback = didFailed;
    didShowCallback = didShow;
    didClickCallback = didClick;
    return self;
}

-(void)adMobVCDidReceiveInterstitialAd:(AdmobViewController*)adMobVC {
    if(didReceiveCallback != nil) {
        didReceiveCallback();
    }
}

-(void) adMobVCWillCloseInterstitialAd:(AdmobViewController *)adMobVC {
    
}

-(void)adMobVCDidCloseInterstitialAd:(AdmobViewController*)adMobVC {
    if(didCloseCallback != nil) {
        didCloseCallback();
    }
}

- (void)adMobVCDidClickInterstitialAd:(AdmobViewController *)adMobVC {
    if(didClickCallback != nil) {
        didClickCallback();
    }
}


- (void)adMobVCDidFailedInterstitialAd:(AdmobViewController *)adMobVC {
    if(didFailedCallback != nil) {
        didFailedCallback();
    }
}


- (void)adMobVCDidShowInterstitialAd:(AdmobViewController *)adMobVC {
    if(didShowCallback != nil) {
        didShowCallback();
    }
}


@end
