//
//  TheSound.h
//  WordSearch
//
//  Created by apple on 13-8-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TheSound : NSObject

+ (void)playTapSound;
+ (void)playConfirmSound;
+ (void)playLevelUpSound;
+ (void)playSlideSound;
+ (void)playCoinSound;
+ (instancetype)sharedSound;
@end
