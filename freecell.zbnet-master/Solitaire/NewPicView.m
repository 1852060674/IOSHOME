//
//  NewPicView.m
//  Canfield
//
//  Created by macbook on 14/12/8.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NewPicView.h"

@interface NewPicView ()
{
    BOOL moveFlag;
}
@end

@implementation NewPicView

- (id)initWithFrame:(CGRect)frame imgName:(NSString *)imgname custom:(BOOL)flag idx:(NSInteger)idx type:(NSInteger)t
{
    if ([super initWithFrame:frame]) {
        CGFloat borderRate = 0.1;
        self.theid = idx;
        self.type = t;
        self.selected = NO;
        self.shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.shadowView.image = [UIImage imageNamed:@"selected"];
        self.shadowView.hidden = YES;
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width*borderRate, frame.size.height*borderRate, frame.size.width-2*frame.size.width*borderRate, frame.size.height-2*frame.size.height*borderRate)];
        if (flag == NO) {
            if (self.type == kPicTypeGameBack) {
                self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",imgname]];
            }
            else
                self.imageView.image = [UIImage imageNamed:imgname];
        }
        else{
            NSString *retinaStr = @"";
            if ([[UIScreen mainScreen] scale] == 2.0) {
                retinaStr = @"@2x";
            }
            self.imageView.image = [UIImage imageWithContentsOfFile:imgname];
        }
        [self addSubview:self.shadowView];
        [self addSubview:self.imageView];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected{
    _selected = selected;
    //self.shadowView.hidden = !self.selected;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    moveFlag = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (!moveFlag) {
        if (self.type == kPicTypeGameBack) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changebg" object:[NSNumber numberWithInteger:self.theid]];
        }
        else if (self.type == kPicTypeCardBack)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changebk" object:[NSNumber numberWithInteger:self.theid]];
        }
        else if (self.type == kPicTypeCardForground)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changecf" object:[NSNumber numberWithInteger:self.theid]];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    moveFlag = YES;
}

- (void)hideShadow:(BOOL)willHide{
    self.shadowView.hidden = willHide;
}

@end
