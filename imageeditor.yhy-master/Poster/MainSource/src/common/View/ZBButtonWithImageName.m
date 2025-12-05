//
//  ZBButtonWithImageName.m
//  Collage
//
//  Created by shen on 13-6-25.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBButtonWithImageName.h"

@implementation ZBButtonWithImageName
@synthesize imageName = _imageName;
@synthesize templateIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
