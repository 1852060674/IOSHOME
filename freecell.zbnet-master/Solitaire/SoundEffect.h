//
//  SoundEffect.h
//  Solitaire
//
//  Created by jerry on 2017/8/22.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundEffect : NSObject
+ (void)playSoundEffect:(NSString *)name alert:(BOOL)alert;
@end
