//
//  ForScrollView.m
//  Flow
//
//  Created by yysdsyl on 13-10-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ForScrollView.h"
#import "LevelView.h"

@implementation ForScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = NO;
    }
    return self;
}

/*
- (UIView *) hitTest:(CGPoint) point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        for (id view in [self subviews]) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                return view;
            }
        }
        //return [self.subviews objectAtIndex:0];
    }
    return nil;
}
*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
