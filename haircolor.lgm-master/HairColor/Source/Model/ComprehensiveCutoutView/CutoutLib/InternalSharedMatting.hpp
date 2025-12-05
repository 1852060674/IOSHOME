//
//  sharedmatting.hpp
//  ShareMatting
//
//  Created by ZB_Mac on 16/9/14.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#ifndef sharedmatting_hpp
#define sharedmatting_hpp

#include <stdio.h>
#include <iostream>
#include <opencv2/imgproc/imgproc_c.h>
#include <opencv2/highgui.hpp>
#include <cmath>
#include <vector>
using namespace std;

struct labelPoint
{
    int x;
    int y;
    int label;
};

struct Tuple
{
    CvScalar f;
    CvScalar b;
    double   sigmaf;
    double   sigmab;
    
    int flag;
    
};

struct Ftuple
{
    CvScalar f;
    CvScalar b;
    double   alphar;
    double   confidence;
};

class InternalSharedMatting
{
public:
    InternalSharedMatting();
    ~InternalSharedMatting();
    
    void loadImage(cv::Mat image);
    void loadTrimap(cv::Mat trimap);
    void expandKnown();
    void sample(CvPoint p, vector<CvPoint>& f, vector<CvPoint>& b);
    void gathering();
    void refineSample();
    void localSmooth();
    void solveAlpha();
    void save(const char * filename);
    void Sample(vector<vector<CvPoint>> &F, vector<vector<CvPoint>> &B);
    void getMatte();
    void release();
    
    double mP(int i, int j, CvScalar f, CvScalar b);
    double nP(int i, int j, CvScalar f, CvScalar b);
    double eP(int i1, int j1, int i2, int j2);
    double pfP(CvPoint p, vector<CvPoint>& f, vector<CvPoint>& b);
    double aP(int i, int j, double pf, CvScalar f, CvScalar b);
    double gP(CvPoint p, CvPoint fp, CvPoint bp, double pf);
    double gP(CvPoint p, CvPoint fp, CvPoint bp, double dpf, double pf);
    double dP(CvPoint s, CvPoint d);
    double sigma2(CvPoint p);
    double distanceColor2(CvScalar cs1, CvScalar cs2);
    double comalpha(CvScalar c, CvScalar f, CvScalar b);
    
    void getMat(cv::Mat &alphaMat);
    
private:

    cv::Mat pImg;
    cv::Mat trimap;

    vector<CvPoint> uT;
    vector<struct Tuple> tuples;
    vector<struct Ftuple> ftuples;
    
    int height;
    int width;
    int kI;
    int kG;
    int ** unknownIndex;//UnknownµƒÀ˜“˝–≈œ¢£ª
    int ** tri;
    int ** alpha;
    double kC;
    
    int step;
    int channels;
    uchar* data;
    
};
#endif /* sharedmatting_hpp */

