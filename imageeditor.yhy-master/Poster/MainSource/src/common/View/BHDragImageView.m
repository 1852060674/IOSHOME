//
//  BHDragImageView.m
//  PicFrame
//
//  Created by shen on 13-6-20.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import "BHDragImageView.h"

@implementation BHDragImageView

@synthesize imageView = _imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initImageView];
    }
    return self;
}

- (void)initImageView
{
    self.imageView = [[UIImageView alloc]init];
    
    // The imageView can be zoomed largest size
    //    imageView.frame = CGRectMake(0, 0, MRScreenWidth * 2.5, MRScreenHeight * 2.5);
    self.imageView.userInteractionEnabled = YES;
    self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:self.imageView];
    // Add gesture,double tap zoom imageView.
    //    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
    //                                                                                action:@selector(handleDoubleTap:)];
    //    [doubleTapGesture setNumberOfTapsRequired:2];
    //    [imageView addGestureRecognizer:doubleTapGesture];
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
}

#pragma mark -- touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
//    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    
    [UIView beginAnimations: @"drag" context: nil];
	self.backgroundColor = [UIColor colorWithRed: 1 green: 0.5 blue: 0 alpha: 1];
	self.alpha = 0.8;
    self.frame = CGRectMake(0, 0, 100, 100);
	[UIView commitAnimations];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView beginAnimations: @"drag" context: nil];
    self.center = [[touches anyObject] locationInView: self.superview];
    [UIView commitAnimations];
    
//    NSArray * touchesArray=[[event allTouches] allObjects];
    
    //    if (touchesArray.count == 1) {
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
     NSLog(@"moveing %f,%f",locationPoint.x,locationPoint.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"superview %@",self.superview);
//    UIView * tmp = self.superview;
//	
//	[self removeFromSuperview];
//	[mOuterView addSubview: self];
//	
//	mOuterView = tmp;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
//    UIView * tmp = self.superview;
//	
//	[self removeFromSuperview];
//	[mOuterView addSubview: self];
//	
//	mOuterView = tmp;
}


@end
