//
//  SkinDetect.cpp
//  Filter
//
//  Created by shen on 14-3-18.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#include "SkinDetect.h"
#include <opencv2/imgproc/imgproc_c.h>
// skin region location using rgb limitation
void cvSkinRGB(IplImage* rgb,IplImage* _dst)
{
	assert(rgb->nChannels==3&& _dst->nChannels==3);
    
	static const int R=0;
	static const int G=1;
	static const int B=2;
    
	IplImage* dst=cvCreateImage(cvGetSize(_dst),8,3);
	cvZero(dst);
    
	for (int h=0;h<rgb->height;h++) {
		unsigned char* prgb=(unsigned char*)rgb->imageData+h*rgb->widthStep;
		unsigned char* pdst=(unsigned char*)dst->imageData+h*dst->widthStep;
		for (int w=0;w<rgb->width;w++) {
			if ((prgb[R]>95 && prgb[G]>40 && prgb[B]>20 &&
                 prgb[R]-prgb[B]>15 && prgb[R]-prgb[G]>15/*&&
                                                          !(prgb[R]>170&&prgb[G]>170&&prgb[B]>170)*/)||//uniform illumination
				(prgb[R]>200 && prgb[G]>210 && prgb[B]>170 &&
                 abs(prgb[R]-prgb[B])<=15 && prgb[R]>prgb[B]&& prgb[G]>prgb[B])//lateral illumination
				) {
                memcpy(pdst,prgb,3);
			}
			prgb+=3;
			pdst+=3;
		}
	}
	cvCopy(dst,_dst);
	cvReleaseImage(&dst);
}
// skin detection in rg space
void cvSkinRG(IplImage* rgb,IplImage* gray)
{
	assert(rgb->nChannels==3&&gray->nChannels==1);
	
	const int R=0;
	const int G=1;
	const int B=2;
    
	double Aup=-1.8423;
	double Bup=1.5294;
	double Cup=0.0422;
	double Adown=-0.7279;
	double Bdown=0.6066;
	double Cdown=0.1766;
	for (int h=0;h<rgb->height;h++) {
		unsigned char* pGray=(unsigned char*)gray->imageData+h*gray->widthStep;
		unsigned char* pRGB=(unsigned char* )rgb->imageData+h*rgb->widthStep;
		for (int w=0;w<rgb->width;w++)
		{
			int s=pRGB[R]+pRGB[G]+pRGB[B];
			double r=(double)pRGB[R]/s;
			double g=(double)pRGB[G]/s;
			double Gup=Aup*r*r+Bup*r+Cup;
			double Gdown=Adown*r*r+Bdown*r+Cdown;
			double Wr=(r-0.33)*(r-0.33)+(g-0.33)*(g-0.33);
			if (g<Gup && g>Gdown && Wr>0.004)
			{
				*pGray=255;
			}
			else
			{
				*pGray=0;
			}
			pGray++;
			pRGB+=3;
		}
	}
    
}
// implementation of otsu algorithm
// author: onezeros#yahoo.cn
// reference: Rafael C. Gonzalez. Digital Image Processing Using MATLAB
void cvThresholdOtsu(IplImage* src, IplImage* dst)
{
	int height=src->height;
	int width=src->width;
    
	//histogram
	float histogram[256]={0};
	for(int i=0;i<height;i++) {
		unsigned char* p=(unsigned char*)src->imageData+src->widthStep*i;
		for(int j=0;j<width;j++) {
			histogram[*p++]++;
		}
	}
	//normalize histogram
	int size=height*width;
	for(int i=0;i<256;i++) {
		histogram[i]=histogram[i]/size;
	}
    
	//average pixel value
	float avgValue=0;
	for(int i=0;i<256;i++) {
		avgValue+=i*histogram[i];
	}
    
	int threshold = 0;
	float maxVariance=0;
	float w=0,u=0;
	for(int i=0;i<256;i++) {
		w+=histogram[i];
		u+=i*histogram[i];
        
		float t=avgValue*w-u;
		float variance=t*t/(w*(1-w));
		if(variance>maxVariance) {
			maxVariance=variance;
			threshold=i;
		}
	}
    
	cvThreshold(src,dst,threshold,255,CV_THRESH_BINARY);
}

void cvSkinOtsu(IplImage* src, IplImage* dst)
{
//	assert(dst->nChannels==1&& src->nChannels==3);
    
	IplImage* ycrcb=cvCreateImage(cvGetSize(src),8,3);
	IplImage* cr=cvCreateImage(cvGetSize(src),8,1);
	cvCvtColor(src,ycrcb,CV_RGB2YCrCb);
	cvSplit(ycrcb,0,cr,0,0);
    
	cvThresholdOtsu(cr,cr);
//	cvCopy(cr,dst);
    cvCvtColor(cr, dst, CV_GRAY2RGB);
	cvReleaseImage(&cr);
	cvReleaseImage(&ycrcb);
}

void cvSkinYCrCb(IplImage* src,IplImage* dst)
{
	IplImage* ycrcb=cvCreateImage(cvGetSize(src),8,3);
	//IplImage* cr=cvCreateImage(cvGetSize(src),8,1);
	//IplImage* cb=cvCreateImage(cvGetSize(src),8,1);
	cvCvtColor(src,ycrcb,CV_RGB2YCrCb);
	//cvSplit(ycrcb,0,cr,cb,0);
    
	static const int Cb=2;
	static const int Cr=1;
    
	//IplImage* dst=cvCreateImage(cvGetSize(_dst),8,3);
	cvZero(dst);
    
	for (int h=0;h<src->height;h++) {
		unsigned char* pycrcb=(unsigned char*)ycrcb->imageData+h*ycrcb->widthStep;
		unsigned char* psrc=(unsigned char*)src->imageData+h*src->widthStep;
		unsigned char* pdst=(unsigned char*)dst->imageData+h*dst->widthStep;
		for (int w=0;w<src->width;w++) {
			if (pycrcb[Cr]>=133&&pycrcb[Cr]<=173&&pycrcb[Cb]>=77&&pycrcb[Cb]<=127)
			{
                memcpy(pdst,psrc,4);
			}
			pycrcb+=3;
			psrc+=4;
			pdst+=4;
		}
	}
    cvReleaseImage(&ycrcb);
	//cvCopyImage(dst,_dst);
	//cvReleaseImage(&dst);
}

void cvSkinHSV(IplImage* src,IplImage* dst)
{
	IplImage* hsv=cvCreateImage(cvGetSize(src),8,3);
	//IplImage* cr=cvCreateImage(cvGetSize(src),8,1);
	//IplImage* cb=cvCreateImage(cvGetSize(src),8,1);
	cvCvtColor(src,hsv,CV_RGB2HSV);
	//cvSplit(ycrcb,0,cr,cb,0);

	static const int H=0;
    
	//IplImage* dst=cvCreateImage(cvGetSize(_dst),8,3);
	cvZero(dst);
    
	for (int h=0;h<src->height;h++) {
		unsigned char* phsv=(unsigned char*)hsv->imageData+h*hsv->widthStep;
		unsigned char* psrc=(unsigned char*)src->imageData+h*src->widthStep;
		unsigned char* pdst=(unsigned char*)dst->imageData+h*dst->widthStep;
		for (int w=0;w<src->width;w++) {
			if (phsv[H]>=7&&phsv[H]<=29)
			{
//                memcpy(pdst,psrc,4);
                pdst[0] = 255;
                pdst[1] = 255;
                pdst[2] = 255;
                pdst[3] = 255;
			}
			phsv+=3;
			psrc+=4;
			pdst+=4;
		}
	}
    cvReleaseImage(&hsv);
	//cvCopyImage(dst,_dst);
	//cvReleaseImage(&dst);
}

bool isSkinRG(unsigned char R, unsigned char G, unsigned char B)
{
    double Aup=-1.8423;
    double Bup=1.5294;
    double Cup=0.0422;
    double Adown=-0.7279;
    double Bdown=0.6066;
    double Cdown=0.1766;

    double s=R+G+B;
    double r=(double)R/s;
    double g=(double)G/s;
    double Gup=Aup*r*r+Bup*r+Cup;
    double Gdown=Adown*r*r+Bdown*r+Cdown;
    double Wr=(r-0.33)*(r-0.33)+(g-0.33)*(g-0.33);
    if (g<Gup && g>Gdown && Wr>0.004)
        return true;
    else
        return false;
}

bool isSkinRGB(unsigned char R, unsigned char G, unsigned char B)
{
    if ((R>95 && G>40 && B>20 && R-B>15 && R-G>15)  //uniform illumination
        || (R>200 && G>210 && B>170 && abs(R-B)<=15 && R>B && G>B)  //lateral illumination
        )
    {
        return true;
    }
    return false;
}
bool isSkinYCrCb(unsigned char Cr, unsigned char Cb)
{
    if (Cr>=133&&Cr<=173&&Cb>=77&&Cb<=127)
    {
        return true;
    }
    return false;
}
bool isSkinHSV(unsigned char H)
{
    if (H>7 && H<29) {
        return true;
    }
    return false;
}

int cvSmoothSkin(IplImage* srcImage, IplImage* dstImage)
{
    if (srcImage == NULL || dstImage == NULL) {
        return -1;
    }
    CvSize srcSize = cvGetSize(srcImage);
    int srcChannel = srcImage->nChannels;
    int srcWidthStep = srcImage->widthStep;
    
    CvSize dstSize = cvGetSize(dstImage);
    int dstChannel = dstImage->nChannels;
    int dstWidthStep = dstImage->widthStep;
    
    if (srcSize.height != dstSize.height || srcSize.width != dstSize.width
        || srcChannel != 4 || dstChannel != 4 || srcWidthStep != dstWidthStep) {
        return -2;
    }
    
    IplImage *YCrCbImage = cvCreateImage(cvGetSize(srcImage), srcImage->depth, 3);
    cvCvtColor(srcImage, YCrCbImage, CV_RGB2YCrCb);
    
    IplImage *HSVImage = cvCreateImage(cvGetSize(srcImage), srcImage->depth, 3);
    cvCvtColor(srcImage, HSVImage, CV_RGB2HSV);

    int blurRadius = 1;
//    IplImage *smoothSrcImage = cvCreateImage(srcSize, srcImage->depth, 4);
//    cvSmooth(srcImage, smoothSrcImage, CV_GAUSSIAN, 2*blurRadius+1, 2*blurRadius+1);
    
    IplImage *smoothSrcImage = cvCreateImage(srcSize, srcImage->depth, 3);
    cvSmooth(HSVImage, smoothSrcImage, CV_BILATERAL, 2*blurRadius+1, 2*blurRadius+1, 25, MAX(1,(2*blurRadius+1)/3));
    cvCvtColor(smoothSrcImage, smoothSrcImage, CV_HSV2RGB);
    
    uchar *dstRowPtr = (uchar *)dstImage->imageData;
    uchar *dstPtr = dstRowPtr;
    
    for (int y=0; y<srcSize.height; ++y) {
        dstPtr = dstRowPtr;
        for (int x=0; x<srcSize.width; ++x) {
        
            unsigned char Cr = CV_IMAGE_ELEM(YCrCbImage, unsigned char, y, x*YCrCbImage->nChannels+1);
            unsigned char Cb = CV_IMAGE_ELEM(YCrCbImage, unsigned char, y, x*YCrCbImage->nChannels+2);
            unsigned char R = CV_IMAGE_ELEM(srcImage, unsigned char, y, x*srcImage->nChannels);
            unsigned char G = CV_IMAGE_ELEM(srcImage, unsigned char, y, x*srcImage->nChannels+1);
            unsigned char B = CV_IMAGE_ELEM(srcImage, unsigned char, y, x*srcImage->nChannels+2);
            unsigned char H = CV_IMAGE_ELEM(HSVImage, unsigned char, y, x*HSVImage->nChannels+0);

            if (isSkinRGB(R, G, B) && isSkinYCrCb(Cr, Cb) && isSkinHSV(H))
            {
//                dstPtr[0] = (CV_IMAGE_ELEM(smoothSrcImage, unsigned char, y, x*smoothSrcImage->nChannels) + R)/2;
//                dstPtr[1] = (CV_IMAGE_ELEM(smoothSrcImage, unsigned char, y, x*smoothSrcImage->nChannels+1) + G)/2;
//                dstPtr[2] = (CV_IMAGE_ELEM(smoothSrcImage, unsigned char, y, x*smoothSrcImage->nChannels+2) + B)/2;
                dstPtr[0] = CV_IMAGE_ELEM(smoothSrcImage, unsigned char, y, x*smoothSrcImage->nChannels);
                dstPtr[1] = CV_IMAGE_ELEM(smoothSrcImage, unsigned char, y, x*smoothSrcImage->nChannels+1);
                dstPtr[2] = CV_IMAGE_ELEM(smoothSrcImage, unsigned char, y, x*smoothSrcImage->nChannels+2);
//                dstPtr[0] = 255;
//                dstPtr[1] = 255;
//                dstPtr[2] = 255;
                
            }
            else
            {
                dstPtr[0] = R;
                dstPtr[1] = G;
                dstPtr[2] = B;
            }
            dstPtr[3] = 0xff;
            
            dstPtr += dstChannel;
        }
        dstRowPtr += dstWidthStep;
    }
    cvReleaseImage(&smoothSrcImage);
    cvReleaseImage(&YCrCbImage);
    cvReleaseImage(&HSVImage);
    return 0;
}

int cvSkin(IplImage* srcImage, IplImage* dstImage)
{
    if (srcImage == NULL || dstImage == NULL) {
        return -1;
    }
    CvSize srcSize = cvGetSize(srcImage);
    int srcChannel = srcImage->nChannels;
    int srcWidthStep = srcImage->widthStep;
    
    CvSize dstSize = cvGetSize(dstImage);
    int dstChannel = dstImage->nChannels;
    int dstWidthStep = dstImage->widthStep;
    
    if (srcSize.height != dstSize.height || srcSize.width != dstSize.width
        || srcChannel != 4 || dstChannel != 4 || srcWidthStep != dstWidthStep) {
        return -2;
    }
    
    IplImage *YCrCbImage = cvCreateImage(cvGetSize(srcImage), srcImage->depth, 3);
    cvCvtColor(srcImage, YCrCbImage, CV_RGB2YCrCb);
    
    IplImage *HSVImage = cvCreateImage(cvGetSize(srcImage), srcImage->depth, 3);
    cvCvtColor(srcImage, HSVImage, CV_RGB2HSV);
        
    uchar *dstRowPtr = (uchar *)dstImage->imageData;
    uchar *dstPtr = dstRowPtr;
    
    for (int y=0; y<srcSize.height; ++y) {
        dstPtr = dstRowPtr;
        for (int x=0; x<srcSize.width; ++x) {
            
            unsigned char Cr = CV_IMAGE_ELEM(YCrCbImage, unsigned char, y, x*YCrCbImage->nChannels+1);
            unsigned char Cb = CV_IMAGE_ELEM(YCrCbImage, unsigned char, y, x*YCrCbImage->nChannels+2);
            unsigned char R = CV_IMAGE_ELEM(srcImage, unsigned char, y, x*srcImage->nChannels);
            unsigned char G = CV_IMAGE_ELEM(srcImage, unsigned char, y, x*srcImage->nChannels+1);
            unsigned char B = CV_IMAGE_ELEM(srcImage, unsigned char, y, x*srcImage->nChannels+2);
            unsigned char H = CV_IMAGE_ELEM(HSVImage, unsigned char, y, x*HSVImage->nChannels+0);
            
            if (isSkinRGB(R, G, B) && isSkinYCrCb(Cr, Cb) && isSkinHSV(H))
            {
                dstPtr[0] = 255;
                dstPtr[1] = 255;
                dstPtr[2] = 255;
                
            }
            else
            {
                dstPtr[0] = 0;
                dstPtr[1] = 0;
                dstPtr[2] = 0;
            }
            dstPtr[3] = 0xff;
            
            dstPtr += dstChannel;
        }
        dstRowPtr += dstWidthStep;
    }
    cvReleaseImage(&YCrCbImage);
    cvReleaseImage(&HSVImage);
    return 0;
}

/*
int main()
{
	
    IplImage* img= cvLoadImage("D:/skin.jpg"); //随便放一张jpg图片在D盘或另行设置目录
	IplImage* dstRGB=cvCreateImage(cvGetSize(img),8,3);
	IplImage* dstRG=cvCreateImage(cvGetSize(img),8,1);
	IplImage* dst_crotsu=cvCreateImage(cvGetSize(img),8,1);
	IplImage* dst_YUV=cvCreateImage(cvGetSize(img),8,3);
	IplImage* dst_HSV=cvCreateImage(cvGetSize(img),8,3);
    
    
    cvNamedWindow("inputimage", CV_WINDOW_AUTOSIZE);
    cvShowImage("inputimage", img);
    cvWaitKey(0);
    
	SkinRGB(img,dstRGB);
	cvNamedWindow("outputimage1", CV_WINDOW_AUTOSIZE);
    cvShowImage("outputimage1", dstRGB);
    cvWaitKey(0);
	cvSkinRG(img,dstRG);
	cvNamedWindow("outputimage2", CV_WINDOW_AUTOSIZE);
    cvShowImage("outputimage2", dstRG);
	cvWaitKey(0);
	cvSkinOtsu(img,dst_crotsu);
	cvNamedWindow("outputimage3", CV_WINDOW_AUTOSIZE);
    cvShowImage("outputimage3", dst_crotsu);
	cvWaitKey(0);
	cvSkinYUV(img,dst_YUV);
	cvNamedWindow("outputimage4", CV_WINDOW_AUTOSIZE);
    cvShowImage("outputimage4", dst_YUV);
	cvWaitKey(0);
	cvSkinHSV(img,dst_HSV);
	cvNamedWindow("outputimage5", CV_WINDOW_AUTOSIZE);
    cvShowImage("outputimage5", dst_HSV);
	cvWaitKey(0);
    return 0;
}*/
