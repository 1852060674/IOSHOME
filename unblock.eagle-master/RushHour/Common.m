//
//  Common.m
//  Flow
//
//  Created by yysdsyl on 13-10-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "Common.h"
#import "Config.h"

@implementation Common

+ (UIColor*)colors:(int)idx
{
    UIColor* color;
    if (idx < 0) {
        return [UIColor blackColor];
    }
    switch (idx) {
        case 0:
            color = [UIColor redColor];
            break;
        case 1:
            color = [UIColor yellowColor];
            break;
        case 2:
            color = [UIColor blueColor];
            break;
        case 3:
            color = [UIColor greenColor];
            break;
        case 4:
            color = [UIColor cyanColor];
            break;
        case 5:
            color = [UIColor brownColor];
            break;
        case 6:
            color = [UIColor orangeColor];
            break;
        case 7:
            color = [UIColor magentaColor];
            break;
        case 8:
            color = RGB(0x00, 0x53, 0x44, 1);
            break;
        case 9:
            color = RGB(0xcd, 0xe6, 0xc7, 1);
            break;
        case 10:
            color = RGB(0xde, 0xab, 0x8a, 1);
            break;
        case 11:
            color = RGB(0xbe, 0xd7, 0x42, 1);
            break;
        case 12:
            color = RGB(0x80, 0x75, 0x2c, 1);
            break;
        case 13:
            color = RGB(0xea, 0x66, 0xa6, 1);
            break;
        case 14:
            color = RGB(0xb6, 0x45, 0x33, 1);
            break;
        case 15:
            color = RGB(0xef, 0x5b, 0x9c, 1);
            break;
        case 16:
            color = RGB(0x90, 0x5a, 0x3d, 1);
            break;
        case 17:
            color = [UIColor whiteColor];
            break;
        default:
            break;
    }
    return color;
}

+ (CAEmitterLayer *)emitter
{
    CAEmitterLayer *particalEmitter = nil;
    if (particalEmitter == nil) {
        // Configure the particle emitter to the top edge of the screen
        particalEmitter = [CAEmitterLayer layer];
        particalEmitter.emitterPosition = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2.0, -30);
        particalEmitter.emitterSize = CGSizeMake([[UIScreen mainScreen] bounds] .size.width * 2.0, 0.0);;
        // Spawn points for the flakes are within on the outline of the line
        particalEmitter.emitterMode		= kCAEmitterLayerOutline;
        particalEmitter.emitterShape	= kCAEmitterLayerLine;
        // Make the flakes seem inset in the background
        particalEmitter.shadowOpacity = 1.0;
        particalEmitter.shadowRadius  = 0.0;
        particalEmitter.shadowOffset  = CGSizeMake(0.0, 1.0);
        particalEmitter.shadowColor   = [[UIColor clearColor] CGColor];
        // Configure the flake emitter cell
        CAEmitterCell *flake1 = [CAEmitterCell emitterCell];
        flake1.birthRate	= 1.0;
        flake1.lifetime		= 120.0;
        flake1.scale = 0.2;
        flake1.velocity		= 10;				// falling down slowly
        flake1.velocityRange = 10;
        flake1.yAcceleration = 2;
        flake1.emissionRange = 0.5 * M_PI;		// some variation in angle
        flake1.spinRange		= 0.25 * M_PI;		// slow spin
        flake1.contents		= (id) [[UIImage imageNamed:@"partical"] CGImage];
        flake1.color			= [[UIColor colorWithRed:1 green:0 blue:0 alpha:0.2] CGColor];
        CAEmitterCell *flake2 = [CAEmitterCell emitterCell];
        flake2.birthRate		= 1.0;
        flake2.lifetime		= 80.0;
        flake2.scale = 0.3;
        flake2.velocity		= -10;				// falling down slowly
        flake2.velocityRange = 10;
        flake2.yAcceleration = 15;
        flake2.emissionRange = 0.5 * M_PI;		// some variation in angle
        flake2.spinRange		= 0.25 * M_PI;		// slow spin
        flake2.contents		= (id) [[UIImage imageNamed:@"partical"] CGImage];
        flake2.color			= [[UIColor colorWithRed:0 green:1 blue:0 alpha:0.2] CGColor];
        CAEmitterCell *flake3 = [CAEmitterCell emitterCell];
        flake3.birthRate		= 0.6;
        flake3.lifetime		= 60.0;
        flake3.scale = 0.25;
        flake3.velocity		= -10;				// falling down slowly
        flake3.velocityRange = 20;
        flake3.yAcceleration = 15;
        flake3.emissionRange = 0.5 * M_PI;		// some variation in angle
        flake3.spinRange		= 0.25 * M_PI;		// slow spin
        flake3.contents		= (id) [[UIImage imageNamed:@"partical"] CGImage];
        flake3.color			= [[UIColor colorWithRed:0 green:0 blue:1 alpha:0.2] CGColor];
        CAEmitterCell *flake4 = [CAEmitterCell emitterCell];
        flake4.birthRate		= 1.0;
        flake4.lifetime		= 100.0;
        flake4.scale = 0.4;
        flake4.velocity		= -10;				// falling down slowly
        flake4.velocityRange = 10;
        flake4.yAcceleration = 10;
        flake4.emissionRange = 0.5 * M_PI;		// some variation in angle
        flake4.spinRange		= 0.25 * M_PI;		// slow spin
        flake4.contents		= (id) [[UIImage imageNamed:@"partical"] CGImage];
        flake4.color			= [[UIColor colorWithRed:1 green:1 blue:0 alpha:0.2] CGColor];
        
        // Add everything to our backing layer below the UIContol defined in the storyboard
        particalEmitter.emitterCells = [NSArray arrayWithObjects:flake1, flake2, flake3, flake4, nil];
    }
    ///
    return particalEmitter;
}

+ (void)addAds:(UIView*)adView rootVc:(UIViewController *)vc
{

}

+ (void)saveGameData:(GameData*)gameData
{
    NSString* path = [NSString stringWithFormat:@"%@/Documents/game.dat",NSHomeDirectory()];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:gameData];
    [data writeToFile:path atomically:YES];
}

@end
