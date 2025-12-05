//
//  BHPhotoFrameView.h
//  PicFrame
//
//  Created by shen Lv on 13-6-3.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHPromptFrameView.h"

@protocol BHPhotoFrameViewDelegate <NSObject>

@optional

//选中某个相框
- (void)selectedAPhotoFrame:(NSString*)photoFrameImage;

@end

@interface BHPhotoFrameView : UIView

@property (nonatomic, assign)id<BHPhotoFrameViewDelegate> delegate;
@property (nonatomic, strong)BHPromptFrameView *promptFrameView;

@end
