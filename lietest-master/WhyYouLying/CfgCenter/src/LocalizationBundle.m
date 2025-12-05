//
//  LocalizationBundle.m
//  Unity-iPhone
//
//  Created by 昭 陈 on 2017/8/28.
//
//

#import <Foundation/Foundation.h>
#import "LocalizationBundle.h"

@implementation LocalizationBundle : NSObject

+ (NSBundle *)bundle
{
    static dispatch_once_t onceToken;
    static NSBundle *localizationBundle = nil;
    
    dispatch_once(&onceToken, ^{
        
        NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"RTService" withExtension:@"bundle"];
        localizationBundle = [NSBundle bundleWithURL:bundleURL];
    });
    
    return localizationBundle;
}

@end
