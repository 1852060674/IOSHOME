//
//  LBFRegressor.cpp
//  FaceAlignmentZB
//
//  Created by ZB_Mac on 2016/12/23.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#include "LBFRegressor.hpp"
#include "LBFRandomForest.hpp"
#include <iostream>
#include "LBFCommon.hpp"
#include <opencv2/highgui/highgui.hpp>
#include "liblinear/linear.h"

namespace LBF {
    LBFRegressor* LBFRegressor::share = NULL;
    
    LBFRegressor * LBFRegressor::defaultRegressor()
    {
        if(LBFRegressor::share == NULL)
        LBFRegressor::share = new LBFRegressor();
        return share;
    }
    
    void LBFRegressor::destoryDefaultRegressor() {
        if(LBFRegressor::share != NULL)
        {
            delete LBFRegressor::share;
            LBFRegressor::share = NULL;
        }
    }
    
    LBFRegressor::LBFRegressor()
    {
        
    }
    
    LBFRegressor::~LBFRegressor()
    {
        release();
    }

    bool LBFRegressor::isInitialized()
    {
        return !models.empty();
    }

    void LBFRegressor::initialize(unsigned char **bufferPtr)
    {
        read(bufferPtr);
    }
    void LBFRegressor::initialize(FILE* fp)
    {
        read(fp);
    }
    void LBFRegressor::release()
    {
        int stage_num = (int)models.size();
        int landmark_num = (int)models[0].size();

        for (int stage_idx=0; stage_idx<stage_num; ++stage_idx) {
            for (int landmark_idx=0; landmark_idx<landmark_num; ++landmark_idx) {
                free_and_destroy_model(&(models[stage_idx][landmark_idx]));
            }
        }

        models.clear();
        forests.clear();
        mean_shape.release();
    }

    void LBFRegressor::train(std::vector<IMAGE_MAT>& images, std::vector<BBox>& bounds, std::vector<SHAPE_MAT>& target_shapes)
    {
        mean_shape = GetMeanShape(target_shapes, bounds);

        // augment train samples
        cv::RNG random_generator(cv::getTickCount());
        int augment_num = Config::GetInstance().augment_n;
        
        for(int i = 0;i < images.size();i++){
            for(int j = 0;j < augment_num;j++){
                int index = 0;
                do{
                    // index = (i+j+1) % (images.size());
                    index = random_generator.uniform(0, (int)images.size());
                }while(index == i);
                
                // 1. Select ground truth shapes of other images as initial shapes
                augmented_images.push_back(images[i]);
                augmented_target_shapes.push_back(target_shapes[i]);
                augmented_bounds.push_back(bounds[i]);
                
                // 2. Project current shape to bounding box of ground truth shapes
                SHAPE_MAT temp(target_shapes[index].rows, target_shapes[index].cols);
                SHAPE_MAT temp2(target_shapes[index].rows, target_shapes[index].cols);
                
                ProjectShape(target_shapes[index], bounds[index], temp);
                ReProjectShape(temp, bounds[i], temp2);
                current_shapes.push_back(temp2);

//                ReProjectShape(mean_shape, bounds[i], temp2);
//                current_shapes.push_back(temp2);
            }
        }
        
        int num_stage = Config::GetInstance().stages_n;
        int num_landmarks = Config::GetInstance().landmark_n;
        
        forests.resize(num_stage);
        models.resize(num_stage);

        for (int stage = 0; stage < num_stage; ++stage)
        {
            forests[stage].resize(num_landmarks);
            
            GetShapeResidual(augmented_target_shapes, current_shapes, augmented_bounds, mean_shape, shapes_residual);
            
            SHAPE_LANDMARK_TYPE residual = 0;
            for (int idx=0; idx<images.size(); ++idx) {
                for (int jj=0; jj<shapes_residual[idx].rows; ++jj)
                {
                    residual += fabs(shapes_residual[idx](jj, 0))+fabs(shapes_residual[idx](jj, 1));
                }
                if (idx < 10)
                {
                    printf("\nshape %d residual before stage: %d:\n", idx, stage);
                    for (int jj=0; jj<shapes_residual[idx].rows; ++jj)
                    {
                        printf("(%f, %f)", shapes_residual[idx](jj, 0), shapes_residual[idx](jj, 1));
                    }
                }
            }
            printf("\naverage residual before stage %d: %f\n", stage, (float)(residual/images.size()/shapes_residual[0].rows/2));

            for (int landmark_index=0; landmark_index<num_landmarks; ++landmark_index)
            {
                forests[stage][landmark_index].regressor = this;
                forests[stage][landmark_index].train(stage, landmark_index);
            }
            
            struct feature_node **features_map;
            features_map = new struct feature_node* [augmented_images.size()];
            for (int i=0;i<augmented_images.size();i++){
                features_map[i] = new struct feature_node[Config::GetInstance().landmark_n*Config::GetInstance().tree_per_forest+1];
            }
            
            derive_local_binary_feature(features_map, stage);
            
            train_global_regression_and_update(features_map, stage);
            
            std::cout<<"stage "<<stage<<" trained"<<std::endl;
            
            for (int i=0;i<images.size();i++){
                delete [] features_map[i];
            }
            delete [] features_map;
        }
        
        GetShapeResidual(augmented_target_shapes, current_shapes, augmented_bounds, mean_shape, shapes_residual);
        SHAPE_LANDMARK_TYPE residual = 0;
        for (int idx=0; idx<images.size(); ++idx) {
            for (int jj=0; jj<shapes_residual[idx].rows; ++jj)
            {
                residual += fabs(shapes_residual[idx](jj, 0))+fabs(shapes_residual[idx](jj, 1));
            }

            if (idx < 10)
            {
                printf("\n shape %d residual result:\n", idx);
                for (int jj=0; jj<shapes_residual[idx].rows; ++jj)
                {
                    printf("(%f, %f)", shapes_residual[idx](jj, 0), shapes_residual[idx](jj, 1));
                }
            }
        }
        printf("\nresult average residual: %f\n", (float)(residual/images.size()/shapes_residual[0].rows/2));
    }

    void LBFRegressor::train_global_regression_and_update(struct feature_node **binfeatures,
                                                          int stage
                                                          )
    {
        int num_residual = shapes_residual[0].rows*shapes_residual[0].cols;
        int num_feature = Config::GetInstance().landmark_n * Config::GetInstance().tree_per_forest * powf(2,(Config::GetInstance().tree_depth-1));
        int num_train_sample = (int)augmented_images.size();
        
        std::vector<struct model*>& stage_models = models[stage];
        stage_models.resize(num_residual);
        
        // shapes_residual: n*(l*2)
        // construct the problem(expect y)
        struct problem* prob = new struct problem;
        prob -> l = num_train_sample;
        prob -> n = num_feature;
        prob -> x = binfeatures;
        prob -> bias = -1;
        
        // construct the parameter
        struct parameter* param = new struct parameter;
        param-> solver_type = L2R_L2LOSS_SVR_DUAL;
        //  param-> solver_type = L2R_L2LOSS_SVR;
        param->C = 1.0/num_train_sample;
        param->p = 0;
        
        // initialize the y
        float** yy = new float*[num_residual];
        
        for (int i=0;i<num_residual;i++){
            yy[i] = new float[num_train_sample];
        }
        for (int i=0; i<num_train_sample;i++)
        {
            for (int j=0;j<num_residual;j++)
            {
                if (j < num_residual/2){
                    yy[j][i] = shapes_residual[i](j,0);
                }
                else{
                    yy[j][i] = shapes_residual[i](j-num_residual/2,1);
                }
            }
        }
        
        //train
        for (int i=0;i < num_residual;i++){
            prob->y = yy[i];
            check_parameter(prob, param);
            struct model* lbfmodel = ::train(prob, param);
            stage_models[i] = lbfmodel;
            
            delete [] yy[i];
        }
        delete [] yy;
        delete  prob;
        delete param;
        
        // update the current shape and shapes_residual
        float tmp;
        float scale;
        SHAPE_MAT rotation;
        SHAPE_MAT deltashape_bar(num_residual/2,2);
        for (int i=0;i<num_train_sample;i++){
            for (int j=0;j<num_residual;j++){
                tmp = ::predict(stage_models[j], binfeatures[i]);
                if (j < num_residual/2)
                {
                    deltashape_bar(j,0) = tmp;
                }
                else
                {
                    deltashape_bar(j-num_residual/2,1) = tmp;
                }
            }
            // now transfer
            SHAPE_MAT projected_current(current_shapes[i].rows, current_shapes[i].cols);
            ProjectShape(current_shapes[i], augmented_bounds[i], projected_current);
            
            SimilarityTransform(projected_current, mean_shape, rotation, scale);
            
            deltashape_bar = scale * deltashape_bar * rotation;

            ReProjectShape(projected_current+deltashape_bar, augmented_bounds[i], current_shapes[i]);
        }
    }
    
    void LBFRegressor::get_local_binary_feature(struct feature_node* features,
                                                IMAGE_MAT& image,
                                                SHAPE_MAT& current_shape,
                                                BBox& bound_box,
                                                int stage
                                                )
    {
        SHAPE_MAT rotation;
        float scale;
        
        SHAPE_MAT projected_shape(current_shape.rows, current_shape.cols);
        ProjectShape(current_shape, bound_box, projected_shape);
        SimilarityTransform(projected_shape, mean_shape, rotation, scale);

        std::vector<LBFRandomForest>& stage_forests = forests[stage];
        int forest_num = (int)stage_forests.size();
        for (int j=0; j<forest_num; j++){
            stage_forests[j].test(features+j*Config::GetInstance().tree_per_forest, image, current_shape, bound_box, mean_shape, rotation, scale);
        }
        features[Config::GetInstance().landmark_n*Config::GetInstance().tree_per_forest].index = -1;
        features[Config::GetInstance().landmark_n*Config::GetInstance().tree_per_forest].value = -1;
    }
    
    void LBFRegressor::derive_local_binary_feature(struct feature_node** features_map, int stage)
    {
        int image_num = (int)augmented_images.size();
        for (int image_idx=0; image_idx<image_num; ++image_idx)
        {
            get_local_binary_feature(features_map[image_idx], augmented_images[image_idx], current_shapes[image_idx], augmented_bounds[image_idx], stage);
        }
    }

    void LBFRegressor::read(FILE* fp)
    {
        int stage_num = 0;
        int landmark_num = 0;
        
        fread(&stage_num, sizeof(int), 1, fp);
        fread(&landmark_num, sizeof(int), 1, fp);
        
        mean_shape.create(landmark_num, 2);
        for (int rowIdx=0; rowIdx<landmark_num; ++rowIdx) {
            fread(&mean_shape(rowIdx,0), sizeof(SHAPE_LANDMARK_TYPE), 1, fp);
            fread(&mean_shape(rowIdx,1), sizeof(SHAPE_LANDMARK_TYPE), 1, fp);
        }
        
        forests.resize(stage_num);
        models.resize(stage_num);
        
        for (int stage_idx=0; stage_idx<stage_num; ++stage_idx) {
            forests[stage_idx].resize(landmark_num);
            
            for (int landmark_idx=0; landmark_idx<landmark_num; ++landmark_idx) {
                forests[stage_idx][landmark_idx].read(fp);
                forests[stage_idx][landmark_idx].regressor = this;
            }
        }
        
        for (int stage_idx=0; stage_idx<stage_num; ++stage_idx) {
            models[stage_idx].resize(landmark_num*2);

            for (int landmark_idx=0; landmark_idx<landmark_num*2; ++landmark_idx) {
                models[stage_idx][landmark_idx] = load_model_binary(fp);
            }
        }
    }
    
    void LBFRegressor::read(unsigned char **bufferPtr)
    {
        int stage_num = 0;
        int landmark_num = 0;
        
        unsigned char *buffer = *bufferPtr;
        
        int amount = sizeof(int);
        memcpy(&stage_num, buffer, amount);
        buffer += amount;
        
        amount = sizeof(int);
        memcpy(&landmark_num, buffer, amount);
        buffer += amount;
        
        mean_shape.create(landmark_num, 2);
        for (int rowIdx=0; rowIdx<landmark_num; ++rowIdx) {
            amount = sizeof(SHAPE_LANDMARK_TYPE);
            memcpy(&mean_shape(rowIdx,0), buffer, amount);
            buffer += amount;

            amount = sizeof(SHAPE_LANDMARK_TYPE);
            memcpy(&mean_shape(rowIdx,1), buffer, amount);
            buffer += amount;
        }
        
        *bufferPtr = buffer;
        forests.resize(stage_num);
        models.resize(stage_num);
        
        for (int stage_idx=0; stage_idx<stage_num; ++stage_idx) {
            forests[stage_idx].resize(landmark_num);
            
            for (int landmark_idx=0; landmark_idx<landmark_num; ++landmark_idx) {
                forests[stage_idx][landmark_idx].read(bufferPtr);
                forests[stage_idx][landmark_idx].regressor = this;
            }
        }
        
        for (int stage_idx=0; stage_idx<stage_num; ++stage_idx) {
            models[stage_idx].resize(landmark_num*2);
            
            for (int landmark_idx=0; landmark_idx<landmark_num*2; ++landmark_idx) {
                models[stage_idx][landmark_idx] = load_model_binary_buffer(bufferPtr);
            }
        }
    }
    
    void LBFRegressor::write(FILE* fp)
    {
        int stage_num = (int)forests.size();
        fwrite(&stage_num, sizeof(int), 1, fp);

        int landmark_num = (int)forests[0].size();
        fwrite(&landmark_num, sizeof(int), 1, fp);

        for (int rowIdx=0; rowIdx<landmark_num; ++rowIdx) {
            fwrite(&mean_shape(rowIdx,0), sizeof(SHAPE_LANDMARK_TYPE), 1, fp);
            fwrite(&mean_shape(rowIdx,1), sizeof(SHAPE_LANDMARK_TYPE), 1, fp);
        }
        
        for (int stage_idx=0; stage_idx<stage_num; ++stage_idx) {
            for (int landmark_idx=0; landmark_idx<landmark_num; ++landmark_idx) {
                forests[stage_idx][landmark_idx].write(fp);
            }
        }
        
        for (int stage_idx=0; stage_idx<stage_num; ++stage_idx) {
            for (int landmark_idx=0; landmark_idx<landmark_num*2; ++landmark_idx) {
                save_model_binary(fp, models[stage_idx][landmark_idx]);
            }
        }
    }
    
    void LBFRegressor::test(IMAGE_MAT& image, BBox& bounding_box, SHAPE_MAT& shape)
    {
        int stage_num = (int)forests.size();
        int landmark_num = (int)forests[0].size();

        shape.create(mean_shape.rows, mean_shape.cols);
        ReProjectShape(mean_shape, bounding_box, shape);
        
        struct feature_node *feature_map = new struct feature_node[Config::GetInstance().landmark_n*Config::GetInstance().tree_per_forest+1];

        float tmp;
        float scale;
        SHAPE_MAT rotation;
        SHAPE_MAT deltashape_bar(landmark_num,2);
        SHAPE_MAT projected_current(mean_shape.rows, mean_shape.cols);
        
        IMAGE_MAT draw_image;
        
        for (int stage_idx=0; stage_idx<stage_num; ++stage_idx) {
            get_local_binary_feature(feature_map, image, shape, bounding_box, stage_idx);

            // update the current shape and shape_residual
            for (int j=0;j<landmark_num*2;j++){
                tmp = ::predict(models[stage_idx][j], feature_map);
                if (j < landmark_num)
                {
                    deltashape_bar(j,0) = tmp;
                }
                else
                {
                    deltashape_bar(j-landmark_num,1) = tmp;
                }
            }
            // now transfer
            ProjectShape(shape, bounding_box, projected_current);
            
            SimilarityTransform(projected_current, mean_shape, rotation, scale);
            
            deltashape_bar = scale * deltashape_bar * rotation;
            
            ReProjectShape(projected_current+deltashape_bar, bounding_box, shape);
            
            printf("\ndelta shape of stage: %d:\n", stage_idx);
            for (int jj=0; jj<deltashape_bar.rows; ++jj)
            {
                printf("(%f, %f)", deltashape_bar(jj, 0), deltashape_bar(jj, 1));
            }
        }

        delete [] feature_map;
    }

}
