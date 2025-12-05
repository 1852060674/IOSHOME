//
//  CameraViewController+UnsedMethod.m
//  SplitPics
//
//  Created by spring on 2016/10/19.
//  Copyright © 2016年 ZBNetWork. All rights reserved.
//

#import "CameraViewController+UnsedMethod.h"

@implementation CameraViewController (UnsedMethod)
#pragma mark - unused Method


#if 0


- (void)sublayoutEndpointsRefeshAfterChangeBlurWidthOldMethod:(float)blurWidth
{
  switch(self.currentLayoutIndex){
    case G1x2:
    case G1x3:
    case G1x4:
    case G1x5:
    case G1x6:
    {
      for (NSInteger i = 0; i < sublayoutEndpoints.count-1; i++) {
        [self sublayoutEndpointsChangedSublayoutIndex:i endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:i+1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      }
      break;
    }
    case G2x1:
    case G3x1:
    case G4x1:
    case G5x1:
    case G6x1:
    {
      for (NSInteger i = 0; i < sublayoutEndpoints.count-1; i++) {
        [self sublayoutEndpointsChangedSublayoutIndex:i endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:i+1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      }
      break;
    }

    case H2_2x1_1x1:{
      [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      break;
    }
    case V2_1x1_1x2:{
      [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      break;
    }
    case G2x2:{
      [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      break;
    }
    case H2_3x1_1x1:{
      [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      break;
    }
    case V2_1x1_1x3:{
      [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      break;
    }
    case LayoutPatternDiagonal:{
      break;
    }
    default:{
      break;
    }
  }

  [self PointsRefresh];
}

- (void)sublayoutEndpointsBackupRefeshAfterchangeBlurWidthOldMethod:(float)blurWidth
{
  switch(self.currentLayoutIndex){
    case G1x2:
    case G1x3:
    case G1x4:
    case G1x5:
    case G1x6:
    {
      for (NSInteger i = 0; i < sublayoutEndpoints.count-1; i++) {
        [self sublayoutEndpointsBackupChangedSublayoutIndex:i endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:i+1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      }
      break;
    }
    case G2x1:
    case G3x1:
    case G4x1:
    case G5x1:
    case G6x1:
    {
      for (NSInteger i = 0; i < sublayoutEndpoints.count-1; i++) {
        [self sublayoutEndpointsBackupChangedSublayoutIndex:i endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:i+1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      }
      break;
    }
    case H2_2x1_1x1:{
      [self sublayoutEndpointsBackupChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      break;
    }
    case V2_1x1_1x2:{
      [self sublayoutEndpointsBackupChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      break;
    }
    case G2x2:{
      [self sublayoutEndpointsBackupChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      break;
    }
    case H2_3x1_1x1:{
      [self sublayoutEndpointsBackupChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      break;
    }
    case V2_1x1_1x3:{
      [self sublayoutEndpointsBackupChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      break;
    }
    case LayoutPatternDiagonal:{
      break;
    }
    default:{
      break;
    }
  }

  [self PointsRefresh];
}

- (void)sublayoutEndpointsRefeshAfterMoveLineIndexOldMethod:(NSInteger)lineIndex blurWidth:(float)blurWidth {
  switch(self.currentLayoutIndex){
    case G1x2:
    case G1x3:
    case G1x4:
    case G1x5:
    case G1x6:
    {
      [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      break;
    }
    case G2x1:
    case G3x1:
    case G4x1:
    case G5x1:
    case G6x1:
    {
      [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      break;
    }
    case H2_2x1_1x1:{
      if(lineIndex == 0){
        [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      }else{
        [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      }
      break;
    }
    case V2_1x1_1x2:{
      if(lineIndex == 0){
        [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      }else{
        [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      }
      break;
    }
    case H2_3x1_1x1:{
      if(lineIndex == 0){
        [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:0 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      }else if(lineIndex == 1) {
        [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      } else {
        [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:2 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      }
      break;
    }
    case V2_1x1_1x3:{
      if(lineIndex == 0){
        [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      }else if(lineIndex == 1) {
        [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      } else {
        [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:2 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:2 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      }
      break;
    }
    case H2_3x1_2x1:{
      if(lineIndex == 0){
        [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:0 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:4 lineIndex:0 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      }else if(lineIndex == 1) {
        [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      } else if(lineIndex == 2) {
        [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:2 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      } else if(lineIndex == 3) {
        [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:2 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:4 lineIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      }
      break;
    }
    case G2x2:{
      if(lineIndex == 0){
        [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      }else{
        [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      }
      break;
    }
    case LayoutPatternDiagonal:{
      NSArray *line = lines[0];
      CGPoint first = CGPointFromString(line[0]);
      CGPoint second = CGPointFromString(line[1]);
      if(first.y <= 0.0){
        NSMutableArray *subPoints1 = [sublayoutEndpoints[0] mutableCopy];
        NSMutableArray *subPoints2 = [sublayoutEndpoints[1] mutableCopy];
        if(subPoints1.count == 5){
          [subPoints1 removeObjectAtIndex:3];
          [subPoints1 removeObjectAtIndex:2];
        }

        CGPoint point1 = CGPointFromString(subPoints1[1]);
        CGPoint point2 = CGPointFromString(subPoints1[2]);

        point1.y = second.y;
        point2.x = first.x;

        NSString *pointStr1 = NSStringFromCGPoint(point1);
        NSString *pointStr2 = NSStringFromCGPoint(point2);

        [subPoints1 replaceObjectAtIndex:1 withObject:pointStr1];
        [subPoints1 replaceObjectAtIndex:2 withObject:pointStr2];

        NSArray *arr = [[NSArray alloc] initWithArray:subPoints1];
        [sublayoutEndpoints replaceObjectAtIndex:0 withObject:arr];

        if(subPoints2.count == 3){
          [subPoints2 insertObject:pointStr2 atIndex:1];
          [subPoints2 insertObject:pointStr1 atIndex:2];

          CGPoint p1 = CGPointMake(1.0, 0.0);
          CGPoint p2 = CGPointMake(0.0, 1.0);

          [subPoints2 replaceObjectAtIndex:0 withObject:NSStringFromCGPoint(p1)];
          [subPoints2 replaceObjectAtIndex:3 withObject:NSStringFromCGPoint(p2)];

          [sublayoutEndpoints replaceObjectAtIndex:1 withObject:(NSArray*)[subPoints2 copy]];
        }else{
          [subPoints2 replaceObjectAtIndex:2 withObject:pointStr1];
          [subPoints2 replaceObjectAtIndex:1 withObject:pointStr2];
          [sublayoutEndpoints replaceObjectAtIndex:1 withObject:(NSArray*)[subPoints2 copy]];
        }
      }else{
        NSMutableArray *subPoints2 = [sublayoutEndpoints[1] mutableCopy];
        NSMutableArray *subPoints1 = [sublayoutEndpoints[0] mutableCopy];
        if(subPoints2.count == 5){
          [subPoints2 removeObjectAtIndex:2];
          [subPoints2 removeObjectAtIndex:1];
        }

        CGPoint point1 = CGPointFromString(subPoints2[0]);
        CGPoint point2 = CGPointFromString(subPoints2[1]);

        point1.y = first.y;
        point2.x = second.x;

        [subPoints2 replaceObjectAtIndex:0 withObject:NSStringFromCGPoint(point1)];
        [subPoints2 replaceObjectAtIndex:1 withObject:NSStringFromCGPoint(point2)];
        [sublayoutEndpoints replaceObjectAtIndex:1 withObject:[subPoints2 copy]];


        if(subPoints1.count == 3){
          [subPoints1 insertObject:NSStringFromCGPoint(point2) atIndex:2];
          [subPoints1 insertObject:NSStringFromCGPoint(point1) atIndex:3];

          CGPoint p1 = CGPointMake(1.0, 0.0);
          CGPoint p2 = CGPointMake(0.0, 1.0);

          [subPoints1 replaceObjectAtIndex:4 withObject:NSStringFromCGPoint(p1)];
          [subPoints1 replaceObjectAtIndex:1 withObject:NSStringFromCGPoint(p2)];

          [sublayoutEndpoints replaceObjectAtIndex:0 withObject:(NSArray*)[subPoints1 copy]];
        }else{
          [subPoints1 replaceObjectAtIndex:2 withObject:NSStringFromCGPoint(point2)];
          [subPoints1 replaceObjectAtIndex:3 withObject:NSStringFromCGPoint(point1)];
          [sublayoutEndpoints replaceObjectAtIndex:0 withObject:(NSArray*)[subPoints1 copy]];
        }
      }
      break;
    }
    case LayoutPatternDownArrowx1:{
      [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@1,@2,@3] axis:1 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@4,@3] axis:1 delta:-blurWidth];
      break;
    }
    case LayoutPatternDownArrowx2:{

      switch (lineIndex) {
        case 0:
          [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@1,@2,@3] axis:1 delta:blurWidth];
          [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@5,@4] axis:1 delta:-blurWidth];
          break;
        case 1:
          [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@1,@2,@3] axis:1 delta:blurWidth];
          [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@4,@3] axis:1 delta:-blurWidth];
          break;
        default:
          break;
      }
      break;
    }

    case LayoutPatternLeftArrowx1:{
      [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@2,@3,@4] axis:0 delta:blurWidth];
      [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@1,@2] axis:0 delta:-blurWidth];
      break;
    }
    case LayoutPatternLeftArrowx2:{

      switch (lineIndex) {
        case 0:
          [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@2,@3,@4] axis:0 delta:blurWidth];
          [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@1,@2] axis:0 delta:-blurWidth];
          break;
        case 1:
          [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@3,@4,@5] axis:0 delta:blurWidth];
          [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@1,@2] axis:0 delta:-blurWidth];
          break;
        default:
          break;
      }
      break;
    }
    default:{
      break;
    }
  }

  [self PointsRefresh];
}

- (void)sublayoutEndpointsBackupRefeshAfterMoveLineIndexOldMethod:(NSInteger)lineIndex blurWidth:(float)blurWidth
{
  switch(self.currentLayoutIndex){
    case G1x2:
    case G1x3:
    case G1x4:
    case G1x5:
    case G1x6:
    {
      [self sublayoutEndpointsBackupChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      break;
    }
    case G2x1:
    case G3x1:
    case G4x1:
    case G5x1:
    case G6x1:
    {
      [self sublayoutEndpointsBackupChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      break;
    }

    case H2_2x1_1x1:{
      if(lineIndex == 0){
        [self sublayoutEndpointsBackupChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      }else{
        [self sublayoutEndpointsBackupChangedSublayoutIndex:0 lineIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      }
      break;
    }
    case V2_1x1_1x2:{
      if(lineIndex == 0){
        [self sublayoutEndpointsBackupChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      }else{
        [self sublayoutEndpointsBackupChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:2 lineIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      }
      break;
    }
    case G2x2:{
      if(lineIndex == 0){
        [self sublayoutEndpointsBackupChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:3 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      }else{
        [self sublayoutEndpointsBackupChangedSublayoutIndex:0 lineIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:2 lineIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:3 lineIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      }
      break;
    }
    case H2_3x1_1x1:{
      if(lineIndex == 0){
        [self sublayoutEndpointsBackupChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      }else if(lineIndex == 1) {
        [self sublayoutEndpointsBackupChangedSublayoutIndex:0 lineIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      } else {
        [self sublayoutEndpointsBackupChangedSublayoutIndex:1 lineIndex:2 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:2 lineIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      }
      break;
    }
    case V2_1x1_1x3:{
      if(lineIndex == 0){
        [self sublayoutEndpointsBackupChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      }else if(lineIndex == 1) {
        [self sublayoutEndpointsBackupChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:2 lineIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      }else{
        [self sublayoutEndpointsBackupChangedSublayoutIndex:2 lineIndex:2 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:3 lineIndex:2 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      }
      break;
    }
    case H2_3x1_2x1:{
      if(lineIndex == 0){
        [self sublayoutEndpointsBackupChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth];
      }else if(lineIndex == 1) {
        [self sublayoutEndpointsBackupChangedSublayoutIndex:0 lineIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      } else {
        [self sublayoutEndpointsBackupChangedSublayoutIndex:1 lineIndex:2 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth];
        [self sublayoutEndpointsBackupChangedSublayoutIndex:2 lineIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth];
      }
      break;
    }
    case LayoutPatternDiagonal:{
      NSArray *line = lines[0];
      CGPoint first = CGPointFromString(line[0]);
      CGPoint second = CGPointFromString(line[1]);
      if(first.y <= 0.0){
        NSMutableArray *subPoints1 = [sublayoutEndpoints[0] mutableCopy];
        NSMutableArray *subPoints2 = [sublayoutEndpoints[1] mutableCopy];
        if(subPoints1.count == 5){
          [subPoints1 removeObjectAtIndex:3];
          [subPoints1 removeObjectAtIndex:2];
        }

        CGPoint point1 = CGPointFromString(subPoints1[1]);
        CGPoint point2 = CGPointFromString(subPoints1[2]);

        point1.y = second.y;
        point2.x = first.x;

        NSString *pointStr1 = NSStringFromCGPoint(point1);
        NSString *pointStr2 = NSStringFromCGPoint(point2);

        [subPoints1 replaceObjectAtIndex:1 withObject:pointStr1];
        [subPoints1 replaceObjectAtIndex:2 withObject:pointStr2];

        NSArray *arr = [[NSArray alloc] initWithArray:subPoints1];
        [sublayoutEndpoints replaceObjectAtIndex:0 withObject:arr];

        if(subPoints2.count == 3){
          [subPoints2 insertObject:pointStr2 atIndex:1];
          [subPoints2 insertObject:pointStr1 atIndex:2];

          CGPoint p1 = CGPointMake(1.0, 0.0);
          CGPoint p2 = CGPointMake(0.0, 1.0);

          [subPoints2 replaceObjectAtIndex:0 withObject:NSStringFromCGPoint(p1)];
          [subPoints2 replaceObjectAtIndex:3 withObject:NSStringFromCGPoint(p2)];

          [sublayoutEndpoints replaceObjectAtIndex:1 withObject:(NSArray*)[subPoints2 copy]];
        }else{
          [subPoints2 replaceObjectAtIndex:2 withObject:pointStr1];
          [subPoints2 replaceObjectAtIndex:1 withObject:pointStr2];
          [sublayoutEndpoints replaceObjectAtIndex:1 withObject:(NSArray*)[subPoints2 copy]];
        }
      }else{
        NSMutableArray *subPoints2 = [sublayoutEndpoints[1] mutableCopy];
        NSMutableArray *subPoints1 = [sublayoutEndpoints[0] mutableCopy];
        if(subPoints2.count == 5){
          [subPoints2 removeObjectAtIndex:2];
          [subPoints2 removeObjectAtIndex:1];
        }

        CGPoint point1 = CGPointFromString(subPoints2[0]);
        CGPoint point2 = CGPointFromString(subPoints2[1]);

        point1.y = first.y;
        point2.x = second.x;

        [subPoints2 replaceObjectAtIndex:0 withObject:NSStringFromCGPoint(point1)];
        [subPoints2 replaceObjectAtIndex:1 withObject:NSStringFromCGPoint(point2)];
        [sublayoutEndpoints replaceObjectAtIndex:1 withObject:[subPoints2 copy]];


        if(subPoints1.count == 3){
          [subPoints1 insertObject:NSStringFromCGPoint(point2) atIndex:2];
          [subPoints1 insertObject:NSStringFromCGPoint(point1) atIndex:3];

          CGPoint p1 = CGPointMake(1.0, 0.0);
          CGPoint p2 = CGPointMake(0.0, 1.0);

          [subPoints1 replaceObjectAtIndex:4 withObject:NSStringFromCGPoint(p1)];
          [subPoints1 replaceObjectAtIndex:1 withObject:NSStringFromCGPoint(p2)];

          [sublayoutEndpoints replaceObjectAtIndex:0 withObject:(NSArray*)[subPoints1 copy]];
        }else{
          [subPoints1 replaceObjectAtIndex:2 withObject:NSStringFromCGPoint(point2)];
          [subPoints1 replaceObjectAtIndex:3 withObject:NSStringFromCGPoint(point1)];
          [sublayoutEndpoints replaceObjectAtIndex:0 withObject:(NSArray*)[subPoints1 copy]];
        }
      }
      break;
    }
    case LayoutPatternDownArrowx1:{
      [self sublayoutEndpointsBackupChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@1,@2,@3] axis:1 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@4,@3] axis:1 delta:-blurWidth];
      break;
    }
    case LayoutPatternDownArrowx2:{

      switch (lineIndex) {
        case 0:
          [self sublayoutEndpointsBackupChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@1,@2,@3] axis:1 delta:blurWidth];
          [self sublayoutEndpointsBackupChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@5,@4] axis:1 delta:-blurWidth];
          break;
        case 1:
          [self sublayoutEndpointsBackupChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@1,@2,@3] axis:1 delta:blurWidth];
          [self sublayoutEndpointsBackupChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@4,@3] axis:1 delta:-blurWidth];
          break;
        default:
          break;
      }
      break;
    }

    case LayoutPatternLeftArrowx1:{
      [self sublayoutEndpointsBackupChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@2,@3,@4] axis:0 delta:blurWidth];
      [self sublayoutEndpointsBackupChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@1,@2] axis:0 delta:-blurWidth];

      break;
    }
    case LayoutPatternLeftArrowx2:{

      switch (lineIndex) {
        case 0:
          [self sublayoutEndpointsBackupChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@2,@3,@4] axis:0 delta:blurWidth];
          [self sublayoutEndpointsBackupChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@1,@2] axis:0 delta:-blurWidth];
          break;
        case 1:
          [self sublayoutEndpointsBackupChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@3,@4,@5] axis:0 delta:blurWidth];
          [self sublayoutEndpointsBackupChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@1,@2] axis:0 delta:-blurWidth];
          break;
        default:
          break;
      }
      break;
    }
    default:{
      break;
    }
  }
}

#endif
@end
