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
static SystemSoundID tapSound = 0;
static SystemSoundID confirmSound = 0;
static SystemSoundID levelupSound = 0;
static SystemSoundID slideSound = 0;
static SystemSoundID coinSound = 0;
AVAudioSession *audioSession;
@implementation TheSound

+ (void)playTapSound
{
    if (![[TheSound sharedSound]getCurrentSound])
        return;
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
    if (![[TheSound sharedSound]getCurrentSound])
        return;
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
    if (![[TheSound sharedSound]getCurrentSound])
        return;
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
    if (![[TheSound sharedSound]getCurrentSound])
        return;
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
    if (![[TheSound sharedSound]getCurrentSound])
        return;
    if (coinSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"coin_pop" withExtension:@"caf"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &coinSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(coinSound);
    }
}

- (BOOL)getCurrentSound{
    //    获取当前音量
    CGFloat volume = audioSession.outputVolume;
    NSLog(@"view volume=  %lf",volume);
    if (volume*100 < 1) {
        return FALSE;
    }else{
        return TRUE;
    }
}
+ (instancetype)sharedSound {
    static TheSound *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:YES error:nil];
    });
    return sharedInstance;
}

@end
