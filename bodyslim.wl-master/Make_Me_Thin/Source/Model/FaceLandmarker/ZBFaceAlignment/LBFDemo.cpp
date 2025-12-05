//
//  LBFTrainDemo.cpp
//  FaceAlignmentZB
//
//  Created by ZB_Mac on 2016/12/24.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#include "LBFDemo.hpp"
#include "LBFRegressor.hpp"
#include "LBFCommon.hpp"
#include <iostream>
#include <fstream>
#include <string>
#include <opencv2/imgcodecs/imgcodecs.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

void Train()
{
    std::string path_dir = "/Users/zb_mac/Desktop/FaceAlignment/FaceAlignmentZB/TrainSet/";
    std::string images_path = "train_images.txt";
    
    int landmark_num = 68;
//    const int required_landmark_num = 35;
//    int required_landmark_idxes[required_landmark_num] = {
//        9, // chin 0
//        18, 19, 20, 21, 22, // left eyebrow 1
//        23, 24, 25, 26, 27, // right eyebrow 6
//        31, 32, 34, 36, // nose 11
//        37, 38, 39, 40, 41, 42, // left eye 15
//        43, 44, 45, 46, 47, 48, // right eye 21
//        49, 52, 55, 58, // outer mouth 27
//        61, 63, 65, 67, // inner mouth 31
//    };
    
    const int required_landmark_num = 16;
    int required_landmark_idxes[required_landmark_num] = {
        5, 7, 9, 11, 13, // contour 0
        32, 34, 36, // nose 11
        37, 40, // left eye 15
        43, 46, // right eye 21
        49, 52, 55, 58, // outer mouth 27
    };

    IMAGE_MAT image_ori;
    IMAGE_MAT image;
    float scale = 1.0;
    
    std::vector<IMAGE_MAT > images;
    std::vector<SHAPE_MAT > ground_truth_shapes;
    std::vector<LBF::BBox> bounding_boxes;
    
    std::ifstream fin_1;
    fin_1.open((path_dir+images_path).c_str());
    std::string image_relative_path;
    std::string last_image_relative_path;
    while (fin_1>>image_relative_path)
    {
        SHAPE_MAT shape(required_landmark_num, 2);
        LBF::BBox box;

        std::string image_path = path_dir + image_relative_path;
        std::string point_path = path_dir + image_relative_path.substr(0, image_relative_path.size()-4)+".pts";
        std::string bound_path = path_dir + image_relative_path.substr(0, image_relative_path.size()-4)+".box";

        int pos_last = (int)last_image_relative_path.find("_");
        int pos = (int)image_relative_path.find("_");
        
        bool same_image = false;
        if (pos_last<last_image_relative_path.length() && pos_last>=0 && pos<image_relative_path.length() && pos>=0)
        {
            if (last_image_relative_path.substr(0, pos_last).compare(image_relative_path.substr(0, pos)) == 0) {
//                same_image = true;
            }
        }
        
        if (!same_image)
        {
            image_ori = cv::imread(image_path, cv::IMREAD_GRAYSCALE);
            
            if (image_ori.cols > 1000 || image_ori.rows > 1000) {
                scale = 1000.0/MAX(image_ori.cols, image_ori.rows);
            }
            cv::resize(image_ori, image, cv::Size(image_ori.cols*scale, image_ori.rows*scale));
        }

        last_image_relative_path = image_relative_path;

        std::ifstream fin;
        fin.open(point_path.c_str());
        
        char line_buffer[1024];
        fin.getline(line_buffer, 1024);
        fin.getline(line_buffer, 1024);
        fin.getline(line_buffer, 1024);
        
        // 9: (1) chin
        // 18~22: (5) left eyebrow
        // 23~27: (5) right eyebrow
        // 37~42: (6) left eye
        // 43~48: (6) right eye
        // 31, 32, 34, 36: (4) nose
        // 49, 52, 55, 58: (4) outer mouth
        // 61, 63, 65, 67: (4) inner mouth
        
        int landmark_idx = 0;
        for(int j = 0;j < landmark_num;j++){
            fin>>shape(landmark_idx,0);
            fin>>shape(landmark_idx,1);
            if (j+1 == required_landmark_idxes[landmark_idx]) {
                ++landmark_idx;
            }
        }
        fin.close();
        
        shape = shape * scale;
        
        fin.open(bound_path.c_str());
        
        if (!fin.is_open()) {
            continue;
        }
        
//        printf("\n%s\n", image_relative_path.c_str());
        
        fin>>box.x>>box.y>>box.width>>box.height;
        fin.close();
        box.x *= scale;
        box.y *= scale;
        box.width *= scale;
        box.height *= scale;
        box.x_center = box.x + box.width/2.0;
        box.y_center = box.y + box.height/2.0;
        
        images.push_back(image);
        ground_truth_shapes.push_back(shape);
        bounding_boxes.push_back(box);

//        if (images.size() > 50) {
//            break;
//        }
    }
    
//    cv::imshow("ddd", images[5]);
//    cvWaitKey();
//    return;
    LBF::LBFRegressor regressor;
    regressor.train(images, bounding_boxes, ground_truth_shapes);
    
    FILE *fp = fopen("lbf_model.bin", "wb+");
    regressor.write(fp);
    fclose(fp);
    //    cvWaitKey(0);
    
    SHAPE_MAT shape;
    SHAPE_MAT shape_residual;
    SHAPE_MAT mean_shape(ground_truth_shapes[0].rows, ground_truth_shapes[0].cols);
    
    regressor.test(images[5], bounding_boxes[5], shape);
    LBF::ProjectShape(shape, bounding_boxes[5], mean_shape);

    LBF::GetShapeResidual(ground_truth_shapes[5], shape, bounding_boxes[5], mean_shape, shape_residual);
    
    printf("\nshape:\n");
    for (int jj=0; jj<shape.rows; ++jj)
    {
        printf("(%f, %f)", shape(jj, 0), shape(jj, 1));
    }

    printf("\nground_truth_shapes:\n");
    for (int jj=0; jj<shape.rows; ++jj)
    {
        printf("(%f, %f)", ground_truth_shapes[5](jj, 0), ground_truth_shapes[5](jj, 1));
    }
    
    printf("\nshape_residual:\n");
    for (int jj=0; jj<shape_residual.rows; ++jj)
    {
        printf("(%f, %f)", shape_residual(jj, 0), shape_residual(jj, 1));
    }

    Test(regressor);
}

void Test()
{
    LBF::LBFRegressor regressor;
    FILE *fp = fopen("lbf_model.bin", "rb");
    regressor.read(fp);
    fclose(fp);
    
    Test(regressor);
    
}
void Test(LBF::LBFRegressor& regressor)
{
//    std::string image_path = "/Users/zb_mac/Desktop/FaceAlignmentZB/TrainSet/afw/1139324862_1.jpg";
//    std::string bound_path = "/Users/zb_mac/Desktop/FaceAlignmentZB/TrainSet/afw/1139324862_1.box";
//    std::string shape_path = "/Users/zb_mac/Desktop/FaceAlignmentZB/TrainSet/afw/1139324862_1.pts";

//    std::string image_path = "/Users/zb_mac/Desktop/FaceAlignmentZB/TrainSet/lfpw/trainset/lfpw_train_image_0001.png";
//    std::string bound_path = "/Users/zb_mac/Desktop/FaceAlignmentZB/TrainSet/lfpw/trainset/lfpw_train_image_0001.box";
//    std::string shape_path = "/Users/zb_mac/Desktop/FaceAlignmentZB/TrainSet/lfpw/trainset/lfpw_train_image_0001.pts";

    std::string image_path = "/Users/zb_mac/Desktop/FaceAlignmentZB/Self_Test/5.jpg";
    std::string bound_path = "/Users/zb_mac/Desktop/FaceAlignmentZB/Self_Test/5.txt";
    
    IMAGE_MAT image = cv::imread((image_path).c_str(), cv::IMREAD_GRAYSCALE);
    LBF::BBox bounding_box;
    
    std::ifstream fin;
    fin.open(bound_path.c_str());
    //    for(int i=0; i<image_idx;++i)
    {
        fin>>bounding_box.x>>bounding_box.y>>bounding_box.width>>bounding_box.height;
        
        bounding_box.x_center = bounding_box.x + bounding_box.width/2.0;
        bounding_box.y_center = bounding_box.y + bounding_box.height/2.0;
    }
    fin.close();
    
    float scale = 1.0;
    bounding_box.width *= scale;
    bounding_box.height *= scale;
    bounding_box.x = bounding_box.x_center-bounding_box.width*0.5;
    bounding_box.y = bounding_box.y_center-bounding_box.height*0.5;
    
    SHAPE_MAT shape;
    
    regressor.test(image, bounding_box, shape);
    
    /*
    int landmark_num = 68;
//    const int required_landmark_num = 35;
//    int required_landmark_idxes[required_landmark_num] = {
//        9, // chin 0
//        18, 19, 20, 21, 22, // left eyebrow 1
//        23, 24, 25, 26, 27, // right eyebrow 6
//        31, 32, 34, 36, // nose 11
//        37, 38, 39, 40, 41, 42, // left eye 15
//        43, 44, 45, 46, 47, 48, // right eye 21
//        49, 52, 55, 58, // outer mouth 27
//        61, 63, 65, 67, // inner mouth 31
//    };

    const int required_landmark_num = 16;
    int required_landmark_idxes[required_landmark_num] = {
        5, 7, 9, 11, 13, // contour 0
        32, 34, 36, // nose 11
        37, 40, // left eye 15
        43, 46, // right eye 21
        49, 52, 55, 58, // outer mouth 27
    };
    
    SHAPE_MAT real_shape(required_landmark_num, 2);
    
    fin.open(shape_path);
    
    char line_buffer[1024];
    fin.getline(line_buffer, 1024);
    fin.getline(line_buffer, 1024);
    fin.getline(line_buffer, 1024);
    
    // 9: (1) chin
    // 18~22: (5) left eyebrow
    // 23~27: (5) right eyebrow
    // 37~42: (6) left eye
    // 43~48: (6) right eye
    // 31, 32, 34, 36: (4) nose
    // 49, 52, 55, 58: (4) outer mouth
    // 61, 63, 65, 67: (4) inner mouth
    
    int landmark_idx = 0;
    for(int j = 0;j < landmark_num;j++){
        fin>>real_shape(landmark_idx,0);
        fin>>real_shape(landmark_idx,1);
        if (j+1 == required_landmark_idxes[landmark_idx]) {
            ++landmark_idx;
        }
    }
    fin.close();
    
    SHAPE_MAT& shape_1 = real_shape;
    SHAPE_MAT& shape_2 = shape;
    LBF::BBox box_1 = bounding_box;
    LBF::BBox box_2 = bounding_box;
    
    SHAPE_MAT shape_residual;
    SHAPE_MAT mean_shape(shape_1.rows, shape_2.cols);
    LBF::ProjectShape(shape_2, box_2, mean_shape);
    
    LBF::GetShapeResidual(shape_1, shape_2, box_1, regressor.mean_shape, shape_residual);
    
    printf("\nshape:\n");
    for (int jj=0; jj<shape.rows; ++jj)
    {
        printf("(%f, %f)", shape(jj, 0), shape(jj, 1));
    }
    
    printf("\nshape_residual:\n");
    for (int jj=0; jj<shape_residual.rows; ++jj)
    {
        printf("(%f, %f)", shape_residual(jj, 0), shape_residual(jj, 1));
    }
    */
    LBF::drawLandmarks(image, shape, bounding_box);
    cv::imshow("result", image);
//    cvWaitKey(0);
}

void TestSimilarTransform()
{
    int sample_num = 100;
    
    int landmark_num = LBF::Config::GetInstance().landmark_n;
    
    std::string landmarks_path = "/Users/zb_mac/Desktop/FaceAlignmentESR/FaceAlignmentESR/COFW_Dataset/keypoints.txt";
    std::string bounds_path = "/Users/zb_mac/Desktop/FaceAlignmentESR/FaceAlignmentESR/COFW_Dataset/boundingbox.txt";

    std::vector<SHAPE_MAT > ground_truth_shapes;
    std::vector<LBF::BBox> bounding_boxes;
    
    std::ifstream fin;

    std::cout<<"Reading bounds..."<<std::endl;
    fin.open(bounds_path.c_str());
    for(int i = 0;i < sample_num;i++){
        LBF::BBox temp;
        fin>>temp.x>>temp.y>>temp.width>>temp.height;
        temp.x_center = temp.x + temp.width/2.0;
        temp.y_center = temp.y + temp.height/2.0;
        bounding_boxes.push_back(temp);
    }
    fin.close();
    std::cout<<sample_num<<" bounds read"<<std::endl;
    
    int landmark_n_ = 29;
    SHAPE_LANDMARK_TYPE landmark_cor;
    std::cout<<"Reading shapes..."<<std::endl;
    fin.open(landmarks_path.c_str());
    for(int i = 0;i < sample_num;i++){
        SHAPE_MAT temp(landmark_num,2);
        //        SHAPE_MAT temp(landmark_n_, 2);
        
        for(int j = 0;j < landmark_n_;j++){
            //            fin>>temp(j,0);
            fin>>landmark_cor;
            
            if (j<landmark_num) {
                temp(j,0) = landmark_cor;
            }
        }
        for(int j = 0;j < landmark_n_;j++){
            //            fin>>temp(j,1);
            fin>>landmark_cor;
            
            if (j<landmark_num) {
                temp(j,1) = landmark_cor;
            }
        }
        ground_truth_shapes.push_back(temp);
    }
    fin.close();

    SHAPE_MAT target_1 = ground_truth_shapes[0];
    LBF::BBox bound_1 = bounding_boxes[0];
    SHAPE_MAT projected_target_1(ground_truth_shapes[0].rows, ground_truth_shapes[0].cols);
//    LBF::ProjectShape(target_1, bound_1, projected_target_1);
    projected_target_1 = target_1;
    SHAPE_MAT re_projected_target_1(ground_truth_shapes[0].rows, ground_truth_shapes[0].cols);
    
    SHAPE_MAT projected_target_2;// = LBF::GetMeanShape(ground_truth_shapes, bounding_boxes);
    
    SHAPE_MAT real_rotation(2, 2);
    double real_scale = 1.5;
    float alpha = 3.1415926/3;
    real_rotation(0,0) = cos(alpha);
    real_rotation(0,1) = -sin(alpha);
    real_rotation(1,0) = sin(alpha);
    real_rotation(1,1) = cos(alpha);
    projected_target_2 = real_scale * projected_target_1 * real_rotation;
    
    SHAPE_MAT rotation;
    float scale;
    
    LBF::SimilarityTransform(projected_target_1, projected_target_2, rotation, scale);
    
    
    std::cout<<sample_num<<" shapes read"<<std::endl;
}
