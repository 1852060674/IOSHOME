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
        self.imageBottom.alpha = 0.6;
        self.imageStar1.alpha = 0;
        self.imageStar2.alpha = 0;
        self.imageStar3.alpha = 0;
        self.imageStar4.alpha = 0;
        self.imageStar5.alpha = 0;
        self.imageStar6.alpha = 0;
        self.imageStar7.alpha = 0;
        self.imageStar8.alpha = 0;
        self.imageStar9.alpha = 0;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    self.selectionStyle = UITableViewCellSelectionStyleGray;
}

- (void)setTime:(NSInteger)time
{
    if (time > 0) {
        self.imageBottom.alpha = 1;
        self.imageStar1.alpha = 0;
        self.imageStar2.alpha = 0;
        self.imageStar3.alpha = 0;
        self.imageStar4.alpha = 0;
        self.imageStar5.alpha = 0;
        self.imageStar6.alpha = 0;
        self.imageStar7.alpha = 0;
        self.imageStar8.alpha = 0;
        self.imageStar9.alpha = 0;
        if (time < 25) {
            self.imageStar3.alpha = 1;
            self.imageStar6.alpha = 1;
            self.imageStar9.alpha = 1;
        }
        else if (time < 50)
        {
            self.imageStar3.alpha = 1;
            self.imageStar6.alpha = 1;
            self.imageStar8.alpha = 1;
        }
        else if (time < 75)
        {
            self.imageStar3.alpha = 1;
            self.imageStar6.alpha = 1;
            self.imageStar7.alpha = 1;
        }
        else if (time < 100)
        {
            self.imageStar3.alpha = 1;
            self.imageStar6.alpha = 1;
        }
        else if (time < 125)
        {
            self.imageStar3.alpha = 1;
            self.imageStar5.alpha = 1;
        }
        else if (time < 150)
        {
            self.imageStar3.alpha = 1;
            self.imageStar4.alpha = 1;
        }
        else if (time < 175)
        {
            self.imageStar3.alpha = 1;
        }
        else if (time < 200)
        {
            self.imageStar2.alpha = 1;
        }
        else if (time < 225)
        {
            self.imageStar1.alpha = 1;
        }
    }
    else
    {
        self.imageBottom.alpha = 0.6;
        self.imageStar1.alpha = 0;
        self.imageStar2.alpha = 0;
        self.imageStar3.alpha = 0;
        self.imageStar4.alpha = 0;
        self.imageStar5.alpha = 0;
        self.imageStar6.alpha = 0;
        self.imageStar7.alpha = 0;
        self.imageStar8.alpha = 0;
        self.imageStar9.alpha = 0;
    }
}

@end
