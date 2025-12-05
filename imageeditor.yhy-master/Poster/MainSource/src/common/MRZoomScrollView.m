//
//  MRZoomScrollView.m
//  ScrollViewWithZoom
//
//  Created by xuym on 13-3-27.
//  Copyright (c) 2013年 xuym. All rights reserved.
//

#import "MRZoomScrollView.h"

#define MRScreenWidth      CGRectGetWidth([UIScreen mainScreen].applicationFrame)
#define MRScreenHeight     CGRectGetHeight([UIScreen mainScreen].applicationFrame)

@interface MRZoomScrollView ()
{
    CGPoint _startPoint;
    float _startOffset;
}
//- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;

@end

@implementation MRZoomScrollView

@synthesize imageView;
@synthesize myDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.delegate = self;
//        self.frame = CGRectMake(0, 0, MRScreenWidth, MRScreenHeight);
        
        [self initImageView];
    }
    return self;
}

- (void)initImageView
{
    imageView = [[UIImageView alloc]init];
    
    // The imageView can be zoomed largest size
//    imageView.frame = CGRectMake(0, 0, MRScreenWidth * 2.5, MRScreenHeight * 2.5);
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];
    [self sendSubviewToBack:imageView];
    // Add gesture,double tap zoom imageView.
//    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                action:@selector(handleDoubleTap:)];
//    [doubleTapGesture setNumberOfTapsRequired:2];
//    [imageView addGestureRecognizer:doubleTapGesture];
    
    
    [self setMinimumZoomScale:1];
    [self setMaximumZoomScale:3];
    [self setZoomScale:1];
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}

//加载图片，并且调整scrollview contentSize的大小
- (void)setImageViewImage:(UIImage*)image
{
    if (nil == image) {
        return;
    }
    float _scale=0;
    self.imageView.image = image;
    
    if (self.frame.size.width>image.size.width || self.frame.size.height>image.size.height)
    {
        //填充框的大小比图片要大，则需要放大图片
        if (self.frame.size.width>=image.size.width && self.frame.size.height<image.size.height)
        {
            _scale = self.frame.size.width/image.size.width;
            imageView.frame = CGRectMake(0, 0, image.size.width*_scale, image.size.height*_scale);
        }
        else if(self.frame.size.width<image.size.width && self.frame.size.height>=image.size.height)
        {
            _scale = self.frame.size.height/image.size.height;
            self.imageView.frame = CGRectMake(0, 0, image.size.width*_scale, image.size.height*_scale);
        }
        else if(self.frame.size.width>image.size.width && self.frame.size.height>image.size.height)
        {
            _scale = self.frame.size.width/image.size.width;
            if (_scale>=self.frame.size.height/image.size.height)
            {
                self.imageView.frame = CGRectMake(0, 0, image.size.width*_scale, image.size.height*_scale);
            }
            else
            {
                _scale = self.frame.size.height/image.size.height;
                self.imageView.frame = CGRectMake(0, 0, image.size.width*_scale, image.size.height*_scale);
            }
        }
    }
    else
    {
        float _scaleW = self.frame.size.width/image.size.width;
        float _scaleH = self.frame.size.height/image.size.height;
        if (_scaleW<=_scaleH)
        {
            self.imageView.frame = CGRectMake(0, 0, image.size.width*_scaleH, image.size.height*_scaleH);
        }
        else
        {
            self.imageView.frame = CGRectMake(0, 0, image.size.width*_scaleW, image.size.height*_scaleW);
        }
        
    }
    
    self.contentSize = self.imageView.frame.size;
}

#pragma mark - Zoom methods

//- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
//{
//    float newScale = self.zoomScale * 1.5;
//    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
//    [self zoomToRect:zoomRect animated:YES];
//}

//- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
//{
//    CGRect zoomRect;
//    zoomRect.size.height = self.frame.size.height / scale;
//    zoomRect.size.width  = self.frame.size.width  / scale;
//    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
//    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
//    return zoomRect;
//}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    if (scale<=1) {
        return;
    }
    NSLog(@"scale %f",scale);
    [scrollView setZoomScale:scale animated:NO];
}

//- (void)scrollViewDidScroll:(UIScrollView *)sender {
//    //    NSLog(@"%f",self.contentOffset.x);
//    float dx = _startPoint.x +  (_startOffset- self.contentOffset.x);
//    //    NSLog(@"%f,%f,%f,%f",_startPoint.x,_startOffset,self.contentOffset.x,self.frame.size.width);
////    NSLog(@"%f,%f,%f",self.contentOffset.x,self.frame.size.width,self.contentSize.width);
//    if (self.contentOffset.x<-50 || self.contentOffset.x+self.frame.size.width>self.contentSize.width+50 || self.contentOffset.y < -50 || self.contentOffset.y>self.frame.size.height+50) {
////        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(emergeImageView)])
////        {
////            [self.myDelegate emergeImageView];
////        }
//        
//    }
//}

#pragma mark - View cycle
- (void)dealloc
{
}

#pragma mark -- touches
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//    CGPoint locationPoint = [[touches anyObject] locationInView:self];
//    NSLog(@"sub %f,%f",locationPoint.x,locationPoint.y);
//    _startPoint = locationPoint;
//    _startOffset = self.contentOffset.x;
////    NSLog(@"%f,%f,%f,%f",self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesMoved:touches withEvent:event];
//    [UIView beginAnimations: @"drag" context: nil];
//    self.imageView.center = [[touches anyObject] locationInView: self.superview];
//    [UIView commitAnimations];
//
//    NSArray * touchesArray=[[event allTouches] allObjects];
//    
//    if (touchesArray.count == 1) {
//        CGPoint locationPoint = [[touches anyObject] locationInView:self];
//        NSLog(@"dx = %f",locationPoint.x - _startPoint.x);
//        int dx = locationPoint.x - _startPoint.x;
//        if (dx>5) {
//            NSLog(@"half now");
//            [self.imageView removeFromSuperview];
//            [self.superview addSubview:self.imageView];
//            [self.superview bringSubviewToFront:self.imageView];
//        }
//    }
//}

@end
