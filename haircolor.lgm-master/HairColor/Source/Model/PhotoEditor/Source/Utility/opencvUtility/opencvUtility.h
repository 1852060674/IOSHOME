//
//  opencvUtility.h
//  FaceMorph
//
//  Created by shen on 14-7-10.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#ifndef __FaceMorph__opencvUtility__
#define __FaceMorph__opencvUtility__

#include "opencv2/imgproc/imgproc.hpp"
void clipPointToImageBounds(const cv::Mat &image, cv::Point2f& uv);
void clipRectToImageBounds(const cv::Mat &image, cv::Rect &rect);
cv::Vec3b bilinearInterpolate(const cv::Mat &image, cv::Point2f center);
cv::Vec3b bilinearInterpolate(const cv::Mat &image, float centerY, float centerX);
cv::Point2f bilinearInterpolatePoint2f(const cv::Mat &image, cv::Point2f center);
void expandRectToContainPoint(cv::Rect &rect, cv::Point point);
void expandRectToContainRect(cv::Rect &rect, cv::Rect r);
#endif /* defined(__FaceMorph__opencvUtility__) */
