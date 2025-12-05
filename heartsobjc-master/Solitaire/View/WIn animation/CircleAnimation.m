//
//  SquareAnimator.m
//  Solitaire
//
//  Created by jerry on 2017/8/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "WinAnimator.h"
#define auto_rotate 0


@interface CircleAnimation : WinAnimator

@end



@implementation CircleAnimation
+ (CircleAnimation *)shared {
  static id man = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    man = [[self alloc] init];
  });
  return man;
}

+ (void)playAnimations:(NSArray<UIView *> *)views cardWidth:(CGFloat)cardWidth cardHeight:(CGFloat)cardHeight screenWidth:(CGFloat)screenWidth screenHeight:(CGFloat)screenHeight completion:(void (^)())completion {
  CGRect rect = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(1, 1), CGRectMake(0, 0, screenWidth, screenHeight));
  CGFloat inset = 0;
#if auto_rotate
  inset = cardHeight/2;
#else
  inset = (screenWidth < screenHeight)?(cardWidth/2):(cardHeight/2);
#endif
  rect = CGRectInset(rect, inset, inset);
  UIBezierPath * path = [UIBezierPath bezierPathWithOvalInRect:rect];
  NSInteger i = 0;
  CGFloat pathdur = 1;
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
