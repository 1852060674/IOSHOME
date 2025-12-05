//
//  TopCell.m
//  Solitaire
//
//  Created by IOS2 on 2024/2/7.
//  Copyright © 2024 apple. All rights reserved.
//

#import "TopCell.h"

@implementation TopCell

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
    frame.size.width -= 40;
    frame.origin.y = 500;
    [super setFrame:frame];
}
@end
