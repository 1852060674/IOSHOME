//
//  ShareDemoView.h
//  CutMeIn
//
//  Created by ZB_Mac on 16/7/20.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareDemoView : UIView
-(ShareDemoView *)initWithFrame:(CGRect)frame andImage:(UIImage *)image;
@property (nonatomic, strong) UIImageView *imageView;

@end
