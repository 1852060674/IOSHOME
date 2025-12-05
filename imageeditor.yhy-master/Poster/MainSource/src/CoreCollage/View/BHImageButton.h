//
//  BHImageButton.h
//  PicFrame
//
//  Created by shen on 13-6-19.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BHImageButtonDelegate <NSObject>

@optional

- (void)clickButton:(id)sender;

@end

@interface BHImageButton : UIView

@property (nonatomic,assign)id<BHImageButtonDelegate> delegate;

@end
