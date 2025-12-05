//
//  SquareAnimator.m
//  Solitaire
//
//  Created by jerry on 2017/8/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "WinAnimator.h"
#import <GLKit/GLKMathUtils.h>

@interface PentagramAnimation : WinAnimator

@end

@implementation PentagramAnimation
+ (PentagramAnimation *)shared {
  static id man = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    man = [[self alloc] init];
  });
  return man;
}

+ (void)playAnimations:(NSArray<UIView *> *)views cardWidth:(CGFloat)cardWidth cardHeight:(CGFloat)cardHeight screenWidth:(CGFloat)screenWidth screenHeight:(CGFloat)screenHeight completion:(void (^)())completion {


  CGFloat radius = MIN(screenWidth, screenHeight)/2;
  if (screenWidth < screenHeight) {
    radius -= cardWidth/2;
    radius = radius/cosf(GLKMathDegreesToRadians(18));
  } else {
    radius -= cardHeight/2;
  }

  UIBezierPath * path = [self starPathCenter:CGPointMake(screenWidth/2, screenHeight/2) radius:radius];
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


+ (UIBezierPath *)PentagramPathCenter:(CGPoint)center radius:(CGFloat)radius {
  UIBezierPath * path = [UIBezierPath bezierPath];


  CGFloat rotation = 0;
  //  CGFloat r = radius*sinf(GLKMathDegreesToRadians(18))/sinf(GLKMathDegreesToRadians(126));
  for (NSInteger i = 0; i < 10; i++) {
    NSInteger k = i/2;
    if (i%2 == 0) {
      // outer point
      CGFloat x = radius*cosf(GLKMathDegreesToRadians(72*k+rotation))+center.x;
      CGFloat y = radius*sinf(GLKMathDegreesToRadians(72*k+rotation))+center.y;
      CGPoint p = CGPointMake(x, y);
      if (i == 0) {
        [path moveToPoint:p];
      } else {
        [path addLineToPoint:p];
      }
    }
    //    else {
    //      // inner point
    //      CGFloat x = r*cosf(GLKMathDegreesToRadians(72*k+36+rotation))+center.x;
    //      CGFloat y = r*sinf(GLKMathDegreesToRadians(72*k+36+rotation))+center.y;
    //      CGPoint p = CGPointMake(x, y);
    //      [path addLineToPoint:p];
    //    }
  }
  [path closePath];
  return path;
}



+ (UIBezierPath *)starPathCenter:(CGPoint)center radius:(CGFloat)radius {
  UIBezierPath * path = [UIBezierPath bezierPath];


  CGFloat rotation = -90;
//  CGFloat r = radius*sinf(GLKMathDegreesToRadians(18))/sinf(GLKMathDegreesToRadians(126));
  NSArray * array = @[@0, @2, @4, @1, @3];

  for (NSInteger j = 0; j < array.count; j++) {

    NSInteger k = [array[j] integerValue];

    // outer point
      CGFloat x = radius*cosf(GLKMathDegreesToRadians(72*k+rotation))+center.x;
      CGFloat y = radius*sinf(GLKMathDegreesToRadians(72*k+rotation))+center.y;
      CGPoint p = CGPointMake(x, y);
      if (k == 0) {
        [path moveToPoint:p];
      } else {
        [path addLineToPoint:p];
      }
  }
  [path closePath];
  return path;
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
