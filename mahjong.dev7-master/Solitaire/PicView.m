//
//  PicView.m
//  Solitaire
//
//  Created by apple on 13-7-21.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PicView.h"

@implementation PicView

@synthesize imageView = _imageView;
@synthesize gouView = _gouView;
@synthesize checkFlag = _checkFlag;
@synthesize theid = _theid;
@synthesize type = _type;
@synthesize name = _name;

- (id)initWithFrame:(CGRect)frame border:(CGFloat)border
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGFloat gousize = frame.size.height/5;
        _gouView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - gousize, 0, gousize, gousize)];
        _gouView.image = [UIImage imageNamed:@"gou"];
        _gouView.hidden = NO;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(border, border + gousize/2, frame.size.width - 2*border - gousize/2, frame.size.height - 2*border - gousize/2)];
        [self addSubview:_imageView];
        [self addSubview:_gouView];
        self.backgroundColor = [UIColor clearColor];
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

bool _moveFlag = NO;

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    _moveFlag = YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _moveFlag = NO;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_moveFlag == NO)
    {
        if (self.type == PIC_BACKGROUND) {
            NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
            [settings setObject:_name forKey:@"background"];
            [settings synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSettings" object:@"background"];
        }
        else if (self.type == PIC_CARDBACK)
        {
            NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
            [settings setObject:_name forKey:@"cardback"];
            [settings synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSettings" object:@"cardback"];
        }
    }
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
