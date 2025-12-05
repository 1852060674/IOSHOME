//
//  BannerAdClient.m
//  Unity-iPhone
//
//  Created by 昭 陈 on 2018/10/11.
//


#import "BannerAdClient.h"
#import "ADWrapper.h"

@implementation BannerAdClient {
    BannerAdLoadedCallback loadedCallback;
    BannerAdFailedLoadedCallback failedLoadedCallback;
    BannerAdClickCallback clickCallback;
}

- (id) initWithCallbackLoaded:(BannerAdLoadedCallback) loaded
                 failedLoaded:(BannerAdFailedLoadedCallback) failed
                        click:(BannerAdClickCallback) click {
    self = [super init];
    loadedCallback = loaded;
    failedLoadedCallback = failed;
    clickCallback = click;
    return self;
}

-(void) adMobVCBannerAdLoaded:(ADWrapper*)bannerad {
    if(loadedCallback != nil) {
        loadedCallback();
    }
}

-(void) adMobVCBannerAdFailedLoaded:(ADWrapper*)bannerad error:(NSError*)error {
    if(failedLoadedCallback != nil) {
        failedLoadedCallback([[error localizedFailureReason] cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

-(void) adMobVCBannerAdClick:(ADWrapper*)bannerad {
    if(clickCallback != nil) {
        clickCallback();
    }
}

@end
