//
//  SwitchCell.m
//  Solitaire
//
//  Created by apple on 13-6-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SwitchCell.h"

@implementation SwitchCell

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
}
- (void)setFrame:(CGRect)frame{
//    frame.origin.x += 20;
//    frame.size.width -= 40;
    frame.origin.y += 20;
    [super setFrame:frame];
}
@end
