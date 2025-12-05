//
//  HomeViewController.h
//  VoiceChanger
//
//  Created by tangtaoyu on 15/5/25.
//  Copyright (c) 2015年 tangtaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface HomeViewController : UIViewController<AVAudioPlayerDelegate>
{
    AVAudioPlayer *audioPalyer;
}

@end
