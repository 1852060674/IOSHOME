//
//  ColorMatrix.h
//  SplitPics
//
//  Created by tangtaoyu on 15-3-16.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#ifndef COLOR_MATRIX_H
#define COLOR_MATRIX_H

#import "GPUImage.h"

//LOMO
const GPUMatrix4x4 colormatrix_lomo = (GPUMatrix4x4){{1.7f, 0.1f, 0.1f, 0},{0,   1.7f,  0.1f, 0},{0,   0.1f,  1.6f, 0},{0,   0.0f,  1.0f, 0.0f}};

//黑白
const GPUMatrix4x4 colormatrix_heibai = (GPUMatrix4x4){{0.8f,  1.6f, 0.2f, 0},{0.8f,  1.6f, 0.2f, 0},{0.8f,  1.6f, 0.2f, 0},{0,  0, 0, 1.0f}};

//复古
const GPUMatrix4x4 colormatrix_huajiu = (GPUMatrix4x4){{0.2f,0.5f, 0.1f, 0},{0.2f, 0.5f, 0.1f, 0},{0.2f,0.5f, 0.1f, 0},{0, 0, 0, 1}};

//哥特
const GPUMatrix4x4 colormatrix_gete = (GPUMatrix4x4){{1.9f,-0.3f, -0.2f, 0},{-0.2f, 1.7f, -0.1f, 0},{-0.1f,-0.6f, 2.0f, 0},{0, 0, 0, 1.0f}};

//锐化
const GPUMatrix4x4 colormatrix_ruise = (GPUMatrix4x4){{4.8f,-1.0f, -0.1f, 0},{-0.5f,4.4f, -0.1f, 0},{-0.5f,-1.0f, 5.2f, 0},{0, 0, 0, 1.0f}};

//淡雅
const GPUMatrix4x4 colormatrix_danya = (GPUMatrix4x4){{0.6f,0.3f, 0.1f, 0},{0.2f,0.7f, 0.1f, 0},{0.2f,0.3f, 0.4f, 0},{0, 0, 0, 1.0f}};

//酒红
const GPUMatrix4x4 colormatrix_jiuhong = (GPUMatrix4x4){{1.2f,0.0f, 0.0f, 0.0f},{0.0f,0.9f, 0.0f, 0.0f},{0.0f,0.0f, 0.8f, 0.0f},{0, 0, 0, 1.0f}};

//清宁
const GPUMatrix4x4 colormatrix_qingning = (GPUMatrix4x4){{0.9f, 0, 0, 0},{0, 1.1f,0, 0},{0, 0, 0.9f, 0},{0, 0, 0, 1.0f}};

//浪漫
const GPUMatrix4x4 colormatrix_langman = (GPUMatrix4x4){{0.9f, 0, 0, 0},{0, 0.9f,0, 0},{0, 0, 0.9f, 0},{0, 0, 0, 1.0f}};

//光晕
const GPUMatrix4x4 colormatrix_guangyun = (GPUMatrix4x4){{0.9f, 0, 0,  0},{0, 0.9f,0,  0},{0, 0, 0.9f,  0},{0, 0, 0, 1.0f}};

//蓝调
const GPUMatrix4x4 colormatrix_landiao = (GPUMatrix4x4){{2.1f, -1.4f, 0.6f, 0.0f},{-0.3f, 2.0f, -0.3f, 0.0f},{-1.1f, -0.2f, 2.6f, 0.0f},{0.0f, 0.0f, 0.0f, 1.0f}};

//梦幻
const GPUMatrix4x4 colormatrix_menghuan = (GPUMatrix4x4){{0.8f, 0.3f, 0.1f, 0.0f},{0.1f, 0.9f, 0.0f, 0.0f},{0.1f, 0.3f, 0.7f, 0.0f},{0.0f, 0.0f, 0.0f, 1.0f}};

//夜色
const GPUMatrix4x4 colormatrix_yese = (GPUMatrix4x4){{1.0f, 0.0f, 0.0f, 0.0f},{0.0f, 1.1f, 0.0f, 0.0f},{0.0f, 0.0f, 1.0f, 0.0f},{0.0f, 0.0f, 0.0f, 1.0f}};


#endif
