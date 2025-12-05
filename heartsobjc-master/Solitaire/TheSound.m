//
//  TheSound.m
//  WordSearch
//
//  Created by apple on 13-8-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "TheSound.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
static SystemSoundID collectSound = 0;
static SystemSoundID dealSound = 0;
static SystemSoundID brokenSound = 0;
static SystemSoundID spadeSound = 0;
AVAudioSession *audioSession;
@implementation TheSound

+ (void)playCollectSound
{
    if (![self getCurrentSound]) {
        return;
    }
    if (collectSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"play" withExtension:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &collectSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(collectSound);
    }
}

+ (void)playDealSound
{
    if (![self getCurrentSound]) {
        return;
    }
    if (dealSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"deal" withExtension:@"aif"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &dealSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(dealSound);
    }
}

+ (void)playBrokenSound
{
    if (![self getCurrentSound]) {
        return;
    }
    if (brokenSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"broken" withExtension:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &brokenSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(brokenSound);
    }
}

+ (void)playSpadeSound
{
    if (![self getCurrentSound]) {
        return;
    }
    if (spadeSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"spade" withExtension:@"aif"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &spadeSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(spadeSound);
    }
}



+ (BOOL)getCurrentSound{
    //    获取当前音量
    audioSession= [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    CGFloat volume = audioSession.outputVolume;
    NSLog(@"view volume=  %lf",volume);
    if (volume*100 < 1) {
        return FALSE;
    }else{
        return TRUE;
    }
}
@end
