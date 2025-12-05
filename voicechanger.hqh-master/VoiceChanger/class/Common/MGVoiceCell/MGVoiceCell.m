//
//  MGVoiceCell.m
//  VoiceChanger
//
//  Created by tangtaoyu on 15/5/25.
//  Copyright (c) 2015年 tangtaoyu. All rights reserved.
//

#import "MGVoiceCell.h"
#import "MGDefine.h"

@implementation MGVoiceCell

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        _durationLabel.font = [UIFont systemFontOfSize:15.];
        
        [self.contentView addSubview:_durationLabel];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat textWidth = 30.;
    CGFloat textHeight = 30.;
    _durationLabel.frame = CGRectMake(kW(self.contentView)-textWidth, kY(self.contentView)+(kH(self.contentView)-textHeight)/2., textWidth, textHeight);
}

@end
