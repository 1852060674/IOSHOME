//
//  CustomNavigationBar.m
//  NavigationBarWithShadowDemo
//
//  Created by Derek Yang on 01/07/12.
//  Copyright 2012 Derek Yang. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "CustomNavigationBar.h"
#import "ImageUtil.h"

@implementation CustomNavigationBar

- (void)awakeFromNib {
    [super awakeFromNib];
    _image = [ImageUtil loadResourceImage:@"fram-bar.png"];//[UIImage imageNamed:@"fram-bar.png"];
//    self.tintColor = [UIColor colorWithRed:46.0 / 255.0 green:149.0 / 255.0 blue:206.0 / 255.0 alpha:1.0];
    self.tintColor = [UIColor brownColor];
    // draw shadow
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0, 3);
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

- (void)drawRect:(CGRect)rect
{
    [_image drawInRect:rect];
}


@end
