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

static AVAudioPlayer* clickPlayer = nil;
static AVAudioPlayer* anotherClickPlayer = nil;
static AVAudioPlayer* tapPlayer = nil;
static AVAudioPlayer* shufflePlayer = nil;
static AVAudioPlayer* anotherShufflePlayer = nil;
static AVAudioPlayer* matchPlayer = nil;
static AVAudioPlayer* anotherMatchPlayer = nil;
static AVAudioPlayer* winPlayer = nil;

@implementation TheSound

+ (void)playClickSound
{
    if (clickPlayer == nil)
    {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"tile_click" ofType:@"caf"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        clickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        clickPlayer.numberOfLoops = 0;
    }
    if (anotherClickPlayer == nil)
    {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"tile_click" ofType:@"caf"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        anotherClickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        anotherClickPlayer.numberOfLoops = 0;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        if ([clickPlayer isPlaying])
            [anotherClickPlayer play];
        else
            [clickPlayer play];
    }
    /*
    if (clickSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"tile_click" withExtension:@"caf"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &clickSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(clickSound);
    }
     */
}

+ (void)playTapSound
{
    if (tapPlayer == nil)
    {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"tap" ofType:@"caf"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        tapPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        tapPlayer.numberOfLoops = 0;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        [tapPlayer play];
    }
    /*
    if (tapSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"tap" withExtension:@"caf"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &tapSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(tapSound);
    }
     */
}

+ (void)playShuffleSound
{
    if (shufflePlayer == nil)
    {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"shuffle" ofType:@"wav"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        shufflePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        shufflePlayer.numberOfLoops = 0;
    }
    if (anotherShufflePlayer == nil)
    {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"shuffle" ofType:@"wav"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        anotherShufflePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        anotherShufflePlayer.numberOfLoops = 0;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        if ([shufflePlayer isPlaying])
            [anotherShufflePlayer play];
        else
            [shufflePlayer play];
    }
    /*
    if (shuffleSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"shuffle" withExtension:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &shuffleSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(shuffleSound);
    }
     */
}

+ (void)playMatchSound
{
    if (matchPlayer == nil)
    {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"tile_match" ofType:@"caf"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        matchPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        matchPlayer.numberOfLoops = 0;
    }
    if (anotherMatchPlayer == nil)
    {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"tile_match" ofType:@"caf"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        anotherMatchPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        anotherMatchPlayer.numberOfLoops = 0;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        if ([matchPlayer isPlaying])
            [anotherMatchPlayer play];
        else
            [matchPlayer play];
    }
    /*
    if (matchSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"tile_match" withExtension:@"caf"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &matchSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(matchSound);
    }
     */
}

+ (void)playWinSound
{
    if (winPlayer == nil)
    {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"win" ofType:@"caf"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        winPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        winPlayer.numberOfLoops = 0;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        [winPlayer play];
    }
    /*
    if (winSound == 0) {
        NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"win" withExtension:@"caf"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &winSound);
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        AudioServicesPlaySystemSound(winSound);
    }
     */
}
@end
