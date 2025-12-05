//
//  SquareAnimator.m
//  Solitaire
//
//  Created by jerry on 2017/8/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "WinAnimator.h"
#import <GLKit/GLKMathUtils.h>


@interface TriangleAnimation : WinAnimator

@end


@implementation TriangleAnimation
+ (TriangleAnimation *)shared {
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
  UIBezierPath * path = [UIBezierPath bezierPath];


  float triangleSize = MIN(screenHeight, screenWidth) - cardWidth;
  float baseLineY = screenHeight / 2.0f + triangleSize * (float)sin(GLKMathDegreesToRadians(60)) / 2 - cardHeight / 2;


  [path moveToPoint:CGPointMake(screenWidth / 2 - triangleSize / 2 , baseLineY)];
  [path addLineToPoint:CGPointMake(screenWidth / 2 + triangleSize / 2, baseLineY)];
  [path addLineToPoint:CGPointMake(screenWidth / 2, MAX((screenHeight - baseLineY - cardHeight), cardHeight/2))];
  [path closePath];




  NSInteger i = 0;
  CGFloat pathdur = 0.8;
  CGFloat repdur = 2;

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
