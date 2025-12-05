//
//  Whiten.h
//  SkinBeautify
//
//  Created by ZB_Mac on 14-11-21.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#ifndef __SkinBeautify__Whiten__
#define __SkinBeautify__Whiten__

#include <stdio.h>
#include <opencv2/opencv.hpp>

int TTPTWhiten(unsigned char *data, int width, int height, int widthStep, int channel, float degree=0.5);
int TTPTWhiten(cv::Mat &srcMat, cv::Mat &dstMat, float degree=0.5);

int logCurveWhiten(unsigned char *data, int width, int height, int widthStep, int channel, float beta=3);
int gradationSoftglowScreenWhiten(unsigned char *data, int width, int height, int widthStep, int channel, float degree=0.5);
#endif /* defined(__SkinBeautify__Whiten__) */
