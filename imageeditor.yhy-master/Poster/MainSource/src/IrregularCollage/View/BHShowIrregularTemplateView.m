//
//  BHShowIrregularTemplateView.m
//  PicFrame
//
//  Created by shen on 13-6-19.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import "BHShowIrregularTemplateView.h"
#import "ImageUtil.h"
#import <QuartzCore/QuartzCore.h>
#import "JBCroppableView.h"

@interface BHShowIrregularTemplateView()
{
    CGPoint _preContentOffset;
    UIImageView *_imageView;
    UIImageView *_imageView2;
    NSMutableArray *_pointArray;
    UIImage *_sourceImage;
    UIImage *_markImage;
}

@end

@implementation BHShowIrregularTemplateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _preContentOffset= CGPointZero;
        _sourceImage = [UIImage imageNamed:@"IMG_0152.JPG"];
        _markImage = [UIImage imageNamed:@"IMG_0152.JPG"];
        _pointArray = [[NSMutableArray alloc] initWithCapacity:2];
                
        float _scale = 0;
        float _edge = 300;
        if (_sourceImage.size.width/_edge>=_sourceImage.size.height/_edge) {
            _scale = _edge/_sourceImage.size.height;
        }
        else
        {
            _scale = _edge/_sourceImage.size.width;
        }
        _sourceImage = [ImageUtil scaleImage:_sourceImage toScale:_scale];
        
        
        CGPoint _point = CGPointMake(0, _sourceImage.size.height-_edge);
        [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        
        _point = CGPointMake(0, _sourceImage.size.height);
        [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        
        _point = CGPointMake(_edge, _sourceImage.size.height-_edge);
        [_pointArray addObject:[NSValue valueWithCGPoint:_point]];

        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _sourceImage.size.width, _sourceImage.size.height)];
        
        
        
        _imageView.image = [JBCroppableView getSpecialImage:_sourceImage withPoints:_pointArray andEdge:_edge andOffset:CGPointZero];
        
//        UITapGestureRecognizer *_singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleThisPic:)];
//        [_imageView addGestureRecognizer:_singleTap];
        
        UIScrollView *_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 10, _edge, _edge)];
        _scrollView.delegate = self;
        _scrollView.tag = 10;
        [_scrollView addSubview:_imageView];
        _scrollView.contentSize = CGSizeMake(_sourceImage.size.width, _sourceImage.size.height);
//        [self addSubview:_scrollView];
        
        ////////////////////////////////////////////
        

        if (_markImage.size.width/_edge>=_markImage.size.height/_edge) {
            _scale = _edge/_markImage.size.height;
        }
        else
        {
            _scale = _edge/_markImage.size.width;
        }
        _markImage = [ImageUtil scaleImage:_markImage toScale:_scale];

        
        [_pointArray removeAllObjects];
        _point = CGPointMake(10, _markImage.size.height);
        [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        
        _point = CGPointMake(300, _markImage.size.height);
        [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        
        _point = CGPointMake(300, _markImage.size.height-290);
        [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        
        _imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _markImage.size.width, _markImage.size.height)];
        _imageView2.backgroundColor = [UIColor clearColor];
        _imageView2.image = [JBCroppableView getSpecialImage:_markImage withPoints:_pointArray andEdge:300 andOffset:CGPointZero];
                
        UIScrollView *_scrollView2 = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 10, _edge, _edge)];
        _scrollView2.delegate = self;
        _scrollView2.tag = 11;
        [_scrollView2 addSubview:_imageView2];
        _scrollView2.contentSize = CGSizeMake(_markImage.size.width, _markImage.size.height);
//        [self addSubview:_scrollView2];
        
        
        
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)handleThisPic:(id)sender
{
    
}

#pragma mark -- custom method

- (UIImage*)getMarkImage:(UIImage*)image withMark:(UIImage*)maskImage
{
    CGRect rect = CGRectZero;
    rect.size = image.size;
    NSLog(@"rect %f,%f",rect.size.width,rect.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
    
    {
        //        [[UIColor blackColor] setFill];
        //        UIRectFill(rect);
        [[UIColor whiteColor] setFill];
        
        UIBezierPath *aPath = [UIBezierPath bezierPath];
        
        // Set the starting point of the shape.
        CGPoint p1 = CGPointMake(0, 0);//[JBCroppableView convertCGPoint:[[points objectAtIndex:0] CGPointValue] fromRect1:image.frame.size toRect2:image.image.size];
        [aPath moveToPoint:CGPointMake(p1.x, p1.y)];
        
        CGPoint p3 = CGPointMake(0, 50);//[JBCroppableView convertCGPoint:[[points objectAtIndex:i] CGPointValue] fromRect1:image.frame.size toRect2:image.image.size];
        [aPath addLineToPoint:CGPointMake(p3.x, p3.y)];
        
        
        CGPoint p2 = CGPointMake(150, 150);//[JBCroppableView convertCGPoint:[[points objectAtIndex:i] CGPointValue] fromRect1:image.frame.size toRect2:image.image.size];
        [aPath addLineToPoint:CGPointMake(p2.x, p2.y)];
        
        CGPoint p4 = CGPointMake(290, 0);//[JBCroppableView convertCGPoint:[[points objectAtIndex:i] CGPointValue] fromRect1:image.frame.size toRect2:image.image.size];
        [aPath addLineToPoint:CGPointMake(p4.x, p4.y)];
        
        [aPath closePath];
        [aPath fill];
    }
    
    UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
    {
        CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, mask.CGImage);
        [image drawAtPoint:CGPointZero];
    }
    
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    NSLog(@"maskedImage %f,%f",maskedImage.size.width,maskedImage.size.height);
    UIGraphicsEndImageContext();
    
    return maskedImage;
    
}

#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint _currentOffset = scrollView.contentOffset;
//    NSLog(@"%f,%f",_currentOffset.x,_currentOffset.y);
    if (scrollView.tag == 10) {
        [_pointArray removeAllObjects];
        float _edge = 300;
        CGPoint _point = CGPointMake(_currentOffset.x, _imageView.image.size.height-_edge+_currentOffset.y);
        [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        
        _point = CGPointMake(_currentOffset.x, _imageView.image.size.height+_currentOffset.y);
        [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        
        _point = CGPointMake(_edge+_currentOffset.x, _imageView.image.size.height-_edge+_currentOffset.y);
        [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        
        _imageView.image = [JBCroppableView getSpecialImage:_imageView.image withPoints:_pointArray andEdge:_edge andOffset:CGPointZero];
    }
    else if(scrollView.tag == 11)
    {
        [_pointArray removeAllObjects];
        float _edge = 300;
        CGPoint _point = CGPointMake(10+_currentOffset.x, _markImage.size.height-_currentOffset.y);
        [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        
        _point = CGPointMake(300+_currentOffset.x, _markImage.size.height-_currentOffset.y);
        [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        
        _point = CGPointMake(300+_currentOffset.x, _markImage.size.height-290-_currentOffset.y);
        [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        
        _imageView2.image = [JBCroppableView getSpecialImage:_markImage withPoints:_pointArray andEdge:_edge andOffset:CGPointZero];
    }
}

#pragma mark -- touches
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    CGPoint locationPoint = [[touches anyObject] locationInView:self];
//    NSLog(@"start : %f,%f",locationPoint.x,locationPoint.y);
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    CGPoint locationPoint = [[touches anyObject] locationInView:self];
//    NSLog(@"%f,%f",locationPoint.x,locationPoint.y);
//}

@end
