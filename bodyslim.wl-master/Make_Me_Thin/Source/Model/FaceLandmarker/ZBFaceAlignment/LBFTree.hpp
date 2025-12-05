//
//  LBFTree.hpp
//  FaceAlignmentZB
//
//  Created by ZB_Mac on 2016/12/23.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#ifndef LBFTree_hpp
#define LBFTree_hpp

#include <stdio.h>
#include "LBFCommon.hpp"

namespace LBF {
    
    class LBFRandomForest;
    
    class LBFTree;
    
    class LBFTreeNode {
        
    public:
        bool splited;
        int depth;
        int child_nodes[2];
        int parent_node;
        bool leaf;
        float thresh;
        float feature[4];
        
        // for training
        std::vector<int> samples_index;
        LBFTree *tree;
        
        LBFTreeNode(){};
        ~LBFTreeNode(){};
        
        void split_node(LBFTreeNode &left_child, LBFTreeNode &right_child);
        void read(FILE* fp);
        void read(unsigned char **bufferPtr);
        void write(FILE* fp);
    };
    
    class LBFTree {
    
    public:
        std::vector<LBFTreeNode> nodes;
        int test(const IMAGE_MAT& image,
                 const SHAPE_MAT& shape,
                 const BBox& bounding_box,
                 const cv::Mat_<float>& rotation,
                 const float scale);
        
        void read(FILE* fp);
        void read(unsigned char **bufferPtr);
        void write(FILE* fp);
        // for training
        LBFRandomForest *forest;
        SHAPE_MAT shapes_residual;
        void train(std::vector<int>& samples_index);
        int get_local_binary_feature();
        
        LBFTree(){};
        ~LBFTree(){};
    };
    
}
#endif /* LBFTree_hpp */
