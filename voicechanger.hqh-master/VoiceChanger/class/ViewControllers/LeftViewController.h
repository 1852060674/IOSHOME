//
//  LeftViewController.h
//  VoiceChanger
//
//  Created by tangtaoyu on 15/5/25.
//  Copyright (c) 2015年 tangtaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioConvert.h"
#import "Recorder.h"

@interface LeftViewController : UIViewController<AudioConvertDelegate, AVAudioPlayerDelegate>

@end
