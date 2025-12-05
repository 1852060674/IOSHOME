//
//  BHDragView.m
//  PicFrame
//
//  Created by shen Lv on 13-6-7.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import "BHDragView.h"
#import "ImageUtil.h"
#import "BHCommenMethod.h"
#import <QuartzCore/QuartzCore.h>

#define MRScreenWidth      CGRectGetWidth([UIScreen mainScreen].applicationFrame)
#define MRScreenHeight     CGRectGetHeight([UIScreen mainScreen].applicationFrame)
#define kDeleteImageViewStartTag   900
#define kDragViewStartTag    800
#define kScaleButtonStartTag       1200
#define k_POINT_WIDTH 30

@interface BHDragView ()
{
    CGPoint startLocation;
    CGRect _oringinRect;
    CGFloat lastDistance;
	CGFloat imgStartWidth;
	CGFloat imgStartHeight;
    UIButton *_deleteButton;
    UIButton *_scaleButton;
    NSUInteger _currentViewTag;
    BOOL _isLineColorNone;
    UIView *_scaleView;
    BOOL _scaleViewIsActive;
    CGPoint lastPoint;
}

@end

@implementation BHDragView

@synthesize imageView;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame withImage:(UIImage*)image andTag:(NSUInteger)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *_closeImage = [ImageUtil loadResourceImage:@"close-iphone.png"];
//        _imageViewColse = [[UIImageView alloc] initWithImage:_closeImage];
//        _imageViewColse.tag = kDeleteImageViewStartTag + self.tag;
//        [_imageViewColse setUserInteractionEnabled:YES];
//        _imageViewColse.frame = 
//        [self addSubview:_imageViewColse];
//        
//        UITapGestureRecognizer *_singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteSelectedImage:)];
//        [_imageViewColse addGestureRecognizer:_singleTap];
        
        
        _currentViewTag = tag;
        [self initImageView:image];
        _oringinRect = frame;
        lastDistance=0;
        
        imgStartWidth=imageView.frame.size.width;
        imgStartHeight=imageView.frame.size.height;
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:_closeImage forState:UIControlStateNormal];
        _deleteButton.frame = CGRectMake(0, 0, _closeImage.size.width, _closeImage.size.height);//CGRectMake(imgStartWidth/2+_closeImage.size.width/2, imgStartHeight/2+_closeImage.size.height/2, _closeImage.size.width, _closeImage.size.height);
        _deleteButton.tag = kDeleteImageViewStartTag + tag - kDragViewStartTag;
        [_deleteButton addTarget:self action:@selector(deleteSelectedImage:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        
//        _scaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_scaleButton setImage:_closeImage forState:UIControlStateNormal];
//        _scaleButton.frame = CGRectMake(self.frame.size.width-_closeImage.size.width, self.frame.size.height-_closeImage.size.height, _closeImage.size.width, _closeImage.size.height);
//        _scaleButton.tag = kDeleteImageViewStartTag + tag - kDragViewStartTag;
//        [_scaleButton addTarget:self action:@selector(scaleImage:) forControlEvents:UIControlEventTouchDragInside];
//        [self addSubview:_scaleButton];
        
//        _scaleView = [self getPointView:0 at:CGPointMake(self.frame.size.width -10, self.frame.size.height -10)];
//        [self addSubview:_scaleView];
        
        [self performSelector:@selector(delayShowDeleteButtonIcon) withObject:nil afterDelay:2];
    }
    return self;

}

- (void)initImageView:(UIImage*)image
{
    imageView = [[UIImageView alloc]initWithImage:image];
    
    // The imageView can be zoomed largest size
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];        
}

- (UIView *)getPointView:(int)num at:(CGPoint)point
{
    UIView *point1 = [[UIView alloc] initWithFrame:CGRectMake(point.x -k_POINT_WIDTH/2, point.y-k_POINT_WIDTH/2, k_POINT_WIDTH, k_POINT_WIDTH)];
    point1.alpha = 0.8;
    point1.backgroundColor    = [UIColor blueColor];
    point1.layer.borderColor  = [UIColor yellowColor].CGColor;
    point1.layer.borderWidth  = 4;
    point1.layer.cornerRadius = k_POINT_WIDTH/2;
    
//    UILabel *number = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, k_POINT_WIDTH, k_POINT_WIDTH)];
//    number.text = [NSString stringWithFormat:@"%d",num];
//    number.textColor = [UIColor whiteColor];
//    number.backgroundColor = [UIColor clearColor];
//    number.font = [UIFont systemFontOfSize:14];
//    number.textAlignment = NSTextAlignmentCenter;
    
//    [point1 addSubview:number];
    
    return point1;
}

#pragma mark -- custom method
- (void)hiddenDeleteButtonIcon:(BOOL)flag
{
    _deleteButton.hidden = flag;
//    _scaleView.hidden = flag;
    if (flag) {
        _isLineColorNone = YES;
    }
    else
    {
        _isLineColorNone = NO;
    }
//    [self setNeedsDisplay];
}

- (void)delayShowDeleteButtonIcon
{
    [self hiddenDeleteButtonIcon:YES];
}

#pragma mark-- touches

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	// Calculate and store offset, and pop view into front if needed
	CGPoint pt = [[touches anyObject] locationInView:self];
	startLocation = pt;
	[[self superview] bringSubviewToFront:self];
    [self hiddenDeleteButtonIcon:NO];
    
    CGPoint viewPoint = [_scaleView convertPoint:pt fromView:self];
    if ([_scaleView pointInside:viewPoint withEvent:event])
    {
        _scaleViewIsActive = YES;
        _scaleView.backgroundColor = [UIColor redColor];
    }
    lastPoint = pt;
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	CGPoint p1;
	CGPoint p2;
	CGFloat sub_x;
	CGFloat sub_y;
	CGFloat currentDistance;
	CGRect imgFrame;
	
	NSArray * touchesArr=[[event allTouches] allObjects];
	
//    NSLog(@"手指个数%d",[touchesArr count]);
    if ([touchesArr count]==1)
    {
        CGPoint pt = [[touches anyObject] locationInView:self];
        if (_scaleViewIsActive)
        {
//            _scaleView.frame = CGRectOffset(_scaleView.frame, pt.x - lastPoint.x, pt.x - lastPoint.x);
//            imageView.frame=CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width+pt.x - lastPoint.x, imageView.frame.size.height+pt.x - lastPoint.x);
//            CGFloat _radians = 0;
////            CGPoint _center = CGPointMake(self.frame.size.width/2, self.frame.size.height);
////            CGFloat _a2 = (lastPoint.x-pt.x)*(lastPoint.x-pt.x)+(lastPoint.y-pt.y)*(lastPoint.y-pt.y);
////            CGFloat _b2 = (_center.x-lastPoint.x)*(_center.x-lastPoint.x)+(_center.y-lastPoint.y)*(_center.y-lastPoint.y);
////            CGFloat _c2 = (_center.x-pt.x)*(_center.x-pt.x)+(_center.y-pt.y)*(_center.y-pt.y);
////            CGFloat _2bc = 2*sqrt(_b2)*sqrt(_c2);
////            if (0!=_2bc) {
////                _radians = (_a2 + _b2 - _c2)/_2bc;
////                NSLog(@"_radians %f",_radians);
////                _radians = sqrtf(1-_radians*_radians);
////                NSLog(@"sin %f",_radians);
////                _radians = 2*asin(_radians);
////                NSLog(@"asin %f",_radians);
////            }
//            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(adjustDragViewFrame: withDragViewTag: andRadians:)])
//            {
//                [self.delegate adjustDragViewFrame:CGRectMake(0, 0, pt.x - lastPoint.x, pt.x - lastPoint.x) withDragViewTag:_currentViewTag andRadians:_radians];
//            }
        }
        else
        {
            
            float dx = pt.x - startLocation.x;
            float dy = pt.y - startLocation.y;
            CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
//            NSLog(@"%f,%f",startLocation.x,startLocation.y);
//            NSLog(@"newcenter = %f,%f",newcenter.x,newcenter.y);
            
            self.center = newcenter;
        }
        lastPoint = pt;
    }
	
	if ([touchesArr count]>=2) {
		p1=[[touchesArr objectAtIndex:0] locationInView:self];
		p2=[[touchesArr objectAtIndex:1] locationInView:self];
		
		sub_x=p1.x-p2.x;
		sub_y=p1.y-p2.y;
		currentDistance=sqrtf(sub_x*sub_x+sub_y*sub_y);
		
		if (lastDistance>0)
        {
			
			imgFrame=imageView.frame;
			if (currentDistance>lastDistance+2)
            {
				NSLog(@"放大");
				
				imgFrame.size.width+=10;
				if (imgFrame.size.width>1000)
                {
					imgFrame.size.width=1000;
				}
				
				lastDistance=currentDistance;
			}
			if (currentDistance<lastDistance-2)
            {
				NSLog(@"缩小");
				
				imgFrame.size.width-=10;
				
				if (imgFrame.size.width<50)
                {
					imgFrame.size.width=50;
				}
				
				lastDistance=currentDistance;
			}
			
			if (lastDistance==currentDistance)
            {
				imgFrame.size.height=imgStartHeight*imgFrame.size.width/imgStartWidth;
                
                float addwidth=imgFrame.size.width-imageView.frame.size.width;
                float addheight=imgFrame.size.height-imageView.frame.size.height;
                
//                float addwidth=imgFrame.size.width-imgStartWidth;
//                float addheight=imgFrame.size.height-imgStartHeight;
//                if (self.frame.origin.x-addwidth<0 || self.frame.origin.y-addheight<0) {
//                    return;
//                }
                
				imageView.frame=CGRectMake(imgFrame.origin.x-addwidth/2.0f, imgFrame.origin.y-addheight/2.0f, imgFrame.size.width, imgFrame.size.height);
//                imageView.frame=CGRectMake(0, 0, imgFrame.size.width, imgFrame.size.height);

//                NSLog(@"imageView Frame %@",imageView);
//                if (self.delegate && [self.delegate respondsToSelector:@selector(adjustDragViewFrame: withDragViewTag: andRadians:)])
//                {
//                    [self.delegate adjustDragViewFrame:CGRectMake(-addwidth/2.0f, -addheight/2.0f, imgFrame.size.width, imgFrame.size.height) withDragViewTag:_currentViewTag andRadians:0];
//                }
//                [self setNeedsDisplay];
//                _deleteButton.frame = CGRectMake(imgFrame.origin.x, imgFrame.origin.y, _deleteButton.frame.size.width, _deleteButton.frame.size.height);
//                [self drawRect:CGRectMake(imgFrame.origin.x, imgFrame.origin.y, imgStartWidth, imgStartHeight)];
//                imageView.frame=CGRectMake(imgFrame.origin.x, imgFrame.origin.y, imgFrame.size.width, imgFrame.size.height);
//                NSLog(@"imageView %@",imageView);
//              
//                self.frame = CGRectMake(_oringinRect.origin.x-addwidth/2.0f, _oringinRect.origin.y-addheight/2.0f, imageView.frame.size.width, imageView.frame.size.height);
//                NSLog(@"self %@",self);
			}
			
		}else {
			lastDistance=currentDistance;
		}
	}
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	lastDistance=0;
//    [self performSelector:@selector(delayShowDeleteButtonIcon) withObject:nil afterDelay:3];
    _scaleView.backgroundColor = [UIColor blueColor];
    _scaleViewIsActive = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _scaleView.backgroundColor = [UIColor blueColor];
    _scaleViewIsActive = NO;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
//    //首先，获取上下文
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    //设置矩形填充颜色：红色
//    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.0);
//    //填充矩形
//    CGContextFillRect(context, rect);
//    //设置画笔颜色：黑色
//    if (_isLineColorNone) {
//        CGContextSetRGBStrokeColor(context, 0, 0, 0, 0);
//    }
//    else
//    {
//        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
//    }
//    
//    //设置画笔线条粗细
//    CGContextSetLineWidth(context, 1.0);
//    //画矩形边框
//    CGContextAddRect(context,rect);
//    //执行绘画
//    CGContextStrokePath(context);
}

#pragma mark -- delete image
- (void)deleteSelectedImage:(id )sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteSeletedSmilingIcon:)]) {
        UIButton *view = (UIButton*)sender;
        int _tagValue = view.tag - kDeleteImageViewStartTag;
        [self.delegate deleteSeletedSmilingIcon:_tagValue];
    }
}

- (void)scaleImage:(id)sender
{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteSeletedSmilingIcon:)]) {
//        UIButton *view = (UIButton*)sender;
//        int _tagValue = view.tag - kDeleteImageViewStartTag;
//        [self.delegate deleteSeletedSmilingIcon:_tagValue];
//    }
}

#pragma mark - View cycle
- (void)dealloc
{
}


@end
