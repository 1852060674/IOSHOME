//
//  MoleRemover2.cpp
//  Test
//
//  Created by ZB_Mac on 16/1/18.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#include "InternalMoleRemover_New.hpp"
#include <stdlib.h>
#include <queue>
#import <opencv2/imgproc/types_c.h>
#include "SkinDetect.h"
//#import <sketchLib2.0_iOS/SkinDetect.h>
#define ORIGINAL_MOLE_FLAG 0x01
#define COUTOUR_MOLE_FLAG 0x03
#define SYNTHESIS_MOLE_FLAG 0x05


static const int g_GridRadius = 2;
static const int g_GoodMatchThreshold = (g_GridRadius*2+1)*(g_GridRadius*2+1)*3*3;

const int DistanceMap[512] = {
    255, 254, 253, 252, 251, 250, 249, 248, 247, 246, 245, 244, 243, 242, 241, 240,
    239, 238, 237, 236, 235, 234, 233, 232, 231, 230, 229, 228, 227, 226, 225, 224,
    223, 222, 221, 220, 219, 218, 217, 216, 215, 214, 213, 212, 211, 210, 209, 208,
    207, 206, 205, 204, 203, 202, 201, 200, 199, 198, 197, 196, 195, 194, 193, 192,
    191, 190, 189, 188, 187, 186, 185, 184, 183, 182, 181, 180, 179, 178, 177, 176,
    175, 174, 173, 172, 171, 170, 169, 168, 167, 166, 165, 164, 163, 162, 161, 160,
    159, 158, 157, 156, 155, 154, 153, 152, 151, 150, 149, 148, 147, 146, 145, 144,
    143, 142, 141, 140, 139, 138, 137, 136, 135, 134, 133, 132, 131, 130, 129, 128,
    127, 126, 125, 124, 123, 122, 121, 120, 119, 118, 117, 116, 115, 114, 113, 112,
    111, 110, 109, 108, 107, 106, 105, 104, 103, 102, 101, 100, 99, 98, 97, 96,
    95, 94, 93, 92, 91, 90, 89, 88, 87, 86, 85, 84, 83, 82, 81, 80,
    79, 78, 77, 76, 75, 74, 73, 72, 71, 70, 69, 68, 67, 66, 65, 64,
    63, 62, 61, 60, 59, 58, 57, 56, 55, 54, 53, 52, 51, 50, 49, 48,
    47, 46, 45, 44, 43, 42, 41, 40, 39, 38, 37, 36, 35, 34, 33, 32,
    31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16,
    15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
    17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32,
    33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48,
    49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64,
    65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80,
    81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96,
    97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112,
    113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128,
    129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144,
    145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160,
    161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176,
    177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192,
    193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208,
    209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224,
    225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240,
    241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255,
};

const int* g_DistanceMap = DistanceMap+255;

typedef struct Neighbour {
    cv::Point2i sourceOf;
    cv::Point2i offset;
    cv::Vec3b pixel;
} Neighbour;

static int exampleBasedTextureSynthesis(cv::Mat &srcMat, cv::Mat &targetRegion);
int prepareMoleRegionAndSkinRegion(cv::Mat srcMat, cv::Mat &moleRegion);
int prepareTargetContourPoints(cv::Mat &targetMoleMask, std::queue<cv::Point> &targetContourPoints);
int computeDistance(cv::Mat &srcMat, cv::Mat &targetMat, int targetX, int targetY, int corpusX, int corpusY, Neighbour *neighbours, int neighbourCount);
int findBestMatchPatch(cv::Mat &srcMat, cv::Mat &targetMat, cv::Mat &sourceOfMap, int targetX, int targetY, int &matchX, int &matchY);

int removeMoleNew(cv::Mat srcMat, cv::Point center, int radius)
{
    cv::Mat moleRegionMat(srcMat.size(), CV_8UC1, cv::Scalar(0));

    cv::circle(moleRegionMat, center, radius, cv::Scalar(ORIGINAL_MOLE_FLAG), -1);
    
//    cv::cvtColor(moleRegionMat, srcMat, CV_GRAY2RGB);
    exampleBasedTextureSynthesis(srcMat, moleRegionMat);
    
    return 0;
}

int removeMoleNew(cv::Mat srcMat, cv::Rect faceRect)
{
    cv::Mat moleRegionMat(srcMat.size(), CV_8UC1, cv::Scalar(0));

    prepareMoleRegionAndSkinRegion(srcMat, moleRegionMat);
    
    exampleBasedTextureSynthesis(srcMat, moleRegionMat);
    
    return 0;
}

int exampleBasedTextureSynthesis(cv::Mat &srcMat, cv::Mat &targetRegion)
{
    std::queue<cv::Point> targetContourPoints;
    prepareTargetContourPoints(targetRegion, targetContourPoints);
    cv::Mat sourceOfMap(srcMat.size(), CV_32SC2, cv::Vec2i(-1, -1));
    int bestX, bestY;
    int bestDistance;
    while (!targetContourPoints.empty()) {
        cv::Point position = targetContourPoints.front();
        
//        if (position.x==489 && position.y==906) {
//            position = position;
//        }
        
        targetContourPoints.pop();
        
        bestDistance = findBestMatchPatch(srcMat, targetRegion, sourceOfMap, position.x, position.y, bestX, bestY);
        
        sourceOfMap.at<cv::Vec2i>(position) = cv::Vec2i(bestX, bestY);
        targetRegion.at<uchar>(position) = SYNTHESIS_MOLE_FLAG;
        srcMat.at<cv::Vec3b>(position) = srcMat.at<cv::Vec3b>(bestY, bestX);
        
//        printf("Original: (%d, %d); Match: (%d, %d); Distance: %d; Match Pixel Type: %d\n", position.x, position.y, bestX, bestY, bestDistance, targetRegion.at<uchar>(bestY, bestX));
        
        cv::Point point(position.x-1, position.y);
        if (point.x>=0 && point.x<srcMat.cols && point.y>=0 && point.y<srcMat.rows && targetRegion.at<uchar>(point)==ORIGINAL_MOLE_FLAG)
        {
            targetRegion.at<uchar>(point)=COUTOUR_MOLE_FLAG;
            targetContourPoints.push(point);
        }
        point = cv::Point(position.x+1, position.y);
        if (point.x>=0 && point.x<srcMat.cols && point.y>=0 && point.y<srcMat.rows && targetRegion.at<uchar>(point)==ORIGINAL_MOLE_FLAG)
        {
            targetRegion.at<uchar>(point)=COUTOUR_MOLE_FLAG;
            targetContourPoints.push(point);
        }
        point = cv::Point(position.x, position.y-1);
        if (point.x>=0 && point.x<srcMat.cols && point.y>=0 && point.y<srcMat.rows && targetRegion.at<uchar>(point)==ORIGINAL_MOLE_FLAG)
        {
            targetRegion.at<uchar>(point)=COUTOUR_MOLE_FLAG;
            targetContourPoints.push(point);
        }
        point = cv::Point(position.x, position.y+1);
        if (point.x>=0 && point.x<srcMat.cols && point.y>=0 && point.y<srcMat.rows && targetRegion.at<uchar>(point)==ORIGINAL_MOLE_FLAG)
        {
            targetRegion.at<uchar>(point)=COUTOUR_MOLE_FLAG;
            targetContourPoints.push(point);
        }
    }
    
    return 0;
}

int computeDistance(cv::Mat &srcMat, cv::Mat &targetMat, int targetX, int targetY, int corpusX, int corpusY, Neighbour *neighbours, int neighbourCount)
{
    int targetXX, targetYY;
    int corpusXX, corpusYY;
    
    int distanceR = 0;
    int distanceG = 0;
    int distanceB = 0;
    
    for (int idx=0; idx<neighbourCount; ++idx) {
        targetXX = targetX+neighbours[idx].offset.x;
        targetYY = targetY+neighbours[idx].offset.y;
        corpusXX = corpusX+neighbours[idx].offset.x;
        corpusYY = corpusY+neighbours[idx].offset.y;
        
        if (corpusXX>=0 && corpusXX<srcMat.cols && corpusYY>=0 && corpusYY<srcMat.rows) {
            if (targetMat.at<uchar>(corpusYY, corpusXX)!=0 && targetMat.at<uchar>(corpusYY, corpusXX)!=SYNTHESIS_MOLE_FLAG)
            {
                return INT32_MAX;
            }
            cv::Vec3b corpusValue = srcMat.at<cv::Vec3b>(corpusYY, corpusXX);
            cv::Vec3b &neighbourValue = neighbours[idx].pixel;
            distanceR += g_DistanceMap[neighbourValue[0]-corpusValue[0]];
            distanceG += g_DistanceMap[neighbourValue[1]-corpusValue[1]];
            distanceB += g_DistanceMap[neighbourValue[2]-corpusValue[2]];
        }
    }
    return distanceR+distanceG+distanceB;
}

int findBestMatchPatch(cv::Mat &srcMat, cv::Mat &targetMat, cv::Mat &sourceOfMap, int targetX, int targetY, int &matchX, int &matchY)
{
    int yStart=MAX(0, targetY-g_GridRadius), yEnd=MIN(srcMat.rows-1, targetY+g_GridRadius);
    int xStart=MAX(0, targetX-g_GridRadius), xEnd=MIN(srcMat.cols-1, targetX+g_GridRadius);
    
    // prepare neighbours
    Neighbour neighbours[(2*g_GridRadius+1)*(2*g_GridRadius+1)];
    int neighbourCount = 0;
    
    neighbours[neighbourCount].sourceOf = sourceOfMap.at<cv::Vec2i>(targetY, targetX);
    neighbours[neighbourCount].offset = cv::Point(0, 0);
    neighbours[neighbourCount].pixel = srcMat.at<cv::Vec3b>(targetY, targetX);
    ++neighbourCount;
    
    cv::Vec3b *srcPtr;
    uchar *targetPtr;
    cv::Vec2i *sourceOfPtr;

    for (int y=yStart; y<=yEnd; ++y) {
        srcPtr = srcMat.ptr<cv::Vec3b>(y)+xStart;
        targetPtr = targetMat.ptr<uchar>(y)+xStart;
        sourceOfPtr = sourceOfMap.ptr<cv::Vec2i>(y)+xStart;
        
        for (int x=xStart; x<xEnd; ++x) {
            
            if (*targetPtr==SYNTHESIS_MOLE_FLAG || *targetPtr==0) {
                if (*targetPtr==SYNTHESIS_MOLE_FLAG) {
                    neighbours[neighbourCount].sourceOf = *sourceOfPtr;
                }
                else
                {
                    neighbours[neighbourCount].sourceOf = cv::Vec2i(-1, -1);
                }
                neighbours[neighbourCount].offset = cv::Point(x-targetX, y-targetY);
                neighbours[neighbourCount].pixel = *srcPtr;
                
                ++neighbourCount;
            }
            
            ++srcPtr;
            ++targetPtr;
            ++sourceOfPtr;
        }
    }
    
    int32_t bestDistance = INT32_MAX;
    int32_t distance = 0;
    // find best match from neighbour
    int bestCorpusX = targetX, bestCorpusY = targetY;
    int corpusX, corpusY;
    for (int idx=0; idx<neighbourCount; ++idx) {
        corpusX = neighbours[idx].sourceOf.x;
        corpusY = neighbours[idx].sourceOf.y;
        
        if (corpusX!=-1) {
            corpusX -= neighbours[idx].offset.x;
            corpusY -= neighbours[idx].offset.y;
            
            if (corpusX>=0 && corpusX<srcMat.cols && corpusY>=0 && corpusY<srcMat.rows && targetMat.at<uchar>(corpusY, corpusX)==0)
            {
                distance = computeDistance(srcMat, targetMat, targetX, targetY, corpusX, corpusY, neighbours, neighbourCount);
                if (bestDistance > distance) {
                    bestDistance = distance;
                    bestCorpusX = corpusX;
                    bestCorpusY = corpusY;
                }
            }
        }
    }
    
    if (bestDistance < g_GoodMatchThreshold) {
        matchX = bestCorpusX;
        matchY = bestCorpusY;
        return bestDistance;
    }
    
    const static int s_SearchRange=4;
    yStart=MAX(g_GridRadius, targetY-g_GridRadius*s_SearchRange), yEnd=MIN(srcMat.rows-g_GridRadius, targetY+g_GridRadius*s_SearchRange);
    xStart=MAX(g_GridRadius, targetX-g_GridRadius*s_SearchRange), xEnd=MIN(srcMat.cols-g_GridRadius, targetX+g_GridRadius*s_SearchRange);
    
    for (int y=yStart; y<yEnd; ++y) {
        
//        if (abs(y-targetGridCenterY)>g_GridRadius*2)
        {
            for (int x=xStart; x<xEnd; ++x) {
//                if (abs(x-targetGridCenterX)>g_gridRadius*2)
                if (x>=0 && x<srcMat.cols && y>=0 && y<srcMat.rows && targetMat.at<uchar>(y, x)==0)
                {
                    distance = computeDistance(srcMat, targetMat, targetX, targetY, x, y, neighbours, neighbourCount);
                    if (distance<bestDistance) {
                        bestCorpusX = x;
                        bestCorpusY = y;
                        bestDistance = distance;
                    }
                }
            }
        }
    }

    matchX = bestCorpusX;
    matchY = bestCorpusY;
    return bestDistance;
}


int prepareTargetContourPoints(cv::Mat &moleRegion, std::queue<cv::Point> &moles)
{
    cv::Mat dilatedMoleRegion;
    cv::erode(moleRegion, dilatedMoleRegion, cv::Mat());
    
    int width = moleRegion.cols;
    int height = moleRegion.rows;
    uchar *molePtr;
    uchar *dilatedMolePtr;
    
    for (int y=0; y<height; ++y) {
        molePtr = moleRegion.ptr<uchar>(y);
        dilatedMolePtr = dilatedMoleRegion.ptr<uchar>(y);
        
        for (int x=0; x<width; ++x) {
            if ((*molePtr)==ORIGINAL_MOLE_FLAG)
            {
                if (*dilatedMolePtr==0) {
                    moles.push(cv::Point(x,y));
                    *molePtr = COUTOUR_MOLE_FLAG;
                }
            }
            
            ++molePtr;
            ++dilatedMolePtr;
        }
    }
    
    return 0;
}

int prepareMoleRegionAndSkinRegion(cv::Mat srcMat, cv::Mat &moleRegion)
{
    static const int skinFlag = 0x01;
    static const int moleFlag = 0x02;
    
    cv::Mat graySrc;
    cv::cvtColor(srcMat, graySrc, CV_RGB2GRAY);
    
    cv::Mat gaussianSrc;
    cv::GaussianBlur(graySrc, gaussianSrc, cv::Size(7, 7), 0);
//    graySrc.copyTo(gaussianSrc);
    cv::GaussianBlur(gaussianSrc, graySrc, cv::Size(25, 25), 0);
    
    uchar *grayPtr, *grayGaussianPtr;
    cv::Vec3b *srcPtr, *hsvPtr;
    
    int height = srcMat.rows;
    int width = srcMat.cols;
    
    for (int y=0; y<height; ++y) {
        grayPtr = graySrc.ptr<uchar>(y);
        grayGaussianPtr = gaussianSrc.ptr<uchar>(y);
        
        for (int x=0; x<width; ++x) {
            
            float result;
            result = *grayGaussianPtr+(127-*grayPtr);
            
            if (result < 120)
            {
                *grayGaussianPtr = moleFlag+skinFlag;
            }
            else
            {
                *grayGaussianPtr = 0;
            }
            
            ++grayPtr;
            ++grayGaussianPtr;
            ++hsvPtr;
            ++srcPtr;
        }
    }
    
    uchar *dstPtr;
    cv::Mat candidateMat(srcMat.size(), CV_32SC1, cv::Scalar(0));
    int candidateCount=0;
    uint32_t *candidatePtr;
    for (int y=0; y<height; ++y) {
        dstPtr = gaussianSrc.ptr<uchar>(y);
        candidatePtr = candidateMat.ptr<uint32_t>(y);
        for (int x=0; x<width; ++x) {
            if (*dstPtr == (moleFlag+skinFlag)) {
                if (*candidatePtr == 0) {
                    // TODO: find all pixels belong to the same candidate spot
                    
                    candidateCount += 1;
                    std::vector<cv::Point> stack;
                    stack.push_back(cv::Point(x, y));
                    candidateMat.at<uint32_t>(cv::Point(x, y)) = candidateCount;
                    cv::Point point;
                    while (!stack.empty()) {
                        point = stack.back();
                        stack.pop_back();
                        
                        if (point.x-1 >=0) {
                            // left
                            if (gaussianSrc.at<uchar>(cv::Point(point.x-1, point.y)) == (moleFlag+skinFlag) && candidateMat.at<uint32_t>(cv::Point(point.x-1, point.y)) == 0) {
                                stack.push_back(cv::Point(point.x-1, point.y));
                                candidateMat.at<uint32_t>(cv::Point(point.x-1, point.y)) = candidateCount;
                                
                            }
                        }
                        if (point.x+1 <width) {
                            // right
                            if (gaussianSrc.at<uchar>(cv::Point(point.x+1, point.y)) == (moleFlag+skinFlag) && candidateMat.at<uint32_t>(cv::Point(point.x+1, point.y)) == 0) {
                                stack.push_back(cv::Point(point.x+1, point.y));
                                candidateMat.at<uint32_t>(cv::Point(point.x+1, point.y)) = candidateCount;
                                
                            }
                        }
                        if (point.y-1 >=0) {
                            // up
                            if (gaussianSrc.at<uchar>(cv::Point(point.x, point.y-1)) == (moleFlag+skinFlag) && candidateMat.at<uint32_t>(cv::Point(point.x, point.y-1)) == 0) {
                                stack.push_back(cv::Point(point.x, point.y-1));
                                candidateMat.at<uint32_t>(cv::Point(point.x, point.y-1)) = candidateCount;
                                
                            }
                        }
                        if (point.y+1 <height) {
                            // down
                            if (gaussianSrc.at<uchar>(cv::Point(point.x, point.y+1)) == (moleFlag+skinFlag) && candidateMat.at<uint32_t>(cv::Point(point.x, point.y+1)) == 0) {
                                stack.push_back(cv::Point(point.x, point.y+1));
                                candidateMat.at<uint32_t>(cv::Point(point.x, point.y+1)) = candidateCount;
                            }
                        }
                    }
                }
            }
            else
            {
                *candidatePtr = 0;
            }
            ++dstPtr;
            ++candidatePtr;
        }
    }
    
    int *candidateArea = new int[candidateCount+1];
    int *candidatePerimeter = new int[candidateCount+1];
    int *candidateLeftMost = new int[candidateCount+1];
    int *candidateRightMost = new int[candidateCount+1];
    int *candidateTopMost = new int[candidateCount+1];
    int *candidateBottomMost = new int[candidateCount+1];
    int *candidateValid = new int[candidateCount+1];
    
    memset(candidateArea, 0, sizeof(int)*(candidateCount+1));
    memset(candidatePerimeter, 0, sizeof(int)*(candidateCount+1));
    memset(candidateLeftMost, 0, sizeof(int)*(candidateCount+1));
    memset(candidateRightMost, 0, sizeof(int)*(candidateCount+1));
    memset(candidateTopMost, 0, sizeof(int)*(candidateCount+1));
    memset(candidateBottomMost, 0, sizeof(int)*(candidateCount+1));
    memset(candidateValid, -1, sizeof(int)*(candidateCount+1));
    
    for (int y=0; y<height; ++y) {
        dstPtr = graySrc.ptr<uchar>(y);
        candidatePtr = candidateMat.ptr<uint32_t>(y);
        for (int x=0; x<width; ++x) {
            uint32_t candidateIdx = *candidatePtr;
            candidateArea[candidateIdx] += 1;
            
            if (candidateArea[candidateIdx] == 1) {
                candidateLeftMost[candidateIdx] = x;
            }
            else if (candidateLeftMost[candidateIdx] > x) {
                candidateLeftMost[candidateIdx] = x;
            }
            
            if (candidateRightMost[candidateIdx] < x) {
                candidateRightMost[candidateIdx] = x;
            }
            
            if (candidateArea[candidateIdx] == 1) {
                candidateTopMost[candidateIdx] = y;
            }
            else if (candidateTopMost[candidateIdx] > y) {
                candidateTopMost[candidateIdx] = y;
            }
            
            if (candidateBottomMost[candidateIdx] < y) {
                candidateBottomMost[candidateIdx] = y;
            }
            
            if (candidateIdx != 0) {
                
                int preimeter = 4;
                if (x-1 >=0) {
                    // left
                    if (candidateMat.at<uint32_t>(cv::Point(x-1, y)) == candidateIdx) {
                        preimeter -= 1;
                    }
                }
                if (x+1 <width) {
                    // right
                    if (candidateMat.at<uint32_t>(cv::Point(x+1, y)) == candidateIdx) {
                        preimeter -= 1;
                    }
                }
                if (y-1 >=0) {
                    // up
                    if (candidateMat.at<uint32_t>(cv::Point(x, y-1)) == candidateIdx) {
                        preimeter -= 1;
                    }
                }
                if (y+1 <height) {
                    // down
                    if (candidateMat.at<uint32_t>(cv::Point(x, y+1)) == candidateIdx) {
                        preimeter -= 1;
                    }
                }
                candidatePerimeter[candidateIdx] += preimeter;
            }
            
            ++candidatePtr;
            ++dstPtr;
        }
    }
    
    for (int idx=0; idx<candidateCount; ++idx) {
        if (candidateArea[idx] < 5 || candidateArea[idx] > 100) {
            candidateValid[idx] = 0;
            continue;
        }
        int width = candidateRightMost[idx]-candidateLeftMost[idx]+1;
        int height = candidateBottomMost[idx]-candidateTopMost[idx]+1;
        
        if (abs(width-height)>3 || width>15 || height>15) {
            candidateValid[idx] = 0;
            continue;
        }
        
        if (candidateArea[idx]*1.0/(MAX(width, height)*MAX(width, height)) < 0.5) {
            candidateValid[idx] = 0;
            continue;
        }

        candidateValid[idx] = 1;
    }
    
    for (int y=0; y<height; ++y) {
        candidatePtr = candidateMat.ptr<uint32_t>(y);
        grayPtr = moleRegion.ptr<uchar>(y);
        srcPtr = srcMat.ptr<cv::Vec3b>(y);
        for (int x=0; x<width; ++x) {
            
            if (candidateValid[*candidatePtr]!=0 && isSkinRGB((*srcPtr)[0], (*srcPtr)[1], (*srcPtr)[2]) && isSkinRG((*srcPtr)[0], (*srcPtr)[1], (*srcPtr)[2]))
            {
                *grayPtr = ORIGINAL_MOLE_FLAG;

            }
            else
            {
                *grayPtr = 0;
            }
            
            ++srcPtr;
            ++grayPtr;
            ++candidatePtr;
        }
    }
    
    cv::dilate(moleRegion, gaussianSrc, cv::Mat());
    gaussianSrc.copyTo(moleRegion);
    
    delete [] candidateArea;
    delete [] candidatePerimeter;
    delete [] candidateLeftMost;
    delete [] candidateRightMost;
    delete [] candidateTopMost;
    delete [] candidateBottomMost;
    delete [] candidateValid;
    
    return 0;
}