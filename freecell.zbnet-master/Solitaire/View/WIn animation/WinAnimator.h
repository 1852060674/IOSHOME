//
//  WinAnimator.h
//  Solitaire
//
//  Created by jerry on 2017/8/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVUtilities.h>

@interface WinAnimator : NSObject<CAAnimationDelegate>

@property (nonatomic, copy) void(^completion)();
@property (nonatomic, assign) NSInteger count;
+ (void)playAnimations:(NSArray<UIView *> *)views cardWidth:(CGFloat)cardWidth cardHeight:(CGFloat)cardHeight screenWidth:(CGFloat)screenWidth screenHeight:(CGFloat)screenHeight completion:(void(^)())completion;
+ (Class)randomAnimator ;
+ (CAAnimationGroup *)groupAnimationWithPath:(UIBezierPath *)path offset:(CGFloat)offset duration:(CGFloat)duration repeatDuration:(CGFloat)repeatDuration;
@end


