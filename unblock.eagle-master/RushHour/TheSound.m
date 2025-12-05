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

static SystemSoundID tapSound = 0;
static SystemSoundID confirmSound = 0;
static SystemSoundID levelupSound = 0;
static SystemSoundID slideSound = 0;
static SystemSoundID coinSound = 0;
static SystemSoundID moveSound = 0;
AVAudioSession *audioSession;
@implementation TheSound

+ (void)playMoveSound
{
    if (![self getCurrentSound]) {
        return;
    }
    if (moveSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"move" withExtension:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &moveSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(moveSound);
    }
}

+ (void)playTapSound
{
    if (![self getCurrentSound]) {
        return;
    }
    if (tapSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"tap" withExtension:@"caf"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &tapSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(tapSound);
    }
}

+ (void)playConfirmSound
{
    if (![self getCurrentSound]) {
        return;
    }
    if (confirmSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"confirmation" withExtension:@"caf"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &confirmSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(confirmSound);
    }
}

+ (void)playLevelUpSound
{
    if (![self getCurrentSound]) {
        return;
    }
    if (levelupSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"level_up" withExtension:@"caf"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &levelupSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(levelupSound);
    }
}

+ (void)playSlideSound
{
    if (![self getCurrentSound]) {
        return;
    }
    if (slideSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"action_menu_slide_in" withExtension:@"caf"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &slideSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(slideSound);
    }
}

+ (void)playCoinSound
{
    if (![self getCurrentSound]) {
        return;
    }
    if (coinSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"coin_pop" withExtension:@"caf"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &coinSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(coinSound);
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
