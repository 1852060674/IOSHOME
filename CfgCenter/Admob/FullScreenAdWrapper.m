//
//  FullScreenAdWrapper.m
//  Unity-iPhone
//
//  Created by 昭 陈 on 2019/3/18.
//

#import <Foundation/Foundation.h>
#import "CfgCenter.h"
#import "FullScreenAdWrapper.h"

@implementation FullScreenAdWrapper

-(void) init_ad {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

/* 展示广告 */
-(BOOL) showAd:(UIViewController*)viewController placeid:(int)place {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(BOOL) isAdReady:(int)place {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void) delayInitAfterNetworkFinish {
}

@end
