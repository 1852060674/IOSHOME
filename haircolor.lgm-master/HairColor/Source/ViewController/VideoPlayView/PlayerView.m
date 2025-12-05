//
//  PlayerView.m
//  PhotoBlend
//
//  Created by ZB_Mac on 16/7/6.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>
@implementation PlayerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

-(void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}
@end
