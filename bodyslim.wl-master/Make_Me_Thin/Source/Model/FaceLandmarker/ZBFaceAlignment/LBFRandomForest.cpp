//
//  LBFRandomForest.cpp
//  FaceAlignmentZB
//
//  Created by ZB_Mac on 2016/12/23.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#include <cmath>
#include "LBFRandomForest.hpp"
#include "LBFCommon.hpp"
#include "LBFRegressor.hpp"
#include "LBFTree.hpp"
#include "liblinear/linear.h"

namespace LBF {
    void LBFRandomForest::train(int stage_idx, int landmark_idx)
    {
        stage = stage_idx;
        landmark_id = landmark_idx;
        
        std::vector<IMAGE_MAT>& images = regressor->augmented_images;

        float overlap_ratio = Config::GetInstance().bagging_overlap;
        int max_tree_number = Config::GetInstance().tree_per_forest;
        
        trees.resize(max_tree_number);
        
        int dbsize = (int)images.size();
        int Q = floor(dbsize*1.0/((1.0-overlap_ratio)*max_tree_number));
        int is,ie;
        std::vector<int> index;
        index.reserve(Q+1);
        for (int j =0;j <max_tree_number; j++){
            index.clear();
            is = fmax( floor(j*Q - j*Q*overlap_ratio ), 0.0);
            ie = fmin(is + Q, dbsize-1);
            for (int k = is; k<=ie;k++){
                index.push_back(k);
            }
            trees[j].forest = this;
            trees[j].train(index);
        }
    }
    
    void LBFRandomForest::test(struct feature_node* features,
                               const IMAGE_MAT& image,
                               const SHAPE_MAT& current_shape,
                               const BBox& bound_box,
                               const SHAPE_MAT& mean_shape,
                               const cv::Mat_<float>& rotation,
                               const float scale)
    {

        int max_depth = Config::GetInstance().tree_depth;
        int tree_num = (int)trees.size();
        int leaf_per_tree = powf(2,(max_depth-1));
        int leaf_index;

        for(int k = 0; k<tree_num; k++)
        {
            leaf_index = trees[k].test(image, current_shape, bound_box, rotation, scale);
            
            // feature index starts at 1
            features[k].index = leaf_per_tree*(tree_num*landmark_id+k) + leaf_index + 1;
            features[k].value = 1;
        }
    }
    
    void LBFRandomForest::read(FILE* fp)
    {
        int size;
        
        fread(&landmark_id, sizeof(int), 1, fp);
        fread(&stage, sizeof(int), 1, fp);
        fread(&size, sizeof(int), 1, fp);
        trees.resize(size);
        
        for (int idx=0; idx<size; ++idx) {
            trees[idx].read(fp);
            trees[idx].forest = this;
        }
    }
    
    void LBFRandomForest::read(unsigned char **bufferPtr)
    {
        unsigned char *buffer = *bufferPtr;
        
        int size = 0;
        int amount = sizeof(int);
        memcpy(&landmark_id, buffer, amount);
        buffer += amount;
        
        amount = sizeof(int);
        memcpy(&stage, buffer, amount);
        buffer += amount;
        
        amount = sizeof(int);
        memcpy(&size, buffer, amount);
        buffer += amount;
        trees.resize(size);

        *bufferPtr = buffer;
        
        for (int idx=0; idx<size; ++idx) {
            trees[idx].read(bufferPtr);
            trees[idx].forest = this;
        }
    }
    
    void LBFRandomForest::write(FILE* fp)
    {
        int size = (int)trees.size();
        
        fwrite(&landmark_id, sizeof(int), 1, fp);
        fwrite(&stage, sizeof(int), 1, fp);
        fwrite(&size, sizeof(int), 1, fp);
        
        for (int idx=0; idx<size; ++idx) {
            trees[idx].write(fp);
        }
    }
}
