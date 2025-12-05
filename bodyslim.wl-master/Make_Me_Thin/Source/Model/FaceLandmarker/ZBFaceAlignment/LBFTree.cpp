//
//  LBFTree.cpp
//  FaceAlignmentZB
//
//  Created by ZB_Mac on 2016/12/23.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#include <stdlib.h>
#include <cmath>

#include "LBFTree.hpp"
#include "LBFCommon.hpp"
#include "LBFRandomForest.hpp"
#include "LBFRegressor.hpp"

namespace LBF {
    inline SHAPE_LANDMARK_TYPE calculate_var(const SHAPE_MAT& v1){
        SHAPE_LANDMARK_TYPE mean_1 = mean(v1)[0];
        SHAPE_LANDMARK_TYPE mean_2 = mean(v1.mul(v1))[0];
        return mean_2 - mean_1*mean_1;
    }
    
    inline SHAPE_LANDMARK_TYPE calculate_var(const std::vector<SHAPE_LANDMARK_TYPE>& v_1 ){
        if (v_1.size() == 0)
            return 0;
        SHAPE_MAT v1(v_1);
        SHAPE_LANDMARK_TYPE mean_1 = mean(v1)[0];
        SHAPE_LANDMARK_TYPE mean_2 = mean(v1.mul(v1))[0];
        return mean_2 - mean_1*mean_1;
        
    }
    
    void LBFTreeNode::split_node(LBFTreeNode &left_child, LBFTreeNode &right_child)
    {
        std::vector<int> left_child_indexs;
        std::vector<int> right_child_indexs;
        
        if (samples_index.size() == 0)
        {
            thresh = 0;
            feature[0] = 0;
            feature[1] = 0;
            feature[2] = 0;
            feature[3] = 0;
            splited = true;
            leaf = false;
        }
        else
        {
            int max_feature_number = Config::GetInstance().feature_m[tree->forest->stage];
            float max_radius_ratio = Config::GetInstance().radius_m[tree->forest->stage];
            std::vector<SHAPE_MAT> &current_shapes = tree->forest->regressor->current_shapes;
            std::vector<BBox> &bounding_box = tree->forest->regressor->augmented_bounds;
            SHAPE_MAT& mean_shape = tree->forest->regressor->mean_shape;
            int landmark_id = tree->forest->landmark_id;
            std::vector<IMAGE_MAT>& images = tree->forest->regressor->augmented_images;
            SHAPE_MAT &shapes_residual = tree->shapes_residual;
            
            // get candidate pixel locations
            cv::RNG random_generator(cv::getTickCount());
            SHAPE_MAT candidate_pixel_locations(max_feature_number,4);
            for(unsigned int i = 0;i < max_feature_number;i++){
                float x1 = random_generator.uniform(-1.0,1.0);
                float y1 = random_generator.uniform(-1.0,1.0);
                float x2 = random_generator.uniform(-1.0,1.0);
                float y2 = random_generator.uniform(-1.0,1.0);
                if((x1*x1 + y1*y1 > 1.0)||(x2*x2 + y2*y2 > 1.0)){
                    i--;
                    continue;
                }
                // cout << x1 << " "<<y1 <<" "<< x2<<" "<< y2<<endl;
                candidate_pixel_locations(i,0) = x1 * max_radius_ratio;
                candidate_pixel_locations(i,1) = y1 * max_radius_ratio;
                candidate_pixel_locations(i,2) = x2 * max_radius_ratio;
                candidate_pixel_locations(i,3) = y2 * max_radius_ratio;
            }
            
            // get pixel difference feature
            cv::Mat_<int> densities(max_feature_number, (int)samples_index.size());
            SHAPE_MAT temp(current_shapes[0].size());
            
            for (int i=0; i<samples_index.size();i++){
                SHAPE_MAT rotation;
                float scale;
                ProjectShape(current_shapes[samples_index[i]],bounding_box[samples_index[i]], temp);
                
                SimilarityTransform(temp, mean_shape, rotation, scale);
                // whether transpose or not ????
                // TODO: check transpose or not!!!
                
                for(int j = 0;j < max_feature_number;j++)
                {
                    float project_x1 = rotation(0,0) * candidate_pixel_locations(j,0) + rotation(0,1) * candidate_pixel_locations(j,1);
                    float project_y1 = rotation(1,0) * candidate_pixel_locations(j,0) + rotation(1,1) * candidate_pixel_locations(j,1);
                    project_x1 = scale * project_x1 * bounding_box[samples_index[i]].width / 2.0;
                    project_y1 = scale * project_y1 * bounding_box[samples_index[i]].height / 2.0;
                    int real_x1 = project_x1 + current_shapes[samples_index[i]](landmark_id,0);
                    int real_y1 = project_y1 + current_shapes[samples_index[i]](landmark_id,1);
                    real_x1 = fmax(0.0,fmin((float)real_x1,images[samples_index[i]].cols-1.0));
                    real_y1 = fmax(0.0,fmin((float)real_y1,images[samples_index[i]].rows-1.0));
                    
                    float project_x2 = rotation(0,0) * candidate_pixel_locations(j,2) + rotation(0,1) * candidate_pixel_locations(j,3);
                    float project_y2 = rotation(1,0) * candidate_pixel_locations(j,2) + rotation(1,1) * candidate_pixel_locations(j,3);
                    project_x2 = scale * project_x2 * bounding_box[samples_index[i]].width / 2.0;
                    project_y2 = scale * project_y2 * bounding_box[samples_index[i]].height / 2.0;
                    int real_x2 = project_x2 + current_shapes[samples_index[i]](landmark_id,0);
                    int real_y2 = project_y2 + current_shapes[samples_index[i]](landmark_id,1);
                    real_x2 = fmax(0.0,fmin((float)real_x2,images[samples_index[i]].cols-1.0));
                    real_y2 = fmax(0.0,fmin((float)real_y2,images[samples_index[i]].rows-1.0));
                    
                    densities(j,i) = ((int)(images[samples_index[i]](real_y1,real_x1))-(int)(images[samples_index[i]](real_y2,real_x2)));
                }
            }
            // pick the feature
            cv::Mat_<int> densities_sorted = densities.clone();
            cv::sort(densities, densities_sorted, cv::SORT_ASCENDING);
            std::vector<SHAPE_LANDMARK_TYPE> lc1,lc2;
            std::vector<SHAPE_LANDMARK_TYPE> rc1,rc2;
            lc1.reserve(samples_index.size());
            rc1.reserve(samples_index.size());
            lc2.reserve(samples_index.size());
            rc2.reserve(samples_index.size());
            float var_overall =(calculate_var(shapes_residual.col(0))+calculate_var(shapes_residual.col(1))) * samples_index.size();
            float threshold = 0;
            float var_lc = 0;
            float var_rc = 0;
            float var_reduce = 0;
            float max_id = 0;
            float max_var_reductions = 0;
            float max_threshold = 0;
            
            for (int i=0; i<max_feature_number; i++){
                lc1.clear();
                lc2.clear();
                rc1.clear();
                rc2.clear();
                int ind = random_generator.uniform(0, (int)samples_index.size());
                threshold = densities_sorted(i,ind);
                for (int j=0;j < samples_index.size();j++)
                {
                    if (densities(i,j) < threshold)
                    {
                        lc1.push_back(shapes_residual(j,0));
                        lc2.push_back(shapes_residual(j,1));
                    }
                    else
                    {
                        rc1.push_back(shapes_residual(j,0));
                        rc2.push_back(shapes_residual(j,1));
                    }
                }
                var_lc = (calculate_var(lc1)+calculate_var(lc2)) * lc1.size();
                var_rc = (calculate_var(rc1)+calculate_var(rc2)) * rc1.size();
                var_reduce = var_overall - var_lc - var_rc;
                //       cout << var_reduce<<endl;
                if (var_reduce > max_var_reductions){
                    max_var_reductions = var_reduce;
                    max_id = i;
                    max_threshold = threshold;
                }
            }
            
            feature[0] =candidate_pixel_locations(max_id,0);//max_radius_ratio;
            feature[1] =candidate_pixel_locations(max_id,1);//max_radius_ratio;
            feature[2] =candidate_pixel_locations(max_id,2);//max_radius_ratio;
            feature[3] =candidate_pixel_locations(max_id,3);//max_radius_ratio;
            thresh = max_threshold;
            
            splited = true;
            leaf = false;
            
            left_child_indexs.clear();
            right_child_indexs.clear();
            for (int j=0; j<samples_index.size(); ++j)
            {
                if (densities(max_id,j) < max_threshold)
                {
                    left_child_indexs.push_back(samples_index[j]);
                }
                else
                {
                    right_child_indexs.push_back(samples_index[j]);
                }
            }
        }
        
        left_child.samples_index = left_child_indexs;
        left_child.splited = false;
        left_child.leaf = true;
        left_child.child_nodes[0] = -1;
        left_child.child_nodes[1] = -1;
        left_child.depth = depth+1;
        
        right_child.samples_index = right_child_indexs;
        right_child.splited = false;
        right_child.leaf = true;
        right_child.child_nodes[0] = -1;
        right_child.child_nodes[1] = -1;
        right_child.depth = depth+1;
    }
    
    void LBFTreeNode::read(FILE* fp)
    {
        fread(&splited, sizeof(bool), 1, fp);
        fread(child_nodes, sizeof(int), 2, fp);
        fread(&leaf, sizeof(bool), 1, fp);
        fread(&thresh, sizeof(float), 1, fp);
        fread(feature, sizeof(float), 4, fp);
        int sample_size;
        fread(&sample_size, sizeof(int), 1, fp);
        samples_index.resize(sample_size);
    }
    
    void LBFTreeNode::read(unsigned char **bufferPtr)
    {
        unsigned char *buffer = *bufferPtr;
        
        int amount = sizeof(bool);
        memcpy(&splited, buffer, amount);
        buffer += amount;
        
        amount = sizeof(int)*2;
        memcpy(child_nodes, buffer, amount);
        buffer += amount;
        
        amount = sizeof(bool);
        memcpy(&leaf, buffer, amount);
        buffer += amount;
        
        amount = sizeof(float);
        memcpy(&thresh, buffer, amount);
        buffer += amount;
        
        amount = sizeof(float)*4;
        memcpy(feature, buffer, amount);
        buffer += amount;
        
        int sample_size;
        amount = sizeof(int);
        memcpy(&sample_size, buffer, amount);
        buffer += amount;
        samples_index.resize(sample_size);
        
        *bufferPtr = buffer;
    }
    
    void LBFTreeNode::write(FILE* fp)
    {
        fwrite(&splited, sizeof(bool), 1, fp);
        fwrite(child_nodes, sizeof(int), 2, fp);
        fwrite(&leaf, sizeof(bool), 1, fp);
        fwrite(&thresh, sizeof(float), 1, fp);
        fwrite(feature, sizeof(float), 4, fp);
        int sample_size = (int)samples_index.size();
        fwrite(&sample_size, sizeof(int), 1, fp);
    }
    
    void LBFTree::train(std::vector<int> &samples_index)
    {
        const std::vector<SHAPE_MAT >& regression_targets = forest->regressor->shapes_residual;
        
        int landmarkID = forest->landmark_id;
        int max_depth = Config::GetInstance().tree_depth;
        
        shapes_residual.create((int)samples_index.size(),2);
        // calculate regression targets: the difference between ground truth shapes and current shapes
        for(int i=0; i<samples_index.size(); i++){
            shapes_residual(i,0) = regression_targets[samples_index[i]](landmarkID,0);
            shapes_residual(i,1) = regression_targets[samples_index[i]](landmarkID,1);
        }
        
        int node_number = pow(2, max_depth)-1;
        nodes.resize(node_number);
        
        // initialize the root
        nodes[0].samples_index = samples_index;
        nodes[0].splited = false;
        nodes[0].leaf = true;
        nodes[0].thresh = 0;
        nodes[0].feature[0] = 0;
        nodes[0].feature[1] = 0;
        nodes[0].feature[2] = 0;
        nodes[0].feature[3] = 0;
        nodes[0].depth = 1;
        nodes[0].parent_node = -1;
        nodes[0].child_nodes[0] = -1;
        nodes[0].child_nodes[1] = -1;
        
        for (int node_idx=0; node_idx<node_number; ++node_idx) {
            nodes[node_idx].tree = this;
            if (!nodes[node_idx].splited && nodes[node_idx].depth<max_depth)
            {
                int left_child_idx=(node_idx+1)*2-1;
                int right_child_idx=(node_idx+1)*2;
                nodes[node_idx].split_node(nodes[left_child_idx], nodes[right_child_idx]);
                nodes[node_idx].child_nodes[0] = left_child_idx;
                nodes[node_idx].child_nodes[1] = right_child_idx;
                nodes[left_child_idx].parent_node = node_idx;
                nodes[right_child_idx].parent_node = node_idx;
            }
        }
    }
    
    int LBFTree::test(const IMAGE_MAT& image,
                      const SHAPE_MAT& shape,
                      const BBox& bounding_box,
                      const cv::Mat_<float>& rotation,
                      const float scale)
    {
        int currnode = 0;
        int bincode = 0;
        
        int landmarkID = forest->landmark_id;
        int node_number = (int)nodes.size();

        while(1){
            float x1 = nodes[currnode].feature[0];
            float y1 = nodes[currnode].feature[1];
            float x2 = nodes[currnode].feature[2];
            float y2 = nodes[currnode].feature[3];
            
            float project_x1 = rotation(0,0) * x1 + rotation(0,1) * y1;
            float project_y1 = rotation(1,0) * x1 + rotation(1,1) * y1;
            project_x1 = scale * project_x1 * bounding_box.width / 2.0;
            project_y1 = scale * project_y1 * bounding_box.height / 2.0;
            int real_x1 = project_x1 + shape(landmarkID,0);
            int real_y1 = project_y1 + shape(landmarkID,1);
            real_x1 = fmax(0.0,fmin((float)real_x1,image.cols-1.0));
            real_y1 = fmax(0.0,fmin((float)real_y1,image.rows-1.0));
            
            float project_x2 = rotation(0,0) * x2 + rotation(0,1) * y2;
            float project_y2 = rotation(1,0) * x2 + rotation(1,1) * y2;
            project_x2 = scale * project_x2 * bounding_box.width / 2.0;
            project_y2 = scale * project_y2 * bounding_box.height / 2.0;
            int real_x2 = project_x2 + shape(landmarkID,0);
            int real_y2 = project_y2 + shape(landmarkID,1);
            real_x2 = fmax(0.0,fmin((float)real_x2,image.cols-1.0));
            real_y2 = fmax(0.0,fmin((float)real_y2,image.rows-1.0));
            float pdf = ((int)(image(real_y1,real_x1))-(int)(image(real_y2,real_x2)));
            
            if (pdf < nodes[currnode].thresh){
                currnode = nodes[currnode].child_nodes[0];
            }
            else{
                currnode = nodes[currnode].child_nodes[1];
            }
            
            if (nodes[currnode].leaf)
            {
                bincode = currnode-(node_number-1)/2;
                
                break;
            }
        }
        return bincode;
    };
    
    void LBFTree::read(FILE* fp)
    {
        int size = 0;
        fread(&size, sizeof(int), 1, fp);
        nodes.resize(size);
        
        for (int idx=0; idx<size; ++idx) {
            nodes[idx].read(fp);
        }
    }
    
    void LBFTree::read(unsigned char **bufferPtr)
    {
        unsigned char *buffer = *bufferPtr;

        int size = 0;
        int amount = sizeof(int);
        memcpy(&size, buffer, amount);
        buffer += amount;
        nodes.resize(size);

        *bufferPtr = buffer;
        
        for (int idx=0; idx<size; ++idx) {
            nodes[idx].read(bufferPtr);
        }
    }
    
    void LBFTree::write(FILE* fp)
    {
        int size = (int)nodes.size();
        fwrite(&size, sizeof(int), 1, fp);
        
        for (int idx=0; idx<size; ++idx) {
            nodes[idx].write(fp);
        }
    }
}
