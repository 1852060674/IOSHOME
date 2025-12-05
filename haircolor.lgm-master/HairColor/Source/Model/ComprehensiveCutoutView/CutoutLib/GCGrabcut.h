//
//  GCGrabcut.h
//  imageCut
//
//  Created by shen on 14-6-20.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#ifndef __imageCut__GCGrabcut__
#define __imageCut__GCGrabcut__

#include "gcgraph-double.hpp"
#include "GCGMM.h"

enum
{
    GC_UNKNOWN = 10,
    GC_IGNORE = 255,
};

class GCGrabCut
{
private:
    GCGMM bgdGMM, fgdGMM;
public:
    void cutImage( cv::InputArray _img, cv::InputOutputArray _mask, cv::Rect rect,
                   cv::InputOutputArray _bgdModel, cv::InputOutputArray _fgdModel,
                   int iterCount, int mode );
    
    void cutImage (cv::InputArray _img, cv::InputOutputArray _mask, int iterCount);
    
    void labelRibbon(cv::InputArray _scaledMask, cv::OutputArray _mask, float scale, int &nBGDCount, int &nFGDCount);
    
    void estimate(cv::InputArray _img, cv::InputOutputArray _mask);
    
    void genModel(cv::InputArray _img, cv::InputOutputArray _mask, cv::Rect rect, cv::InputOutputArray _bgdModel, cv::InputOutputArray _fgdModel, int mode);
    
    void estimate2 (cv::InputArray _img, cv::InputOutputArray _mask);
    
    void estimate3 (cv::InputArray _img, cv::InputOutputArray _mask);

};

#endif /* defined(__imageCut__GCGrabcut__) */
