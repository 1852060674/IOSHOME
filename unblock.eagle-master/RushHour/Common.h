//
//  Common.h
//  Flow
//
//  Created by yysdsyl on 13-10-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameData.h"
#import "TheSound.h"

@interface Common : NSObject

+ (UIColor*)colors:(int)idx;
+ (CAEmitterLayer*)emitter;
+ (void)addAds:(UIView*)adView rootVc:(UIViewController*)vc;
+ (void)saveGameData:(GameData*)gameData;

@end
