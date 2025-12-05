//
//  UIImage+ImageWithLabel.h
//  bokehPhoto
//
//  Created by tangtaoyu on 15-3-30.
//  Copyright (c) 2015年 tangtaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (ImageWithLabel)

- (void) setImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType;

@end
