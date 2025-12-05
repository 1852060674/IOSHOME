//
//  VideoPlayCell.m
//  CutMeIn
//
//  Created by ZB_Mac on 16/8/8.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "VideoPlayCell.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayerView.h"

@implementation VideoPlayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    AVPlayerLayer *layer = (AVPlayerLayer *)_playerView.layer;
    layer.videoGravity=AVLayerVideoGravityResizeAspect;
}

-(void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

@end
