//
//  FullScreenAdWrapper.h
//  Unity-iPhone
//
//  Created by 昭 陈 on 2025/10/18.
//

#ifndef FullScreenAdWrapper_h
#define FullScreenAdWrapper_h

#import <UIKit/UIKit.h>

@class AdmobViewController;
@class FullScreenAdWrapper;

@protocol FullScreenAdWrapperDelegate <NSObject>

//reward ad wrapper回调的函数
- (void) AdDidReceive:(FullScreenAdWrapper*) adobj;
- (void) AdFailToReceivedWithError:(FullScreenAdWrapper*) adobj error:(NSString*)error;
- (void) AdDidOpen:(FullScreenAdWrapper*) adobj;
- (void) AdDidClose:(FullScreenAdWrapper*) adobj;
- (void) AdWillLeaveApplication:(FullScreenAdWrapper*) adobj;

@end

@interface FullScreenAdWrapper : NSObject

@property (nonatomic, retain) AdmobViewController* RootViewController;

@property (nonatomic, retain) id<FullScreenAdWrapperDelegate> delegate;

-(void) init_ad;

/* 展示广告 */
-(BOOL) showAd:(UIViewController*)viewController placeid:(int)place;
-(BOOL) isAdReady:(int)place;

- (void) delayInitAfterNetworkFinish;

@end

#endif /* RewardAdWrapper_h */
