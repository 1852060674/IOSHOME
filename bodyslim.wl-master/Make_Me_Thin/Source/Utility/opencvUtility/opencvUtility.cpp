//
//  opencvUtility.cpp
//  FaceMorph
//
//  Created by shen on 14-7-10.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#include "opencvUtility.h"

void clipPointToImageBounds(const cv::Mat &image, cv::Point2f& uv)
{
    if (uv.x>image.cols-1) uv.x = image.cols-1;
    else if (uv.x<0) uv.x=0;
    
    if (uv.y>image.rows-1) uv.y = image.rows-1;
    else if (uv.y<0) uv.y=0;
}

void clipRectToImageBounds(const cv::Mat &image, cv::Rect &rect)
{
    int left = rect.x, right = rect.x+rect.width;
    int top = rect.y, bottom = rect.y+rect.height;
    
    if (left<0)left=0;
    else if (left>=image.cols) left=image.cols-1;
    
    if (right<0)right=0;
    else if (right>=image.cols) right=image.cols-1;
    
    if (top<0)top=0;
    else if (top>=image.rows) top=image.rows-1;
    
    if (bottom<0)bottom=0;
    else if (bottom>=image.rows) bottom=image.rows-1;
    
    rect.x=left; rect.y=top;
    rect.width=right-left+1; rect.height=bottom-top+1;
}

cv::Vec3b bilinearInterpolate(const cv::Mat &image, cv::Point2f center)
{
    int lowX = (int)floor(center.x);
    int lowY = (int)floor(center.y);
    int highX = (int)ceil(center.x);
    int highY = (int)ceil(center.y);
    
    cv::Vec3b TL = image.at<cv::Vec3b>(lowY, lowX);
    cv::Vec3b TR = image.at<cv::Vec3b>(lowY, highX);
    cv::Vec3b BL = image.at<cv::Vec3b>(highY, lowX);
    cv::Vec3b BR = image.at<cv::Vec3b>(highY, highX);
    
    cv::Vec3b T, B;
    if (lowX == highX) {
        T = TL;
        B = BL;
    }
    else
    {
        T = TR*(center.x-lowX)+TL*(highX-center.x);
        B = BR*(center.x-lowX)+BL*(highX-center.x);
    }
    
    cv::Vec3b result;
    if (lowY == highY) {
        result = T;
    }
    else
    {
        result = B*(center.y-lowY) + T*(highY-center.y);
    }
    
    return result;
}

cv::Vec3b bilinearInterpolate(const cv::Mat &image, float centerY, float centerX)
{
    int lowX = (int)floor(centerX);
    int lowY = (int)floor(centerY);
    int highX = (int)ceil(centerX);
    int highY = (int)ceil(centerY);
    
    cv::Vec3b TL = image.at<cv::Vec3b>(lowY, lowX);
    cv::Vec3b TR = image.at<cv::Vec3b>(lowY, highX);
    cv::Vec3b BL = image.at<cv::Vec3b>(highY, lowX);
    cv::Vec3b BR = image.at<cv::Vec3b>(highY, highX);
    
    cv::Vec3b T, B;
    if (lowX == highX) {
        T = TL;
        B = BL;
    }
    else
    {
        T = TR*(centerX-lowX)+TL*(highX-centerX);
        B = BR*(centerX-lowX)+BL*(highX-centerX);
    }
    
    cv::Vec3b result;
    if (lowY == highY) {
        result = T;
    }
    else
    {
        result = B*(centerY-lowY) + T*(highY-centerY);
    }
    
    return result;
}

cv::Point2f bilinearInterpolatePoint2f(const cv::Mat &image, cv::Point2f center)
{
    int lowX = (int)floor(center.x);
    int lowY = (int)floor(center.y);
    int highX = (int)ceil(center.x);
    int highY = (int)ceil(center.y);
    
    cv::Point2f TL = image.at<cv::Point2f>(lowY, lowX);
    cv::Point2f TR = image.at<cv::Point2f>(lowY, highX);
    cv::Point2f BL = image.at<cv::Point2f>(highY, lowX);
    cv::Point2f BR = image.at<cv::Point2f>(highY, highX);
    
    cv::Point2f T, B;
    if (lowX == highX) {
        T = TL;
        B = BL;
    }
    else
    {
        T = TR*(center.x-lowX)+TL*(highX-center.x);
        B = BR*(center.x-lowX)+BL*(highX-center.x);
    }
    
    cv::Point2f result;
    if (lowY == highY) {
        result = T;
    }
    else
    {
        result = B*(center.y-lowY) + T*(highY-center.y);
    }
    
    return result;
}
void expandRectToContainPoint(cv::Rect &rect, cv::Point point)
{
    if (rect.x > point.x)
    {
        rect.width += rect.x-point.x;
        rect.x = point.x;
    }
    else if (rect.x+rect.width < point.x)
    {
        rect.width = point.x - rect.x;
    }
    
    if (rect.y > point.y) {
        rect.height += rect.y - point.y;
        rect.y = point.y;
    }
    else if (rect.y+rect.height < point.y)
    {
        rect.height = point.y - rect.y;
    }
}

void expandRectToContainRect(cv::Rect &rect, cv::Rect r)
{
    expandRectToContainPoint(rect, cv::Point(r.x, r.y));
    expandRectToContainPoint(rect, cv::Point(r.x+r.width, r.y));
    expandRectToContainPoint(rect, cv::Point(r.x, r.y+r.height));
    expandRectToContainPoint(rect, cv::Point(r.x+r.width, r.y+r.height));
}