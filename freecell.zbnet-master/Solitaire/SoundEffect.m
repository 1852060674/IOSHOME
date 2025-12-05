//
//  SoundEffect.m
//  Solitaire
//
//  Created by jerry on 2017/8/22.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "SoundEffect.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
@implementation SoundEffect

+ (NSMutableDictionary *)alerts {
  static NSMutableDictionary * d = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    d = [NSMutableDictionary dictionary];
  });
  return d;
}

+ (NSMutableDictionary *)players {
  static NSMutableDictionary * d = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    d = [NSMutableDictionary dictionary];
  });
  return d;
}

+ (void)playSoundEffect:(NSString *)name alert:(BOOL)alert {
  if (alert) {
    NSNumber * num = [self alerts][name];
    if (num) {
      SystemSoundID ssd = (UInt32)[num unsignedIntegerValue];
      AudioServicesPlaySystemSound(ssd);
    } else {
      NSURL *clickQuickUrl = [[NSBundle mainBundle] URLForResource:[name stringByDeletingPathExtension] withExtension:[name pathExtension]];
      SystemSoundID ssd;
      AudioServicesCreateSystemSoundID((__bridge CFURLRef)clickQuickUrl, &ssd);
      [self alerts][name] = [NSNumber numberWithUnsignedInteger:ssd];
      AudioServicesPlaySystemSound(ssd);
    }
  } else {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
      [[AVAudioSession sharedInstance] setActive:YES error:nil];
    });
    AVAudioPlayer * player = [self players][name];
    if (player) {
      player.currentTime = 0;
      [player play];
    } else {
      NSURL *clickQuickUrl = [[NSBundle mainBundle] URLForResource:[name stringByDeletingPathExtension] withExtension:[name pathExtension]];
      NSError * error = nil;
      player = [[AVAudioPlayer alloc] initWithContentsOfURL:clickQuickUrl error:&error];
      if (player) {
        [self players][name] = player;
      }
      player.enableRate = YES;
      if ([player prepareToPlay]) {
        [player play];
      }
    }
  }
}

@end
