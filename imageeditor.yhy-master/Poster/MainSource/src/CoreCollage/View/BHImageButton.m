//
//  BHImageButton.m
//  PicFrame
//
//  Created by shen on 13-6-19.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import "BHImageButton.h"

@interface BHImageButton()
{
     CGPoint _startPoint;
}

@end

@implementation BHImageButton

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    _startPoint = locationPoint;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray * touchesArr=[[event allTouches] allObjects];
    
    if ([touchesArr count] == 1)
    {
//        CGPoint pt = [[touches anyObject] locationInView:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray * touchesArr=[[event allTouches] allObjects];
    
    if ([touchesArr count] == 1)
    {
        CGPoint pt = [[touches anyObject] locationInView:self];
        if (pt.x == _startPoint.x && pt.y == _startPoint.y) {
            //执行button的点击功能
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickButton:)]) {
                [self.delegate clickButton:self];
            }
        }
    }
}


@end
