//
//  BHAspectView.h
//  PicFrame
//
//  Created by shen Lv on 13-6-5.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBCommonDefine.h"

@protocol BHAspectViewDelegate <NSObject>

@optional

- (void)selectedAspectType:(AspectType)type;

@end

@interface BHAspectView : UIView

@property (nonatomic,assign)id<BHAspectViewDelegate> delegate;

@end
