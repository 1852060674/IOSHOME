//
//  LevelView.m
//  Flow
//
//  Created by yysdsyl on 13-10-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "LevelView.h"
#import "Common.h"

//#define BORDER_WIDTH 2
//#define SPACE_WIDTH 2

@interface LevelView()
{
    CGFloat BORDER_WIDTH;
    CGFloat SPACE_WIDTH;
}

@end

@implementation LevelView

@synthesize type;
@synthesize no;
@synthesize state;
@synthesize coloridx;
@synthesize leftBorder;
@synthesize rightBorder;
@synthesize upBorder;
@synthesize downBorder;
@synthesize bkView;
@synthesize perfectImage;
@synthesize passedImage;
@synthesize lockedImage;
@synthesize noLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame theType:(int)theType theNo:(int)theNo theState:(int)theState color:(int)color
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        BORDER_WIDTH = 4;
        SPACE_WIDTH = 4;
    }
    else
    {
        BORDER_WIDTH = 2;
        SPACE_WIDTH = 2;
    }
    self = [super initWithFrame:frame];
    if (self) {
        CGRect theframe = CGRectMake(SPACE_WIDTH, SPACE_WIDTH, frame.size.width-2*SPACE_WIDTH, frame.size.height-2*SPACE_WIDTH);
        self.type = theType;
        self.no = theNo;
        self.state = theState;
        self.coloridx = color;
        ///
        self.backgroundColor = [UIColor clearColor];
        ///
        self.perfectImage = [[UIImageView alloc] initWithFrame:theframe];
        self.perfectImage.image = [UIImage imageNamed:@"perfect"];
        self.perfectImage.alpha = 0;
        self.passedImage = [[UIImageView alloc] initWithFrame:theframe];
        self.passedImage.image = [UIImage imageNamed:@"passed"];
        self.passedImage.alpha = 0;
        self.lockedImage = [[UIImageView alloc] initWithFrame:theframe];
        self.lockedImage.image = [UIImage imageNamed:@"locked"];
        self.lockedImage.alpha = 0;
        self.noLabel = [[UILabel alloc] initWithFrame:theframe];
        self.noLabel.text = [NSString stringWithFormat:@"%d",self.no];
        self.noLabel.textAlignment = UITextAlignmentCenter;
        self.noLabel.font = [UIFont fontWithName:@"Helvetica" size:theframe.size.height*1/2];
        self.noLabel.backgroundColor = [UIColor clearColor];
        self.noLabel.textColor = [UIColor whiteColor];
        ///
        UIColor* cl = [Common colors:self.coloridx];
        /*
        self.leftBorder = [[UIView alloc] initWithFrame:CGRectMake(SPACE_WIDTH, SPACE_WIDTH, BORDER_WIDTH, theframe.size.height)];
        self.leftBorder.backgroundColor = cl;
        self.rightBorder = [[UIView alloc] initWithFrame:CGRectMake(theframe.size.width, SPACE_WIDTH, BORDER_WIDTH, theframe.size.height)];
        self.rightBorder.backgroundColor = cl;
        self.upBorder = [[UIView alloc] initWithFrame:CGRectMake(SPACE_WIDTH, SPACE_WIDTH, theframe.size.width, BORDER_WIDTH)];
        self.upBorder.backgroundColor = cl;
        self.downBorder = [[UIView alloc] initWithFrame:CGRectMake(SPACE_WIDTH, theframe.size.height, theframe.size.width, BORDER_WIDTH)];
        self.downBorder.backgroundColor = cl;
         */
        self.bkView = [[UIImageView alloc] initWithFrame:theframe];
        //self.bkView.backgroundColor = cl;
        self.bkView.image = [UIImage imageNamed:@"tile"];
        //self.bkView.alpha = 0;
        ///
        [self addSubview:self.bkView];
        [self addSubview:self.lockedImage];
        [self addSubview:self.passedImage];
        [self addSubview:self.perfectImage];
        [self addSubview:self.noLabel];
        //[self addSubview:self.leftBorder];
        //[self addSubview:self.rightBorder];
        //[self addSubview:self.upBorder];
        //[self addSubview:self.downBorder];
        ///
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)updateDisplay
{
    switch (self.state) {
        case LEVEL_STATE_OPEN:
            self.lockedImage.alpha = 0;
            self.passedImage.alpha = 0;
            self.perfectImage.alpha = 0;
            break;
        case LEVEL_STATE_LOCKED:
            self.lockedImage.alpha = 0.5;
            self.passedImage.alpha = 0;
            self.perfectImage.alpha = 0;
            break;
        case LEVEL_STATE_PASSED:
            self.lockedImage.alpha = 0;
            self.passedImage.alpha = 0.5;
            self.perfectImage.alpha = 0;
            break;
        case LEVEL_STATE_PERFECT:
            self.lockedImage.alpha = 0;
            self.passedImage.alpha = 0;
            self.perfectImage.alpha = 0.5;
            break;
        default:
            break;
    }
}

- (void)tapEffect
{
    self.bkView.alpha = 0;
    [UIView animateWithDuration:0.1 animations:^{
        self.bkView.alpha = 1;
    } completion:^(BOOL finished) {
        self.bkView.alpha = 1;
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.bkView.alpha = 0;
    [UIView animateWithDuration:0.1 animations:^{
        self.bkView.alpha = 1;
    } completion:^(BOOL finished) {
        if (((UITouch*)[touches anyObject]).tapCount == 1)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"leveltap" object:self];
    }];
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
