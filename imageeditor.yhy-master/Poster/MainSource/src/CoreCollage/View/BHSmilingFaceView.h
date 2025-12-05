//
//  BHSmilingFaceView.h
//  PicFrame
//
//  Created by shen Lv on 13-6-6.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBCommonDefine.h"
#import "BHPromptFrameView.h"

@protocol BHSmilingFaceViewDelegate <NSObject>

@optional

- (BOOL)canAddSmilingFace:(NSInteger)index;

- (void)selectedSmilingFaceType:(UIImage*)imageName atIndex:(NSInteger)index;

@end

@interface BHSmilingFaceView : UIView

@property (nonatomic,assign)id<BHSmilingFaceViewDelegate> delegate;
@property (nonatomic,strong)BHPromptFrameView *promptFrame;

@end
