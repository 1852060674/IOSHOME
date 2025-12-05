//
//  LBFCommon.cpp
//  FaceAlignmentZB
//
//  Created by ZB_Mac on 2016/12/23.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#include "LBFCommon.hpp"
#include <opencv2/imgproc/imgproc.hpp>

namespace LBF {
    Config::Config() {

        stages_n = 5;
        tree_per_forest = 100;
        tree_depth = 4;
//        landmark_n = 29;
        landmark_n = 16;
        augment_n = 40;
        bagging_overlap = 0.2;

        int feats_m[] = {2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000};
//        int feats_m[] = {2000, 1500, 1000, 1000, 500, 500, 500, 300, 300, 300};
//        int feats_m[] = {200, 200, 200, 100, 100, 100, 80, 80, 60, 60};
//        int feats_m[] = {50, 50, 50, 30, 30, 30, 20, 20, 20, 10};
//        int feats_m[] = {500, 500, 500, 300, 300, 300, 200, 200, 200, 100};
//        float radius_m[] = {0.4, 0.3, 0.2, 0.15, 0.12, 0.10, 0.08, 0.06, 0.06, 0.05};
        float radius_m[] = {0.4, 0.2, 0.1, 0.05, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03};
//        float radius_m[] = {0.2, 0.1, 0.05, 0.05, 0.03, 0.03, 0.03, 0.02, 0.02, 0.02};

        for (int i = 0; i < stages_n; i++) {
            this->feature_m.push_back(feats_m[i]);
            this->radius_m.push_back(radius_m[i]);
        }
    }
    
    BBox::BBox(float x, float y, float w, float h) {
        this->x = x; this->y = y;
        this->width = w; this->height = h;
        this->x_center = x + w / 2.;
        this->y_center = y + h / 2.;
        this->x_scale = w / 2.;
        this->y_scale = h / 2.;
    }
    
    void ProjectShape(const SHAPE_MAT& shape, const BBox& bounding_box, SHAPE_MAT& projected_shape)
    {
        for(int j = 0;j < shape.rows;j++){
            projected_shape(j,0) = (shape(j,0)-bounding_box.x_center) / (bounding_box.width / 2.0);
            projected_shape(j,1) = (shape(j,1)-bounding_box.y_center) / (bounding_box.height / 2.0);
        }
    }
    
    void ReProjectShape(const SHAPE_MAT& projected_shape, const BBox& bounding_box, SHAPE_MAT& shape)
    {
        for(int j = 0;j < projected_shape.rows;j++){
            shape(j,0) = (projected_shape(j,0) * bounding_box.width / 2.0 + bounding_box.x_center);
            shape(j,1) = (projected_shape(j,1) * bounding_box.height / 2.0 + bounding_box.y_center);
        }
    }
    
    // transform shape2 to shape1 by rotation and scale
    void SimilarityTransform(const SHAPE_MAT& shape1, const SHAPE_MAT& shape2, SHAPE_MAT& rotation,float& scale)
    {
        rotation.create(2, 2);
        scale = 0;
        
        // center the data
        float center_x_1 = 0;
        float center_y_1 = 0;
        float center_x_2 = 0;
        float center_y_2 = 0;
        for(int i = 0;i < shape1.rows;i++){
            center_x_1 += shape1(i,0);
            center_y_1 += shape1(i,1);
            center_x_2 += shape2(i,0);
            center_y_2 += shape2(i,1);
        }
        center_x_1 /= shape1.rows;
        center_y_1 /= shape1.rows;
        center_x_2 /= shape2.rows;
        center_y_2 /= shape2.rows;
        
        SHAPE_MAT temp1 = shape1.clone();
        SHAPE_MAT temp2 = shape2.clone();
        for(int i = 0;i < shape1.rows;i++){
            temp1(i,0) -= center_x_1;
            temp1(i,1) -= center_y_1;
            temp2(i,0) -= center_x_2;
            temp2(i,1) -= center_y_2;
        }
        
        SHAPE_MAT covariance1, covariance2;
        SHAPE_MAT mean1,mean2;
        // calculate covariance matrix
        cv::calcCovarMatrix(temp1,covariance1,mean1,cv::COVAR_ROWS);
        cv::calcCovarMatrix(temp2,covariance2,mean2,cv::COVAR_ROWS);
        temp1.type();
        float s1 = sqrt(norm(covariance1));
        float s2 = sqrt(norm(covariance2));
        scale = s1 / s2;
        temp1 = 1.0 / s1 * temp1;
        temp2 = 1.0 / s2 * temp2;
        
        float num = 0;
        float den = 0;
        for(int i = 0;i < shape1.rows;i++){
            num = num + temp1(i,1) * temp2(i,0) - temp1(i,0) * temp2(i,1);
            den = den + temp1(i,0) * temp2(i,0) + temp1(i,1) * temp2(i,1);
        }
        
        float norm = sqrt(num*num + den*den);
        float sin_theta = num / norm;
        float cos_theta = den / norm;
        rotation(0,0) = cos_theta;
        rotation(0,1) = sin_theta;
        rotation(1,0) = -sin_theta;
        rotation(1,1) = cos_theta;
    }
    
    SHAPE_LANDMARK_TYPE calculate_covariance(const SHAPE_VECTOR& v_1, const SHAPE_VECTOR& v_2)
    {
        SHAPE_MAT v1(v_1);
        SHAPE_MAT v2(v_2);
        SHAPE_LANDMARK_TYPE mean_1 = mean(v1)[0];
        SHAPE_LANDMARK_TYPE mean_2 = mean(v2)[0];
        v1 = v1 - mean_1;
        v2 = v2 - mean_2;
        return mean(v1.mul(v2))[0];
    }
    
    SHAPE_MAT GetMeanShape(const std::vector<SHAPE_MAT >& shapes,
                           const std::vector<BBox>& bounding_box)
    {
        SHAPE_MAT result(shapes[0].rows, shapes[0].cols);
        result.setTo(0.0);
        
        SHAPE_MAT projected(shapes[0].rows, shapes[0].cols);

        for(int i = 0;i < shapes.size();i++)
        {
            ProjectShape(shapes[i], bounding_box[i], projected);
            result = result + projected;
        }
        
        result = 1.0 / shapes.size() * result;
        
        return result;
    }
    
    void GetShapeResidual(const std::vector<SHAPE_MAT >& ground_truth_shapes,
                          const std::vector<SHAPE_MAT >& current_shapes,
                          const std::vector<BBox>& bounding_boxs,
                          const SHAPE_MAT& mean_shape,
                          std::vector<SHAPE_MAT >& shape_residuals)
    {
        SHAPE_MAT rotation;
        float scale;
        shape_residuals.resize(ground_truth_shapes.size());
        
        SHAPE_MAT projected_target(ground_truth_shapes[0].rows, ground_truth_shapes[0].cols);
        SHAPE_MAT projected_current(current_shapes[0].rows, current_shapes[0].cols);
        
        for (int i = 0; i < bounding_boxs.size(); ++i)
        {
            ProjectShape(ground_truth_shapes[i], bounding_boxs[i], projected_target);
            ProjectShape(current_shapes[i], bounding_boxs[i], projected_current);
            
            SimilarityTransform(mean_shape, projected_current,rotation,scale);
            
            shape_residuals[i] = scale * (projected_target-projected_current) * rotation;
        }
    }
    
    void GetShapeResidual(const SHAPE_MAT& ground_truth_shape,
                          const SHAPE_MAT& current_shape,
                          const BBox bounding_box,
                          const SHAPE_MAT& mean_shape,
                          SHAPE_MAT& shape_residual)
    {
        SHAPE_MAT rotation;
        float scale;
        
        SHAPE_MAT projected_target(ground_truth_shape.rows, ground_truth_shape.cols);
        SHAPE_MAT projected_current(current_shape.rows, current_shape.cols);
        
        ProjectShape(ground_truth_shape, bounding_box, projected_target);
        ProjectShape(current_shape, bounding_box, projected_current);
        
        SimilarityTransform(mean_shape, projected_current,rotation,scale);
        
        shape_residual = scale * (projected_target-projected_current) * rotation;
    }
    
    void drawLandmarks(IMAGE_MAT& image, SHAPE_MAT& shape, BBox& bounding_box)
    {
        int landmark_num = shape.rows;
        for(int j = 0; j<landmark_num; j++){
            cv::circle(image,cv::Point2d(shape(j,0),shape(j,1)),3,cv::Scalar(255,0,0),-1,8,0);
        }
        
        cv::circle(image,cv::Point(bounding_box.x, bounding_box.y),7,cv::Scalar(255,0,0),-1,8,0);
        cv::circle(image,cv::Point(bounding_box.x+bounding_box.width, bounding_box.y+bounding_box.height),11,cv::Scalar(255,0,0),-1,8,0);
        
        cv::rectangle(image, cv::Point(bounding_box.x, bounding_box.y), cv::Point(bounding_box.x+bounding_box.width, bounding_box.y+bounding_box.height), cv::Scalar(255,0,0),2,8,0);
    }
}
