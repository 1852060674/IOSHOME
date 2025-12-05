//
//  MGVoice.m
//  SpeakToText
//
//  Created by tangtaoyu on 15/5/27.
//  Copyright (c) 2015年 tangtaoyu. All rights reserved.
//

#import "MGVoice.h"

@implementation MGVoice


+ (BOOL)AccessToMicroPhone
{
    __block BOOL bCanRecord = YES;

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                bCanRecord = YES;
            } else {
                bCanRecord = NO;
            }
        }];
    }
    
    return bCanRecord;
}

@end
