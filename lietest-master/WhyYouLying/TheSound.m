
//
//  TheSound.m
//  why you lying
//
//  Created by awt on 15/10/25.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import "TheSound.h"

#import <AudioToolbox/AudioToolbox.h>

static SystemSoundID tapSound = 0;
static SystemSoundID confirmSound = 0;
static SystemSoundID levelupSound = 0;
static SystemSoundID slideSound = 0;


@implementation TheSound

+ (void)playTrueAdultSound
{
    if (tapSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"t_a" withExtension:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &tapSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(tapSound);
    }
}

+ (void)playFalseAdultSound
{
    if (confirmSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"l_a" withExtension:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &confirmSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(confirmSound);
    }
}

+ (void)playTrueChildSound
{
    if (levelupSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"t_c" withExtension:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &levelupSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(levelupSound);
    }
}

+ (void)playFalseChidSound
{
    if (slideSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"l_c" withExtension:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &slideSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(slideSound);
    }
}
//
//+ (void)playCoinSound
//{
//    if (coinSound == 0) {
//        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"coin_pop" withExtension:@"caf"];
//        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &coinSound);
//    }
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
//        AudioServicesPlaySystemSound(coinSound);
//    }
//}
@end
