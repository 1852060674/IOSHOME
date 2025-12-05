//
//  ComprehensiveCutoutMaskView.h
//  CutMeIn
//
//  Created by ZB_Mac on 16/6/27.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComprehensiveCutoutShapeMaskView.h"

@interface ComprehensiveCutoutMaskView : UIView

-(ComprehensiveCutoutMaskView *)initWithFrame:(CGRect)frame andImageWidth:(NSInteger)imageWidth andImageHeight:(NSInteger)imageHeight;

@property (nonatomic, readwrite) NSInteger imageWidth;
@property (nonatomic, readwrite) NSInteger imageHeight;

@property (nonatomic, strong) ComprehensiveCutoutShapeMaskView *shapeMaskView;

// for brush&eraser

-(NSInteger)brushRadius;
-(void)setBrushRadius:(NSInteger)brushRadius;
-(CGFloat)brushSmooth;
-(void)setBrushSmooth:(CGFloat)brushSmooth;
-(CGFloat)brushAlpha;
-(void)setBrushAlpha:(CGFloat)brushAlpha;
-(void)setEraseMode:(BOOL)eraseMode;

-(void)privateTouchesBeganAtPoint:(CGPoint)point;
-(void)privateTouchesMovedToPoint:(CGPoint)point;
-(void)privateTouchesEndedAtPoint:(CGPoint)point;
-(void)privateTouchesCancelled;

-(UIImage *)getFixMaskImage;
-(void)setFixMaskImage:(UIImage *)image;

// for shape
-(void)resetShapeView;
-(UIImage *)getShapeMaskImage;
-(void)setShapeMaskImage:(UIImage *)image;
-(void)zoomByScale:(CGFloat)scale;
-(void)rotateByAngle:(CGFloat)angle;
-(void)translateByOffset:(CGPoint)offset;

//
-(void)updateContextSize;

-(UIImage *)getMaskImage;
-(void)setFixMaskImage:(UIImage *)fixImage andShapeMaskImage:(UIImage *)shapeImage record:(BOOL)record;

//
-(void)makeAndPushHistoryFrame:(NSInteger)type;

-(void)undo;
-(void)redo;

-(BOOL)canUndo;
-(BOOL)canRedo;

-(void)jumpToLast;
-(void)jumpToFirst;

-(void)useHistoryIndex:(NSInteger)idx;
-(void)clearHistoryIndex:(NSInteger)idx;

-(void)reset;
@end
