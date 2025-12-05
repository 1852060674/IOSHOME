//
//  SquareAnimator.m
//  Solitaire
//
//  Created by jerry on 2017/8/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "WinAnimator.h"
#import <GLKit/GLKMathUtils.h>


@interface HeartAnimation : WinAnimator

@end


@implementation HeartAnimation
+ (HeartAnimation *)shared {
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




  float heartWidth = MIN(screenHeight, screenWidth) - 1* cardWidth;
  float heartHeight = MIN(screenHeight, screenWidth) - 1* cardHeight;
  float alpha = GLKMathDegreesToRadians(52);

  CGPoint center = CGPointMake(screenWidth/2, screenHeight/2);

  CGPoint pointFLeftUp = CGPointMake(center.x - heartWidth / 4, center.y-heartHeight/2);

  CGPoint pointFLeftBottom = CGPointMake(center.x - heartWidth / 2 ,center.y+heartHeight/2- heartWidth/2*tan(alpha));

  // 心形的；六个点
  CGPoint pointFCenterUp = CGPointMake(center.x , pointFLeftBottom.y);
  CGPoint pointFCenterBottom = CGPointMake(center.x , center.y+heartHeight/2);


  CGPoint pointFRightUp = CGPointMake(screenWidth - pointFLeftUp.x, pointFLeftUp.y);
  CGPoint pointFRightBottom = CGPointMake(screenWidth-pointFLeftBottom.x, pointFLeftBottom.y);

  [path moveToPoint:CGPointMake(pointFLeftBottom.x, pointFLeftBottom.y)];
  [path addLineToPoint:CGPointMake(pointFLeftUp.x, pointFLeftUp.y)];
  [path addLineToPoint:CGPointMake(pointFCenterUp.x, pointFCenterUp.y)];
  [path addLineToPoint:CGPointMake(pointFRightUp.x, pointFRightUp.y)];
  [path addLineToPoint:CGPointMake(pointFRightBottom.x, pointFRightBottom.y)];
  [path addLineToPoint:CGPointMake(pointFCenterBottom.x, pointFCenterBottom.y)];
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
