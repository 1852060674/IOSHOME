//
//  BannerAdClient.h
//  Unity-iPhone
//
//  Created by 昭 陈 on 2018/10/11.
//

#ifndef BannerAdClient_h
#define BannerAdClient_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Admob.h"

typedef void (*BannerAdLoadedCallback)();
typedef void (*BannerAdFailedLoadedCallback)(const char* error);
typedef void (*BannerAdClickCallback)();

typedef void (*AdmobVCBannerAdDelegate)();

@interface BannerAdClient : NSObject

- (id) initWithCallbackLoaded:(BannerAdLoadedCallback) loaded
                        failedLoaded:(BannerAdFailedLoadedCallback) failed
                          click:(BannerAdClickCallback) click;
@end

#endif /* BannerAdClient_h */
