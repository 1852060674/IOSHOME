//
//  Whiten.cpp
//  SkinBeautify
//
//  Created by ZB_Mac on 14-11-21.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#include "Whiten.h"
#include <math.h>
#include <opencv2/imgproc/types_c.h>

int logCurveWhiten(unsigned char *data, int width, int height, int widthStep, int channel, float beta)
{
    float betaR, betaG, betaB;
    betaG = beta<1.0?1.0:beta;
    betaR = betaG*1.1;
    betaB = betaG*1.08;
    
    float denominatorR = log(betaR);
    float denominatorG = log(betaG);
    float denominatorB = log(betaB);
    float value;
    unsigned char *ptr;
    if (channel == 4) {
        for (int y=0; y<height; ++y) {
            ptr = data+widthStep*y;
            for (int x=0; x<width; ++x) {
                value = log(ptr[0]/255.0*(betaR-1)+1)/denominatorR;
                ptr[0] = value*255;
                value = log(ptr[1]/255.0*(betaG-1)+1)/denominatorG;
                ptr[1] = value*255;
                value = log(ptr[2]/255.0*(betaB-1)+1)/denominatorB;
                ptr[2] = value*255;
                ptr += 4;
            }
        }
    }
    return 0;
}

static int TTPTWhitenMap[272] = {
    0,1,3,4,6,8,9,11,13,14,16,18,19,21,23,24,//16
    26,28,29,31,33,34,36,38,39,41,42,44,46,47,49,51,//32
    52,54,55,57,59,60,62,64,65,67,68,70,71,73,75,76,//48
    78,79,81,82,84,86,87,89,90,92,93,95,96,98,99,101,//64
    102,104,105,107,108,110,111,113,114,116,117,119,120,121,123,124,//80
    126,127,128,130,131,133,134,135,137,138,139,141,142,143,145,146,//96
    147,149,150,151,152,154,155,156,157,159,160,161,162,164,165,166,//112
    167,168,169,171,172,173,174,175,176,177,178,179,180,181,182,183,//128
    184,186,187,188,188,189,190,191,192,193,194,195,196,197,198,199,//144
    200,200,201,202,203,204,205,205,206,207,208,208,209,210,211,211,//160
    212,213,214,214,215,216,216,217,218,218,219,219,220,221,221,222,//176
    223,223,224,224,225,225,226,226,227,228,228,229,229,230,230,231,//192
    231,232,232,233,233,234,234,234,235,235,236,236,237,237,237,238,//208
    238,239,239,240,240,240,241,241,241,242,242,243,243,243,244,244,//224
    244,245,245,245,246,246,246,247,247,247,248,248,248,249,249,249,//240
    250,250,250,251,251,251,252,252,252,253,253,253,254,254,254,255,//256
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
};

int TTPTWhiten(unsigned char *data, int width, int height, int widthStep, int channel, float degree)
{
    unsigned char *ptr;
    
    float originalWeight = 1.0-degree;
    if (channel == 4) {
        for (int y=0; y<height; ++y) {
            ptr = data+widthStep*y;
            for (int x=0; x<width; ++x) {
                ptr[0] = TTPTWhitenMap[ptr[0]]*degree+ptr[0]*originalWeight;
                ptr[1] = TTPTWhitenMap[ptr[1]]*degree+ptr[1]*originalWeight;
                ptr[2] = TTPTWhitenMap[ptr[2]+5]*degree+ptr[2]*originalWeight;

                ptr += 4;
            }
        }
    }
    
    return 0;
}

int TTPTWhiten(cv::Mat &srcMat, cv::Mat &dstMat, float degree)
{
    int width = srcMat.cols;
    int height = srcMat.rows;
    dstMat.create(height, width, CV_8UC3);
    cv::Vec3b *srcPtr, *dstPtr;
    
    float originalWeight = 1.0-degree;
    {
        for (int y=0; y<height; ++y) {
            srcPtr = srcMat.ptr<cv::Vec3b>(y);
            dstPtr = dstMat.ptr<cv::Vec3b>(y);
            
            for (int x=0; x<width; ++x) {
                
                (*dstPtr)[0] = TTPTWhitenMap[(*srcPtr)[0]]*degree+(*srcPtr)[0]*originalWeight;
                (*dstPtr)[1] = TTPTWhitenMap[(*srcPtr)[1]]*degree+(*srcPtr)[1]*originalWeight;
                (*dstPtr)[2] = TTPTWhitenMap[(*srcPtr)[2]+5]*degree+(*srcPtr)[2]*originalWeight;
                
                ++dstPtr;
                ++srcPtr;
            }
        }
    }

    return 0;
}

static float alphaMap[256] = {
    1.000000, 0.997546, 0.995091, 0.992637, 0.990181, 0.987726, 0.985269, 0.982812, 0.980353, 0.977893,
    0.975432, 0.972969, 0.970504, 0.968038, 0.965569, 0.963099, 0.960625, 0.958150, 0.955671, 0.953190,
    0.950706, 0.948219, 0.945728, 0.943234, 0.940737, 0.938235, 0.935730, 0.933221, 0.930707, 0.928189,
    0.925666, 0.923139, 0.920607, 0.918070, 0.915527, 0.912979, 0.910426, 0.907867, 0.905302, 0.902732,
    0.900155, 0.897572, 0.894982, 0.892386, 0.889783, 0.887173, 0.884556, 0.881932, 0.879300, 0.876661,
    0.874014, 0.871360, 0.868697, 0.866026, 0.863347, 0.860659, 0.857963, 0.855258, 0.852544, 0.849820,
    0.847088, 0.844346, 0.841594, 0.838833, 0.836062, 0.833281, 0.830489, 0.827687, 0.824875, 0.822052,
    0.819218, 0.816373, 0.813517, 0.810650, 0.807771, 0.804880, 0.801978, 0.799064, 0.796137, 0.793199,
    0.790248, 0.787284, 0.784308, 0.781318, 0.778316, 0.775301, 0.772272, 0.769229, 0.766173, 0.763103,
    0.760020, 0.756922, 0.753809, 0.750682, 0.747541, 0.744385, 0.741214, 0.738027, 0.734826, 0.731609,
    0.728377, 0.725128, 0.721864, 0.718584, 0.715288, 0.711975, 0.708646, 0.705300, 0.701938, 0.698558,
    0.695161, 0.691747, 0.688316, 0.684867, 0.681400, 0.677915, 0.674412, 0.670891, 0.667352, 0.663793,
    0.660217, 0.656621, 0.653006, 0.649373, 0.645719, 0.642047, 0.638354, 0.634642, 0.630910, 0.627158,
    0.623386, 0.619593, 0.615779, 0.611945, 0.608090, 0.604213, 0.600316, 0.596397, 0.592457, 0.588494,
    0.584510, 0.580504, 0.576476, 0.572426, 0.568353, 0.564257, 0.560139, 0.555998, 0.551833, 0.547645,
    0.543434, 0.539200, 0.534941, 0.530659, 0.526352, 0.522022, 0.517667, 0.513287, 0.508883, 0.504454,
    0.500000, 0.495521, 0.491017, 0.486488, 0.481935, 0.477358, 0.472757, 0.468133, 0.463485, 0.458814,
    0.454121, 0.449404, 0.444666, 0.439906, 0.435124, 0.430320, 0.425496, 0.420650, 0.415784, 0.410897,
    0.405990, 0.401064, 0.396117, 0.391152, 0.386167, 0.381164, 0.376142, 0.371102, 0.366044, 0.360968,
    0.355874, 0.350764, 0.345636, 0.340492, 0.335331, 0.330154, 0.324961, 0.319753, 0.314529, 0.309291,
    0.304037, 0.298769, 0.293486, 0.288190, 0.282880, 0.277556, 0.272219, 0.266869, 0.261506, 0.256131,
    0.250743, 0.245344, 0.239933, 0.234511, 0.229078, 0.223633, 0.218178, 0.212713, 0.207238, 0.201753,
    0.196258, 0.190754, 0.185242, 0.179720, 0.174190, 0.168652, 0.163106, 0.157552, 0.151990, 0.146422,
    0.140847, 0.135265, 0.129676, 0.124082, 0.118482, 0.112876, 0.107265, 0.101649, 0.096028, 0.090402,
    0.084773, 0.079139, 0.073502, 0.067861, 0.062217, 0.056570, 0.050921, 0.045269, 0.039615, 0.033959,
    0.028302, 0.022643, 0.016983, 0.011323, 0.005661, 0.000000,
};



int gradationSoftglowScreenWhiten(unsigned char *data, int width, int height, int widthStep, int channel, float degree)
{
    const float minInput = 0;
    const float maxInput = 225;
    
    const float gamma = 1.2;
    const float softglow = 0.75;
    const float screen = 0.6;
    
    unsigned char inputMap[256];
    for (int i=0; i<256; ++i) {
        float value = pow(i/255.0, 1.0/gamma)*(maxInput-minInput)+minInput;
        inputMap[i] = fmin(fmaxf(value+0.5, 0.0), 255.0);
    }
    
    unsigned char *ptr;
    unsigned char r, g, b;
    if (channel == 4) {
        for (int y=0; y<height; ++y) {
            ptr = data+widthStep*y;
            for (int x=0; x<width; ++x) {
                
                // 1. color gradation
                r = inputMap[ptr[0]];
                g = inputMap[ptr[1]];
                b = inputMap[ptr[2]];
                
                // 2. softglow
//                Dc * (Dc + (2 * Sc * (1 - Dc)))
                r = r*(r+(2*r*(255-r)/255))/255*softglow + r*(1.0-softglow);
                g = g*(g+(2*g*(255-g)/255))/255*softglow + g*(1.0-softglow);
                b = b*(b+(2*b*(255-b)/255))/255*softglow + b*(1.0-softglow);
                
//                if ((r+g+b)/3 > 127) {
//                    r = (255-(255-r)*(255-r)/255)*softglow + r*(1.0-softglow);
//                    g = (255-(255-g)*(255-g)/255)*softglow + g*(1.0-softglow);
//                    b = (255-(255-b)*(255-b)/255)*softglow + b*(1.0-softglow);
//                }
//                else
//                {
//                    r = r*r/255*softglow + r*(1.0-softglow);
//                    g = g*g/255*softglow + g*(1.0-softglow);
//                    b = b*b/255*softglow + b*(1.0-softglow);
//                }
//                if (r>128) {
//                    r = (255-(255-r)*(255-r)/255)*softglow + r*(1.0-softglow);
//                }
//                else
//                {
//                    r = r*r/255*softglow + r*(1.0-softglow);
//                }
//                
//                if (g>128) {
//                    g = (255-(255-g)*(255-g)/255)*softglow + g*(1.0-softglow);
//                }
//                else
//                {
//                    g = g*g/255*softglow + g*(1.0-softglow);
//                }
//                
//                if (b>128) {
//                    b = (255-(255-b)*(255-b)/255)*softglow + b*(1.0-softglow);
//                }
//                else
//                {
//                    b = b*b/255*softglow + b*(1.0-softglow);
//                }
//                
                // 3. screen
                r = (255-(255-r)*(255-r)/255)*screen + r*(1.0-screen);
                g = (255-(255-g)*(255-g)/255)*screen + g*(1.0-screen);
                b = (255-(255-b)*(255-b)/255)*screen + b*(1.0-screen);
                
                // 4. degree control
                ptr[0] = r*degree + ptr[0]*(1.0-degree);
                ptr[1] = g*degree + ptr[1]*(1.0-degree);
                ptr[2] = b*degree + ptr[2]*(1.0-degree);
                ptr += 4;
            }
        }
    }
    
    return 0;
}


