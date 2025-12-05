//
//  MGLineView.m
//  SplitPics
//
//  Created by tangtaoyu on 15-3-11.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "MGLineView.h"
#import "UIView+ColorOfPoint.h"
#import "MGDefine.h"

#define kMINGAP  0.15
#define touchWidth 20.0

@implementation MGLineView{
  CGPoint startPoint;
  UIBezierPath *rangePath;
  BOOL isShowLine;

  //    UIBezierPath *pathInner;
  //    UIBezierPath *pathOuter;
}

- (id)initWithFrame:(CGRect)frame
{
  if(self = [super initWithFrame:frame]){
    isShowLine = YES;
  }

  return self;
}

- (void)hideLine
{
  isShowLine = NO;
  [self createPath];
  //    [self setNeedsDisplay];
}

- (void)showLine
{
  isShowLine = YES;
  [self createPath];
  //    [self setNeedsDisplay];
}

- (void)drawRect22:(CGRect)rect {
  // Drawing code

  UIBezierPath *bPath = [self createPath];

  bPath.lineWidth = _width;

  if(isShowLine) {
    [[UIColor clearColor] setStroke];
    //     [[UIColor whiteColor] setStroke];
  } else {
    [[UIColor clearColor] setStroke];
  }

  [bPath stroke];

  [bPath closePath];
}

- (CGRect)rectWithBlurValue {
  CGRect rect = CGRectZero;
  if(_points.count > 1){
    CGPoint point1 = CGPointFromString(_points[0]);
    point1 = [self absolutePoint:point1 inRect:self.bounds];
    CGPoint point2 = CGPointFromString(_points[1]);
    point2 = [self absolutePoint:point2 inRect:self.bounds];
    // 垂直
    if(fabs(point1.x-point2.x) < 0.001){
      rect = CGRectMake(point1.x-self.blurValue, fmin(point1.y, point2.y), 2*self.blurValue, fabs(point1.y-point2.y));
    } else {
      rect = CGRectMake(fmin(point1.x, point2.x), point1.y-self.blurValue, fabs(point1.x-point2.x), 2*self.blurValue);
    }
  }
  return rect;
}

- (CGPoint)absolutePoint:(CGPoint)point inRect:(CGRect)frame {
  CGPoint pointA = CGPointZero;
  pointA = CGPointMake(CGRectGetWidth(frame)*point.x, CGRectGetHeight(frame)*point.y);
  return pointA;
}

- (void)updateBlurView {
  self.layer.mask = [self updateBlurViewMaskLayer];
}


- (CALayer *)updateBlurViewMaskLayer {
  CGSize size = [self rectWithBlurValue].size;
  UIGraphicsBeginImageContextWithOptions(size,YES,0);
  CGContextRef context =UIGraphicsGetCurrentContext();
  [self addBorderBlur:context];
  UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  CALayer * maskLayer = [[CALayer alloc] init];
  maskLayer.frame = [self rectWithBlurValue];
  maskLayer.contents = (__bridge id)temp.CGImage;
  return maskLayer;
}

- (void)addBorderBlur:(CGContextRef)context {
  CGRect frame = [self rectWithBlurValue];
  UIRectClip(CGRectMake(0, 0, frame.size.width, frame.size.height));
  CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();

  CGFloat compoents[]={
    0.0,0.0,0.0,1.0,

    1.0,1.0,1.0,0.0,

    1.0,1.0,1.0,1.0,

    1.0,1.0,1.0,0.0,

    0.0,0.0,0.0,1.0
  };

  CGGradientRef gradient= CGGradientCreateWithColorComponents(colorSpace, compoents, NULL, sizeof(compoents)/sizeof(compoents[0])/4);
  if (_points.count > 1) {
    // 垂直
    CGPoint point1 = CGPointFromString(_points[0]);
    point1 = [self absolutePoint:point1 inRect:frame ];

    CGPoint point2 = CGPointFromString(_points[1]);
    point2 = [self absolutePoint:point2 inRect:frame];

    if(fabs(point1.x-point2.x) < 0.001){
      CGContextDrawLinearGradient(context, gradient, CGPointMake(point1.x-self.blurValue, point1.y), CGPointMake(point1.x+self.blurValue, point1.y), kCGGradientDrawsAfterEndLocation);
    } else {
      CGContextDrawLinearGradient(context, gradient, CGPointMake(point1.x, point1.y-self.blurValue), CGPointMake(point1.x, point1.y+self.blurValue), kCGGradientDrawsAfterEndLocation);
    }
  }
  CGGradientRelease(gradient);
  CGColorSpaceRelease(colorSpace);
}

- (UIBezierPath*)createPath {
  UIBezierPath *path = [UIBezierPath bezierPath];

  if(_points.count > 0){
    for(int j=0; j<_points.count; j++){
      CGPoint point = CGPointFromString(_points[j]);

      if(j == 0){
        [path moveToPoint:CGPointMake(point.x*self.bounds.size.width, point.y*self.bounds.size.height)];
      }else{
        [path addLineToPoint:CGPointMake(point.x*self.bounds.size.width, point.y*self.bounds.size.height)];
      }
    }
    [path closePath];
    [self setRangeBezier];
  }else{
    path = self.bezierArea;
    //[self setPathSpace];
  }

  return path;
}

-(void)setRangeBezier
{
  UIBezierPath *path = [UIBezierPath bezierPath];
  if (_points.count == 2) {
    CGPoint point1 = CGPointFromString(_points[0]);
    CGPoint point2 = CGPointFromString(_points[1]);

    if (self.layoutIndex == LayoutPatternShapeSx2 || self.layoutIndex == LayoutPatternShapeSx1) {

      CGPoint curveBegin = CGPointMake(point1.x*self.bounds.size.width, point1.y*self.bounds.size.height);
      CGPoint curveEnd = CGPointMake(point2.x*self.bounds.size.width, point2.y*self.bounds.size.height);
      CGPoint curveControl1 = CGPointMake((point1.x-0.1)*self.bounds.size.width, curveBegin.y+(curveEnd.y-curveBegin.y)*0.25);
      CGPoint curveControl2 = CGPointMake((point1.x+0.1)*self.bounds.size.width, curveBegin.y+(curveEnd.y-curveBegin.y)*0.75);



      CGFloat touchAreaWidth = touchWidth;

      [path moveToPoint:CGPointMake(curveBegin.x-touchAreaWidth, curveBegin.y)];
      [path addCurveToPoint:CGPointMake(curveEnd.x-touchAreaWidth, curveEnd.y) controlPoint1:CGPointMake(curveControl1.x-touchAreaWidth, curveControl1.y) controlPoint2:CGPointMake(curveControl2.x-touchAreaWidth, curveControl2.y)];
      [path addLineToPoint:CGPointMake(curveEnd.x+touchAreaWidth, curveEnd.y)];
      [path addCurveToPoint:CGPointMake(curveBegin.x+touchAreaWidth, curveBegin.y) controlPoint1:CGPointMake(curveControl2.x+touchAreaWidth, curveControl2.y) controlPoint2:CGPointMake(curveControl1.x+touchAreaWidth, curveControl1.y)];
      [path closePath];



    } else {
      if(fabs(point1.x-point2.x) < 0.001){
        //垂直

        CGPoint p1 = point1.y < point2.y ? point1 : point2;
        CGPoint p2 = point2.y < point1.y ? point1 : point2;
        [path moveToPoint:CGPointMake(p1.x*self.bounds.size.width-touchWidth/2,
                                      p1.y*self.bounds.size.height)];
        [path addLineToPoint:CGPointMake(p1.x*self.bounds.size.width+touchWidth/2,
                                         p1.y*self.bounds.size.height)];
        [path addLineToPoint:CGPointMake(p2.x*self.bounds.size.width+touchWidth/2,
                                         p2.y*self.bounds.size.height)];
        [path addLineToPoint:CGPointMake(p2.x*self.bounds.size.width-touchWidth/2,
                                         p2.y*self.bounds.size.height)];
      } else {
        CGPoint p1 = point1.x < point2.x ? point1 : point2;
        CGPoint p2 = point2.x < point1.x ? point1 : point2;
        [path moveToPoint:CGPointMake(p1.x*self.bounds.size.width,
                                      p1.y*self.bounds.size.height-touchWidth/2)];
        [path addLineToPoint:CGPointMake(p1.x*self.bounds.size.width,
                                         p1.y*self.bounds.size.height+touchWidth/2)];
        [path addLineToPoint:CGPointMake(p2.x*self.bounds.size.width,
                                         p2.y*self.bounds.size.height+touchWidth/2)];
        [path addLineToPoint:CGPointMake(p2.x*self.bounds.size.width,
                                         p2.y*self.bounds.size.height-touchWidth/2)];
      }
      [path closePath];
    }
  } else if (self.layoutIndex == LayoutPatternLeftArrowx2 || self.layoutIndex == LayoutPatternLeftArrowx1) {
    CGPoint p1 = CGPointFromString(_points[0]);
    CGPoint p2 = CGPointFromString(_points[1]);
    CGPoint p3 = CGPointFromString(_points[2]);
    [path moveToPoint:   CGPointMake(p1.x*self.bounds.size.width-touchWidth/2,p1.y*self.bounds.size.height)];
    [path addLineToPoint:CGPointMake(p2.x*self.bounds.size.width-touchWidth/2,p2.y*self.bounds.size.height)];
    [path addLineToPoint:CGPointMake(p3.x*self.bounds.size.width-touchWidth/2,p3.y*self.bounds.size.height)];

    [path addLineToPoint:CGPointMake(p3.x*self.bounds.size.width+touchWidth/2,p3.y*self.bounds.size.height)];
    [path addLineToPoint:CGPointMake(p2.x*self.bounds.size.width+touchWidth/2,p2.y*self.bounds.size.height)];
    [path addLineToPoint:CGPointMake(p1.x*self.bounds.size.width+touchWidth/2,p1.y*self.bounds.size.height)];
    [path closePath];
  } else if (self.layoutIndex == LayoutPatternDownArrowx1 || self.layoutIndex == LayoutPatternDownArrowx2) {
    CGPoint p1 = CGPointFromString(_points[0]);
    CGPoint p2 = CGPointFromString(_points[1]);
    CGPoint p3 = CGPointFromString(_points[2]);
    [path moveToPoint:   CGPointMake(p1.x*self.bounds.size.width,p1.y*self.bounds.size.height-touchWidth/2)];
    [path addLineToPoint:CGPointMake(p2.x*self.bounds.size.width,p2.y*self.bounds.size.height-touchWidth/2)];
    [path addLineToPoint:CGPointMake(p3.x*self.bounds.size.width,p3.y*self.bounds.size.height-touchWidth/2)];

    [path addLineToPoint:CGPointMake(p3.x*self.bounds.size.width,p3.y*self.bounds.size.height+touchWidth/2)];
    [path addLineToPoint:CGPointMake(p2.x*self.bounds.size.width,p2.y*self.bounds.size.height+touchWidth/2)];
    [path addLineToPoint:CGPointMake(p1.x*self.bounds.size.width,p1.y*self.bounds.size.height+touchWidth/2)];
    [path closePath];
  }



  rangePath = path;
}

-(void)setRangeBezierPathPublic {

}

//- (void)setPathSpace
//{
//    CGPathRef path1 = createPathRotatedAroundBoundingBoxCenter(self.bezierArea.CGPath, (kRW(self.viewRect)-touchWidth/2)/kRW(self.viewRect), touchWidth/2, touchWidth/2);
//    pathInner = [UIBezierPath bezierPathWithCGPath:path1];
//
//    CGPathRef path2 = createPathRotatedAroundBoundingBoxCenter(self.bezierArea.CGPath, (kRW(self.viewRect)+touchWidth/2)/kRW(self.viewRect), -touchWidth/2, -touchWidth/2);
//    pathOuter = [UIBezierPath bezierPathWithCGPath:path2];
//}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
  //    BOOL isTransparent = NO;
  //
  //    if([self alphaOfPoint:point] < 0.5){
  //        isTransparent = YES;
  //    }
  //
  //    if(!isTransparent)
  //        NSLog(@"click in Stroke");
  //    else
  //        NSLog(@"click Out Stroke");
  //
  //    return (!isTransparent);

  BOOL isContained;

  if(self.points.count > 0) {
    isContained = [rangePath containsPoint:point];
  }
  else{
    //        isContained = ![pathInner containsPoint:point] && [pathOuter containsPoint:point];
  }
  return isContained;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];

  startPoint = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];

  CGPoint point = [touch locationInView:self];

  NSArray *arr = [self LineChanged:point];

  _points = nil;
  _points = [[NSArray alloc] initWithArray:arr];

  //    [self setNeedsDisplay];
  [self createPath];

  [self.delegate mgLineChangedWithArray:_points WithIndex:self.lineIndex];
  [self.delegate mgLineMovedWithViewIndex:self.lineIndex];

  startPoint = point;
}

//switch layout

- (NSArray*)LineChanged:(CGPoint)point {
  NSMutableArray *arr = [[NSMutableArray alloc] init];

  float dx = (point.x - startPoint.x)/self.bounds.size.width;
  float dy = (point.y - startPoint.y)/self.bounds.size.height;

  float dxpercent = point.x/self.bounds.size.width;
  float dypercent = point.y/self.bounds.size.height;

  float minLimit, maxLimit;

  NSInteger numberOfLines = [self.dataSource numberOfLines];

  for(int i=0; i<_points.count; i++){
    CGPoint p = CGPointFromString(_points[i]);

    switch(self.layoutIndex){

      case G1x2:
      case G1x3:
      case G1x4:
      case G1x5:
      case G1x6:
      {
        if (self.lineIndex == 0) {
          CGPoint affectedPoint = CGPointZero;
          if (self.layoutIndex == G1x2) {
            affectedPoint = CGPointMake(1, 1);
          } else {
            NSArray *affectedArr = [self.dataSource mgLineView:self AffectInIndex:1];
            affectedPoint = CGPointFromString(affectedArr[0]);
          }

          minLimit = kMINGAP;
          maxLimit = affectedPoint.x-kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
        } else if(self.lineIndex == numberOfLines-1) {
          NSArray *affectedArr = [self.dataSource mgLineView:self AffectInIndex:numberOfLines-2];
          CGPoint affectedPoint = CGPointFromString(affectedArr[0]);

          minLimit = affectedPoint.x+kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
        } else {
          NSArray *affectedArr0 = [self.dataSource mgLineView:self AffectInIndex:self.lineIndex-1];
          CGPoint affectedPoint0 = CGPointFromString(affectedArr0[0]);
          NSArray *affectedArr1 = [self.dataSource mgLineView:self AffectInIndex:self.lineIndex+1];
          CGPoint affectedPoint1 = CGPointFromString(affectedArr1[0]);

          minLimit = affectedPoint0.x+kMINGAP;
          maxLimit = affectedPoint1.x-kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
        }
        break;
      }
      case G2x1:
      case G3x1:
      case G4x1:
      case G5x1:
      case G6x1:
      {
        if (self.lineIndex == 0) {
          CGPoint affectedPoint = CGPointZero;
          if (self.layoutIndex == G2x1) {
            affectedPoint = CGPointMake(1, 1);
          } else {
            NSArray *affectedArr = [self.dataSource mgLineView:self AffectInIndex:1];
            affectedPoint = CGPointFromString(affectedArr[0]);
          }

          minLimit = kMINGAP;
          maxLimit = affectedPoint.y-kMINGAP;
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
        } else if (self.lineIndex == numberOfLines-1) {
          NSArray *affectedArr = [self.dataSource mgLineView:self AffectInIndex:numberOfLines-2];
          CGPoint affectedPoint = CGPointFromString(affectedArr[0]);

          minLimit = affectedPoint.y+kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
        } else {
          NSArray *affectedArr0 = [self.dataSource mgLineView:self AffectInIndex:self.lineIndex-1];
          CGPoint affectedPoint0 = CGPointFromString(affectedArr0[0]);
          NSArray *affectedArr1 = [self.dataSource mgLineView:self AffectInIndex:self.lineIndex+1];
          CGPoint affectedPoint1 = CGPointFromString(affectedArr1[0]);

          minLimit = affectedPoint0.y+kMINGAP;
          maxLimit = affectedPoint1.y-kMINGAP;
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
        }
        break;
      }

      case H2_2x1_1x1:{
        if(self.lineIndex == 0){
          minLimit = kMINGAP;
          maxLimit = 1.0 - kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];

          NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:1] mutableCopy];
          CGPoint affectedPoint = CGPointFromString(affectedArr[1]);
          affectedPoint.x = p.x;
          [affectedArr replaceObjectAtIndex:1 withObject:NSStringFromCGPoint(affectedPoint)];
          [self.delegate mgAffectLineChangedWithArray:affectedArr WithIndex:1];

        }else{
          minLimit = kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
        }
        break;
      }
      case V2_1x1_1x2:{
        if(self.lineIndex == 0){
          minLimit = kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];

          NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:1] mutableCopy];
          CGPoint affectedPoint = CGPointFromString(affectedArr[0]);
          affectedPoint.y = p.y;
          [affectedArr replaceObjectAtIndex:0 withObject:NSStringFromCGPoint(affectedPoint)];
          [self.delegate mgAffectLineChangedWithArray:affectedArr WithIndex:1];
        }else{
          minLimit = kMINGAP;
          maxLimit = 1.0 - kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
        }
        break;
      }
      case G2x2:{
        if(self.lineIndex == 0){
          minLimit = kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
        }else{
          minLimit = kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
        }
        break;
      }


      case H2_3x1_1x1:{
        if(self.lineIndex == 0){
          minLimit = kMINGAP;
          maxLimit = 1.0 - kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
          for (NSInteger i = 1; i < numberOfLines; i++) {
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:i] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[1]);
            affectedPoint.x = p.x;
            [affectedArr replaceObjectAtIndex:1 withObject:NSStringFromCGPoint(affectedPoint)];
            [self.delegate mgAffectLineChangedWithArray:affectedArr WithIndex:i];
          }
        } else if (self.lineIndex == 1) {
          CGPoint affectedPoint = CGPointZero;
          NSArray *affectedArr = [self.dataSource mgLineView:self AffectInIndex:2];
          affectedPoint = CGPointFromString(affectedArr[0]);

          minLimit = kMINGAP;
          maxLimit = affectedPoint.y-kMINGAP;
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
        } else if (self.lineIndex == numberOfLines-1) {
          NSArray *affectedArr = [self.dataSource mgLineView:self AffectInIndex:numberOfLines-2];
          CGPoint affectedPoint = CGPointFromString(affectedArr[0]);

          minLimit = affectedPoint.y+kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
        }
        break;
      }
      case V2_1x1_1x3:{
        if(self.lineIndex == 0){
          minLimit = kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
          for (NSInteger i = 1; i < numberOfLines; i++) {
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:i] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[0]);
            affectedPoint.y = p.y;
            [affectedArr replaceObjectAtIndex:0 withObject:NSStringFromCGPoint(affectedPoint)];
            [self.delegate mgAffectLineChangedWithArray:affectedArr WithIndex:i];
          }
        }else if (self.lineIndex == 1) {
          CGPoint affectedPoint = CGPointZero;

          NSArray *affectedArr = [self.dataSource mgLineView:self AffectInIndex:2];
          affectedPoint = CGPointFromString(affectedArr[0]);

          minLimit = kMINGAP;
          maxLimit = affectedPoint.x-kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
        } else if(self.lineIndex == numberOfLines-1) {
          NSArray *affectedArr = [self.dataSource mgLineView:self AffectInIndex:numberOfLines-2];
          CGPoint affectedPoint = CGPointFromString(affectedArr[0]);

          minLimit = affectedPoint.x+kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
        }
        break;
      }
      case H2_3x1_2x1:{
        if(self.lineIndex == 0){
          minLimit = kMINGAP;
          maxLimit = 1.0 - kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
          for (NSInteger lineIdx1 = 1; lineIdx1 < numberOfLines-1; lineIdx1++) {
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:lineIdx1] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[1]);
            affectedPoint.x = p.x;
            [affectedArr replaceObjectAtIndex:1 withObject:NSStringFromCGPoint(affectedPoint)];
            [self.delegate mgAffectLineChangedWithArray:affectedArr WithIndex:lineIdx1];
          }
          NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:3] mutableCopy];
          CGPoint affectedPoint = CGPointFromString(affectedArr[0]);
          affectedPoint.x = p.x;
          [affectedArr replaceObjectAtIndex:0 withObject:NSStringFromCGPoint(affectedPoint)];
          [self.delegate mgAffectLineChangedWithArray:affectedArr WithIndex:3];

        } else if (self.lineIndex == 1) {
          CGPoint affectedPoint = CGPointZero;
          NSArray *affectedArr = [self.dataSource mgLineView:self AffectInIndex:2];
          affectedPoint = CGPointFromString(affectedArr[0]);

          minLimit = kMINGAP;
          maxLimit = affectedPoint.y-kMINGAP;
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
        } else if (self.lineIndex == 2) {
          NSArray *affectedArr = [self.dataSource mgLineView:self AffectInIndex:1];
          CGPoint affectedPoint = CGPointFromString(affectedArr[0]);

          minLimit = affectedPoint.y+kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
        } else if (self.lineIndex == 3) {
          minLimit = kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
        }
        break;
      }
      case V2_1x2_1x3:{
        if(self.lineIndex == 0){
          minLimit = kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
          for (NSInteger lineIdx2 = 1; lineIdx2 < numberOfLines-1; lineIdx2++) {
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:lineIdx2] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[0]);
            affectedPoint.y = p.y;
            [affectedArr replaceObjectAtIndex:0 withObject:NSStringFromCGPoint(affectedPoint)];
            [self.delegate mgAffectLineChangedWithArray:affectedArr WithIndex:lineIdx2];
          }
          NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:3] mutableCopy];
          CGPoint affectedPoint = CGPointFromString(affectedArr[1]);
          affectedPoint.y = p.y;
          [affectedArr replaceObjectAtIndex:1 withObject:NSStringFromCGPoint(affectedPoint)];
          [self.delegate mgAffectLineChangedWithArray:affectedArr WithIndex:3];

        }else if (self.lineIndex == 1) {
          CGPoint affectedPoint = CGPointZero;

          NSArray *affectedArr = [self.dataSource mgLineView:self AffectInIndex:2];
          affectedPoint = CGPointFromString(affectedArr[0]);

          minLimit = kMINGAP;
          maxLimit = affectedPoint.x-kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
        } else if(self.lineIndex == 2) {
          NSArray *affectedArr = [self.dataSource mgLineView:self AffectInIndex:1];
          CGPoint affectedPoint = CGPointFromString(affectedArr[0]);

          minLimit = affectedPoint.x+kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
        } else if(self.lineIndex == 3) {
          minLimit = kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
        }
        break;
      }
      case H3_2x1_1x1_1x1:{
        if(self.lineIndex == 0){
          minLimit = kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];

        }else if (self.lineIndex == 1) {
          NSArray *affectedArr = [self.dataSource mgLineView:self AffectInIndex:2];
          CGPoint affectedPoint = CGPointFromString(affectedArr[0]);

          minLimit = kMINGAP;
          maxLimit = affectedPoint.x-kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
        } else if(self.lineIndex == 2) {
          NSArray *affectedArr = [self.dataSource mgLineView:self AffectInIndex:1];
          CGPoint affectedPoint = CGPointFromString(affectedArr[0]);

          minLimit = affectedPoint.x+kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
        }
        break;

      }
      case V3_1x2_1x1_1x1:{
        if(self.lineIndex == 0){
          minLimit = kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];


        }else if (self.lineIndex == 1) {
          NSArray *affectedArr = [self.dataSource mgLineView:self AffectInIndex:2];
          CGPoint affectedPoint = CGPointFromString(affectedArr[0]);

          minLimit = kMINGAP;
          maxLimit = affectedPoint.y-kMINGAP;
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
        } else if(self.lineIndex == 2) {
          NSArray *affectedArr = [self.dataSource mgLineView:self AffectInIndex:1];
          CGPoint affectedPoint = CGPointFromString(affectedArr[0]);

          minLimit = affectedPoint.y+kMINGAP;
          maxLimit = 1.0-kMINGAP;
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
        }
        break;
        
      }

      case LayoutPatternDiagonal:{
        if(i == 0){
          p.x = dxpercent+dypercent;
          p.y = 0;

          if(p.x < kMINGAP*2){
            p.x = kMINGAP*2;
          }
          if(p.x > 1.0){
            p.x = 1.0;
            p.y = dxpercent+dypercent-1.0;

            if(p.y > 1-kMINGAP*2){
              p.y = 1-kMINGAP*2;
            }
          }
        }else{
          p.x = 0;
          p.y = dxpercent+dypercent;

          if(p.y < kMINGAP*2){
            p.y = kMINGAP*2;
          }
          if(p.y > 1.0){
            p.x = dxpercent+dypercent-1.0;
            p.y = 1.0;

            if(p.x > 1-kMINGAP*2){
              p.x = 1-kMINGAP*2;
            }
          }
        }
        break;
      }
      case LayoutPatternShapeSx1:{
          CGFloat padding = 0;
          minLimit = padding+kMINGAP;
          maxLimit = 1-kMINGAP-padding;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
        break;
      }

      case LayoutPatternShapeSx2:{
        CGFloat padding = 0;
        if (self.lineIndex == 0) {
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:1] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[i]);
            minLimit = padding+kMINGAP;
            maxLimit = affectedPoint.x-kMINGAP;
            p.x += dx;
            p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
        } else if (self.lineIndex == 1) {
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:0] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[i]);
            minLimit = affectedPoint.x+kMINGAP;
            maxLimit = 1-kMINGAP-padding;
            p.x += dx;
            p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
        }
        break;
      }
      case LayoutPatternDownArrowx1:{
        if(i == 0){
          minLimit = kMINGAP;
          maxLimit = 1-kMINGAP-(0.6-0.4);
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];

        }else if(i == 1){

          minLimit = 0.6-0.4+kMINGAP;
          maxLimit = 1-kMINGAP;
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
        }else if(i == 2){

          minLimit = kMINGAP;
          maxLimit = 1-kMINGAP-(0.6-0.4);
          p.y += dy;
          p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
        }
        break;
      }
      case LayoutPatternDownArrowx2:{
        if (self.lineIndex == 0) {
          if(i == 0){
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:1] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[i]);
            minLimit = kMINGAP;
            maxLimit = affectedPoint.y-kMINGAP;
            p.y += dy;
            p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];

          }else if(i == 1){
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:1] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[i]);
            minLimit = 0.4-0.3+kMINGAP;
            maxLimit = affectedPoint.y-kMINGAP;
            p.y += dy;
            p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
          }else if(i == 2){
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:1] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[i]);
            minLimit = kMINGAP;
            maxLimit = affectedPoint.y-kMINGAP;
            p.y += dy;
            p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
          }
        } else if (self.lineIndex == 1) {
          if(i == 0){
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:0] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[i]);
            minLimit = affectedPoint.y+kMINGAP;
            maxLimit = 1-kMINGAP-(0.4-0.3);
            p.y += dy;
            p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
          }else if(i == 1){
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:0] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[i]);
            minLimit = affectedPoint.y+kMINGAP;
            maxLimit = 1-kMINGAP;
            p.y += dy;
            p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
          }else if(i == 2){
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:0] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[i]);
            minLimit = affectedPoint.y+kMINGAP;
            maxLimit = 1-kMINGAP-(0.4-0.3);
            p.y += dy;
            p.y = [self pointLimit:p.y withMin:minLimit WithMax:maxLimit];
          }
        }
        break;
      }
      case LayoutPatternLeftArrowx1:{
        if(i == 0){
          minLimit = 0.6-0.4+kMINGAP;
          maxLimit = 1-kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];

        }else if(i == 1){

          minLimit = kMINGAP;
          maxLimit = 1-kMINGAP-(0.6-0.4);
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
        }else if(i == 2){

          minLimit = 0.6-0.4+kMINGAP;
          maxLimit = 1-kMINGAP;
          p.x += dx;
          p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
        }
        break;
      }

      case LayoutPatternLeftArrowx2:{
        if (self.lineIndex == 0) {
          if(i == 0){
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:1] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[i]);
            minLimit = 0.4-0.3+kMINGAP;
            maxLimit = affectedPoint.x-kMINGAP;
            p.x += dx;
            p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];

          }else if(i == 1){
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:1] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[i]);
            minLimit = kMINGAP;
            maxLimit = affectedPoint.x-kMINGAP;
            p.x += dx;
            p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
          }else if(i == 2){
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:1] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[i]);
            minLimit = 0.4-0.3+kMINGAP;
            maxLimit = affectedPoint.x-kMINGAP;
            p.x += dx;
            p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
          }
        } else if (self.lineIndex == 1) {
          if(i == 0){
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:0] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[i]);
            minLimit = affectedPoint.x+kMINGAP;
            maxLimit = 1-kMINGAP;
            p.x += dx;
            p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];

          }else if(i == 1){
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:0] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[i]);
            minLimit = affectedPoint.x+kMINGAP;
            maxLimit = 1-kMINGAP-(0.4-0.3);
            p.x += dx;
            p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
          }else if(i == 2){
            NSMutableArray *affectedArr = [[self.dataSource mgLineView:self AffectInIndex:0] mutableCopy];
            CGPoint affectedPoint = CGPointFromString(affectedArr[i]);
            minLimit = affectedPoint.x+kMINGAP;
            maxLimit = 1-kMINGAP;
            p.x += dx;
            p.x = [self pointLimit:p.x withMin:minLimit WithMax:maxLimit];
          }
        }
        break;
      }
        
        
        
      default:{
        break;
      }
    }
    
    [arr addObject:NSStringFromCGPoint(p)];
  }
  

  return arr;
}



- (float)pointLimit:(float)p withMin:(float)minLimit WithMax:(float)maxLimit
{
  float output = p;
  if(p < minLimit){
    output = minLimit;
  }
  if(p > maxLimit){
    output = maxLimit;
  }
  return output;
}



#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wunused-function"

static CGPathRef createPathRotatedAroundBoundingBoxCenter(CGPathRef path, CGFloat scale, CGFloat x, CGFloat y)
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wunused-variable"
  CGRect bounds = CGPathGetBoundingBox(path); // might want to use CGPathGetPathBoundingBox
#pragma clang diagnostic pop
  CGAffineTransform transform = CGAffineTransformIdentity;
  //transform = CGAffineTransformTranslate(transform, center.x, center.y);
  transform = CGAffineTransformTranslate(transform, x, y);
  transform = CGAffineTransformScale(transform, scale, scale);
  
  return CGPathCreateCopyByTransformingPath(path, &transform);
}

#pragma clang diagnostic pop



@end
