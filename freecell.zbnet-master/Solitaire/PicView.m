//
//  PicView.m
//  Solitaire
//
//  Created by apple on 13-7-21.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PicView.h"
#import "ChangeBackgroundViewController.h"

@implementation PicView

@synthesize imageView = _imageView;
@synthesize gouView = _gouView;
@synthesize checkFlag = _checkFlag;
@synthesize theid = _theid;
@synthesize type = _type;

- (id)initWithFrame:(CGRect)frame border:(CGFloat)border
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _gouView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - frame.size.width/4, frame.size.height - frame.size.height/4, frame.size.height/4, frame.size.height/4)];
        _gouView.image = [UIImage imageNamed:@"gou"];
        _gouView.hidden = NO;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(border, border, frame.size.width - 2*border, frame.size.height - 2*border)];
        [self addSubview:_imageView];
        [self addSubview:_gouView];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setImage:(NSString*)imgname custom:(BOOL)flag idx:(NSInteger)idx type:(NSInteger)type
{
    if (flag == NO) {
        self.imageView.image = [UIImage imageNamed:imgname];
    }
    else
    {
        NSString *retinaStr = @"";
        if ([[UIScreen mainScreen] scale] == 2.0) {
            retinaStr = @"@2x";
        }
        self.imageView.image = [UIImage imageWithContentsOfFile:imgname];
    }
    self.theid = idx;
    self.type = type;
}

- (void)setCheck:(BOOL)flag
{
    self.checkFlag = flag;
    self.gouView.hidden = !self.checkFlag;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
   
    if (self.type == PIC_BACKGROUND) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"backgroundpic" object:[NSNumber numberWithInteger:self.theid]];
    }
    else if (self.type == PIC_CARDBACK)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cardbackpic" object:[NSNumber numberWithInteger:self.theid]];
    }
    ///
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.8;
    }];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
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
