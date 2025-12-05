//
//  LBFRandomForest.hpp
//  FaceAlignmentZB
//
//  Created by ZB_Mac on 2016/12/23.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#ifndef LBFRandomForest_hpp
#define LBFRandomForest_hpp

#include <stdio.h>
#include <vector>
#include "LBFTree.hpp"
#include "linear.h"

namespace LBF {
    class LBFRegressor;
    
    class LBFRandomForest
    {
    public:
        void test(struct feature_node* features,
                  const IMAGE_MAT& image,
                  const SHAPE_MAT& current_shape,
                  const BBox& bound_box,
                  const SHAPE_MAT& mean_shape,
                  const cv::Mat_<float>& rotation,
                  const float scale);
        
        void read(FILE* fp);
        void read(unsigned char **bufferPtr);

        void write(FILE* fp);
        
    public:
        std::vector<LBFTree> trees;

        LBFRegressor *regressor;
        int landmark_id;
        int stage;
        
        void train(int stage_idx, int landmark_idx);
        
        LBFRandomForest(){};
        ~LBFRandomForest(){};
    };
}


#endif /* LBFRandomForest_hpp */
