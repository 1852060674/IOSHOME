//
//  MGVoice.h
//  SpeakToText
//
//  Created by tangtaoyu on 15/5/27.
//  Copyright (c) 2015年 tangtaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#define kTipsMicroPhone    @"This app requires access to your device's Microphone.\n\nPlease enable Microphone access for this app in Settings > Privacy > Microphone"

@interface MGVoice : NSObject

+ (BOOL)AccessToMicroPhone;

@end
