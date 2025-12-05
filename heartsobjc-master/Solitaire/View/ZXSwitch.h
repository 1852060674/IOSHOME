//
//  ZXSwitch.h
//  Solitaire
//
//  Created by jerry on 2017/8/15.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXSwitch : UIControl
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIImage * onImage;
@property (nonatomic, strong) UIImage * offImage;
@end
