//
//  MoleRemover2.hpp
//  Test
//
//  Created by ZB_Mac on 16/1/18.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#ifndef MoleRemover2_hpp
#define MoleRemover2_hpp

#include <stdio.h>
#include <opencv2/opencv.hpp>

int removeMoleNew(cv::Mat srcMat, cv::Point center, int radius);
int removeMoleNew(cv::Mat src, cv::Rect faceRect);
#endif /* MoleRemover2_hpp */
