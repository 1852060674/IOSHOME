//
//  LayoutCell.m
//  Mahjong
//
//  Created by yysdsyl on 14-11-24.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "LayoutCell.h"

@interface LayoutCell()
{
    UIImageView* layoutImageView;
    UIView* shadowLayer;
    UIImageView* lockImageView;
    UIImageView* star1Image;
    UIImageView* star2Image;
    UIImageView* star3Image;
    //
    BOOL _moveFlag;
}
@end

@implementation LayoutCell

@synthesize layoutid;
@synthesize locked;
@synthesize stars;

- (id)initWithFrame:(CGRect)frame lock:(BOOL)lk stars:(int)st layoutid:(int)idx
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layoutid = idx;
        self.locked = lk;
        self.stars = st;
        //
        CGFloat borderSize = 2;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            borderSize = 4;
        }
        self.backgroundColor = [UIColor whiteColor];
        // Initialization code
        CGRect theframe = CGRectMake(borderSize, borderSize, frame.size.width-2*borderSize, frame.size.height-2*borderSize);
        layoutImageView = [[UIImageView alloc] initWithFrame:theframe];
        layoutImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"layout%d.jpg",self.layoutid]];
        [self addSubview:layoutImageView];
        shadowLayer = [[UIView alloc] initWithFrame:theframe];
        shadowLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.33];
        [self addSubview:shadowLayer];
        lockImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, theframe.size.height*0.4/1.3, theframe.size.height*0.4)];
        lockImageView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        lockImageView.image = [UIImage imageNamed:@"lock"];
        [self addSubview:lockImageView];
        //
        CGFloat starSize = theframe.size.height/3.5;
        CGFloat space = starSize*0.15;
        CGFloat starOffsetX = borderSize+(theframe.size.width-(starSize*3+2*space));
        CGFloat starOffsetY = borderSize+theframe.size.height-starSize;
        star1Image = [[UIImageView alloc] initWithFrame:CGRectMake(starOffsetX, starOffsetY, starSize, starSize)];
        star1Image.image = [UIImage imageNamed:@"star"];
        [self addSubview:star1Image];
        star2Image = [[UIImageView alloc] initWithFrame:CGRectMake(starOffsetX+1*(starSize+space), starOffsetY, starSize, starSize)];
        star2Image.image = [UIImage imageNamed:@"star"];
        [self addSubview:star2Image];
        star3Image = [[UIImageView alloc] initWithFrame:CGRectMake(starOffsetX+2*(starSize+space), starOffsetY, starSize, starSize)];
        star3Image.image = [UIImage imageNamed:@"star"];
        [self addSubview:star3Image];
    }
    return self;
}

- (void)unlockAnim
{
    [UIView animateWithDuration:0.7 animations:^{
        shadowLayer.alpha = 0;
        lockImageView.transform = CGAffineTransformScale(lockImageView.transform, 3, 3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.8 animations:^{
            lockImageView.transform = CGAffineTransformScale(lockImageView.transform, 0.05, 0.05);
        } completion:^(BOOL finished) {
            // zzx
            lockImageView.hidden = NO;
        }];
    }];
}

- (void)updateState
{
    if (self.locked)
    {
        //zzx
        dispatch_async(dispatch_get_main_queue(), ^{
            lockImageView.hidden = NO;
            shadowLayer.hidden = NO;
        });
//        lockImageView.hidden = NO;
//        shadowLayer.hidden = NO;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            lockImageView.hidden = YES;
            shadowLayer.hidden = YES;
        });
//        lockImageView.hidden = YES;
//        shadowLayer.hidden = YES;
    }
    //
    switch (self.stars) {
        case 0:
            star1Image.hidden = YES;
            star2Image.hidden = YES;
            star3Image.hidden = YES;
            break;
        case 1:
            star1Image.hidden = YES;
            star2Image.hidden = YES;
            star3Image.hidden = NO;
            break;
        case 2:
            star1Image.hidden = YES;
            star2Image.hidden = NO;
            star3Image.hidden = NO;
            break;
        case 3:
            star1Image.hidden = NO;
            star2Image.hidden = NO;
            star3Image.hidden = NO;
            break;
        default:
            break;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    _moveFlag = YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _moveFlag = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_moveFlag)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"levelChoose" object:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
