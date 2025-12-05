//
//  TwoStateButtonWithTitle.m
//  EyeColor4.0
//
//  Created by ZB_Mac on 15-1-20.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "TwoStateButtonWithTitle.h"

@interface TwoStateButtonWithTitle ()

@property (strong, nonatomic) UIView *state0View;
@property (strong, nonatomic) UIView *state1View;
@end

@implementation TwoStateButtonWithTitle

@synthesize buttonState=_buttonState;
-(void)setButtonState:(NSUInteger)buttonState
{
    switch (buttonState) {
        case 0:
            self.state0View.hidden = NO;
            self.state1View.hidden = YES;
            break;
        case 1:
            self.state0View.hidden = YES;
            self.state1View.hidden = NO;
            break;
        default:
            break;
    }
    if (buttonState == _buttonState) {
        return;
    }
    _buttonState = buttonState;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

-(instancetype)initWithFrame:(CGRect)frame
              andState0Image:(UIImage*)image0
              andState1Image:(UIImage *)image1
                   andTitle0:(NSString*)title0
                   andTitle1:(NSString *)title1
             andTitle0Insets:(UIEdgeInsets)title0Insets
             andTitle1Insets:(UIEdgeInsets)title1Insets
              andTitle0Color:(UIColor *)color0
              andTitle1Color:(UIColor *)color1
             andContentRatio:(CGFloat)ratio
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        CGRect viewFrame = CGRectMake(frame.size.width*(1.0-ratio)/2.0, frame.size.height*(1.0-ratio)/2.0, frame.size.width*ratio, frame.size.height*ratio);
        self.state0View = [[UIView alloc] initWithFrame:viewFrame];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.state0View.bounds];
        imageView.image = [image0 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        imageView.tintColor = color0;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.state0View addSubview:imageView];
        UILabel *label = [[UILabel alloc] initWithFrame:UIEdgeInsetsInsetRect(self.state0View.bounds, title0Insets)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:CGRectGetHeight(label.bounds) * 0.5];
        label.textColor = color0;
        label.text = title0;
        label.backgroundColor = [UIColor clearColor];
        [self.state0View addSubview:label];
        [self addSubview:self.state0View];
        self.state0View.userInteractionEnabled = NO;
        
        self.state1View = [[UIView alloc] initWithFrame:viewFrame];
        imageView = [[UIImageView alloc] initWithFrame:self.state1View.bounds];
        imageView.image = [image1 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        imageView.tintColor = color1;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.state1View addSubview:imageView];
        label = [[UILabel alloc] initWithFrame:UIEdgeInsetsInsetRect(self.state1View.bounds, title1Insets)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:CGRectGetHeight(label.bounds) * 0.5];
        label.textColor = color1;
        label.text = title1;
        label.backgroundColor = [UIColor clearColor];
        [self.state1View addSubview:label];
        [self addSubview:self.state1View];
        self.state1View.userInteractionEnabled = NO;

        [self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchUpInside];
        
        self.zoomEnable = YES;
        self.zoomScale = 0.85;
        self.buttonState = 0;
    }
    return self;
}

-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        
        if (self.zoomEnable) {
            [UIView animateWithDuration:0.2 animations:^{
                self.transform = CGAffineTransformMakeScale(self.zoomScale, self.zoomScale);
            }];
        }
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
    }
}

-(void)touchDown:(TwoStateButtonWithTitle *)button
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
