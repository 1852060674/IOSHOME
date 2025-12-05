//
//  LBFRegressor.hpp
//  FaceAlignmentZB
//
//  Created by ZB_Mac on 2016/12/23.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#ifndef LBFRegressor_hpp
#define LBFRegressor_hpp

#include <stdio.h>
#include <vector>
#include "LBFCommon.hpp"
#include "LBFRandomForest.hpp"
#include "liblinear/linear.h"

namespace LBF {
    
    class LBFRegressor
    {
    public:
        
        static LBFRegressor* share;
        static LBFRegressor* defaultRegressor();
        static void destoryDefaultRegressor();

        bool isInitialized();

        std::vector<std::vector<LBFRandomForest> > forests;
        std::vector<std::vector<struct model*> > models;
        SHAPE_MAT mean_shape;

        void get_local_binary_feature(struct feature_node* features,
                                      IMAGE_MAT& image,
                                      SHAPE_MAT& current_shape,
                                      BBox& bound_box,
                                      int stage
                                      );
        
        // for training
        std::vector<IMAGE_MAT> augmented_images;
        std::vector<BBox> augmented_bounds;
        std::vector<SHAPE_MAT> augmented_target_shapes;
        std::vector<SHAPE_MAT> current_shapes;
        std::vector<SHAPE_MAT >shapes_residual;
        
        void train(std::vector<IMAGE_MAT>& images, std::vector<BBox>& bounds, std::vector<SHAPE_MAT>& target_shapes);
        void derive_local_binary_feature(struct feature_node** features_map, int stage);
        
        void train_global_regression_and_update(struct feature_node **binfeatures,
                                                int stage
                                                );
        
        void read(FILE* fp);
        void read(unsigned char **bufferPtr);
        void write(FILE* fp);

        void initialize(unsigned char **bufferPtr);
        void initialize(FILE* fp);
        void release();

        void test(IMAGE_MAT& image, BBox& bounding_box, SHAPE_MAT& shape);
        
    public:
        LBFRegressor();
        ~LBFRegressor();
    };
}
#endif /* LBFRegressor_hpp */
