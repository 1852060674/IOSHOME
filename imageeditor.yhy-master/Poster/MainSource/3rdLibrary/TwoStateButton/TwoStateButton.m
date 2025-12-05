//
//  TwoStateButton.m
//  cloneCamera
//
//  Created by ZB_Mac on 14-10-13.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#import "TwoStateButton.h"

@interface TwoStateButton ()
@property (strong, nonatomic) UIImage *state0Image;
@property (strong, nonatomic) UIImage *state1Image;
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation TwoStateButton

@synthesize buttonState=_buttonState;
-(void)setButtonState:(NSUInteger)buttonState
{
    if (buttonState == _buttonState) {
        return;
    }
    switch (buttonState) {
        case 0:
            self.imageView.image = self.state0Image;
            break;
        case 1:
            self.imageView.image = self.state1Image;
            break;
        default:
            break;
    }
    _buttonState = buttonState;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

-(instancetype)initWithFrame:(CGRect)frame andState0Image:(UIImage*)image0 andState1Image:(UIImage *)image1 andContentRatio:(CGFloat)ratio
{
    self = [super initWithFrame:frame];
    if (self) {
        self.zoomEnable = YES;
        self.zoomScale = 0.85;
        self.clipsToBounds = YES;
        
        self.buttonState = 0;
        self.state0Image = image0;
        self.state1Image = image1;
        
        
        CGRect imageFrame = CGRectMake(frame.size.width*(1.0-ratio)/2.0, frame.size.height*(1.0-ratio)/2.0, frame.size.width*ratio, frame.size.height*ratio);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        imageView.image = image0;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        [self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame andState0Image:(UIImage*)image0 andState1Image:(UIImage *)image1
{
    return [self initWithFrame:frame andState0Image:image0 andState1Image:image1 andContentRatio:1.0];
}

-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted) {

        if (self.zoomEnable) {
            [UIView animateWithDuration:0.2 animations:^{
                self.imageView.transform = CGAffineTransformMakeScale(self.zoomScale, self.zoomScale);
            }];
        }
    }
    else
    {
        if (self.zoomEnable){
            [UIView animateWithDuration:0.2 animations:^{
                self.imageView.transform = CGAffineTransformIdentity;
            }];
        }
    }
}

-(void)touchDown:(TwoStateButton *)button
{
    if (self.buttonState == 0) {
        self.buttonState = 1;
    }
    else
    {
        self.buttonState = 0;
    }
}

-(void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    self.alpha = enabled?1.0:0.5;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
