//
//  Soubdutton.h
//  why you lying
//
//  Created by awt on 15/10/25.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
@protocol SoundButtonDelegate <NSObject>
- (void) beginAnimation;
- (void) stopAnimationWithResult: (BOOL) isTrueOrFalse;

@end

@interface  Soubdutton : UIImageView

@property (nonatomic,strong) AVAudioRecorder *recorder;
@property (nonatomic,weak) id<SoundButtonDelegate> soundDelegate;

- (double) getCerrentVolume;
@end
