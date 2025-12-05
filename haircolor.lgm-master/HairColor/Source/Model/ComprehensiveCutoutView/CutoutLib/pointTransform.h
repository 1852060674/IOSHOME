//
//  pointTransform.h
//  imageCut
//
//  Created by shen on 14-6-24.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#ifndef imageCut_pointTransform_h
#define imageCut_pointTransform_h

inline CGPoint fromUItoQuartz(CGPoint point,CGSize frameSize){
	point.y = frameSize.height - point.y;
	return point;
}

inline CGPoint scalePoint(CGPoint point,CGSize previousSize,CGSize currentSize){
	return CGPointMake(currentSize.width *point.x / previousSize.width,
					   currentSize.height *point.y / previousSize.height);
}

#endif
