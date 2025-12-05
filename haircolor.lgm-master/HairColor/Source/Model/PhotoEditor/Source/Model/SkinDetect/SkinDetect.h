//
//  SkinDetect.h
//  Filter
//
//  Created by shen on 14-3-18.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#ifndef __Filter__SkinDetect__
#define __Filter__SkinDetect__

#include <iostream>
#include <opencv2/imgproc/types_c.h>

void cvSkinRGB(IplImage* rgb,IplImage* _dst);
void cvSkinRG(IplImage* rgb,IplImage* gray);
void cvSkinOtsu(IplImage* src, IplImage* dst);
void cvSkinYCrCb(IplImage* src,IplImage* dst);
void cvSkinHSV(IplImage* src,IplImage* dst);

bool isSkinRG(unsigned char R, unsigned char G, unsigned char B);
bool isSkinRGB(unsigned char R, unsigned char G, unsigned char B);
bool isSkinYCrCb(unsigned char Cr, unsigned char Cb);
bool isSkinHSV(unsigned char H);
int cvSkin(IplImage* srcImage, IplImage* dstImage);
int cvSmoothSkin(IplImage* src, IplImage* dst);
#endif /* defined(__Filter__SkinDetect__) */
