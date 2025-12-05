//
//  BlockView.m
//  UnblockMe
//
//  Created by yysdsyl on 13-10-18.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "BlockView.h"
#import "DrawView.h"

#define CAR_NUM 14
#define TRUNK_NUM 6

@interface BlockView()
{
    CGFloat BORDER_WIDTH;
    UIImageView* bodyView;
    UIImageView* oriView;
    UIImageView* opOriView;
}

@end

@implementation BlockView

@synthesize seq;
@synthesize x;
@synthesize y;
@synthesize hor;
@synthesize len;
@synthesize type;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame seq:(int)SEQ x:(int)X y:(int)Y hor:(BOOL)HOR len:(int)LEN type:(BOOL)TYPE
{
    BORDER_WIDTH = 0;
    self.multipleTouchEnabled = NO;
    self = [super initWithFrame:frame];
    if (self) {
        self.seq = SEQ;
        self.x = X;
        self.y = Y;
        self.hor = HOR;
        self.len = LEN;
        self.type = TYPE;
        ///
        self.backgroundColor = [UIColor clearColor];
        bodyView = [[UIImageView alloc] initWithFrame:CGRectMake(BORDER_WIDTH, BORDER_WIDTH, frame.size.width-2*BORDER_WIDTH, frame.size.height-2*BORDER_WIDTH)];
        if (self.type == 1) {
            bodyView.image = [UIImage imageNamed:[NSString stringWithFormat:@"normal_%d_%d_%d",self.hor,self.len,self.type]];
        }
        else
        {
            if (self.len == 2) {
                bodyView.image = [UIImage imageNamed:[NSString stringWithFormat:@"normal_%d_%d_%d_%d",self.hor,self.len,self.type,rand()%CAR_NUM]];
            }
            else
            {
                bodyView.image = [UIImage imageNamed:[NSString stringWithFormat:@"normal_%d_%d_%d_%d",self.hor,self.len,self.type,rand()%TRUNK_NUM]];
            }
        }
        //bodyView.image = [UIImage imageNamed:[NSString stringWithFormat:@"normal_%d_%d_%d",self.hor,self.len,self.type]];
        CGFloat oriWidth = frame.size.width > frame.size.height ? frame.size.height : frame.size.width;
        oriView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, oriWidth, oriWidth)];
        opOriView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, oriWidth, oriWidth)];
        if (self.hor) {
            oriView.image = [UIImage imageNamed:@"left"];
            opOriView.image = [UIImage imageNamed:@"right"];
        }
        else
        {
            oriView.image = [UIImage imageNamed:@"up"];
            opOriView.image = [UIImage imageNamed:@"down"];
        }
        ///
        [self addSubview:bodyView];
        [self addSubview:oriView];
        [self addSubview:opOriView];
        oriView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        opOriView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        oriView.alpha = 0;
        opOriView.alpha = 0;
    }
    return self;
}

- (NSUInteger)hash
{
    return self.seq | (self.y << 8) | (self.x << 16);
}

- (void)moveTopLeft:(int)flag
{
    if (flag == -1) {
        oriView.alpha = 0;
        opOriView.alpha = 0;
    }
    else if (flag == 0)
    {
        oriView.alpha = 0;
        opOriView.alpha = 1;
    }
    else if (flag == 1)
    {
        oriView.alpha = 1;
        opOriView.alpha = 0;
    }
}

#pragma touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    DrawView* dv = (DrawView*)[self superview];
    [dv touchesBegan:touches withEvent:event view:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    DrawView* dv = (DrawView*)[self superview];
    [dv touchesMoved:touches withEvent:event view:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    DrawView* dv = (DrawView*)[self superview];
    [dv touchesEnded:touches withEvent:event view:self];
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
