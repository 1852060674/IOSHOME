//
//  LBFCommon.hpp
//  FaceAlignmentZB
//
//  Created by ZB_Mac on 2016/12/23.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#ifndef LBFCommon_hpp
#define LBFCommon_hpp

#include <stdio.h>
#include <string>
#include <vector>
#include <opencv2/core/core.hpp>

namespace LBF {
#define SHAPE_LANDMARK_TYPE double
#define SHAPE_MAT cv::Mat_<SHAPE_LANDMARK_TYPE>
#define SHAPE_VECTOR std::vector<SHAPE_LANDMARK_TYPE>

#define IMAGE_MAT cv::Mat_<uchar>

    class Config {
    public:
        static inline Config& GetInstance() {
            static Config c;
            return c;
        }
        
    public:
        int stages_n;
        int tree_per_forest;
        int tree_depth;

        int landmark_n;
        int augment_n;
        std::vector<int> feature_m;
        std::vector<float> radius_m;
        float bagging_overlap;        
    private:
        Config();
        ~Config(){};
        Config(const Config &other);
        Config &operator=(const Config &other);
    };
    
    class BBox {
    public:
        BBox(){};
        ~BBox(){};
        //BBox(const BBox &other);
        //BBox &operator=(const BBox &other);
        BBox(float x, float y, float w, float h);
        
    public:
//        cv::Mat Project(const cv::Mat &shape) const;
//        cv::Mat ReProject(const cv::Mat &shape) const;
        
    public:
        float x, y;
        float x_center, y_center;
        float x_scale, y_scale;
        float width, height;
    };
    
    void ProjectShape(const SHAPE_MAT& shape,
                      const BBox& bounding_box,
                      SHAPE_MAT& projected_shape);
    
    void ReProjectShape(const SHAPE_MAT& projected_shape,
                        const BBox& bounding_box,
                        SHAPE_MAT& shape);
    
    // transform shape2 to shape1 by rotation and scale
    void SimilarityTransform(const SHAPE_MAT& shape1,
                             const SHAPE_MAT& shape2,
                             SHAPE_MAT& rotation,
                             float& scale);
    
    SHAPE_LANDMARK_TYPE calculate_covariance(const SHAPE_VECTOR& v_1,
                                             const SHAPE_VECTOR& v_2);
    
    SHAPE_MAT GetMeanShape(const std::vector<SHAPE_MAT >& shapes,
                           const std::vector<BBox>& bounding_box);
    
    void GetShapeResidual(const std::vector<SHAPE_MAT >& ground_truth_shapes,
                          const std::vector<SHAPE_MAT >& current_shapes,
                          const std::vector<BBox>& bounding_boxs,
                          const SHAPE_MAT& mean_shape,
                          std::vector<SHAPE_MAT >& shape_residuals);
    
    void GetShapeResidual(const SHAPE_MAT& ground_truth_shape,
                          const SHAPE_MAT& current_shape,
                          const BBox bounding_box,
                          const SHAPE_MAT& mean_shape,
                          SHAPE_MAT& shape_residual);
    
    void drawLandmarks(IMAGE_MAT& image, SHAPE_MAT& shape, BBox& bounding_box);
}

#endif /* LBFCommon_hpp */
