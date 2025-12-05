//
//  canvasView.m
//  eyeColorPlus
//
//  Created by shen on 14-7-16.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import "CanvasView.h"
#import "MaskView.h"
#import "CGRectCGPointUtility.h"
#import "ZoomView.h"

@interface CanvasView ()<MaskViewDataSource>
{
    CGRect originalFrame;
    
    CGFloat mirrorWidth, mirrorHeight;
    CGRect mirrorLeftArea, mirrorRightArea;
    CGFloat mirrorScale;
    
    CGFloat viewScale;
    BOOL needTransfromAdjust;
    
    BOOL startPointValid;
    CGPoint startPoint;
    CGPoint startPointInView;
    
    BOOL reportAction;
}
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) MaskView *maskView;

@property (strong, nonatomic) UIView* mirrorShellView;
@property (strong, nonatomic) UIView* mirrorImageContainerView;
@property (strong, nonatomic) UIImageView* mirrorImageView;
@property (strong, nonatomic) UIImageView* mirrorMaskView;
//@property (strong, nonatomic) UIView *mirrorEraserView;
@property (strong, nonatomic) ZoomView *mirrorEraserView;
@property (strong, nonatomic) ZoomView *mirrorEraserBeginView;
@property (strong, nonatomic) ZoomView *dragBeginView;
@property (strong, nonatomic) ZoomView *dragEndView;
@end

@implementation CanvasView
-(void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = _image;
}

-(void)setMode:(CanvasMode)mode
{
    _mode = mode;
    self.maskView.hidden = (mode!=kCanvasModePaint || !self.supportInteraction);
}

-(void)setSupportMirror:(BOOL)supportMirror
{
    _supportMirror = supportMirror;
}

-(void)setSupportScale:(BOOL)supportScale
{
    _supportScale = supportScale;
}

-(void)setSupportInteraction:(BOOL)supportInteraction
{
    _supportInteraction = supportInteraction;
    self.maskView.hidden = (self.mode!=kCanvasModePaint || !_supportInteraction);
    if (!_supportInteraction) {
        self.mirrorShellView.hidden = YES;
    }
}

-(void)setRadius:(CGFloat)radius
{
    _radius = radius;
}

-(ZoomView *)dragBeginView
{
    if (_dragBeginView == nil) {
        _dragBeginView = [[ZoomView alloc] initWithCircleRadius:self.radius/[self getImageViewScale]];
        _dragBeginView.circleLineDashed = YES;
        _dragBeginView.circleColor = [UIColor darkGrayColor];
        _dragBeginView.hasCross = NO;
        _dragBeginView.hidden = YES;
        [self.imageView addSubview:_dragBeginView];
    }
    return _dragBeginView;
}

-(ZoomView *)dragEndView
{
    if (_dragEndView == nil) {
        _dragEndView = [[ZoomView alloc] initWithCircleRadius:self.radius/[self getImageViewScale]];
        _dragEndView.hidden = YES;
        [self.imageView addSubview:_dragEndView];
    }
    return _dragEndView;
}

- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        viewScale = 1.0;
        needTransfromAdjust = NO;
        self.radius = 1;
        
        self.clipsToBounds = YES;
        originalFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.containerView = [[UIView alloc] initWithFrame:originalFrame];
        self.containerView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.containerView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:originalFrame];
        self.image = image;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.backgroundColor = [UIColor clearColor];
        [self.containerView addSubview:self.imageView];
        
        self.maskView = [[MaskView alloc] initWithFrame:originalFrame andDataSource:self];
        self.maskView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.maskView];
//        [self setupMirror];
    }
    return self;
}

#pragma mark - mirror
-(void) setupMirrorInView:(UIView *)mirrorSuperView
{
    CGRect frame = mirrorSuperView.bounds;
    // mirror init
    mirrorScale = 0.3;
    mirrorWidth = mirrorHeight = MAX(frame.size.width, frame.size.height)*mirrorScale;
//    mirrorHeight = frame.size.height*mirrorScale;
    
    mirrorLeftArea = CGRectMake(0, 0, mirrorWidth, mirrorHeight);
    mirrorRightArea = CGRectMake(frame.size.width-mirrorWidth, 0, mirrorWidth, mirrorHeight);
    
    self.mirrorShellView = [[UIView alloc] initWithFrame:mirrorLeftArea];
    CALayer *layer = [self.mirrorShellView layer];
    layer.borderColor = [[UIColor whiteColor] CGColor];
    layer.borderWidth = 2.0f;
    layer.cornerRadius = 3.0;
    self.mirrorShellView.clipsToBounds = YES;
    self.mirrorImageContainerView = [[UIView alloc] initWithFrame:frame];
    self.mirrorImageView = [[UIImageView alloc] initWithFrame:frame];
    self.mirrorImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.mirrorImageView.backgroundColor = [UIColor blackColor];
    
    self.mirrorMaskView = [[UIImageView alloc] initWithFrame:frame];
    self.mirrorMaskView.contentMode = UIViewContentModeScaleAspectFit;
    self.mirrorMaskView.backgroundColor = [UIColor clearColor];
    
    CGFloat eraserSize = [self stokeWidthForMaskView:self.maskView];
    self.mirrorEraserView = [[ZoomView alloc] initWithCircleRadius:eraserSize/[self getImageViewScale]];
    self.mirrorEraserView.center = CGPointMake(mirrorWidth/2, mirrorHeight/2);
    
    self.mirrorEraserBeginView = [[ZoomView alloc] initWithCircleRadius:eraserSize/[self getImageViewScale]];
    self.mirrorEraserBeginView.circleLineDashed = YES;
    self.mirrorEraserBeginView.circleColor = [UIColor darkGrayColor];
    self.mirrorEraserBeginView.hasCross = NO;
    self.mirrorEraserBeginView.hidden = YES;
    self.mirrorEraserBeginView.center = CGPointMake(mirrorWidth/2, mirrorHeight/2);
    self.mirrorEraserBeginView.hidden = (self.mode != kCanvasModeDrag);
    
    [self.mirrorImageContainerView addSubview:self.mirrorImageView];
    [self.mirrorShellView addSubview:self.mirrorImageContainerView];
    [self.mirrorShellView addSubview:self.mirrorMaskView];
    [self.mirrorShellView addSubview:self.mirrorEraserView];
    [self.mirrorImageView addSubview:self.mirrorEraserBeginView];
    
    self.mirrorShellView.hidden = YES;
    [mirrorSuperView addSubview:self.mirrorShellView];
}
- (void)updateMirrorWithTouches:(NSSet *)touches andEvent:(UIEvent *)event
{
    if (self.mirrorShellView.hidden == YES) {
        return;
    }
    
    CGPoint pointInMirrorSuper = [[touches anyObject] locationInView:self.mirrorShellView.superview];
    if (CGRectContainsPoint(self.mirrorShellView.frame, pointInMirrorSuper)) {
        
        if (!CGRectContainsPoint(mirrorLeftArea, pointInMirrorSuper)) {
            self.mirrorShellView.frame = mirrorLeftArea;
        }
        else if (!CGRectContainsPoint(mirrorRightArea, pointInMirrorSuper))
        {
            self.mirrorShellView.frame = mirrorRightArea;
        }
    }
    
    CGPoint point = [[touches anyObject] locationInView:self.containerView];
    
    CGRect frame = self.containerView.frame;
    CGRect canvasFrame = self.frame;
    
    CGFloat offsetX = point.x-mirrorWidth/2.0;
    CGFloat offsetY = point.y-mirrorHeight/2.0;
    
    CGFloat eraserOffsetX=mirrorWidth/2.0;
    CGFloat eraserOffsetY=mirrorHeight/2.0;
    
    CGPoint pointInCanvas = [[touches anyObject] locationInView:self];
    if (pointInCanvas.x<mirrorWidth/2.0) {
        offsetX = point.x - pointInCanvas.x;
        eraserOffsetX = pointInCanvas.x;
    }
    else if (pointInCanvas.x>canvasFrame.size.width-mirrorWidth/2.0)
    {
        offsetX = canvasFrame.size.width-mirrorWidth-pointInCanvas.x+point.x;
        eraserOffsetX = mirrorWidth-(canvasFrame.size.width-pointInCanvas.x);
    }
    
    if (pointInCanvas.y<mirrorHeight/2.0) {
        offsetY = point.y - pointInCanvas.y;
        eraserOffsetY = pointInCanvas.y;
    }
    else if (pointInCanvas.y>canvasFrame.size.height-mirrorHeight/2.0)
    {
        offsetY = canvasFrame.size.height-mirrorHeight-pointInCanvas.y+point.y;
        eraserOffsetY = mirrorHeight-(canvasFrame.size.height-pointInCanvas.y);
    }
    
    CGPoint center = CGPointMake(eraserOffsetX, eraserOffsetY);
    CGFloat eraserSize = [self stokeWidthForMaskView:self.maskView];
    self.mirrorEraserView.circleRadius = eraserSize;
    self.mirrorEraserView.center = center;
    self.mirrorEraserBeginView.circleRadius = eraserSize;
    self.mirrorEraserBeginView.hidden = (self.mode != kCanvasModeDrag);
    self.mirrorEraserBeginView.center = self.dragBeginView.center;
    
    self.mirrorImageView.image = self.image;
    frame.origin = CGPointZero;
    self.mirrorImageView.frame = CGRectOffset(frame, -offsetX, -offsetY);
    
    self.mirrorMaskView.image = [self.maskView getViewImage];
    CGFloat maskOffsetX = pointInCanvas.x-eraserOffsetX;
    CGFloat maskOffsetY = pointInCanvas.y-eraserOffsetY;
    canvasFrame.origin = CGPointZero;
    self.mirrorMaskView.frame = CGRectOffset(canvasFrame, -maskOffsetX, -maskOffsetY);
}
-(void) updateMirrorFrame
{
    mirrorWidth = originalFrame.size.width*mirrorScale;
    mirrorHeight = originalFrame.size.height*mirrorScale;
    mirrorLeftArea = CGRectMake(0, 0, mirrorWidth, mirrorHeight);
    mirrorRightArea = CGRectMake(originalFrame.size.width-mirrorWidth, 0, mirrorWidth, mirrorHeight);
    
    self.mirrorShellView.frame = mirrorLeftArea;
    self.mirrorImageContainerView.frame = originalFrame;
    self.mirrorImageView.frame = originalFrame;
    self.mirrorMaskView.frame = originalFrame;
    self.mirrorEraserView.center = CGPointMake(mirrorWidth/2, mirrorHeight/2);
    self.mirrorEraserBeginView.center = CGPointMake(mirrorWidth/2.0, mirrorHeight/2.0);
}

-(CGRect)getContainerFrame
{
    return self.containerView.frame;
}
- (CGFloat) getImageViewScale
{
    CGFloat factor = self.image.size.width/self.imageView.frame.size.width;
    if (factor < self.image.size.height/self.imageView.frame.size.height) {
        factor = self.image.size.height/self.imageView.frame.size.height;
    }
    //    CGFloat imageScale = self.image.scale;
    //    CGFloat screenScale = [[UIScreen mainScreen] scale];
    return factor;
}
#pragma mark - touche
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSInteger count = [[[event allTouches] allObjects] count];
    if (count == 1) {
        
        UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
        
        switch (self.mode) {
            case kCanvasModeDrag:
            {
                self.dragBeginView.circleRadius = self.radius;
                self.dragBeginView.center = [mytouch locationInView:self.imageView];
                self.dragBeginView.hidden = NO;
                self.dragEndView.circleRadius = self.radius;
                self.dragEndView.center = [mytouch locationInView:self.imageView];
                self.dragEndView.hidden = NO;
                break;
            }
            default:
                break;
        }
        
        startPointValid = YES;
        CGPoint point = [mytouch locationInView:self.imageView];
        CGRect imageRect = CGRectZero; imageRect.size = self.image.size;
        startPointInView = point;
        startPoint = [CGRectCGPointUtility imageViewConvertPoint:point fromViewRect:self.imageView.frame toImageRect:imageRect];
        [self.maskView privateTouchesBegan:touches withEvent:event];
        
        if ((self.mode == kCanvasModeClick || self.mode == kCanvasModePaint || self.mode == kCanvasModeDrag) && self.supportInteraction) {
            [self.mirrorShellView setHidden:NO];
        }
        [self updateMirrorWithTouches:touches andEvent:event];
    }
    else if (count == 2)
    {
        
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSInteger count = [[[event allTouches] allObjects] count];
    if (count == 1) {
        UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
        
        switch (self.mode) {
            case kCanvasModeDrag:
            {
                self.dragEndView.circleRadius = self.radius;
                self.dragEndView.center = [mytouch locationInView:self.imageView];
                self.dragEndView.hidden = NO;
                break;
            }
            default:
                break;
        }
        
        if (self.mode == kCanvasModePaint) {
            [self.maskView privateTouchesMoved:touches withEvent:event];
        }
        else if (self.mode == kCanvasModeNone)
        {
            [self scaleAndMoveTouchesMoved:touches withEvent:event];
        }
        if ((self.mode == kCanvasModeClick || self.mode == kCanvasModePaint || self.mode == kCanvasModeDrag) && self.supportInteraction) {
            [self.mirrorShellView setHidden:NO];
        }
        [self updateMirrorWithTouches:touches andEvent:event];
    }
    else if (count == 2)
    {
        self.mirrorShellView.hidden = YES;
        self.dragBeginView.hidden = YES;
        self.dragEndView.hidden = YES;
        startPointValid = NO;
        [self scaleAndMoveTouchesMoved:touches withEvent:event];
    }
}

#define MINIMAL_DRAG_DISTANCE 5.0
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self adjustTransformAfterScaleOrMove];
    
    NSInteger count = [[[event allTouches] allObjects] count];
    if (count == 1) {
        [self.maskView privateTouchesEnded:touches withEvent:event];
        
        if (self.supportInteraction && startPointValid) {
            switch (self.mode) {
                case kCanvasModeClick:
                {
                    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
                    CGPoint point = [mytouch locationInView:self.imageView];
                    CGRect imageRect = CGRectZero; imageRect.size = self.image.size;
                    point = [CGRectCGPointUtility imageViewConvertPoint:point fromViewRect:self.imageView.frame toImageRect:imageRect];
                    if ([self.delegate respondsToSelector:@selector(touchEndWithPointInImage:)]) {
                        [self.delegate touchEndWithPointInImage:point];
                    }
                    break;
                }
                case kCanvasModePaint:
                {
                    if ([self.delegate respondsToSelector:@selector(touchEndWithMaskImage:)]) {
                        [self.delegate touchEndWithMaskImage:[self.maskView getMaskImage]];
                    }
                    break;
                }
                case kCanvasModeDrag:
                {
                    if (startPointValid) {
                        UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
                        CGPoint endPoint = [mytouch locationInView:self.imageView];
                        CGRect imageRect = CGRectZero; imageRect.size = self.image.size;
                        
                        CGFloat distance = sqrt((endPoint.x-startPointInView.x)*(endPoint.x-startPointInView.x)+(endPoint.y-startPointInView.y)*(endPoint.y-startPointInView.y));
                        
                        endPoint = [CGRectCGPointUtility imageViewConvertPoint:endPoint fromViewRect:self.imageView.frame toImageRect:imageRect];
#ifdef DEBUG
                        NSLog(@"(%f, %f) (%f, %f)", startPoint.x, startPoint.y, endPoint.x, endPoint.y);
#endif
                        BOOL startOutOfImage = NO, endOutOfImage = NO;
                        
                        if (startPoint.x<0 || startPoint.x>self.image.size.width
                            || startPoint.y<0 || startPoint.y>self.image.size.height) {
                            startOutOfImage = YES;
                        }
                        
                        if (endPoint.x<0 || endPoint.x>self.image.size.width
                            || endPoint.y<0 || endPoint.y>self.image.size.height) {
                            endOutOfImage = YES;
                        }
                        
                        if (startOutOfImage && endOutOfImage) {
#ifdef DEBUG
                            NSLog(@"Outside Image!!");
#endif
                            
                        }
                        
                        if (distance <= MINIMAL_DRAG_DISTANCE) {
#ifdef DEBUG
                            NSLog(@"distance less than MINIMAL_DRAG_DISTANCE, %f", distance);
#endif
                            
                        }
                        
                        if ([self.delegate respondsToSelector:@selector(touchEndWithEndPointInImage:andStartPointInImage:)] && distance > MINIMAL_DRAG_DISTANCE && !(startOutOfImage && endOutOfImage))
                        {
#ifdef DEBUG
                            NSLog(@"Image Process: (%f, %f) (%f, %f)", startPoint.x, startPoint.y, endPoint.x, endPoint.y);
                            NSLog(@"Image Process: distance %f", distance);
#endif
                            
                            [self.delegate touchEndWithEndPointInImage:endPoint andStartPointInImage:startPoint];
                        }
                    }
                }
                default:
                    break;
            }
        }
    }
    else if (count == 2)
    {
        
    }
    startPointValid = NO;
    [self.mirrorShellView setHidden:YES];
    self.mirrorMaskView.image = nil;
    self.dragEndView.hidden = YES;
    self.dragBeginView.hidden = YES;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self adjustTransformAfterScaleOrMove];
    
    NSInteger count = [[[event allTouches] allObjects] count];
    if (count == 1) {
        
    }
    else if (count == 2)
    {
    }
    startPointValid = NO;
    [self.maskView privateTouchesEnded:touches withEvent:event];
    [self.mirrorShellView setHidden:YES];
    self.mirrorMaskView.image = nil;
    self.dragEndView.hidden = YES;
    self.dragBeginView.hidden = YES;
}

- (void)scaleAndMoveTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p1;
	CGPoint p2;
	CGFloat sub_x;
	CGFloat sub_y;
	CGFloat currentDistance;
    CGFloat lastDistance;
	
	NSArray * touchesArr=[[event allTouches] allObjects];
    
    CGPoint currentPoint, lastPoint;
	
	if ([touchesArr count]>=2) {
		p1=[[touchesArr objectAtIndex:0] locationInView:self];
		p2=[[touchesArr objectAtIndex:1] locationInView:self];
        
        CGPoint pre1 = [[touchesArr objectAtIndex:0] previousLocationInView:self];
        CGPoint pre2 = [[touchesArr objectAtIndex:1] previousLocationInView:self];
        lastPoint.x = (pre1.x+pre2.x)/2;
        lastPoint.y = (pre1.y+pre2.y)/2;
        
        currentPoint.x = (p1.x+p2.x)/2;
        currentPoint.y = (p1.y+p2.y)/2;
        
		sub_x=p1.x-p2.x;
		sub_y=p1.y-p2.y;
		
		currentDistance=sqrtf(sub_x*sub_x+sub_y*sub_y);
		lastDistance = sqrtf((pre1.x-pre2.x)*(pre1.x-pre2.x)+(pre1.y-pre2.y)*(pre1.y-pre2.y));
        
        CGFloat zoomScale = currentDistance/lastDistance;
        
        if (viewScale * zoomScale < 0.1 || viewScale * zoomScale > 10.0) {
            return;
        }
        
        needTransfromAdjust = YES;
        viewScale *= zoomScale;
        
        CGRect frame = self.containerView.frame;
        frame.size.width *= zoomScale;
        frame.size.height *= zoomScale;
        CGPoint currentPointInImageView = [self.containerView convertPoint:currentPoint fromView:self];
        float addwidth = currentPointInImageView.x*(zoomScale-1.0);
        float addheight = currentPointInImageView.y*(zoomScale-1.0);
        frame.origin.x += (currentPoint.x-lastPoint.x)-addwidth;
        frame.origin.y += (currentPoint.y-lastPoint.y)-addheight;
        self.containerView.frame = frame;
        self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    else if ([touchesArr count] == 1)
    {
        needTransfromAdjust = YES;
        
        p1=[[touchesArr objectAtIndex:0] locationInView:self];
        CGPoint pre1 = [[touchesArr objectAtIndex:0] previousLocationInView:self];
        
        CGRect frame = CGRectOffset(self.containerView.frame, p1.x-pre1.x, p1.y-pre1.y);
        self.containerView.frame = frame;
    }
}

#pragma mark -
- (void)adjustTransformAfterScaleOrMove
{
    if (viewScale < 1.0 && needTransfromAdjust == YES) {
        
        self.containerView.frame = originalFrame;
        self.imageView.frame = CGRectMake(0, 0, originalFrame.size.width, originalFrame.size.height);
        viewScale = 1.0;
    }
    
    if (needTransfromAdjust == YES) {
        CGRect frame = self.containerView.frame;
        CGFloat left = frame.origin.x, right = frame.origin.x+frame.size.width;
        CGFloat top = frame.origin.y, bottom = frame.origin.y+frame.size.height;
        
        CGFloat shiftX=0, shiftY=0;
        if (left > originalFrame.origin.x) {
            shiftX = originalFrame.origin.x-left;
        }
        else if (right < originalFrame.origin.x+originalFrame.size.width) {
            shiftX = originalFrame.origin.x+originalFrame.size.width-right;
        }
        
        if (top > originalFrame.origin.y) {
            shiftY = originalFrame.origin.y-top;
        }
        else if (bottom<originalFrame.origin.y+originalFrame.size.height) {
            shiftY = originalFrame.origin.y+originalFrame.size.height-bottom;
        }
        frame = CGRectOffset(frame, shiftX, shiftY);
        self.containerView.frame = frame;
    }
    
    needTransfromAdjust = NO;
}

#pragma mark - MaskViewDataSource
-(CGFloat)imageScaleForMaskView:(MaskView *)maskView
{
    return self.image.scale;
}

-(CGSize)imageSizeForMaskView:(MaskView *)maskView
{
    return self.image.size;
}

-(CGFloat)stokeWidthForMaskView:(MaskView *)maskView
{
    return self.radius;
}
-(UIImageView *)underneathImageView
{
    return self.imageView;
}

-(CGFloat)viewScaleForMaskView:(MaskView *)maskView
{
    return viewScale;
}

#pragma mark -
-(void)setFrame:(CGRect)frame
{
    super.frame = frame;
    originalFrame = frame; originalFrame.origin = CGPointZero;
    if (self.containerView != nil) {
        self.maskView.frame = originalFrame;
//        mirrorWidth = frame.size.width*mirrorScale;
//        mirrorHeight = frame.size.height*mirrorScale;
//        mirrorLeftArea = CGRectMake(0, 0, mirrorWidth, mirrorHeight);
//        mirrorRightArea = CGRectMake(frame.size.width-mirrorWidth, 0, mirrorWidth, mirrorHeight);
//        [self updateMirrorFrame];
    }
    else
    {
        //        NSLog(@"[INFO] IC: child frame not set!");
    }
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
