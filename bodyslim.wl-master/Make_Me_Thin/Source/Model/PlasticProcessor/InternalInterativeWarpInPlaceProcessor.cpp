//
//  InternalInterativeWarpProcessor.cpp
//  Plastic Surgeon
//
//  Created by ZB_Mac on 15/6/9.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#include "InternalInterativeWarpInPlaceProcessor.h"
#include "opencvUtility.h"

void InterativeWarpInPlaceProcessor_::setSize(int width, int height)
{
    mWidth = width;
    mHeight = height;
    
    if (mWidth>0 && mHeight>0) {
        mMap.release();
        mProcessingMap.release();
        
        mMap.create(mHeight, mWidth, CV_32FC2);
        cv::Point2f *ptr = NULL;
        for (int y=0; y<mHeight; ++y)
        {
            ptr = mMap.ptr<cv::Point2f>(y);
            
            for (int x=0; x<mWidth; ++x) {
                *ptr = cv::Point2f(x, y);
                
                ++ptr;
            }
        }
        
        mMap.copyTo(mProcessingMap);
    }
}

void InterativeWarpInPlaceProcessor_::fillMapWithMat(cv::Mat *map)
{
    if (map) {
        map->copyTo(mMap);
    }
}

void InterativeWarpInPlaceProcessor_::fillMatWithMap(cv::Mat *map)
{
    if (map) {
        mMap.copyTo(*map);
    }
}

void InterativeWarpInPlaceProcessor_::fillProcessingMapWithMat(cv::Mat *processingMap)
{
    if (processingMap) {
        processingMap->copyTo(mProcessingMap);
    }
}

void InterativeWarpInPlaceProcessor_::fillMatWithProcessingMap(cv::Mat *processingMap)
{
    if (processingMap) {
        mProcessingMap.copyTo(*processingMap);
    }
}

void InterativeWarpInPlaceProcessor_::fillMapWithProcessingMap()
{
    mProcessingMap.copyTo(mMap);
}

int InterativeWarpInPlaceProcessor_::applyMat(cv::Mat &srcMat, cv::Mat &dstMat)
{
    if (mWidth<=0 || mHeight<=0 || mMap.data==NULL || srcMat.rows!=mHeight || srcMat.cols!=mWidth) {
        return -1;
    }
    
    dstMat.create(mHeight, mWidth, CV_8UC3);
    
    cv::Point2f *coordinatePtr = NULL;
    cv::Vec3b *dstPtr = NULL;
    
    cv::Point2f uv;
    if (mSpeedFirst) {
        for (int y=0; y<mHeight; ++y) {
            coordinatePtr = mProcessingMap.ptr<cv::Point2f>(y);
            dstPtr = dstMat.ptr<cv::Vec3b>(y);
            
            for (int x=0; x<mWidth; ++x) {
                uv = *coordinatePtr;
                clipPointToImageBounds(mProcessingMap, uv);
                
                *dstPtr = srcMat.at<cv::Vec3b>(uv);
                
                ++coordinatePtr;
                ++dstPtr;
            }
        }
    }
    else
    {
        for (int y=0; y<mHeight; ++y) {
            coordinatePtr = mProcessingMap.ptr<cv::Point2f>(y);
            dstPtr = dstMat.ptr<cv::Vec3b>(y);
            
            for (int x=0; x<mWidth; ++x) {
                uv = *coordinatePtr;
                clipPointToImageBounds(mProcessingMap, uv);
                
                *dstPtr = bilinearInterpolate(srcMat, uv);
                
                ++coordinatePtr;
                ++dstPtr;
            }
        }
    }
    
    return 0;
}

void InterativeWarpInPlaceProcessor_::clean()
{
    mWidth = -1;
    mHeight = -1;
    
    mMap.release();
    mProcessingMap.release();
}

int InterativeWarpInPlaceProcessor_::applyPoint(cv::Point2f &srcPoint, cv::Point2f &dstPoint)
{
    if (mWidth<=0 || mHeight<=0 || !mMap.data || srcPoint.x<0 || srcPoint.x>mWidth-1 || srcPoint.y<0 || srcPoint.y>mHeight-1) {
        return -1;
    }
    
    dstPoint = bilinearInterpolatePoint2f(mMap, srcPoint);

    cv::Point firstGuess(2*srcPoint.x-dstPoint.x, 2*srcPoint.y-dstPoint.y);
    int searchRadius = 10;
    
    float minDifference = MAXFLOAT;

    for (int x=MAX(firstGuess.x-searchRadius, 0); x<MIN(firstGuess.x+searchRadius, mHeight); ++x) {
        for (int y=MAX(firstGuess.y-searchRadius, 0); y<MIN(firstGuess.y+searchRadius, mWidth); ++y) {
            cv::Point2f point = mMap.at<cv::Point2f>(y, x);
            float difference = fabs(point.x-srcPoint.x)+fabs(point.y-srcPoint.y);
            if (difference < minDifference) {
                minDifference = difference;
                dstPoint = cv::Point2f(x,y);
            }
        }
    }
    
    return 0;
}

int InterativeWarpInPlaceProcessor_::enlarge(cv::Point2f center, float radius)
{
    if (mWidth<=0 || mHeight<=0 || !mMap.data || !mProcessingMap.data) {
        return -1;
    }
    
    this->enlargeCenter = center;
    this->enlargeRadius = radius;
    
    cv::Point2f xy, uv;
    cv::Vec3b color;
    
    cv::Rect rect;
    
    rect.x = center.x-radius;
    rect.y = center.y-radius;
    rect.width = 2*radius;
    rect.height = 2*radius;
    
    mMap.copyTo(mProcessingMap);
    
    clipRectToImageBounds(mProcessingMap, rect);
    
    this->enlargeCenter.x -= rect.x;
    this->enlargeCenter.y -= rect.y;
    
    cv::Mat srcROI = mProcessingMap(rect);
    cv::Mat dstROI(srcROI.rows, srcROI.cols, CV_32FC2);
    
    int width = dstROI.cols;
    int height = dstROI.rows;
    
    cv::Vec2f *ptr = NULL;
    
    const float centerSmoothLenght = 1.2;
    const float smoothness = 5.0;
    const float centerEnlargeRate_1 = 1.5;
    float help = centerEnlargeRate_1+tanh((1.0-centerSmoothLenght)*smoothness);
    float distance;
    float rate;
    
    if (mOverlayWarps) {
        for (int y=0; y<height; ++y) {
            for (int x=0; x<width; ++x) {
                xy.x = x; xy.y = y;
                
                distance = sqrt((xy.x-this->enlargeCenter.x)*(xy.x-this->enlargeCenter.x)+(xy.y-this->enlargeCenter.y)*(xy.y-this->enlargeCenter.y));
                
                if (distance <= this->enlargeRadius)
                {
                    rate = 1.0-(1.0-distance/this->enlargeRadius)*(1.0-distance/this->enlargeRadius)*this->mStrenght;
                    rate = (tanh((rate-centerSmoothLenght)*smoothness)+centerEnlargeRate_1)/help;
                    
                    uv.x = this->enlargeCenter.x + (xy.x-this->enlargeCenter.x)*rate;
                    uv.y = this->enlargeCenter.y + (xy.y-this->enlargeCenter.y)*rate;
                }
                else
                {
                    uv = xy;
                }
                
                uv.x+=rect.x; uv.y+=rect.y;
                clipPointToImageBounds(mProcessingMap, uv);
                dstROI.at<cv::Vec2f>(y, x) = uv;
            }
        }
    }
    else
    {
        
        for (int y=0; y<height; ++y) {
            ptr = srcROI.ptr<cv::Vec2f>(y);
            for (int x=0; x<width; ++x) {
                xy = *ptr;
                xy.x-=rect.x; xy.y-=rect.y;
                
                distance = sqrt((xy.x-this->enlargeCenter.x)*(xy.x-this->enlargeCenter.x)+(xy.y-this->enlargeCenter.y)*(xy.y-this->enlargeCenter.y));
                
                if (distance <= this->enlargeRadius)
                {
                    rate = 1.0-(1.0-distance/this->enlargeRadius)*(1.0-distance/this->enlargeRadius)*this->mStrenght;
                    rate = (tanh((rate-centerSmoothLenght)*smoothness)+centerEnlargeRate_1)/help;
                    
                    uv.x = this->enlargeCenter.x + (xy.x-this->enlargeCenter.x)*rate;
                    uv.y = this->enlargeCenter.y + (xy.y-this->enlargeCenter.y)*rate;
                }
                else
                {
                    uv = xy;
                }
                
                uv.x+=rect.x; uv.y+=rect.y;
                clipPointToImageBounds(mProcessingMap, uv);
                dstROI.at<cv::Vec2f>(y, x) = uv;
                
                ++ptr;

            }
        }
    }
    
    dstROI.copyTo(srcROI);
    dstROI.release();
    return 0;
}

int InterativeWarpInPlaceProcessor_::shrink(cv::Point2f center, float radius)
{
    if (mWidth<=0 || mHeight<=0 || mMap.data==NULL) {
        return -1;
    }
    
    this->shrinkCenter = center;
    this->shrinkRadius = radius;
    
    cv::Point2f xy, uv;
    cv::Vec3b color;
    
    cv::Rect rect;
    
    rect.x = center.x-radius;
    rect.y = center.y-radius;
    rect.width = 2*radius;
    rect.height = 2*radius;
    
    mMap.copyTo(mProcessingMap);

    clipRectToImageBounds(mProcessingMap, rect);
    
    this->shrinkCenter.x -= rect.x;
    this->shrinkCenter.y -= rect.y;
    
    cv::Mat srcROI = mProcessingMap(rect);
    cv::Mat dstROI(srcROI.rows, srcROI.cols, CV_32FC2);
    
    int width = dstROI.cols;
    int height = dstROI.rows;
    
    cv::Vec2f *ptr = NULL;
    
    const float centerSmoothLenght = 1.2;
    const float smoothness = 5.0;
    const float centerEnlargeRate_1 = 1.5;
    float help = centerEnlargeRate_1+tanh((1.0-centerSmoothLenght)*smoothness);
    
    float distance;
    float rate;
    
    if (mOverlayWarps) {
        for (int y=0; y<height; ++y) {
            for (int x=0; x<width; ++x) {
                xy.x = x; xy.y = y;
                
                distance = sqrt((xy.x-this->shrinkCenter.x)*(xy.x-this->shrinkCenter.x)+(xy.y-this->shrinkCenter.y)*(xy.y-this->shrinkCenter.y));
                
                if (distance <= this->shrinkRadius)
                {
                    rate = 1+(1.0-distance/this->shrinkRadius)*(1.0-distance/this->shrinkRadius)*this->mStrenght;
                    rate = 2.0-(tanh((2.0-rate-centerSmoothLenght)*smoothness)+centerEnlargeRate_1)/help;
                                        
                    uv.x = this->shrinkCenter.x + (xy.x-this->shrinkCenter.x)*rate;
                    uv.y = this->shrinkCenter.y + (xy.y-this->shrinkCenter.y)*rate;
                }
                else
                {
                    uv = xy;
                }
                
                uv.x+=rect.x; uv.y+=rect.y;
                clipPointToImageBounds(mProcessingMap, uv);
                dstROI.at<cv::Vec2f>(y, x) = uv;
            }
        }
    }
    else
    {
        for (int y=0; y<height; ++y) {
            ptr = srcROI.ptr<cv::Vec2f>(y);
            for (int x=0; x<width; ++x) {
                xy = *ptr;
                xy.x-=rect.x; xy.y-=rect.y;
                
                distance = sqrt((xy.x-this->shrinkCenter.x)*(xy.x-this->shrinkCenter.x)+(xy.y-this->shrinkCenter.y)*(xy.y-this->shrinkCenter.y));
                
                if (distance <= this->shrinkRadius)
                {
                    rate = 1+(1.0-distance/this->shrinkRadius)*(1.0-distance/this->shrinkRadius)*this->mStrenght;
                    rate = 2.0-(tanh((2.0-rate-centerSmoothLenght)*smoothness)+centerEnlargeRate_1)/help;
                    
                    uv.x = this->shrinkCenter.x + (xy.x-this->shrinkCenter.x)*rate;
                    uv.y = this->shrinkCenter.y + (xy.y-this->shrinkCenter.y)*rate;
                }
                else
                {
                    uv = xy;
                }
                
                uv.x+=rect.x; uv.y+=rect.y;
                clipPointToImageBounds(mProcessingMap, uv);
                dstROI.at<cv::Vec2f>(y, x) = uv;
                
                ++ptr;
                
            }
        }
    }
    
    dstROI.copyTo(srcROI);
    dstROI.release();
    return 0;
}

int InterativeWarpInPlaceProcessor_::translate(cv::Point2f start, cv::Point2f end, float radius)
{
    if (mWidth<=0 || mHeight<=0 || mMap.data==NULL) {
        return -1;
    }
    
    float distance = sqrt((end.x-start.x)*(end.x-start.x)+(end.y-start.y)*(end.y-start.y));
    float dx = (end.x-start.x)/distance;
    float dy = (end.y-start.y)/distance;
    dx*=this->mStrenght; dy*=this->mStrenght;
    distance = MIN(distance, radius);
    end.x = start.x+distance*dx;
    end.y = start.y+distance*dy;
    
    this->startCenter = start;
    this->endCenter = end;
    this->translateRadius = radius;
    
    cv::Point2f xy, uv;
    cv::Vec3b color;
    
    cv::Rect rect;
    
    float temp = (this->translateRadius+10)*1.1;
    rect.x = this->startCenter.x-radius;
    rect.y = this->startCenter.y-radius;
    rect.width = temp*2.0;
    rect.height = temp*2.0;
    
    mMap.copyTo(mProcessingMap);
    clipRectToImageBounds(mProcessingMap, rect);
    
    this->startCenter.x -= rect.x;
    this->startCenter.y -= rect.y;
    this->endCenter.x -= rect.x;
    this->endCenter.y -= rect.y;
    
    cv::Mat srcROI = mProcessingMap(rect);
    cv::Mat dstROI(srcROI.rows, srcROI.cols, CV_32FC2);
    
    int width = dstROI.cols;
    int height = dstROI.rows;
    
    cv::Vec2f *ptr = NULL;

    if (mOverlayWarps) {
        if (mDepressRadialWarp) {
            for (int y=0; y<height; ++y) {
                for (int x=0; x<width; ++x) {
                    xy.x=x; xy.y=y;
                    coordinateTranslateDepressRadialWarp(xy, uv);
                    uv.x+=rect.x; uv.y+=rect.y;
                    clipPointToImageBounds(mProcessingMap, uv);
                    dstROI.at<cv::Vec2f>(y, x) = uv;
                }
            }
        }
        else
        {
            for (int y=0; y<height; ++y) {
                for (int x=0; x<width; ++x) {
                    xy.x=x; xy.y=y;
                    coordinateTranslate(xy, uv);
                    uv.x+=rect.x; uv.y+=rect.y;
                    clipPointToImageBounds(mProcessingMap, uv);
                    dstROI.at<cv::Vec2f>(y, x) = uv;
                }
            }
        }
    }
    else
    {
        if (mDepressRadialWarp) {
            for (int y=0; y<height; ++y) {
                ptr = srcROI.ptr<cv::Vec2f>(y);
                for (int x=0; x<width; ++x) {
                    xy = *ptr;
                    xy.x-=rect.x; xy.y-=rect.y;
                    coordinateTranslateDepressRadialWarp (xy, uv);
                    uv.x+=rect.x; uv.y+=rect.y;
                    clipPointToImageBounds(mProcessingMap, uv);
                    dstROI.at<cv::Vec2f>(y, x) = uv;
                    
                    ++ptr;
                }
            }
        }
        else
        {
            for (int y=0; y<height; ++y) {
                ptr = srcROI.ptr<cv::Vec2f>(y);
                for (int x=0; x<width; ++x) {
                    xy = *ptr;
                    xy.x-=rect.x; xy.y-=rect.y;
                    coordinateTranslate (xy, uv);
                    uv.x+=rect.x; uv.y+=rect.y;
                    clipPointToImageBounds(mProcessingMap, uv);
                    dstROI.at<cv::Vec2f>(y, x) = uv;
                    
                    ++ptr;
                }
            }
        }
    }

    
    dstROI.copyTo(srcROI);
    dstROI.release();
    return 0;
}


int InterativeWarpInPlaceProcessor_::translate(cv::Point2f start1, cv::Point2f end1, float radius1, cv::Point2f start2, cv::Point2f end2, float radius2)
{
    if (mWidth<=0 || mHeight<=0 || mMap.data==NULL) {
        return -1;
    }
    
    cv::Point2f xy, uv;
    cv::Vec3b color;
    cv::Rect rect;
    mMap.copyTo(mProcessingMap);

    float distance = sqrt((end1.x-start1.x)*(end1.x-start1.x)+(end1.y-start1.y)*(end1.y-start1.y));
    float dx = (end1.x-start1.x)/distance;
    float dy = (end1.y-start1.y)/distance;
    dx*=this->mStrenght; dy*=this->mStrenght;
//    distance = MIN(distance, radius1*this->mStrenght*this->mStrenght);
    distance = MIN(distance, radius1);
    end1.x = start1.x+distance*dx;
    end1.y = start1.y+distance*dy;
    
    this->startCenter = start1;
    this->endCenter = end1;
    this->translateRadius = radius1;
    
    float temp = (this->translateRadius+10)*1.1;
    rect.x = this->startCenter.x-radius1;
    rect.y = this->startCenter.y-radius1;
    rect.width = temp*2.0;
    rect.height = temp*2.0;
    
    clipRectToImageBounds(mProcessingMap, rect);
    
    this->startCenter.x -= rect.x;
    this->startCenter.y -= rect.y;
    this->endCenter.x -= rect.x;
    this->endCenter.y -= rect.y;
    
    cv::Mat srcROI = mProcessingMap(rect);
    cv::Mat dstROI(srcROI.rows, srcROI.cols, CV_32FC2);
    
    int width = dstROI.cols;
    int height = dstROI.rows;
    
    cv::Vec2f *ptr = NULL;
    
    if (mOverlayWarps) {
        if (mDepressRadialWarp) {
            for (int y=0; y<height; ++y) {
                for (int x=0; x<width; ++x) {
                    xy.x=x; xy.y=y;
                    coordinateTranslateDepressRadialWarp(xy, uv);
                    uv.x+=rect.x; uv.y+=rect.y;
                    clipPointToImageBounds(mProcessingMap, uv);
                    dstROI.at<cv::Vec2f>(y, x) = uv;
                }
            }
        }
        else
        {
            for (int y=0; y<height; ++y) {
                for (int x=0; x<width; ++x) {
                    xy.x=x; xy.y=y;
                    coordinateTranslate(xy, uv);
                    uv.x+=rect.x; uv.y+=rect.y;
                    clipPointToImageBounds(mProcessingMap, uv);
                    dstROI.at<cv::Vec2f>(y, x) = uv;
                }
            }
        }
    }
    else
    {
        if (mDepressRadialWarp) {
            for (int y=0; y<height; ++y) {
                ptr = srcROI.ptr<cv::Vec2f>(y);
                for (int x=0; x<width; ++x) {
                    xy = *ptr;
                    xy.x-=rect.x; xy.y-=rect.y;
                    coordinateTranslateDepressRadialWarp (xy, uv);
                    uv.x+=rect.x; uv.y+=rect.y;
                    clipPointToImageBounds(mProcessingMap, uv);
                    dstROI.at<cv::Vec2f>(y, x) = uv;
                    
                    ++ptr;
                }
            }
        }
        else
        {
            for (int y=0; y<height; ++y) {
                ptr = srcROI.ptr<cv::Vec2f>(y);
                for (int x=0; x<width; ++x) {
                    xy = *ptr;
                    xy.x-=rect.x; xy.y-=rect.y;
                    coordinateTranslate (xy, uv);
                    uv.x+=rect.x; uv.y+=rect.y;
                    clipPointToImageBounds(mProcessingMap, uv);
                    dstROI.at<cv::Vec2f>(y, x) = uv;
                    
                    ++ptr;
                }
            }
        }
    }
    
    dstROI.copyTo(srcROI);
    dstROI.release();
    
    // 2.0
    distance = sqrt((end2.x-start2.x)*(end2.x-start2.x)+(end2.y-start2.y)*(end2.y-start2.y));
    dx = (end2.x-start2.x)/distance;
    dy = (end2.y-start2.y)/distance;
    dx*=this->mStrenght; dy*=this->mStrenght;
//    distance = MIN(distance, radius2*this->mStrenght*this->mStrenght);
    distance = MIN(distance, radius2);

    end2.x = start2.x+distance*dx;
    end2.y = start2.y+distance*dy;
    
    this->startCenter = start2;
    this->endCenter = end2;
    this->translateRadius = radius2;
    
    temp = (this->translateRadius+10)*1.1;
    rect.x = this->startCenter.x-radius2;
    rect.y = this->startCenter.y-radius2;
    rect.width = temp*2.0;
    rect.height = temp*2.0;
    
    clipRectToImageBounds(mProcessingMap, rect);
    
    this->startCenter.x -= rect.x;
    this->startCenter.y -= rect.y;
    this->endCenter.x -= rect.x;
    this->endCenter.y -= rect.y;
    
    srcROI = mProcessingMap(rect);
    dstROI.create(srcROI.rows, srcROI.cols, CV_32FC2);
    
    width = dstROI.cols;
    height = dstROI.rows;
    
    ptr = NULL;
    
    if (mOverlayWarps) {
        if (mDepressRadialWarp) {
            for (int y=0; y<height; ++y) {
                for (int x=0; x<width; ++x) {
                    xy.x=x; xy.y=y;
                    coordinateTranslateDepressRadialWarp(xy, uv);
                    uv.x+=rect.x; uv.y+=rect.y;
                    clipPointToImageBounds(mProcessingMap, uv);
                    dstROI.at<cv::Vec2f>(y, x) = uv;
                }
            }
        }
        else
        {
            for (int y=0; y<height; ++y) {
                for (int x=0; x<width; ++x) {
                    xy.x=x; xy.y=y;
                    coordinateTranslate(xy, uv);
                    uv.x+=rect.x; uv.y+=rect.y;
                    clipPointToImageBounds(mProcessingMap, uv);
                    dstROI.at<cv::Vec2f>(y, x) = uv;
                }
            }
        }
    }
    else
    {
        if (mDepressRadialWarp) {
            for (int y=0; y<height; ++y) {
                ptr = srcROI.ptr<cv::Vec2f>(y);
                for (int x=0; x<width; ++x) {
                    xy = *ptr;

                    xy.x-=rect.x; xy.y-=rect.y;
                    coordinateTranslateDepressRadialWarp (xy, uv);
                    uv.x+=rect.x; uv.y+=rect.y;
                    clipPointToImageBounds(mProcessingMap, uv);
                    dstROI.at<cv::Vec2f>(y, x) = uv;
                    
                    ++ptr;
                }
            }
        }
        else
        {
            for (int y=0; y<height; ++y) {
                ptr = srcROI.ptr<cv::Vec2f>(y);
                for (int x=0; x<width; ++x) {
                    xy = *ptr;
                    xy.x-=rect.x; xy.y-=rect.y;
                    coordinateTranslate (xy, uv);
                    uv.x+=rect.x; uv.y+=rect.y;
                    clipPointToImageBounds(mProcessingMap, uv);
                    dstROI.at<cv::Vec2f>(y, x) = uv;
                    
                    ++ptr;
                }
            }
        }
    }

    
    dstROI.copyTo(srcROI);
    dstROI.release();
    
    return 0;
}

void InterativeWarpInPlaceProcessor_::coordinateEnlargeOld(const cv::Point2f& xy, cv::Point2f& uv)
{
    float distance = sqrt((xy.x-this->enlargeCenter.x)*(xy.x-this->enlargeCenter.x)+(xy.y-this->enlargeCenter.y)*(xy.y-this->enlargeCenter.y));
    if (distance > this->enlargeRadius) {
        uv=xy;
        return;
    }
    
    float rate = 1.0-(1.0-distance/this->enlargeRadius)*(1.0-distance/this->enlargeRadius)*this->mStrenght;
    
    uv.x = this->enlargeCenter.x + (xy.x-this->enlargeCenter.x)*rate;
    uv.y = this->enlargeCenter.y + (xy.y-this->enlargeCenter.y)*rate;
}

void InterativeWarpInPlaceProcessor_::coordinateShrinkOld(const cv::Point2f& xy, cv::Point2f& uv)
{
    float distance = sqrt((xy.x-this->shrinkCenter.x)*(xy.x-this->shrinkCenter.x)+(xy.y-this->shrinkCenter.y)*(xy.y-this->shrinkCenter.y));
    if (distance > this->shrinkRadius) {
        uv=xy;
        return;
    }
    
    float rate = 1.0+(1.0-distance/this->shrinkRadius)*(1.0-distance/this->shrinkRadius)*this->mStrenght;
    
    uv.x = this->shrinkCenter.x + (xy.x-this->shrinkCenter.x)*rate;
    uv.y = this->shrinkCenter.y + (xy.y-this->shrinkCenter.y)*rate;
}

void InterativeWarpInPlaceProcessor_::coordinateEnlargeNew(const cv::Point2f& xy, cv::Point2f& uv)
{
    const float centerSmoothLenght = 1.2;
    const float smoothness = 5.0;
    const float centerEnlargeRate_1 = 1.5;
    float help = centerEnlargeRate_1+tanh((1.0-centerSmoothLenght)*smoothness);
    
    float distance = sqrt((xy.x-this->enlargeCenter.x)*(xy.x-this->enlargeCenter.x)+(xy.y-this->enlargeCenter.y)*(xy.y-this->enlargeCenter.y));
    
    if (distance > this->enlargeRadius) {
        uv=xy;
        return;
    }
    
    float rate = 1.0-(1.0-distance/this->enlargeRadius)*(1.0-distance/this->enlargeRadius)*this->mStrenght;
    rate = (tanh((rate-centerSmoothLenght)*smoothness)+centerEnlargeRate_1)/help;
    
    uv.x = this->enlargeCenter.x + (xy.x-this->enlargeCenter.x)*rate;
    uv.y = this->enlargeCenter.y + (xy.y-this->enlargeCenter.y)*rate;
}

void InterativeWarpInPlaceProcessor_::coordinateShrinkNew(const cv::Point2f& xy, cv::Point2f& uv)
{
    const float centerSmoothLenght = 1.2;
    const float smoothness = 5.0;
    const float centerEnlargeRate_1 = 1.5;
    float help = centerEnlargeRate_1+tanh((1.0-centerSmoothLenght)*smoothness);
    
    float distance = sqrt((xy.x-this->shrinkCenter.x)*(xy.x-this->shrinkCenter.x)+(xy.y-this->shrinkCenter.y)*(xy.y-this->shrinkCenter.y));
    
    if (distance > this->shrinkRadius) {
        uv=xy;
        return;
    }
    
    float rate = 1+(1.0-distance/this->shrinkRadius)*(1.0-distance/this->shrinkRadius)*this->mStrenght;
    rate = 2.0-(tanh((2.0-rate-centerSmoothLenght)*smoothness)+centerEnlargeRate_1)/help;

    uv.x = this->shrinkCenter.x + (xy.x-this->shrinkCenter.x)*rate;
    uv.y = this->shrinkCenter.y + (xy.y-this->shrinkCenter.y)*rate;
}

void InterativeWarpInPlaceProcessor_::coordinateTranslate(const cv::Point2f& xy, cv::Point2f& uv)
{
    cv::Point2f x2c = xy-this->startCenter;
    cv::Point2f x2m = xy-this->endCenter;
    cv::Point2f m2c = this->endCenter-this->startCenter;
    
    float distance = sqrt(x2c.x*x2c.x+x2c.y*x2c.y);
    if (distance >= this->translateRadius) {
        uv=xy;
        return;
    }
    
    float msq = x2m.x*x2m.x+x2m.y*x2m.y;
//    float msq = m2c.x*m2c.x+m2c.y*m2c.y;
    float csq = x2c.x*x2c.x+x2c.y*x2c.y;
    float edge_dist = this->translateRadius*this->translateRadius - csq;
    
    float a = edge_dist/(edge_dist+msq);
    a *= a;
    
    uv = xy - m2c*a;
}

void InterativeWarpInPlaceProcessor_::coordinateTranslateDepressRadialWarp(const cv::Point2f& xy, cv::Point2f& uv)
{
    cv::Point2f x2c = xy-this->startCenter;
    cv::Point2f x2m = xy-this->endCenter;
    cv::Point2f m2c = this->endCenter-this->startCenter;
    
    float distance = sqrt(x2c.x*x2c.x+x2c.y*x2c.y);
    if (distance >= this->translateRadius) {
        uv=xy;
        return;
    }
    
    float msq = x2m.x*x2m.x+x2m.y*x2m.y;
    //    float msq = m2c.x*m2c.x+m2c.y*m2c.y;
    float csq = x2c.x*x2c.x+x2c.y*x2c.y;
    float edge_dist = this->translateRadius*this->translateRadius - csq;
    
    float a = edge_dist/(edge_dist+msq);
    a *= a;
    
    // 径向投影
    
    x2m.x = m2c.x/sqrt(m2c.x*m2c.x+m2c.y*m2c.y);
    x2m.y = m2c.y/sqrt(m2c.x*m2c.x+m2c.y*m2c.y);
    float radialShadowRatio = (x2m.x*x2c.x+x2m.y*x2c.y)*(x2m.x*x2c.x+x2m.y*x2c.y)/(this->translateRadius*this->translateRadius);
    if (radialShadowRatio>0 && radialShadowRatio<1.0)
    {
        radialShadowRatio = 1.0-radialShadowRatio;
        radialShadowRatio *= radialShadowRatio*radialShadowRatio*radialShadowRatio;
        radialShadowRatio *= radialShadowRatio*radialShadowRatio*radialShadowRatio;
        radialShadowRatio *= radialShadowRatio*radialShadowRatio*radialShadowRatio;

//        radialShadowRatio = (-log2f(1.0-radialShadowRatio)+1);

        a *= radialShadowRatio;//*radialShadowRatio*radialShadowRatio*radialShadowRatio;
    }
    
//    printf("%f\n", radialShadowRatio);

    uv = xy - m2c*a;
}