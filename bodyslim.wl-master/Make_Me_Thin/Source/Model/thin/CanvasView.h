//
//  canvasView.h
//  eyeColorPlus
//
//  Created by shen on 14-7-16.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kCanvasModeNone,
    kCanvasModePaint,
    kCanvasModeClick,
    kCanvasModeDrag,
} CanvasMode;

@class CanvasView;

@protocol CanvasViewDelegate <NSObject>

@optional
-(void) touchEndWithMaskImage:(UIImage *)maskImage;
-(void) touchEndWithPointInImage:(CGPoint) point;
-(void) touchEndWithEndPointInImage:(CGPoint)endPoint andStartPointInImage:(CGPoint) startPoint;
@end

@interface CanvasView : UIView
- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)image;

@property (nonatomic, weak) id<CanvasViewDelegate> delegate;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, readwrite) BOOL supportScale;
@property (nonatomic, readwrite) BOOL supportMirror;
@property (nonatomic, readwrite) BOOL supportInteraction;
@property (nonatomic, readwrite) CanvasMode mode;
@property (nonatomic, readwrite) CGFloat radius;

- (CGRect) getContainerFrame;
- (CGFloat) getImageViewScale;

-(void) setupMirrorInView:(UIView *)mirrorSuperView;

@end
