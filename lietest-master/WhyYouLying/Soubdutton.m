//
//  Soubdutton.m
//  why you lying
//
//  Created by awt on 15/10/25.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import "Soubdutton.h"

@implementation Soubdutton

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setUserInteractionEnabled:YES];
    [self setImage:[UIImage imageNamed:@"fingeImage2"]];
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax], AVEncoderAudioQualityKey,
                              nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    NSError *error;
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    AVAudioRecorder* recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    [recorder prepareToRecord];
    [recorder setMeteringEnabled:YES];
    [self setRecorder:recorder];
//    [self setBackgroundColor:[UIColor redColor]];
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touches anyObject];
    [self.recorder record];

    [self.soundDelegate beginAnimation];
    [self setImage:[UIImage imageNamed:@"fingerImage"]];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.recorder deleteRecording];
    [self.recorder stop];
    [self setImage:[UIImage imageNamed:@"fingeImage2"]];
    BOOL isTure;
    if (arc4random()%2 == 1) {
        isTure = YES;
    }
    else{
        isTure = NO;
    }
    [self setUserInteractionEnabled:NO];
    [self.soundDelegate stopAnimationWithResult:isTure];
    
}

- (double) getCerrentVolume
{
    [self.recorder updateMeters];
    //  const double ALPHA = 1.0; // 0.05f
    double peakPowerForChannel = pow(10, (0.05*[self.recorder peakPowerForChannel:0]));
    NSLog(@" volume is %f",peakPowerForChannel);
    return peakPowerForChannel;
}

@end
