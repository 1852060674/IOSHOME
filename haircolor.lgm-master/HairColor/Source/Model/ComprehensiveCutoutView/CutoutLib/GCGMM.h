//
//  GCGMM.h
//  imageCut
//
//  Created by shen on 14-6-20.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#ifndef __imageCut__GCGMM__
#define __imageCut__GCGMM__

#include "opencv2/imgproc/imgproc.hpp"
/*
 GCGMM - Gaussian Mixture Model for GrabCut
 */

class GCGMM
{
public:
    static const int componentsCount = 5;
    GCGMM(){};
    GCGMM(const GCGMM&);
    GCGMM(const cv::Mat& _model );
    void useModel(const cv::Mat& _model);
    double operator()( const cv::Vec3d color ) const;
    double operator()( int ci, const cv::Vec3d color ) const;
    int whichComponent( const cv::Vec3d color ) const;
    
    void initLearning();
    void addSample( int ci, const cv::Vec3d color );
    void endLearning();
    
private:
    void calcInverseCovAndDeterm( int ci );
    cv::Mat model;
    double* coefs;
    double* mean;
    double* cov;
    
    double inverseCovs[componentsCount][3][3];
    double covDeterms[componentsCount];
    
    double sums[componentsCount][3];
    double prods[componentsCount][3][3];
    int sampleCounts[componentsCount];
    int totalSampleCount;
};
#endif /* defined(__imageCut__GCGMM__) */
