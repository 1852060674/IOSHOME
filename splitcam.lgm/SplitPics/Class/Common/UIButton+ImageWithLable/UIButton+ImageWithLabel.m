//
//  UIImage+ImageWithLabel.m
//  bokehPhoto
//
//  Created by tangtaoyu on 15-3-30.
//  Copyright (c) 2015年 tangtaoyu. All rights reserved.
//

#import "UIButton+ImageWithLabel.h"
#import "MGDefine.h"

@implementation UIButton (ImageWithLabel)

- (void) setImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType {
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    
    [self setTitle:title forState:stateType];
    [self.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
    [self setImage:image forState:stateType];
    
    CGFloat spacing = 6.0;
    CGSize imageSize = self.imageView.frame.size;
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize.width,
                                              -(imageSize.height + spacing), 0.0);
    
    CGSize titleSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]}];
    self.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height-spacing), 0.0, 0.0, -titleSize.width);
    
//    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];    [self.imageView setContentMode:UIViewContentModeCenter];
//    [self setImageEdgeInsets:UIEdgeInsetsMake(-20.0,
//                                              0,
//                                              0,
//                                              -titleSize.width)];
//    [self setImage:image forState:stateType];
//    
//    [self.titleLabel setContentMode:UIViewContentModeCenter];
//    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
//    [self.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
//    [self.titleLabel setTextColor:[UIColor whiteColor]];
//    [self setTitleEdgeInsets:UIEdgeInsetsMake(self.frame.size.height-titleSize.height-5,
//                                              -image.size.width,
//                                              0.0,
//                                              0.0)];
//    [self setTitle:title forState:stateType];
}

@end
