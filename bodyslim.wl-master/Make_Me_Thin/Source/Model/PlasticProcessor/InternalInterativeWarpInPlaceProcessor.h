//
//  InternalInterativeWarpProcessor.h
//  Plastic Surgeon
//
//  Created by ZB_Mac on 15/6/9.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#ifndef __Plastic_Surgeon__InternalInterativeWarpProcessor__
#define __Plastic_Surgeon__InternalInterativeWarpProcessor__

#include <stdio.h>
#include <opencv2/core/types.hpp>
#include <opencv2/core/mat.hpp>

class InterativeWarpInPlaceProcessor_ {
    // size
    int mWidth;
    int mHeight;
    cv::Mat mMap;
    cv::Mat mProcessingMap;
    
    // para
    float mStrenght;
    bool mSpeedFirst;
    bool mDepressRadialWarp;
    bool mOverlayWarps;
    
    // enlarge
    cv::Point2f enlargeCenter;
    int enlargeRadius;

    // shrink
    cv::Point2f shrinkCenter;
    int shrinkRadius;
    
    // translate
    cv::Point2f startCenter;
    cv::Point2f endCenter;
    int translateRadius;
    
public:
    InterativeWarpInPlaceProcessor_()
    {
        mStrenght = 0.5;
        mWidth = -1;
        mHeight = -1;
    };
    ~InterativeWarpInPlaceProcessor_(){mMap.release(); mProcessingMap.release();};
    
    void fillMatWithProcessingMap(cv::Mat *processingMap);
    void fillProcessingMapWithMat(cv::Mat *processingMap);
    
    void fillMatWithMap(cv::Mat *map);
    void fillMapWithMat(cv::Mat *map);
    
    void fillMapWithProcessingMap();
    // [0, 1];
    void setStrenght(float s){mStrenght = s;};
    
    void setSpeedFirst(bool f){mSpeedFirst = f;};
    void setSize(int width, int height);
    void setOverlayWarps(bool o){mOverlayWarps = o;};
    void setDepressRadialWarp(bool d){mDepressRadialWarp = d;};
    
    int enlarge(cv::Point2f center, float radius);
    int shrink(cv::Point2f center, float radius);
    int translate(cv::Point2f start, cv::Point2f end, float radius);
    int translate(cv::Point2f start1, cv::Point2f end1, float radius1, cv::Point2f start2, cv::Point2f end2, float radius2);
    
    int applyMat(cv::Mat &srcMat, cv::Mat &dstMat);
    int applyPoint(cv::Point2f &srcPoint, cv::Point2f &dstPoint);
        
    void clean();
    
private:
    void coordinateEnlargeOld(const cv::Point2f& xy, cv::Point2f& uv);
    void coordinateShrinkOld(const cv::Point2f& xy, cv::Point2f& uv);
    void coordinateEnlargeNew(const cv::Point2f& xy, cv::Point2f& uv);
    void coordinateShrinkNew(const cv::Point2f& xy, cv::Point2f& uv);
    void coordinateTranslate(const cv::Point2f& xy, cv::Point2f& uv);
    void coordinateTranslateDepressRadialWarp(const cv::Point2f& xy, cv::Point2f& uv);
};

#endif /* defined(__Plastic_Surgeon__InternalInterativeWarpProcessor__) */
