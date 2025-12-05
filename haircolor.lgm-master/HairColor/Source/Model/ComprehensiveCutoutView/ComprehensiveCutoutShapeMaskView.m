//
//  ComprehensiveCutoutMaskView.m
//  CutMeIn
//
//  Created by ZB_Mac on 16/6/24.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "ComprehensiveCutoutShapeMaskView.h"
#import "UIImage+vImage.h"
#import "UIImage+Rotation.h"
#import "Masonry.h"

@interface ComprehensiveCutoutShapeMaskView ()
{
    UIImage *_shapeMaskImage;
    
    BOOL _everUpdate;
}
@end

@implementation ComprehensiveCutoutShapeMaskView

-(ComprehensiveCutoutShapeMaskView *)initWithFrame:(CGRect)frame andImageWidth:(NSInteger)imageWidth andImageHeight:(NSInteger)imageHeight
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _imageWidth = imageWidth;
        _imageHeight = imageHeight;
        
        _shapeMaskImageView = [[UIImageView alloc] init];
        _shapeMaskImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_shapeMaskImageView];
//        [_shapeMaskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.bottom.top.equalTo(self);
//        }];
    }
    
    return self;
}
-(void)zoomByScale:(CGFloat)scale
{
    _shapeMaskImageView.transform = CGAffineTransformScale(_shapeMaskImageView.transform, scale, scale);
}
-(void)rotateByAngle:(CGFloat)angle
{
    _shapeMaskImageView.transform = CGAffineTransformRotate(_shapeMaskImageView.transform, angle);
}
-(void)translateByOffset:(CGPoint)offset;
{
    CGPoint center = _shapeMaskImageView.center;
    center.x += offset.x;
    center.y += offset.y;
    
    _shapeMaskImageView.center = center;
    
//    _shapeMaskImageView.transform = CGAffineTransformTranslate(_shapeMaskImageView.transform, offset.x, offset.y);

}

#pragma mark - public

-(UIImage *)getMaskImage
{
    return [_shapeMaskImage resizeImageToSize:CGSizeMake(_imageWidth, _imageHeight)];
}

-(UIImage *)getShapeMaskImage
{
    return _shapeMaskImage;
}
-(void)setShapeMaskImage:(UIImage *)image
{
    _shapeMaskImage = image;
    _shapeMaskImageView.image = image;
}

-(void)resetShapeView
{
    _shapeMaskImageView.transform = CGAffineTransformIdentity;
    _shapeMaskImageView.frame = self.bounds;
}

#pragma mark -
-(void)updateContextSize
{
    CGAffineTransform transform = _shapeMaskImageView.transform;

    if (!_everUpdate) {
        _shapeMaskImageView.frame = self.bounds;
    }
    else
    {
        _shapeMaskImageView.bounds = self.bounds;
    }

    if (!CGRectIsEmpty(self.bounds)) {
        _everUpdate = YES;
    }
    
    _shapeMaskImageView.transform = transform;
}

@end
