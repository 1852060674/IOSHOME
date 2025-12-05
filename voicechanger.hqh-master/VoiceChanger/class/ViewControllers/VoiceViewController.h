//
//  VoiceViewController.h
//  VoiceChanger
//
//  Created by tangtaoyu on 15/5/27.
//  Copyright (c) 2015年 tangtaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioConvert.h"
#import "Recorder.h"

typedef void (^BackBlock)();

@interface VoiceViewController : UIViewController<AudioConvertDelegate, AVAudioPlayerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, assign) NSInteger voiceTimeLength;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, assign) AudioConvertOutputFormat outputFormat; //输出音频格式
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, copy) BackBlock backBlock;

@property (nonatomic, assign) BOOL isPresent;

@end
