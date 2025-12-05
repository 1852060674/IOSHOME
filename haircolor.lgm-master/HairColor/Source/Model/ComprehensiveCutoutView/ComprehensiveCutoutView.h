//
//  ComprehensiveCutoutView.h
//  CutMeIn
//
//  Created by ZB_Mac on 16/6/24.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kCutoutModeNone,
    kCutoutModeSmartScissors,
    kCutoutModeNormalEraser,
    kCutoutModeNormalBrush,
    kCutoutModeShape,
} CutoutMode;

typedef enum : NSUInteger {
    kSelectionModeReplace,
    kSelectionModeAdd,
    kSelectionModeSub,
} SelectionMode;

typedef enum : NSUInteger {
    kICImageTypeBGFullSize,
    kICImageTypeFGFullSize,
    kICImageTypeBGWrap,
    kICImageTypeFGWrap,
    kICImageTypeMaskBGFullSize,
    kICImageTypeMaskBGWrap,
    kICImageTypeMaskFGFullSize,
    kICImageTypeMaskFGWrap,

} ICImageType;

@class ComprehensiveCutoutView;

@protocol ComprehensiveCutoutViewDelegate <NSObject>

-(void)comprehensiveCutoutViewWillBeginTimeConsumingOperation:(ComprehensiveCutoutView *)cutoutView;
-(void)comprehensiveCutoutViewDidFinishTimeConsumingOperation:(ComprehensiveCutoutView *)cutoutView;

-(void)comprehensiveCutoutViewDidChange:(ComprehensiveCutoutView *)cutoutView;
-(void)comprehensiveCutoutViewWillBeginDraw:(ComprehensiveCutoutView *)cutoutView;
-(void)comprehensiveCutoutViewDidEndDraw:(ComprehensiveCutoutView *)cutoutView;

@end

// new
@interface ComprehensiveCutoutView : UIView

-(ComprehensiveCutoutView *)initWithFrame:(CGRect)frame andImage:(UIImage *)image;

@property (nonatomic, weak) UIView *magnifierParentView;
@property (nonatomic, weak) id<ComprehensiveCutoutViewDelegate> delegate;

@property (nonatomic, readwrite) CutoutMode cutoutMode;
@property (nonatomic, readwrite) SelectionMode selectionMode;

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *selectionColorView;
@property (nonatomic, strong) UIImageView *selectedColorView;
@property (nonatomic, strong) UIImageView *baseSelectedcolorView;

@property (nonatomic, strong) UIColor *maskColor;

// brush & eraser mode
-(CGFloat)brushSmooth;
-(void)setBrushSmooth:(CGFloat)smoothness;

-(CGFloat)brushAlpha;
-(void)setBrushAlpha:(CGFloat)alpha;


@property (readwrite, nonatomic) NSInteger brushRadius;
@property (readwrite, nonatomic) NSInteger refineBrushRadius;

// shape mode
-(void)resetShapeView;
-(void)setShapeImage:(UIImage *)image;
-(void)conformShape;

//
-(CGFloat)drawLineWidth;
-(void)setDrawLineWidth:(CGFloat)lineWidth;

// update size change
-(void)updateForSizeChange;
-(void)setDefaultParaments;
-(void)resetContainer;

// 返回请求类型的图片，按照请求顺序
-(NSArray *)requireImages:(NSArray *)imageTypes withAccurateOn:(BOOL)on;
-(CGRect)getWrapFGImageFrame;
-(CGRect)getWrapFGImageFrameInImageView;

-(UIImage *)getMaskImage;
-(UIImage *)getFixeMaskImage;
-(UIImage *)getShapeMaskImage;

-(void)setMaskImage:(UIImage *)maskImage;
-(void)setMaskImageWithoutSave:(UIImage *)maskImage;
-(void)setFixMaskImage:(UIImage *)fixImage andShapeMaskImage:(UIImage *)shapeImage save:(BOOL)save;

// 是否进行人脸识别，默认开启，开启人脸识别可以帮助人脸眼睛＋嘴巴的扣图，人脸误判时可能将背景误分为前景
@property (readwrite, nonatomic) BOOL faceDetectEnable;

-(void)setLeftEyeRect:(CGRect)leftEye;
-(void)setRightEyeRect:(CGRect)rightEye;
-(void)setMouthRect:(CGRect)mouth;

// 重做撤销
-(void)undo;
-(void)redo;
-(BOOL)canUndo;
-(BOOL)canRedo;

-(void)jumpToLast;
-(void)jumpToFirst;
///
-(void)useHistoryIndex:(NSInteger)idx;
-(void)clearHistoryIndex:(NSInteger)idx;

@end
