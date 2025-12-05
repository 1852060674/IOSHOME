//
//  BHButton.m
//  PicFrame
//
//  Created by shen on 13-6-14.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import "BHButton.h"

@implementation BHButton
@synthesize cententPoint;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//    [super drawRect:rect];
//    CGPoint firstPoint = CGPointMake(self.cententPoint.x-25, self.cententPoint.y);
//    CGPoint secondPoint = CGPointMake(self.cententPoint.x+25, self.cententPoint.y);//
//    CGPoint thirdPoint = CGPointMake(self.cententPoint.x, self.cententPoint.y-25);
//    CGPoint fourthPoint = CGPointMake(self.cententPoint.x, self.cententPoint.y+25);
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetRGBFillColor(context, 0, 0.25, 0, 0.5);
//    CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1.0);
//	// Draw them with a 2.0 stroke width so they are a bit more visible.
//	CGContextSetLineWidth(context, 8.0);
//    CGPoint addLines1[] =
//	{
//        firstPoint,secondPoint
//	};
//    CGContextAddLines(context, addLines1, sizeof(addLines1)/sizeof(addLines1[0]));
//	CGContextStrokePath(context);
//    
//    CGPoint addLines[] =
//	{
//        thirdPoint,fourthPoint
//	};
//    CGContextAddLines(context, addLines, sizeof(addLines)/sizeof(addLines[0]));
//	CGContextStrokePath(context);
//}


@end
