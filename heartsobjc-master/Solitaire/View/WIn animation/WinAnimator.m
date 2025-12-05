//
//  WinAnimator.m
//  Solitaire
//
//  Created by jerry on 2017/8/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "WinAnimator.h"
#define anim_seq

#ifdef anim_seq
static int animIdx = 0;
#endif


@implementation WinAnimator

+ (void)playAnimations:(NSArray<UIView *> *)views cardWidth:(CGFloat)cardWidth cardHeight:(CGFloat)cardHeight screenWidth:(CGFloat)screenWidth screenHeight:(CGFloat)screenHeight completion:(void(^)())completion{
  @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Must Override" userInfo:nil];
}

+ (Class)randomAnimator {
  NSArray * array = @[
                      @"CircleAnimation",
                      @"SquareAnimation",
                      @"PentagramAnimation",
                      @"HeartAnimation",
                      @"TriangleAnimation",
                      ];
#ifdef anim_seq
  animIdx = (animIdx+1)%array.count;
  return NSClassFromString(array[animIdx]);
#else
  return NSClassFromString(array[arc4random()%array.count]);
#endif
}

+ (WinAnimator *)shared {
  return nil;
}


+ (CAAnimationGroup *)groupAnimationWithPath:(UIBezierPath *)path offset:(CGFloat)offset duration:(CGFloat)duration repeatDuration:(CGFloat)repeatDuration {

  CAKeyframeAnimation * ani1 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
  ani1.path = [path CGPath];
  ani1.duration = duration;
  ani1.repeatDuration = repeatDuration;
  ani1.calculationMode = kCAAnimationPaced;
  ani1.timeOffset = offset;

  CAAnimationGroup * group = [CAAnimationGroup animation];
  group.animations = @[ani1, ];
  group.duration = ani1.repeatDuration;
  group.delegate = [self shared];
  return group;
}

@end
