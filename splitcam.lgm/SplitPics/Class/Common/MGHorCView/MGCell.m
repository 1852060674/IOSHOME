//
//  MGCell.m
//  FunFace
//
//  Created by tangtaoyu on 15-2-5.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "MGCell.h"
#import "MGDefine.h"

@implementation MGCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self widgetsInit];
    }
    return self;
}

- (void)widgetsInit
{
    self.imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    
    float labelH = (kH(self.contentView) > kW(self.contentView)) ? kW(self.contentView) : kH(self.contentView);
    labelH = labelH*3/7;
    self.indexlabel = [[UILabel alloc] init];
    self.indexlabel.frame = CGRectMake(kW(self.contentView)-labelH, kH(self.contentView)-labelH, labelH, labelH);
    self.indexlabel.textAlignment = NSTextAlignmentCenter;
    self.indexlabel.textColor = [UIColor whiteColor];
    self.indexlabel.font = [UIFont systemFontOfSize:10];
    self.indexlabel.backgroundColor = [UIColor orangeColor];
    self.indexlabel.text = @"";
    [self addSubview:self.indexlabel];
    
    self.layer.borderWidth = 2.0;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}

- (void)setIndex:(NSInteger)newValue
{
    _index = newValue;
    self.indexlabel.text = [NSString stringWithFormat:@"%i", (int)newValue];
    
    if(newValue == 0){
        self.indexlabel.hidden = YES;
    }else{
        self.indexlabel.hidden = NO;
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if(selected){
        self.layer.borderColor = [UIColor orangeColor].CGColor;
    }else{
        self.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

- (void)selectedBorder:(BOOL)isSelected
{
    if(isSelected)
        self.layer.borderColor = [UIColor orangeColor].CGColor;
    else
        self.layer.borderColor = [UIColor whiteColor].CGColor;
}


@end
