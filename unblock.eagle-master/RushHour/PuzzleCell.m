//
//  PuzzleCell.m
//  WordSearch
//
//  Created by apple on 13-8-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PuzzleCell.h"

@implementation PuzzleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)selectEffect
{
    CGFloat dua = 0.1;
    UIColor* oldcolor = self.nameLabel.textColor;
    self.nameLabel.textColor = [UIColor whiteColor];
    [UIView animateWithDuration:dua animations:^{
        self.nameLabel.alpha = 0.8;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:dua animations:^{
            self.nameLabel.alpha = 1;
            self.nameLabel.textColor = oldcolor;
        } completion:^(BOOL finished) {
            self.nameLabel.textColor = oldcolor;
        }];
    }];
}

@end
