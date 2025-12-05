//
//  LuxandLandmark.m
//  ChildLook4
//
//  Created by ZB_Mac on 15/9/6.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "LuxandLandmark.h"
#import "CGPointUtility.h"

@implementation LuxandLandmark
-(void)setUsedLandmarks:(NSArray *)array
{
//    self.leftEyeBrowLeft = [array[0] CGPointValue];
//    self.leftEyeBrowLeftQuater = [array[1] CGPointValue];
//    self.leftEyeBrowMiddle = [array[2] CGPointValue];
//    self.leftEyeBrowRightQuater = [array[3] CGPointValue];
//    self.leftEyeBrowRight = [array[4] CGPointValue];
//    self.rightEyeBrowLeft = [array[5] CGPointValue];
//    self.rightEyeBrowLeftQuater = [array[6] CGPointValue];
//    self.rightEyeBrowMiddle = [array[7] CGPointValue];
//    self.rightEyeBrowRightQuater = [array[8] CGPointValue];
//    self.rightEyeBrowRight = [array[9] CGPointValue];
//    self.leftEyeLeft = [array[10] CGPointValue];
//    self.leftEyeBottom = [array[11] CGPointValue];
//    self.leftEyeRight = [array[12] CGPointValue];
//    self.leftEyeTop = [array[13] CGPointValue];
//    self.rightEyeLeft = [array[14] CGPointValue];
//    self.rightEyeBottom = [array[15] CGPointValue];
//    self.rightEyeRight = [array[16] CGPointValue];
//    self.rightEyeTop = [array[17] CGPointValue];
//    self.noseLowerMiddleContour = [array[18] CGPointValue];
//    self.noseLeft = [array[19] CGPointValue];
//    self.noseLeftContour2 = [array[20] CGPointValue];
//    self.noseLeftContour3 = [array[21] CGPointValue];
//    self.noseRight = [array[22] CGPointValue];
//    self.noseRightContour2 = [array[23] CGPointValue];
//    self.noseRightContour3 = [array[24] CGPointValue];
//    self.mouthLeft = [array[25] CGPointValue];
//    self.mouthRight = [array[26] CGPointValue];
//    self.mouthLowerLipBottom = [array[27] CGPointValue];
//    self.mouthLowerLipTop = [array[28] CGPointValue];
//    self.mouthUpperLipBottom = [array[29] CGPointValue];
//    self.mouthUpperLipTop = [array[30] CGPointValue];
//    self.contourLeft7 = [array[31] CGPointValue];
//    self.contourLeft8 = [array[32] CGPointValue];
//    self.contourLeft9 = [array[33] CGPointValue];
//    self.contourRight7 = [array[34] CGPointValue];
//    self.contourRight8 = [array[35] CGPointValue];
//    self.contourRight9 = [array[36] CGPointValue];
//    self.contourChin = [array[37] CGPointValue];
    
    self.leftEyeBrowLeft = [array[0] CGPointValue];
    self.leftEyeBrowMiddle = [array[1] CGPointValue];
    self.leftEyeBrowRight = [array[2] CGPointValue];
    self.rightEyeBrowLeft = [array[3] CGPointValue];
    self.rightEyeBrowMiddle = [array[4] CGPointValue];
    self.rightEyeBrowRight = [array[5] CGPointValue];
    self.leftEyeCenter = [array[6] CGPointValue];
    self.rightEyeCenter = [array[7] CGPointValue];
    self.noseTip = [array[8] CGPointValue];
    self.mouthLeft = [array[9] CGPointValue];
    self.mouthRight = [array[10] CGPointValue];
    self.contourRight6 = [array[11] CGPointValue];
    self.contourRight8 = [array[12] CGPointValue];
    self.contourRight9 = [array[13] CGPointValue];
    self.contourChin = [array[14] CGPointValue];
    self.contourLeft9 = [array[15] CGPointValue];
    self.contourLeft8 = [array[16] CGPointValue];
    self.contourLeft6 = [array[17] CGPointValue];
}

-(NSArray *)usedLandmarks
{
    if (!_resultValid) {
        return nil;
    }
    
//    NSArray *tLandmarks = tLandmarks = @[
//                                         [NSValue valueWithCGPoint:self.leftEyeBrowLeft],
//                                         [NSValue valueWithCGPoint:self.leftEyeBrowLeftQuater],
//                                         [NSValue valueWithCGPoint:self.leftEyeBrowMiddle],
//                                         [NSValue valueWithCGPoint:self.leftEyeBrowRightQuater],
//                                         [NSValue valueWithCGPoint:self.leftEyeBrowRight],
//
//                                         [NSValue valueWithCGPoint:self.rightEyeBrowLeft],
//                                         [NSValue valueWithCGPoint:self.rightEyeBrowLeftQuater],
//                                         [NSValue valueWithCGPoint:self.rightEyeBrowMiddle],
//                                         [NSValue valueWithCGPoint:self.rightEyeBrowRightQuater],
//                                         [NSValue valueWithCGPoint:self.rightEyeBrowRight],
//                                         
//                                         [NSValue valueWithCGPoint:self.leftEyeLeft],
//                                         [NSValue valueWithCGPoint:self.leftEyeBottom],
//                                         [NSValue valueWithCGPoint:self.leftEyeRight],
//                                         [NSValue valueWithCGPoint:self.leftEyeTop],
//                                         
//                                         [NSValue valueWithCGPoint:self.rightEyeLeft],
//                                         [NSValue valueWithCGPoint:self.rightEyeBottom],
//                                         [NSValue valueWithCGPoint:self.rightEyeRight],
//                                         [NSValue valueWithCGPoint:self.rightEyeTop],
//                                         
//                                         [NSValue valueWithCGPoint:self.noseLowerMiddleContour],
//                                         [NSValue valueWithCGPoint:self.noseLeft],
//                                         [NSValue valueWithCGPoint:self.noseLeftContour2],
//                                         [NSValue valueWithCGPoint:self.noseLeftContour3],
//                                         [NSValue valueWithCGPoint:self.noseRight],
//                                         [NSValue valueWithCGPoint:self.noseRightContour2],
//                                         [NSValue valueWithCGPoint:self.noseRightContour3],
//                                         
//                                         [NSValue valueWithCGPoint:self.mouthLeft],
//                                         [NSValue valueWithCGPoint:self.mouthRight],
//                                         [NSValue valueWithCGPoint:self.mouthLowerLipBottom],
//                                         [NSValue valueWithCGPoint:self.mouthLowerLipTop],
//                                         
//                                         [NSValue valueWithCGPoint:self.mouthUpperLipBottom],
//                                         [NSValue valueWithCGPoint:self.mouthUpperLipTop],
//                                         
//                                         [NSValue valueWithCGPoint:self.contourLeft7],
//                                         [NSValue valueWithCGPoint:self.contourLeft8],
//                                         [NSValue valueWithCGPoint:self.contourLeft9],
//                                         
//                                         [NSValue valueWithCGPoint:self.contourRight7],
//                                         [NSValue valueWithCGPoint:self.contourRight8],
//                                         [NSValue valueWithCGPoint:self.contourRight9],
//                                         
//                                         [NSValue valueWithCGPoint:self.contourChin],
//
//                                         ];
    
    NSArray *tLandmarks = tLandmarks = @[
                                         [NSValue valueWithCGPoint:self.leftEyeBrowLeft],
                                         [NSValue valueWithCGPoint:self.leftEyeBrowMiddle],
                                         [NSValue valueWithCGPoint:self.leftEyeBrowRight],
                                         
                                         [NSValue valueWithCGPoint:self.rightEyeBrowLeft],
                                         [NSValue valueWithCGPoint:self.rightEyeBrowMiddle],
                                         [NSValue valueWithCGPoint:self.rightEyeBrowRight],
                                         
                                         [NSValue valueWithCGPoint:self.leftEyeCenter],
                                         [NSValue valueWithCGPoint:self.rightEyeCenter],
                                         
                                         [NSValue valueWithCGPoint:self.noseTip],
                                         
                                         [NSValue valueWithCGPoint:self.mouthLeft],
                                         [NSValue valueWithCGPoint:self.mouthRight],
                                         
                                         [NSValue valueWithCGPoint:self.contourRight6],
                                         [NSValue valueWithCGPoint:self.contourRight8],
                                         [NSValue valueWithCGPoint:self.contourRight9],
                                         
                                         [NSValue valueWithCGPoint:self.contourChin],
                                         
                                         [NSValue valueWithCGPoint:self.contourLeft9],
                                         [NSValue valueWithCGPoint:self.contourLeft8],
                                         [NSValue valueWithCGPoint:self.contourLeft6],
                                         ];
    return tLandmarks;
}


-(NSArray *)faceContour
{
    if (_resultSource==LandmarkSourceFacePP || _resultSource==LandmarkSourceLuxand) {
        NSArray *tLandmarks = @[
                                [NSValue valueWithCGPoint:self.leftEyeBrowLeft],
                                [NSValue valueWithCGPoint:self.leftEyeBrowMiddle],
                                [NSValue valueWithCGPoint:self.leftEyeBrowRight],
                                
                                [NSValue valueWithCGPoint:self.rightEyeBrowLeft],
                                [NSValue valueWithCGPoint:self.rightEyeBrowMiddle],
                                [NSValue valueWithCGPoint:self.rightEyeBrowRight],
                                
                                [NSValue valueWithCGPoint:self.contourRight6],
                                [NSValue valueWithCGPoint:self.contourRight8],
                                [NSValue valueWithCGPoint:self.contourRight9],
                                
                                [NSValue valueWithCGPoint:self.contourChin],
                                
                                [NSValue valueWithCGPoint:self.contourLeft9],
                                [NSValue valueWithCGPoint:self.contourLeft8],
                                [NSValue valueWithCGPoint:self.contourLeft6],
                                ];
        return tLandmarks;
    }  else if (_resultSource==LandmarkSourceZB) {
        NSArray *tLandmarks = @[
                                [NSValue valueWithCGPoint:self.leftEyeTop],
                                
                                [NSValue valueWithCGPoint:self.rightEyeTop],
                                
                                [NSValue valueWithCGPoint:self.contourRight6],
                                [NSValue valueWithCGPoint:self.contourRight8],
                                
                                [NSValue valueWithCGPoint:self.contourChin],
                                
                                [NSValue valueWithCGPoint:self.contourLeft8],
                                [NSValue valueWithCGPoint:self.contourLeft6],
                                ];
        return tLandmarks;
    }
    return nil;
}

-(void)scaleLandmarkByRatio:(CGFloat)scale
{
    self.leftEyeBrowLeft = [CGPointUtility scalePoint:self.leftEyeBrowLeft byRatio:scale];
    self.leftEyeBrowLeftQuater = [CGPointUtility scalePoint:self.leftEyeBrowLeftQuater byRatio:scale];
    self.leftEyeBrowMiddle = [CGPointUtility scalePoint:self.leftEyeBrowMiddle byRatio:scale];
    self.leftEyeBrowRightQuater = [CGPointUtility scalePoint:self.leftEyeBrowRightQuater byRatio:scale];
    self.leftEyeBrowRight = [CGPointUtility scalePoint:self.leftEyeBrowRight byRatio:scale];
    self.rightEyeBrowLeft = [CGPointUtility scalePoint:self.rightEyeBrowLeft byRatio:scale];
    self.rightEyeBrowLeftQuater = [CGPointUtility scalePoint:self.rightEyeBrowLeftQuater byRatio:scale];
    self.rightEyeBrowMiddle = [CGPointUtility scalePoint:self.rightEyeBrowMiddle byRatio:scale];
    self.rightEyeBrowRightQuater = [CGPointUtility scalePoint:self.rightEyeBrowRightQuater byRatio:scale];
    self.rightEyeBrowRight = [CGPointUtility scalePoint:self.rightEyeBrowRight byRatio:scale];
    self.leftEyeLeft = [CGPointUtility scalePoint:self.leftEyeLeft byRatio:scale];
    self.leftEyeBottom = [CGPointUtility scalePoint:self.leftEyeBottom byRatio:scale];
    self.leftEyeRight = [CGPointUtility scalePoint:self.leftEyeRight byRatio:scale];
    self.leftEyeTop = [CGPointUtility scalePoint:self.leftEyeTop byRatio:scale];
    self.leftEyeCenter = [CGPointUtility scalePoint:self.leftEyeCenter byRatio:scale];
    self.leftEyeLowerLeftQuarter = [CGPointUtility scalePoint:self.leftEyeLowerLeftQuarter byRatio:scale];
    self.leftEyeLowerRightQuarter = [CGPointUtility scalePoint:self.leftEyeLowerRightQuarter byRatio:scale];
    self.leftEyeUpperLeftQuarter = [CGPointUtility scalePoint:self.leftEyeUpperLeftQuarter byRatio:scale];
    self.leftEyeUpperRightQuarter = [CGPointUtility scalePoint:self.leftEyeUpperRightQuarter byRatio:scale];
    self.rightEyeLeft = [CGPointUtility scalePoint:self.rightEyeLeft byRatio:scale];
    self.rightEyeBottom = [CGPointUtility scalePoint:self.rightEyeBottom byRatio:scale];
    self.rightEyeRight = [CGPointUtility scalePoint:self.rightEyeRight byRatio:scale];
    self.rightEyeTop = [CGPointUtility scalePoint:self.rightEyeTop byRatio:scale];
    self.rightEyeCenter = [CGPointUtility scalePoint:self.rightEyeCenter byRatio:scale];
    self.rightEyeLowerLeftQuarter = [CGPointUtility scalePoint:self.rightEyeLowerLeftQuarter byRatio:scale];
    self.rightEyeLowerRightQuarter = [CGPointUtility scalePoint:self.rightEyeLowerRightQuarter byRatio:scale];
    self.rightEyeUpperLeftQuarter = [CGPointUtility scalePoint:self.rightEyeUpperLeftQuarter byRatio:scale];
    self.rightEyeUpperRightQuarter = [CGPointUtility scalePoint:self.rightEyeUpperRightQuarter byRatio:scale];
    self.noseTip = [CGPointUtility scalePoint:self.noseTip byRatio:scale];
    self.noseLowerMiddleContour = [CGPointUtility scalePoint:self.noseLowerMiddleContour byRatio:scale];
    self.noseLeft = [CGPointUtility scalePoint:self.noseLeft byRatio:scale];
    self.noseLeftContour2 = [CGPointUtility scalePoint:self.noseLeftContour2 byRatio:scale];
    self.noseLeftContour3 = [CGPointUtility scalePoint:self.noseLeftContour3 byRatio:scale];
    self.noseRight = [CGPointUtility scalePoint:self.noseRight byRatio:scale];
    self.noseRightContour2 = [CGPointUtility scalePoint:self.noseRightContour2 byRatio:scale];
    self.noseRightContour3 = [CGPointUtility scalePoint:self.noseRightContour3 byRatio:scale];
    self.mouthLeft = [CGPointUtility scalePoint:self.mouthLeft byRatio:scale];
    self.mouthRight = [CGPointUtility scalePoint:self.mouthRight byRatio:scale];
    self.mouthLowerLipBottom = [CGPointUtility scalePoint:self.mouthLowerLipBottom byRatio:scale];
    self.mouthLowerLipLeftContour1 = [CGPointUtility scalePoint:self.mouthLowerLipLeftContour1 byRatio:scale];
    self.mouthLowerLipLeftContour3 = [CGPointUtility scalePoint:self.mouthLowerLipLeftContour3 byRatio:scale];
    self.mouthLowerLipRightContour1 = [CGPointUtility scalePoint:self.mouthLowerLipRightContour1 byRatio:scale];
    self.mouthLowerLipRightContour3 = [CGPointUtility scalePoint:self.mouthLowerLipRightContour3 byRatio:scale];
    self.mouthLowerLipTop = [CGPointUtility scalePoint:self.mouthLowerLipTop byRatio:scale];
    self.mouthUpperLipBottom = [CGPointUtility scalePoint:self.mouthUpperLipBottom byRatio:scale];
    self.mouthUpperLipLeftContour2 = [CGPointUtility scalePoint:self.mouthUpperLipLeftContour2 byRatio:scale];
    self.mouthUpperLipLeftContour3 = [CGPointUtility scalePoint:self.mouthUpperLipLeftContour3 byRatio:scale];
    self.mouthUpperLipRightContour2 = [CGPointUtility scalePoint:self.mouthUpperLipRightContour2 byRatio:scale];
    self.mouthUpperLipRightContour3 = [CGPointUtility scalePoint:self.mouthUpperLipRightContour3 byRatio:scale];
    self.mouthUpperLipTop = [CGPointUtility scalePoint:self.mouthUpperLipTop byRatio:scale];

    self.contourLeft1 = [CGPointUtility scalePoint:self.contourLeft1 byRatio:scale];
    self.contourLeft2 = [CGPointUtility scalePoint:self.contourLeft2 byRatio:scale];
    self.contourLeft3 = [CGPointUtility scalePoint:self.contourLeft3 byRatio:scale];
    self.contourLeft4 = [CGPointUtility scalePoint:self.contourLeft4 byRatio:scale];
    self.contourLeft5 = [CGPointUtility scalePoint:self.contourLeft5 byRatio:scale];
    self.contourLeft6 = [CGPointUtility scalePoint:self.contourLeft6 byRatio:scale];
    self.contourLeft7 = [CGPointUtility scalePoint:self.contourLeft7 byRatio:scale];
    self.contourLeft8 = [CGPointUtility scalePoint:self.contourLeft8 byRatio:scale];
    self.contourLeft9 = [CGPointUtility scalePoint:self.contourLeft9 byRatio:scale];

    self.contourRight1 = [CGPointUtility scalePoint:self.contourRight1 byRatio:scale];
    self.contourRight2 = [CGPointUtility scalePoint:self.contourRight2 byRatio:scale];
    self.contourRight3 = [CGPointUtility scalePoint:self.contourRight3 byRatio:scale];
    self.contourRight4 = [CGPointUtility scalePoint:self.contourRight4 byRatio:scale];
    self.contourRight5 = [CGPointUtility scalePoint:self.contourRight5 byRatio:scale];
    self.contourRight6 = [CGPointUtility scalePoint:self.contourRight6 byRatio:scale];
    self.contourRight7 = [CGPointUtility scalePoint:self.contourRight7 byRatio:scale];
    self.contourRight8 = [CGPointUtility scalePoint:self.contourRight8 byRatio:scale];
    self.contourRight9 = [CGPointUtility scalePoint:self.contourRight9 byRatio:scale];
    self.contourChin = [CGPointUtility scalePoint:self.contourChin byRatio:scale];
    self.contourForeHead = [CGPointUtility scalePoint:self.contourForeHead byRatio:scale];
    self.cheekLeft1 = [CGPointUtility scalePoint:self.cheekLeft1 byRatio:scale];
    self.cheekLeft2 = [CGPointUtility scalePoint:self.cheekLeft2 byRatio:scale];
    self.cheekRight1 = [CGPointUtility scalePoint:self.cheekRight1 byRatio:scale];
    self.cheekRight2 = [CGPointUtility scalePoint:self.cheekRight2 byRatio:scale];
    
    
}

-(void)translateLandmarkByOffset:(CGPoint)offset
{
    self.leftEyeBrowLeft = [CGPointUtility pointFromPoint:self.leftEyeBrowLeft translateByVector:offset];
    self.leftEyeBrowLeftQuater = [CGPointUtility pointFromPoint:self.leftEyeBrowLeftQuater translateByVector:offset];
    self.leftEyeBrowMiddle = [CGPointUtility pointFromPoint:self.leftEyeBrowMiddle translateByVector:offset];
    self.leftEyeBrowRightQuater = [CGPointUtility pointFromPoint:self.leftEyeBrowRightQuater translateByVector:offset];
    self.leftEyeBrowRight = [CGPointUtility pointFromPoint:self.leftEyeBrowRight translateByVector:offset];

    self.rightEyeBrowLeft = [CGPointUtility pointFromPoint:self.rightEyeBrowLeft translateByVector:offset];
    self.rightEyeBrowLeftQuater = [CGPointUtility pointFromPoint:self.rightEyeBrowLeftQuater translateByVector:offset];
    self.rightEyeBrowMiddle = [CGPointUtility pointFromPoint:self.rightEyeBrowMiddle translateByVector:offset];
    self.rightEyeBrowRightQuater = [CGPointUtility pointFromPoint:self.rightEyeBrowRightQuater translateByVector:offset];
    self.rightEyeBrowRight = [CGPointUtility pointFromPoint:self.rightEyeBrowRight translateByVector:offset];

    self.leftEyeLeft = [CGPointUtility pointFromPoint:self.leftEyeLeft translateByVector:offset];
    self.leftEyeBottom = [CGPointUtility pointFromPoint:self.leftEyeBottom translateByVector:offset];
    self.leftEyeRight = [CGPointUtility pointFromPoint:self.leftEyeRight translateByVector:offset];
    self.leftEyeTop = [CGPointUtility pointFromPoint:self.leftEyeTop translateByVector:offset];
    self.leftEyeCenter = [CGPointUtility pointFromPoint:self.leftEyeCenter translateByVector:offset];
    self.leftEyeLowerLeftQuarter = [CGPointUtility pointFromPoint:self.leftEyeLowerLeftQuarter translateByVector:offset];
    self.leftEyeLowerRightQuarter = [CGPointUtility pointFromPoint:self.leftEyeLowerRightQuarter translateByVector:offset];
    self.leftEyeUpperLeftQuarter = [CGPointUtility pointFromPoint:self.leftEyeUpperLeftQuarter translateByVector:offset];
    self.leftEyeUpperRightQuarter = [CGPointUtility pointFromPoint:self.leftEyeUpperRightQuarter translateByVector:offset];
    self.rightEyeLeft = [CGPointUtility pointFromPoint:self.rightEyeLeft translateByVector:offset];
    self.rightEyeBottom = [CGPointUtility pointFromPoint:self.rightEyeBottom translateByVector:offset];
    self.rightEyeRight = [CGPointUtility pointFromPoint:self.rightEyeRight translateByVector:offset];
    self.rightEyeTop = [CGPointUtility pointFromPoint:self.rightEyeTop translateByVector:offset];
    self.rightEyeCenter = [CGPointUtility pointFromPoint:self.rightEyeCenter translateByVector:offset];
    self.rightEyeLowerLeftQuarter = [CGPointUtility pointFromPoint:self.rightEyeLowerLeftQuarter translateByVector:offset];
    self.rightEyeLowerRightQuarter = [CGPointUtility pointFromPoint:self.rightEyeLowerRightQuarter translateByVector:offset];
    self.rightEyeUpperLeftQuarter = [CGPointUtility pointFromPoint:self.rightEyeUpperLeftQuarter translateByVector:offset];
    self.rightEyeUpperRightQuarter = [CGPointUtility pointFromPoint:self.rightEyeUpperRightQuarter translateByVector:offset];
    self.noseTip = [CGPointUtility pointFromPoint:self.noseTip translateByVector:offset];
    self.noseLowerMiddleContour = [CGPointUtility pointFromPoint:self.noseLowerMiddleContour translateByVector:offset];
    self.noseLeft = [CGPointUtility pointFromPoint:self.noseLeft translateByVector:offset];
    self.noseLeftContour2 = [CGPointUtility pointFromPoint:self.noseLeftContour2 translateByVector:offset];
    self.noseLeftContour3 = [CGPointUtility pointFromPoint:self.noseLeftContour3 translateByVector:offset];
    self.noseRight = [CGPointUtility pointFromPoint:self.noseRight translateByVector:offset];
    self.noseRightContour2 = [CGPointUtility pointFromPoint:self.noseRightContour2 translateByVector:offset];
    self.noseRightContour3 = [CGPointUtility pointFromPoint:self.noseRightContour3 translateByVector:offset];
    self.mouthLeft = [CGPointUtility pointFromPoint:self.mouthLeft translateByVector:offset];
    self.mouthRight = [CGPointUtility pointFromPoint:self.mouthRight translateByVector:offset];
    self.mouthLowerLipBottom = [CGPointUtility pointFromPoint:self.mouthLowerLipBottom translateByVector:offset];
    self.mouthLowerLipLeftContour1 = [CGPointUtility pointFromPoint:self.mouthLowerLipLeftContour1 translateByVector:offset];
    self.mouthLowerLipLeftContour3 = [CGPointUtility pointFromPoint:self.mouthLowerLipLeftContour3 translateByVector:offset];
    self.mouthLowerLipRightContour1 = [CGPointUtility pointFromPoint:self.mouthLowerLipRightContour1 translateByVector:offset];
    self.mouthLowerLipRightContour3 = [CGPointUtility pointFromPoint:self.mouthLowerLipRightContour3 translateByVector:offset];
    self.mouthLowerLipTop = [CGPointUtility pointFromPoint:self.mouthLowerLipTop translateByVector:offset];
    self.mouthUpperLipBottom = [CGPointUtility pointFromPoint:self.mouthUpperLipBottom translateByVector:offset];
    self.mouthUpperLipLeftContour2 = [CGPointUtility pointFromPoint:self.mouthUpperLipLeftContour2 translateByVector:offset];
    self.mouthUpperLipLeftContour3 = [CGPointUtility pointFromPoint:self.mouthUpperLipLeftContour3 translateByVector:offset];
    self.mouthUpperLipRightContour2 = [CGPointUtility pointFromPoint:self.mouthUpperLipRightContour2 translateByVector:offset];
    self.mouthUpperLipRightContour3 = [CGPointUtility pointFromPoint:self.mouthUpperLipRightContour3 translateByVector:offset];
    self.mouthUpperLipTop = [CGPointUtility pointFromPoint:self.mouthUpperLipTop translateByVector:offset];

    self.contourLeft1 = [CGPointUtility pointFromPoint:self.contourLeft1 translateByVector:offset];
    self.contourLeft2 = [CGPointUtility pointFromPoint:self.contourLeft2 translateByVector:offset];
    self.contourLeft3 = [CGPointUtility pointFromPoint:self.contourLeft3 translateByVector:offset];
    self.contourLeft4 = [CGPointUtility pointFromPoint:self.contourLeft4 translateByVector:offset];
    self.contourLeft5 = [CGPointUtility pointFromPoint:self.contourLeft5 translateByVector:offset];
    self.contourLeft6 = [CGPointUtility pointFromPoint:self.contourLeft6 translateByVector:offset];
    self.contourLeft7 = [CGPointUtility pointFromPoint:self.contourLeft7 translateByVector:offset];
    self.contourLeft8 = [CGPointUtility pointFromPoint:self.contourLeft8 translateByVector:offset];
    self.contourLeft9 = [CGPointUtility pointFromPoint:self.contourLeft9 translateByVector:offset];

    self.contourRight1 = [CGPointUtility pointFromPoint:self.contourRight1 translateByVector:offset];
    self.contourRight2 = [CGPointUtility pointFromPoint:self.contourRight2 translateByVector:offset];
    self.contourRight3 = [CGPointUtility pointFromPoint:self.contourRight3 translateByVector:offset];
    self.contourRight4 = [CGPointUtility pointFromPoint:self.contourRight4 translateByVector:offset];
    self.contourRight5 = [CGPointUtility pointFromPoint:self.contourRight5 translateByVector:offset];
    self.contourRight6 = [CGPointUtility pointFromPoint:self.contourRight6 translateByVector:offset];
    self.contourRight7 = [CGPointUtility pointFromPoint:self.contourRight7 translateByVector:offset];
    self.contourRight8 = [CGPointUtility pointFromPoint:self.contourRight8 translateByVector:offset];
    self.contourRight9 = [CGPointUtility pointFromPoint:self.contourRight9 translateByVector:offset];
    self.contourChin = [CGPointUtility pointFromPoint:self.contourChin translateByVector:offset];
    self.contourForeHead = [CGPointUtility pointFromPoint:self.contourForeHead translateByVector:offset];
    self.cheekLeft1 = [CGPointUtility pointFromPoint:self.cheekLeft1 translateByVector:offset];
    self.cheekLeft2 = [CGPointUtility pointFromPoint:self.cheekLeft2 translateByVector:offset];
    self.cheekRight1 = [CGPointUtility pointFromPoint:self.cheekRight1 translateByVector:offset];
    self.cheekRight2 = [CGPointUtility pointFromPoint:self.cheekRight2 translateByVector:offset];
}

-(id)copyWithZone:(NSZone *)zone
{
    LuxandLandmark *copy = [[LuxandLandmark allocWithZone:zone] init];
    copy.resultValid = self.resultValid;
    copy.resultSource = self.resultSource;
    copy.imageWidth = self.imageWidth;
    copy.imageHeight = self.imageHeight;
    
    copy.leftEyeBrowLeft = self.leftEyeBrowLeft;
    copy.leftEyeBrowLeftQuater = self.leftEyeBrowLeftQuater;
    copy.leftEyeBrowMiddle = self.leftEyeBrowMiddle;
    copy.leftEyeBrowRightQuater = self.leftEyeBrowRightQuater;
    copy.leftEyeBrowRight = self.leftEyeBrowRight;

    copy.rightEyeBrowLeft = self.rightEyeBrowLeft;
    copy.rightEyeBrowLeftQuater = self.rightEyeBrowLeftQuater;
    copy.rightEyeBrowMiddle = self.rightEyeBrowMiddle;
    copy.rightEyeBrowRightQuater = self.rightEyeBrowRightQuater;
    copy.rightEyeBrowRight = self.rightEyeBrowRight;

    copy.leftEyeLeft = self.leftEyeLeft;
    copy.leftEyeBottom = self.leftEyeBottom;
    copy.leftEyeRight = self.leftEyeRight;
    copy.leftEyeTop = self.leftEyeTop;
    copy.leftEyeCenter = self.leftEyeCenter;
    copy.leftEyeLowerLeftQuarter = self.leftEyeLowerLeftQuarter;
    copy.leftEyeLowerRightQuarter = self.leftEyeLowerRightQuarter;
    copy.leftEyeUpperLeftQuarter = self.leftEyeUpperLeftQuarter;
    copy.leftEyeUpperRightQuarter = self.leftEyeUpperRightQuarter;
    copy.rightEyeLeft = self.rightEyeLeft;
    copy.rightEyeBottom = self.rightEyeBottom;
    copy.rightEyeRight = self.rightEyeRight;
    copy.rightEyeTop = self.rightEyeTop;
    copy.rightEyeCenter = self.rightEyeCenter;
    copy.rightEyeLowerLeftQuarter = self.rightEyeLowerLeftQuarter;
    copy.rightEyeLowerRightQuarter = self.rightEyeLowerRightQuarter;
    copy.rightEyeUpperLeftQuarter = self.rightEyeUpperLeftQuarter;
    copy.rightEyeUpperRightQuarter = self.rightEyeUpperRightQuarter;
    copy.noseTip = self.noseTip;
    copy.noseLowerMiddleContour = self.noseLowerMiddleContour;
    copy.noseLeft = self.noseLeft;
    copy.noseLeftContour2 = self.noseLeftContour2;
    copy.noseLeftContour3 = self.noseLeftContour3;
    copy.noseRight = self.noseRight;
    copy.noseRightContour2 = self.noseRightContour2;
    copy.noseRightContour3 = self.noseRightContour3;
    copy.mouthLeft = self.mouthLeft;
    copy.mouthRight = self.mouthRight;
    copy.mouthLowerLipBottom = self.mouthLowerLipBottom;
    copy.mouthLowerLipLeftContour1 = self.mouthLowerLipLeftContour1;
    copy.mouthLowerLipLeftContour3 = self.mouthLowerLipLeftContour3;
    copy.mouthLowerLipRightContour1 = self.mouthLowerLipRightContour1;
    copy.mouthLowerLipRightContour3 = self.mouthLowerLipRightContour3;
    copy.mouthLowerLipTop = self.mouthLowerLipTop;
    copy.mouthUpperLipBottom = self.mouthUpperLipBottom;
    copy.mouthUpperLipLeftContour2 = self.mouthUpperLipLeftContour2;
    copy.mouthUpperLipLeftContour3 = self.mouthUpperLipLeftContour3;
    copy.mouthUpperLipRightContour2 = self.mouthUpperLipRightContour2;
    copy.mouthUpperLipRightContour3 = self.mouthUpperLipRightContour3;
    copy.mouthUpperLipTop = self.mouthUpperLipTop;

    copy.contourLeft1 = self.contourLeft1;
    copy.contourLeft2 = self.contourLeft2;
    copy.contourLeft3 = self.contourLeft3;
    copy.contourLeft4 = self.contourLeft4;
    copy.contourLeft5 = self.contourLeft5;
    copy.contourLeft6 = self.contourLeft6;
    copy.contourLeft7 = self.contourLeft7;
    copy.contourLeft8 = self.contourLeft8;
    copy.contourLeft9 = self.contourLeft9;

    copy.contourRight1 = self.contourRight1;
    copy.contourRight2 = self.contourRight2;
    copy.contourRight3 = self.contourRight3;
    copy.contourRight4 = self.contourRight4;
    copy.contourRight5 = self.contourRight5;
    copy.contourRight6 = self.contourRight6;
    copy.contourRight7 = self.contourRight7;
    copy.contourRight8 = self.contourRight8;
    copy.contourRight9 = self.contourRight9;

    copy.contourChin = self.contourChin;
    copy.contourForeHead = self.contourForeHead;
    copy.cheekLeft1 = self.cheekLeft1;
    copy.cheekLeft2 = self.cheekLeft2;
    copy.cheekRight1 = self.cheekRight1;
    copy.cheekRight2 = self.cheekRight2;

    return copy;
}

-(CGRect)getFaceRect
{
    CGFloat maxX = 0;
    CGFloat minX = MAXFLOAT;
    CGFloat maxY = 0;
    CGFloat minY = MAXFLOAT;
    
    //
    maxX = MAX(maxX, self.leftEyeBrowLeft.x);
    maxX = MAX(maxX, self.leftEyeBrowMiddle.x);
    maxX = MAX(maxX, self.leftEyeBrowRight.x);

    maxX = MAX(maxX, self.rightEyeBrowLeft.x);
    maxX = MAX(maxX, self.rightEyeBrowMiddle.x);
    maxX = MAX(maxX, self.rightEyeBrowRight.x);

    maxX = MAX(maxX, self.contourLeft6.x);
    maxX = MAX(maxX, self.contourLeft8.x);
    maxX = MAX(maxX, self.contourLeft9.x);

    maxX = MAX(maxX, self.contourRight6.x);
    maxX = MAX(maxX, self.contourRight8.x);
    maxX = MAX(maxX, self.contourRight9.x);
    maxX = MAX(maxX, self.contourChin.x);
    
    //
    minX = MIN(minX, self.leftEyeBrowLeft.x);
    minX = MIN(minX, self.leftEyeBrowMiddle.x);
    minX = MIN(minX, self.leftEyeBrowRight.x);

    minX = MIN(minX, self.rightEyeBrowLeft.x);
    minX = MIN(minX, self.rightEyeBrowMiddle.x);
    minX = MIN(minX, self.rightEyeBrowRight.x);

    minX = MIN(minX, self.contourLeft6.x);
    minX = MIN(minX, self.contourLeft8.x);
    minX = MIN(minX, self.contourLeft9.x);

    minX = MIN(minX, self.contourRight6.x);
    minX = MIN(minX, self.contourRight8.x);
    minX = MIN(minX, self.contourRight9.x);
    minX = MIN(minX, self.contourChin.x);
    
    //
    maxY = MAX(maxY, self.leftEyeBrowLeft.y);
    maxY = MAX(maxY, self.leftEyeBrowMiddle.y);
    maxY = MAX(maxY, self.leftEyeBrowRight.y);

    maxY = MAX(maxY, self.rightEyeBrowLeft.y);
    maxY = MAX(maxY, self.rightEyeBrowMiddle.y);
    maxY = MAX(maxY, self.rightEyeBrowRight.y);

    maxY = MAX(maxY, self.contourLeft6.y);
    maxY = MAX(maxY, self.contourLeft8.y);
    maxY = MAX(maxY, self.contourLeft9.y);

    maxY = MAX(maxY, self.contourRight6.y);
    maxY = MAX(maxY, self.contourRight8.y);
    maxY = MAX(maxY, self.contourRight9.y);
    maxY = MAX(maxY, self.contourChin.y);
    
    //
    minY = MIN(minY, self.leftEyeBrowLeft.y);
    minY = MIN(minY, self.leftEyeBrowMiddle.y);
    minY = MIN(minY, self.leftEyeBrowRight.y);

    minY = MIN(minY, self.rightEyeBrowLeft.y);
    minY = MIN(minY, self.rightEyeBrowMiddle.y);
    minY = MIN(minY, self.rightEyeBrowRight.y);

    minY = MIN(minY, self.contourLeft6.y);
    minY = MIN(minY, self.contourLeft8.y);
    minY = MIN(minY, self.contourLeft9.y);

    minY = MIN(minY, self.contourRight6.y);
    minY = MIN(minY, self.contourRight8.y);
    minY = MIN(minY, self.contourRight9.y);
    minY = MIN(minY, self.contourChin.y);
    
    return CGRectMake(minX, minY, maxX-minX, maxY-minY);
}

-(CGPoint)faceContourCentroid
{
    CGPoint center = CGPointZero;
    NSInteger count = 0;
    for (NSValue *value in [self faceContour]) {
        CGPoint point = [value CGPointValue];
        center.x += point.x;
        center.y += point.y;
        ++count;
    }
    
    center.x /= count;
    center.y /= count;
    
    return center;
}

-(CGFloat)faceContourRadius;
{
    CGFloat radius = 0.0;
    if (_resultSource == LandmarkSourceFacePP || _resultSource == LandmarkSourceZB || _resultSource == LandmarkSourceLuxand) {
        CGPoint centroid = [self faceContourCentroid];
        
        CGFloat distance = 0;
        NSInteger count = 0;
        
        for (NSValue *value in [self faceContour]) {
            CGPoint point = [value CGPointValue];
            distance += [CGPointUtility distanceBetweenPoint:centroid andPoint:point];
            ++count;
        }
        
        radius = (distance/count);
    } else if (_resultSource == LandmarkSourceCI) {
        radius = [CGPointUtility distanceBetweenPoint:_leftEyeCenter andPoint:_rightEyeCenter];
    }

    return radius;
}
@end
