//
//  CharView.m
//  WordSearch
//
//  Created by apple on 13-8-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "CharView.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "DrawView.h"


@interface CharView ()
{
    UILabel* charLabel;
    CGFloat BOUNCE_HEIGHT;
}
@end

@implementation CharView

@synthesize col;
@synthesize row;
@synthesize c;

- (id)initWithFrame:(CGRect)frame theChar:(char)theChar row:(int)rowIdx col:(int)colIdx
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        charLabel = [[UILabel alloc] initWithFrame:frame];
        charLabel.text = [NSString stringWithFormat:@"%c",theChar];
        charLabel.textAlignment = UITextAlignmentCenter;
        //charLabel.font = [UIFont fontWithName:@"Helvetica-Bold"  size:25];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            BOUNCE_HEIGHT = 8;
            charLabel.font = [UIFont fontWithName:@"Helvetica"  size:35];
        }
        else
        {
            BOUNCE_HEIGHT = 4;
            charLabel.font = [UIFont fontWithName:@"Helvetica"  size:20];
        }
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        charLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.row = rowIdx;
        self.col = colIdx;
        self.c = theChar;
        [self addSubview:charLabel];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)bounce
{
    CGPoint targetCenter = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [UIView animateWithDuration:0.1 animations:^(void){
        charLabel.center = CGPointMake(targetCenter.x, targetCenter.y-BOUNCE_HEIGHT);
    }completion:^(BOOL finished){
        CALayer *layer= [charLabel layer];
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:0.750] forKey:kCATransactionAnimationDuration];
        CAAnimation *chase = [CAKeyframeAnimation animationWithKeyPath:@"position" function:BounceEaseOut fromPoint:charLabel.center toPoint:targetCenter];
        [chase setDelegate:self];
        [layer addAnimation:chase forKey:@"position"];
        [CATransaction commit];
        [charLabel setCenter:targetCenter];
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //DrawView *parentView = (DrawView *) [self superview];
    //[parentView touchesEnded:touches withEvent:event withCharView:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //DrawView *parentView = (DrawView *) [self superview];
    //[parentView touchesBegan:touches withEvent:event withCharView:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //DrawView *parentView = (DrawView *) [self superview];
    //[parentView touchesCancelled:touches withEvent:event withCharView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //DrawView *parentView = (DrawView *) [self superview];
    //[parentView touchesMoved:touches withEvent:event withCharView:self];
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
