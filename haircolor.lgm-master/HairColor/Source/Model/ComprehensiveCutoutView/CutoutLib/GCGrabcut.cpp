//
//  GCGrabcut.cpp
//  imageCut
//
//  Created by shen on 14-6-20.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#include "GCGrabcut.h"
#include "gcgraph-double.hpp"
#include "sys/time.h"
#include <opencv2/core/types_c.h>

//#define DEBUG 1

using namespace cv;
static double MyCalcBeta( const Mat& img )
{
    double beta = 0;
    for( int y = 0; y < img.rows; y++ )
    {
        for( int x = 0; x < img.cols; x++ )
        {
            Vec3d color = img.at<Vec3b>(y,x);
            if( x>0 ) // left
            {
                Vec3d diff = color - (Vec3d)img.at<Vec3b>(y,x-1);
                beta += diff.dot(diff);
            }
            if( y>0 && x>0 ) // upleft
            {
                Vec3d diff = color - (Vec3d)img.at<Vec3b>(y-1,x-1);
                beta += diff.dot(diff);
            }
            if( y>0 ) // up
            {
                Vec3d diff = color - (Vec3d)img.at<Vec3b>(y-1,x);
                beta += diff.dot(diff);
            }
            if( y>0 && x<img.cols-1) // upright
            {
                Vec3d diff = color - (Vec3d)img.at<Vec3b>(y-1,x+1);
                beta += diff.dot(diff);
            }
        }
    }
    if( beta <= std::numeric_limits<double>::epsilon() )
        beta = 0;
    else
        beta = 1.f / (2 * beta/(4*img.cols*img.rows - 3*img.cols - 3*img.rows + 2) );
    
    return beta;
}

/*
 Calculate weights of noterminal vertices of graph.
 beta and gamma - parameters of GrabCut algorithm.
 */
static void MyCalcNWeights( const Mat& img, const Mat& mask, Mat& leftW, Mat& upleftW, Mat& upW, Mat& uprightW, double beta, double gamma )
{
    const double gammaDivSqrt2 = gamma / std::sqrt(2.0f);
    leftW.create( img.rows, img.cols, CV_64FC1 );
    upleftW.create( img.rows, img.cols, CV_64FC1 );
    upW.create( img.rows, img.cols, CV_64FC1 );
    uprightW.create( img.rows, img.cols, CV_64FC1 );
    for( int y = 0; y < img.rows; y++ )
    {
        for( int x = 0; x < img.cols; x++ )
        {
            uchar val = mask.at<uchar>(y,x);
            if (val == GC_IGNORE) {
                continue;
            }
            Vec3d color = img.at<Vec3b>(y,x);
            if( x-1>=0 ) // left
            {
                Vec3d diff = color - (Vec3d)img.at<Vec3b>(y,x-1);
                leftW.at<double>(y,x) = gamma * exp(-beta*diff.dot(diff));
            }
            else
                leftW.at<double>(y,x) = 0;
            if( x-1>=0 && y-1>=0 ) // upleft
            {
                Vec3d diff = color - (Vec3d)img.at<Vec3b>(y-1,x-1);
                upleftW.at<double>(y,x) = gammaDivSqrt2 * exp(-beta*diff.dot(diff));
            }
            else
                upleftW.at<double>(y,x) = 0;
            if( y-1>=0 ) // up
            {
                Vec3d diff = color - (Vec3d)img.at<Vec3b>(y-1,x);
                upW.at<double>(y,x) = gamma * exp(-beta*diff.dot(diff));
            }
            else
                upW.at<double>(y,x) = 0;
            if( x+1<img.cols && y-1>=0 ) // upright
            {
                Vec3d diff = color - (Vec3d)img.at<Vec3b>(y-1,x+1);
                uprightW.at<double>(y,x) = gammaDivSqrt2 * exp(-beta*diff.dot(diff));
            }
            else
                uprightW.at<double>(y,x) = 0;
        }
    }
}

/*
 Check size, type and element values of mask matrix.
 */
static void MyCheckMask( const Mat& img, const Mat& mask )
{
    if( mask.empty() )
        CV_Error( CV_StsBadArg, "mask is empty" );
    if( mask.type() != CV_8UC1 )
        CV_Error( CV_StsBadArg, "mask must have CV_8UC1 type" );
    if( mask.cols != img.cols || mask.rows != img.rows )
        CV_Error( CV_StsBadArg, "mask must have as many rows and cols as img" );
    for( int y = 0; y < mask.rows; y++ )
    {
        for( int x = 0; x < mask.cols; x++ )
        {
            uchar val = mask.at<uchar>(y,x);
            if( val!=GC_BGD && val!=GC_FGD && val!=GC_PR_BGD && val!=GC_PR_FGD && val!=GC_IGNORE && val!=GC_UNKNOWN)
                CV_Error( CV_StsBadArg, "mask element value must be equel"
                         "GC_BGD or GC_FGD or GC_PR_BGD or GC_PR_FGD or GC_IGNORE or GC_UNKNOWN" );
        }
    }
}

/*
 Initialize mask using rectangular.
 */
static void MyInitMaskWithRect( Mat& mask, Size imgSize, Rect rect )
{
    mask.create( imgSize, CV_8UC1 );
    mask.setTo( GC_BGD );
    
    rect.x = max(0, rect.x);
    rect.y = max(0, rect.y);
    rect.width = min(rect.width, imgSize.width-rect.x);
    rect.height = min(rect.height, imgSize.height-rect.y);
    
    (mask(rect)).setTo( Scalar(GC_PR_FGD) );
}

/*
 Initialize GCGMM background and foreground models using kmeans algorithm.
 */
static void MyInitGMMs( const Mat& img, const Mat& mask, GCGMM& bgdGMM, GCGMM& fgdGMM )
{
    const int kMeansItCount = 10;
    const int kMeansType = KMEANS_PP_CENTERS;
    
    Mat bgdLabels, fgdLabels;
    std::vector<Vec3f> bgdSamples, fgdSamples;
    Point p;
    for( p.y = 0; p.y < img.rows; p.y++ )
    {
        for( p.x = 0; p.x < img.cols; p.x++ )
        {
            uchar val = mask.at<uchar>(p);

            if( val == GC_BGD || val == GC_PR_BGD )
                bgdSamples.push_back( (Vec3f)img.at<Vec3b>(p) );
            else if (val == GC_FGD || val == GC_PR_FGD)
                fgdSamples.push_back( (Vec3f)img.at<Vec3b>(p) );
        }
    }
    CV_Assert( !bgdSamples.empty() && !fgdSamples.empty() );
    Mat _bgdSamples( (int)bgdSamples.size(), 3, CV_32FC1, &bgdSamples[0][0] );
    kmeans( _bgdSamples, GCGMM::componentsCount, bgdLabels,
           TermCriteria( CV_TERMCRIT_ITER, kMeansItCount, 0.0), 0, kMeansType );
    Mat _fgdSamples( (int)fgdSamples.size(), 3, CV_32FC1, &fgdSamples[0][0] );
    kmeans( _fgdSamples, GCGMM::componentsCount, fgdLabels,
           TermCriteria( CV_TERMCRIT_ITER, kMeansItCount, 0.0), 0, kMeansType );
    
    bgdGMM.initLearning();
    for( int i = 0; i < (int)bgdSamples.size(); i++ )
        bgdGMM.addSample( bgdLabels.at<int>(i,0), bgdSamples[i] );
    bgdGMM.endLearning();
    
    fgdGMM.initLearning();
    for( int i = 0; i < (int)fgdSamples.size(); i++ )
        fgdGMM.addSample( fgdLabels.at<int>(i,0), fgdSamples[i] );
    fgdGMM.endLearning();
}

/*
 Assign GCGMMs components for each pixel.
 */
static void MyAssignGMMsComponents( const Mat& img, const Mat& mask, const GCGMM& bgdGMM, const GCGMM& fgdGMM, Mat& compIdxs )
{
    Point p;
    for( p.y = 0; p.y < img.rows; p.y++ )
    {
        for( p.x = 0; p.x < img.cols; p.x++ )
        {
            uchar val = mask.at<uchar>(p);
            
            Vec3d color = img.at<Vec3b>(p);
            if( val == GC_BGD || val == GC_PR_BGD )
                compIdxs.at<int>(p) = bgdGMM.whichComponent(color);
            else if (val == GC_FGD || val == GC_PR_FGD)
                compIdxs.at<int>(p) = fgdGMM.whichComponent(color);
            else
                continue;
        }
    }
}

/*
 Learn GCGMMs parameters.
 */
static void MyLearnGMMs( const Mat& img, const Mat& mask, const Mat& compIdxs, GCGMM& bgdGMM, GCGMM& fgdGMM )
{
    bgdGMM.initLearning();
    fgdGMM.initLearning();
    Point p;
    
    for( p.y = 0; p.y < img.rows; p.y++ )
    {
        for( p.x = 0; p.x < img.cols; p.x++ )
        {
            uchar val = mask.at<uchar>(p);
            int ci = compIdxs.at<int>(p);

            if( val == GC_BGD || val == GC_PR_BGD )
                bgdGMM.addSample( ci, img.at<Vec3b>(p) );
            else if (val == GC_FGD || val == GC_PR_FGD)
                fgdGMM.addSample( ci, img.at<Vec3b>(p) );
        }
    }
    
    bgdGMM.endLearning();
    fgdGMM.endLearning();
}

/*
 Construct MyGCGraph
 */
static void MyconstructGCGraph( const Mat& img, const Mat& mask, const GCGMM& bgdGMM, const GCGMM& fgdGMM, double lambda,
                               const Mat& leftW, const Mat& upleftW, const Mat& upW, const Mat& uprightW,
                               MyGCGraph_double& graph )
{
//    int vtxCount = img.cols*img.rows,
//    edgeCount = 2*(4*img.cols*img.rows - 3*(img.cols + img.rows) + 2);
//    graph.create(vtxCount, edgeCount);
    Point p;
    Point leftP, upLeftP, upP, upRightP;
    
    int leftIdx, upLeftIdx, upIdx, upRightIdx;
    Mat nodeIdxMat(img.size(), CV_32SC1);
    
    for( p.y = 0; p.y < img.rows; p.y++ )
    {
        for( p.x = 0; p.x < img.cols; p.x++)
        {
            uchar val = mask.at<uchar>(p);

            // 忽略的像素不建节点
            if (val==GC_IGNORE) {
                continue;
            }
            // add node
            int vtxIdx = graph.addVtx();
//            int vtxIdx = graph.add_node();
            nodeIdxMat.at<int32_t>(p) = vtxIdx;
            Vec3b color = img.at<Vec3b>(p);
            
            // set t-weights
            double fromSource, toSink;
            if( val == GC_PR_BGD || val == GC_PR_FGD || val == GC_UNKNOWN)
            {
                fromSource = -log(bgdGMM(color));
                toSink = -log(fgdGMM(color));
            }
            else if( val == GC_BGD )
            {
                fromSource = 0;
                toSink = lambda;
            }
            else if (val == GC_FGD )
            {
                fromSource = lambda;
                toSink = 0;
            }
            graph.addTermWeights( vtxIdx, fromSource, toSink );
//            graph.add_tweights(vtxIdx, fromSource, toSink);
            // set n-weights
            if( p.x>0 )
            {
                leftP.y = p.y; leftP.x = p.x-1;
                leftIdx = nodeIdxMat.at<int32_t>(leftP);
                
                if (mask.at<uchar>(leftP) != GC_IGNORE) {
                    
                    double w = leftW.at<double>(p);
                    graph.addEdges( vtxIdx, leftIdx, w, w );
//                    graph.add_edge(vtxIdx, leftIdx, w, w);
                }
            }
            if( p.x>0 && p.y>0 )
            {
                upLeftP.y = p.y-1; upLeftP.x = p.x-1;
                upLeftIdx = nodeIdxMat.at<int32_t>(upLeftP);
                
                if (mask.at<uchar>(upLeftP) != GC_IGNORE) {
                    double w = upleftW.at<double>(p);
                    graph.addEdges( vtxIdx, upLeftIdx, w, w );
//                    graph.add_edge(vtxIdx, upLeftIdx, w, w);

                }
            }
            if( p.y>0 )
            {
                upP.x = p.x; upP.y = p.y-1;
                upIdx = nodeIdxMat.at<int32_t>(upP);
                
                if (mask.at<uchar>(upP) != GC_IGNORE) {
                    
                    double w = upW.at<double>(p);
                    graph.addEdges( vtxIdx, upIdx, w, w );
//                    graph.add_edge(vtxIdx, upIdx, w, w);

                }
            }
            if( p.x<img.cols-1 && p.y>0 )
            {
                upRightP.x = p.x+1; upRightP.y = p.y-1;
                upRightIdx = nodeIdxMat.at<int32_t>(upRightP);
                
                if (mask.at<uchar>(upRightP) != GC_IGNORE) {
                    
                    double w = uprightW.at<double>(p);
                    graph.addEdges( vtxIdx, upRightIdx, w, w );
//                    graph.add_edge(vtxIdx, upRightIdx, w, w);

                }
            }
        }
    }
}

/*
 Estimate segmentation using MaxFlow algorithm
 */

static void MyEstimateSegmentation( MyGCGraph_double& graph, Mat& mask )
{
    graph.maxFlow();

    Point p;
    int vtxIdx = 0;
    for( p.y = 0; p.y < mask.rows; p.y++ )
    {
        for( p.x = 0; p.x < mask.cols; p.x++ )
        {
            uchar val = mask.at<uchar>(p);
            
            // 忽略的像素不需要判断属于前景or背景
            if (val==GC_IGNORE) {
                continue;
            }

            if(val == GC_PR_BGD || val == GC_PR_FGD || val == GC_UNKNOWN)
            {
                if (graph.inSourceSegment(vtxIdx))
                    mask.at<uchar>(p) = GC_PR_FGD;
                else
                    mask.at<uchar>(p) = GC_PR_BGD;
            }
            
            ++vtxIdx;
        }
    }
}

static void doEstimate( const Mat& img, const Mat& mask, const GCGMM& bgdGMM, const GCGMM& fgdGMM)
{
    //    int vtxCount = img.cols*img.rows,
    //    edgeCount = 2*(4*img.cols*img.rows - 3*(img.cols + img.rows) + 2);
    //    graph.create(vtxCount, edgeCount);
    Point p;
    
    for( p.y = 0; p.y < img.rows; p.y++ )
    {
        for( p.x = 0; p.x < img.cols; p.x++)
        {
            uchar val = mask.at<uchar>(p);
            
            // 忽略的像素不建节点
            if (val==GC_IGNORE) {
                continue;
            }
            // add node
            //            int vtxIdx = graph.add_node();
            Vec3b color = img.at<Vec3b>(p);
            
            // set t-weights
            double fromSource, toSink;
            if( val == GC_PR_BGD || val == GC_PR_FGD || val == GC_UNKNOWN)
            {
                fromSource = (bgdGMM(color));
                toSink = (fgdGMM(color));
                
//                if (p.x % 5 == 0 && p.y % 5 == 0) {
//                    printf("point: (%d, %d), fromSource: %f, toSink: %f\n", p.x, p.y, fromSource, toSink);
//                }
            }
        }
    }
}

static void doEstimate2( const Mat& img, Mat& mask, const GCGMM& bgdGMM, const GCGMM& fgdGMM)
{
    //    int vtxCount = img.cols*img.rows,
    //    edgeCount = 2*(4*img.cols*img.rows - 3*(img.cols + img.rows) + 2);
    //    graph.create(vtxCount, edgeCount);
    Point p;
    
    for( p.y = 0; p.y < img.rows; p.y++ )
    {
        for( p.x = 0; p.x < img.cols; p.x++)
        {
            uchar val = mask.at<uchar>(p);

            // add node
            //            int vtxIdx = graph.add_node();
            Vec3b color = img.at<Vec3b>(p);
            
            // set t-weights
            double fromSource, toSink;
            {
                fromSource = (bgdGMM(color));
                toSink = (fgdGMM(color));

                if (((fromSource > toSink*8 && toSink < 0.000010 && fromSource > 0.000050)) && val>128) {
                    val = MIN(val*(toSink/fromSource), 255);
                }
                mask.at<uchar>(p) = val;
//                if (p.x % 5 == 0 && p.y % 5 == 0) {
//                    printf("point: (%d, %d), fromSource: %f, toSink: %f\n", p.x, p.y, fromSource, toSink);
//                }
            }
        }
    }
//    printf("row: %d, col: %d\n", img.rows, img.cols);
}

static void doEstimate3( const Mat& img, Mat& mask, const GCGMM& bgdGMM, const GCGMM& fgdGMM)
{
    //    int vtxCount = img.cols*img.rows,
    //    edgeCount = 2*(4*img.cols*img.rows - 3*(img.cols + img.rows) + 2);
    //    graph.create(vtxCount, edgeCount);
    Point p;
    
    for( p.y = 0; p.y < img.rows; p.y++ )
    {
        for( p.x = 0; p.x < img.cols; p.x++)
        {
            uchar val = mask.at<uchar>(p);
            
            // add node
            //            int vtxIdx = graph.add_node();
            Vec3b color = img.at<Vec3b>(p);
            
            // set t-weights
            double fromSource, toSink;
            {
                fromSource = (bgdGMM(color));
                toSink = (fgdGMM(color));
                
                if ((val == cv::GC_FGD || val == cv::GC_PR_FGD) && ((fromSource > toSink*8 && toSink < 0.000010 && fromSource > 0.000050) || (toSink > fromSource*8 && fromSource < 0.000010 && toSink > 0.000050)))
                {
                    mask.at<uchar>(p) = GC_UNKNOWN;
                }
            }
        }
    }
    //    printf("row: %d, col: %d\n", img.rows, img.cols);
}
#pragma mark -
#pragma mark public member function

void GCGrabCut::labelRibbon(cv::InputArray _scaledMask, cv::OutputArray _mask, float scale, int &nBGDCount, int &nFGDCount)
{
    Mat &mask = _mask.getMatRef();
    Mat scaledMask = _scaledMask.getMat();
    
    int nScaledMaskRows = scaledMask.rows;
    int nScaledMaskCols = scaledMask.cols;
    
    mask.setTo(GC_IGNORE);
    int nMaskRows = mask.rows;
    int nMaskCols = mask.cols;

    const int radius = 1;
    Point maskPoint, scaledMaskPoint;
    int count=0, maxCount=0;
    nBGDCount = 0, nFGDCount = 0;

    for (maskPoint.y=0; maskPoint.y<nMaskRows; ++maskPoint.y) {
        for (maskPoint.x=0; maskPoint.x<nMaskCols; ++maskPoint.x) {
            count=0; maxCount=0;
            
            // self
            scaledMaskPoint.x=maskPoint.x*scale; scaledMaskPoint.y=maskPoint.y*scale;
            if (scaledMaskPoint.x>=nScaledMaskCols || scaledMaskPoint.y>=nScaledMaskRows)
            {
//                mask.at<uchar>(maskPoint) = GC_PR_BGD;
//                continue;
            }
            if (scaledMaskPoint.x>=nScaledMaskCols) scaledMaskPoint.x=nScaledMaskCols-1;
            if (scaledMaskPoint.y>=nScaledMaskRows) scaledMaskPoint.y=nScaledMaskRows-1;
            ++maxCount;
            if (scaledMask.at<uchar>(scaledMaskPoint) == GC_PR_FGD || scaledMask.at<uchar>(scaledMaskPoint) == GC_FGD) {
                ++count;
            }
            
            // left
            scaledMaskPoint.x=maskPoint.x*scale; scaledMaskPoint.y=maskPoint.y*scale;
            if (scaledMaskPoint.x>=nScaledMaskCols) scaledMaskPoint.x=nScaledMaskCols-1;
            if (scaledMaskPoint.y>=nScaledMaskRows) scaledMaskPoint.y=nScaledMaskRows-1;
            if (scaledMaskPoint.x>=radius) {
                scaledMaskPoint.x -= radius;
                ++maxCount;
                if (scaledMask.at<uchar>(scaledMaskPoint) == GC_PR_FGD || scaledMask.at<uchar>(scaledMaskPoint) == GC_FGD) {
                    ++count;
                }
            }
            
            // top
            scaledMaskPoint.x=maskPoint.x*scale; scaledMaskPoint.y=maskPoint.y*scale;
            if (scaledMaskPoint.x>=nScaledMaskCols) scaledMaskPoint.x=nScaledMaskCols-1;
            if (scaledMaskPoint.y>=nScaledMaskRows) scaledMaskPoint.y=nScaledMaskRows-1;
            if (scaledMaskPoint.y>=radius) {
                scaledMaskPoint.y -= radius;
                ++maxCount;
                if (scaledMask.at<uchar>(scaledMaskPoint) == GC_PR_FGD || scaledMask.at<uchar>(scaledMaskPoint) == GC_FGD) {
                    ++count;
                }
            }
            
            // right
            scaledMaskPoint.x=maskPoint.x*scale; scaledMaskPoint.y=maskPoint.y*scale;
            if (scaledMaskPoint.x>=nScaledMaskCols) scaledMaskPoint.x=nScaledMaskCols-1;
            if (scaledMaskPoint.y>=nScaledMaskRows) scaledMaskPoint.y=nScaledMaskRows-1;
            if (scaledMaskPoint.x<nScaledMaskCols-radius) {
                scaledMaskPoint.x += radius;
                ++maxCount;
                if (scaledMask.at<uchar>(scaledMaskPoint) == GC_PR_FGD || scaledMask.at<uchar>(scaledMaskPoint) == GC_FGD) {
                    ++count;
                }
            }
            
            // bottom
            scaledMaskPoint.x=maskPoint.x*scale; scaledMaskPoint.y=maskPoint.y*scale;
            if (scaledMaskPoint.x>=nScaledMaskCols) scaledMaskPoint.x=nScaledMaskCols-1;
            if (scaledMaskPoint.y>=nScaledMaskRows) scaledMaskPoint.y=nScaledMaskRows-1;
            if (scaledMaskPoint.y<nScaledMaskRows-radius) {
                scaledMaskPoint.y += radius;
                ++maxCount;
                if (scaledMask.at<uchar>(scaledMaskPoint) == GC_PR_FGD || scaledMask.at<uchar>(scaledMaskPoint) == GC_FGD) {
                    ++count;
                }
            }
            
            if (count<maxCount && count>0) {
                if (count>maxCount/2) {
                    mask.at<uchar>(maskPoint) = GC_PR_FGD;

                    ++nFGDCount;
                }
                else
                {
                    mask.at<uchar>(maskPoint) = GC_PR_BGD;

                    ++nBGDCount;
                }
            }
        }
    }
#ifdef DEBUG
    printf("pr background: %d, pr foreground: %d\n", nBGDCount, nFGDCount);
    printf("rows: %d, cols: %d\n", nMaskRows, nMaskCols);
#endif
    int neighberIgnoreCount=0, neighberBGDCount=0, neighberFGDCount=0;
    Point left, right, top, bottom;
    uchar val;
    for (maskPoint.y=0; maskPoint.y<nMaskRows; ++maskPoint.y) {
        for (maskPoint.x=0; maskPoint.x<nMaskCols; ++maskPoint.x) {
            
            if (mask.at<uchar>(maskPoint) != GC_IGNORE) {
                continue;
            }
            neighberFGDCount = neighberBGDCount = neighberIgnoreCount = 0;
            // left
            left=maskPoint;
            if (left.x>=radius) {
                left.x -= radius;
                val = mask.at<uchar>(left);
                if (val == GC_PR_FGD) {
                    ++neighberFGDCount;
                }
                else if (val == GC_PR_BGD)
                {
                    ++neighberBGDCount;
                }
                else if (val == GC_IGNORE)
                {
                    ++neighberIgnoreCount;
                }
            }
            
            // top
            top=maskPoint;
            if (top.y>=radius) {
                top.y -= radius;
                val = mask.at<uchar>(top);
                if (val == GC_PR_FGD) {
                    ++neighberFGDCount;
                }
                else if (val == GC_PR_BGD)
                {
                    ++neighberBGDCount;
                }
                else if (val == GC_IGNORE)
                {
                    ++neighberIgnoreCount;
                }
            }
            
            // right
            right=maskPoint;
            if (right.x<nMaskCols-radius) {
                right.x += radius;
                val = mask.at<uchar>(right);
                if (val == GC_PR_FGD) {
                    ++neighberFGDCount;
                }
                else if (val == GC_PR_BGD)
                {
                    ++neighberBGDCount;
                }
                else if (val == GC_IGNORE)
                {
                    ++neighberIgnoreCount;
                }
            }
            
            // bottom
            bottom=maskPoint;
            if (bottom.y<nMaskRows-radius) {
                bottom.y += radius;
                val = mask.at<uchar>(bottom);
                if (val == GC_PR_FGD) {
                    ++neighberFGDCount;
                }
                else if (val == GC_PR_BGD)
                {
                    ++neighberBGDCount;
                }
                else if (val == GC_IGNORE)
                {
                    ++neighberIgnoreCount;
                }
            }
            
            if (neighberFGDCount == 0 && neighberBGDCount > 0) {
                mask.at<uchar>(maskPoint)=GC_BGD;
                ++nBGDCount;
            }
            else if (neighberBGDCount == 0 && neighberFGDCount > 0)
            {
                mask.at<uchar>(maskPoint)=GC_FGD;
                ++nFGDCount;
            }
            else
            {
                mask.at<uchar>(maskPoint)=GC_IGNORE;
            }
        }
    }
}

void GCGrabCut::cutImage (cv::InputArray _img, cv::InputOutputArray _mask, int iterCount)
{
    if (iterCount <= 0) return;
    
    Mat img = _img.getMat();
    Mat& mask = _mask.getMatRef();
    
    if( img.empty() )
        CV_Error( CV_StsBadArg, "image is empty" );
    if( img.type() != CV_8UC3 )
        CV_Error( CV_StsBadArg, "image mush have CV_8UC3 type" );
#ifdef DEBUG
    struct timeval begin, end;
    int stage = 0;
    gettimeofday(&begin, NULL);
#endif
    //    GCGMM bgdGMM( bgdModel ), fgdGMM( fgdModel );
    
#ifdef DEBUG
    gettimeofday(&end, NULL);
    printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
    begin = end;
#endif
    
    Mat compIdxs( img.size(), CV_32SC1 );

    MyInitGMMs( img, mask, bgdGMM, fgdGMM );

#ifdef DEBUG
    gettimeofday(&end, NULL);
    printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
    begin = end;
#endif
    if( iterCount <= 0)
        return;

    
    if( img.empty() )
        CV_Error( CV_StsBadArg, "image is empty" );
    if( img.type() != CV_8UC3 )
        CV_Error( CV_StsBadArg, "image mush have CV_8UC3 type" );
    
    MyCheckMask(img, mask);
    
#ifdef DEBUG
    gettimeofday(&begin, NULL);
#endif
    const double gamma = 50;
    const double lambda = 9*gamma;
    const double beta = MyCalcBeta( img );
    
    Mat leftW, upleftW, upW, uprightW;
    MyCalcNWeights( img, mask, leftW, upleftW, upW, uprightW, beta, gamma );
#ifdef DEBUG
    gettimeofday(&end, NULL);
    printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
    begin = end;
#endif
    
//    Mat compIdxs( img.size(), CV_32SC1 );

    for( int i = 0; i < iterCount; i++ )
    {
        int vtxCount = img.cols*img.rows,
        edgeCount = 2*(4*img.cols*img.rows - 3*(img.cols + img.rows) + 2);

//        Graph graph(vtxCount, edgeCount);
        MyGCGraph_double graph(vtxCount, edgeCount);
        MyAssignGMMsComponents( img, mask, bgdGMM, fgdGMM, compIdxs );
#ifdef DEBUG
        gettimeofday(&end, NULL);
        printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
        begin = end;
#endif
        MyLearnGMMs( img, mask, compIdxs, bgdGMM, fgdGMM );
#ifdef DEBUG
        gettimeofday(&end, NULL);
        printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
        begin = end;
#endif
        MyconstructGCGraph(img, mask, bgdGMM, fgdGMM, lambda, leftW, upleftW, upW, uprightW, graph );
#ifdef DEBUG
        gettimeofday(&end, NULL);
        printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
        begin = end;
#endif
        MyEstimateSegmentation( graph, mask );
#ifdef DEBUG
        gettimeofday(&end, NULL);
        printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
        begin = end;
#endif
    }
}

void GCGrabCut::estimate3 (cv::InputArray _img, cv::InputOutputArray _mask)
{
    Mat img = _img.getMat();
    Mat& mask = _mask.getMatRef();
    
    doEstimate3(img, mask, bgdGMM, fgdGMM);
}

void GCGrabCut::estimate2 (cv::InputArray _img, cv::InputOutputArray _mask)
{
    Mat img = _img.getMat();
    Mat& mask = _mask.getMatRef();

    doEstimate2(img, mask, bgdGMM, fgdGMM);
}

void GCGrabCut::estimate (cv::InputArray _img, cv::InputOutputArray _mask)
{
    Mat img = _img.getMat();
    Mat& mask = _mask.getMatRef();
    
    if( img.empty() )
        CV_Error( CV_StsBadArg, "image is empty" );
    if( img.type() != CV_8UC3 )
        CV_Error( CV_StsBadArg, "image mush have CV_8UC3 type" );
#ifdef DEBUG
    struct timeval begin, end;
    int stage = 0;
    gettimeofday(&begin, NULL);
#endif
    //    GCGMM bgdGMM( bgdModel ), fgdGMM( fgdModel );
    
    Mat bgdModel;
    Mat fgdModel;
    
    if( img.empty() )
        CV_Error( CV_StsBadArg, "image is empty" );
    if( img.type() != CV_8UC3 )
        CV_Error( CV_StsBadArg, "image mush have CV_8UC3 type" );

    bgdGMM.useModel(bgdModel);
    fgdGMM.useModel(fgdModel);
#ifdef DEBUG
    gettimeofday(&end, NULL);
    printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
    begin = end;
#endif
    
    Mat compIdxs( img.size(), CV_32SC1 );
    
    MyInitGMMs( img, mask, bgdGMM, fgdGMM );
    
#ifdef DEBUG
    gettimeofday(&end, NULL);
    printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
    begin = end;
#endif

    if( img.empty() )
        CV_Error( CV_StsBadArg, "image is empty" );
    if( img.type() != CV_8UC3 )
        CV_Error( CV_StsBadArg, "image mush have CV_8UC3 type" );
    
    MyCheckMask(img, mask);
    
#ifdef DEBUG
    gettimeofday(&begin, NULL);
#endif
    
#ifdef DEBUG
    gettimeofday(&end, NULL);
    printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
    begin = end;
#endif
    
    //    Mat compIdxs( img.size(), CV_32SC1 );
    
//    for( int i = 0; i < iterCount; i++ )
    {
        int vtxCount = img.cols*img.rows,
        edgeCount = 2*(4*img.cols*img.rows - 3*(img.cols + img.rows) + 2);
        
        //        Graph graph(vtxCount, edgeCount);
        MyGCGraph_double graph(vtxCount, edgeCount);
        MyAssignGMMsComponents( img, mask, bgdGMM, fgdGMM, compIdxs );
#ifdef DEBUG
        gettimeofday(&end, NULL);
        printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
        begin = end;
#endif
        MyLearnGMMs( img, mask, compIdxs, bgdGMM, fgdGMM );
#ifdef DEBUG
        gettimeofday(&end, NULL);
        printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
        begin = end;
#endif
        doEstimate(img, mask, bgdGMM, fgdGMM);
    }
}

void GCGrabCut::genModel( InputArray _img, InputOutputArray _mask, Rect rect,
                         InputOutputArray _bgdModel, InputOutputArray _fgdModel, int mode)
{
    Mat img = _img.getMat();
    Mat& mask = _mask.getMatRef();
    Mat& bgdModel = _bgdModel.getMatRef();
    Mat& fgdModel = _fgdModel.getMatRef();
    
    if( img.empty() )
        CV_Error( CV_StsBadArg, "image is empty" );
    if( img.type() != CV_8UC3 )
        CV_Error( CV_StsBadArg, "image mush have CV_8UC3 type" );
#ifdef DEBUG
    struct timeval begin, end;
    int stage = 0;
    gettimeofday(&begin, NULL);
#endif
    //    GCGMM bgdGMM( bgdModel ), fgdGMM( fgdModel );
    bgdGMM.useModel(bgdModel);
    fgdGMM.useModel(fgdModel);
    
#ifdef DEBUG
    gettimeofday(&end, NULL);
    printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
    begin = end;
#endif
    
    Mat compIdxs( img.size(), CV_32SC1 );
    
    if( mode == GC_INIT_WITH_RECT || mode == GC_INIT_WITH_MASK )
    {
        if( mode == GC_INIT_WITH_RECT )
            MyInitMaskWithRect( mask, img.size(), rect );
        else // flag == GC_INIT_WITH_MASK
            MyCheckMask( img, mask );
#ifdef DEBUG
        gettimeofday(&end, NULL);
        printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
        begin = end;
#endif
        MyInitGMMs( img, mask, bgdGMM, fgdGMM );
    }
}

void GCGrabCut::cutImage( InputArray _img, InputOutputArray _mask, Rect rect,
                InputOutputArray _bgdModel, InputOutputArray _fgdModel,
                int iterCount, int mode )
{
    Mat img = _img.getMat();
    Mat& mask = _mask.getMatRef();
    Mat& bgdModel = _bgdModel.getMatRef();
    Mat& fgdModel = _fgdModel.getMatRef();
    
    if( img.empty() )
        CV_Error( CV_StsBadArg, "image is empty" );
    if( img.type() != CV_8UC3 )
        CV_Error( CV_StsBadArg, "image mush have CV_8UC3 type" );
#ifdef DEBUG
    struct timeval begin, end;
    int stage = 0;
    gettimeofday(&begin, NULL);
#endif
//    GCGMM bgdGMM( bgdModel ), fgdGMM( fgdModel );
    bgdGMM.useModel(bgdModel);
    fgdGMM.useModel(fgdModel);
    
#ifdef DEBUG
    gettimeofday(&end, NULL);
    printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
    begin = end;
#endif
    
    Mat compIdxs( img.size(), CV_32SC1 );
    
    if( mode == GC_INIT_WITH_RECT || mode == GC_INIT_WITH_MASK )
    {
        if( mode == GC_INIT_WITH_RECT )
            MyInitMaskWithRect( mask, img.size(), rect );
        else // flag == GC_INIT_WITH_MASK
            MyCheckMask( img, mask );
#ifdef DEBUG
        gettimeofday(&end, NULL);
        printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
        begin = end;
#endif
        MyInitGMMs( img, mask, bgdGMM, fgdGMM );
    }
#ifdef DEBUG
    gettimeofday(&end, NULL);
    printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
    begin = end;
#endif
    if( iterCount <= 0)
        return;
    
    if( mode == GC_EVAL )
        MyCheckMask( img, mask );
    
    const double gamma = 50;
    const double lambda = 9*gamma;
    const double beta = MyCalcBeta( img );
    
    Mat leftW, upleftW, upW, uprightW;
    MyCalcNWeights( img, mask, leftW, upleftW, upW, uprightW, beta, gamma );
#ifdef DEBUG
    gettimeofday(&end, NULL);
    printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
    begin = end;
#endif
    for( int i = 0; i < iterCount; i++ )
    {
        int vtxCount = img.cols*img.rows,
        edgeCount = 2*(4*img.cols*img.rows - 3*(img.cols + img.rows) + 2);
        
        MyGCGraph_double graph(vtxCount, edgeCount);
//        Graph graph(vtxCount, edgeCount);
        MyAssignGMMsComponents( img, mask, bgdGMM, fgdGMM, compIdxs );
#ifdef DEBUG
        gettimeofday(&end, NULL);
        printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
        begin = end;
#endif
        MyLearnGMMs( img, mask, compIdxs, bgdGMM, fgdGMM );
#ifdef DEBUG
        gettimeofday(&end, NULL);
        printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
        begin = end;
#endif
        MyconstructGCGraph(img, mask, bgdGMM, fgdGMM, lambda, leftW, upleftW, upW, uprightW, graph );
#ifdef DEBUG
        gettimeofday(&end, NULL);
        printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
        begin = end;
#endif
        MyEstimateSegmentation( graph, mask );
#ifdef DEBUG
        gettimeofday(&end, NULL);
        printf("line %d, stage %u: use %lu ms\n",__LINE__, ++stage, (end.tv_sec-begin.tv_sec)*1000+(end.tv_usec-begin.tv_usec)/1000);
        begin = end;
#endif
    }
}
