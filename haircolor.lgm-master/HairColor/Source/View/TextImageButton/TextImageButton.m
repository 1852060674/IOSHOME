//
//  TextImageButton.m
//  HairColorNew
//
//  Created by ZB_Mac on 16/8/26.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "TextImageButton.h"

@interface TextImageButton ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, readwrite) CGFloat padding;
@end

@implementation TextImageButton

-(TextImageButton *)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.padding = 4;
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.label];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imageView];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

-(void)setText:(NSString *)text;
{
    self.label.text = text;
    [self setNeedsLayout];
}
-(NSString *)getText;
{
    return self.label.text;
}
-(void)setTextColor:(UIColor *)textColor;
{
    self.label.textColor = textColor;
}

-(void)setImage:(UIImage *)image;
{
    self.imageView.image = image;
}
-(UIImage *)getImage
{
    return self.imageView.image;
}

-(void)rotateImageUp:(BOOL)up animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.imageView.transform = up?CGAffineTransformIdentity:CGAffineTransformMakeRotation(M_PI);
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, M_PI);
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat imageViewSize = self.imageView.image?CGRectGetHeight(self.bounds)*0.33:0;
    NSInteger paddingCnt = self.imageView.image?3:2;
    
    self.label.font = [UIFont systemFontOfSize:CGRectGetHeight(self.bounds)*0.30];
    CGSize fitSize = [self.label sizeThatFits:CGSizeMake(CGRectGetWidth(self.bounds)-self.padding*paddingCnt-imageViewSize*2, CGRectGetHeight(self.bounds))];
    fitSize.width = MIN(CGRectGetWidth(self.bounds)-self.padding*paddingCnt-imageViewSize*2, fitSize.width);
    self.label.bounds = CGRectMake(0, 0, fitSize.width, fitSize.height);
    self.label.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    self.imageView.bounds = CGRectMake(0, 0, imageViewSize, imageViewSize);
    self.imageView.center = CGPointMake(CGRectGetMaxX(self.label.frame)+self.padding+imageViewSize*0.5, self.label.center.y);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
