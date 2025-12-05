//
//  MagnifierView.m
//  Transsexual
//
//  Created by ZB_Mac on 15/10/26.
//  Copyright © 2015年 ZB_Mac. All rights reserved.
//

#import "MagnifierView.h"

@implementation MagnifierView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, self.frame.size.width/2, self.frame.size.height/2 );
    CGContextScaleCTM(context, _zoomScale, _zoomScale);
    CGContextTranslateCTM(context, -_magnifyPoint.x, -_magnifyPoint.y);
    [_viewToMagnify.layer renderInContext:context];
}


@end
