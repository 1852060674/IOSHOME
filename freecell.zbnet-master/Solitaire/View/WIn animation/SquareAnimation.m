//
//  SquareAnimator.m
//  Solitaire
//
//  Created by jerry on 2017/8/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "WinAnimator.h"


@interface SquareAnimation : WinAnimator

@end


@implementation SquareAnimation
+ (SquareAnimation *)shared {
  static id man = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    man = [[self alloc] init];
  });
  return man;
}

+ (void)playAnimations:(NSArray<UIView *> *)views cardWidth:(CGFloat)cardWidth cardHeight:(CGFloat)cardHeight screenWidth:(CGFloat)screenWidth screenHeight:(CGFloat)screenHeight completion:(void (^)())completion {
  CGRect rect = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(1, 1), CGRectMake(0, 0, screenWidth, screenHeight));
  rect = CGRectInset(rect, cardWidth/2, cardHeight/2);
  UIBezierPath * path = [UIBezierPath bezierPathWithRect:rect];
  NSInteger i = 0;
  CGFloat pathdur = 0.8;
  CGFloat repdur = pathdur*2;

  CGFloat count = views.count;
  [self shared].count = count;
  [self shared].completion = completion;
  for (UIView * view in views) {
    CGFloat delay = i*pathdur/count;
    CAAnimationGroup * group = [self groupAnimationWithPath:path offset:delay duration:pathdur repeatDuration:repdur];
    [view.layer addAnimation:group forKey:@"win"];
    i ++;
  }
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

- (void)animationDidStart:(CAAnimation *)anim {

}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  if ([anim isKindOfClass:[CAAnimationGroup class]]) {
    self.count --;
    if (self.count == 1 && self.completion) {
      self.completion();
    }
  }
}

@end
