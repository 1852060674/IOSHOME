//
//  UtilByZh.m
//  RushHour
//
//  Created by IOS2 on 2023/11/13.
//  Copyright © 2023 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UtilByZh.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ProtocolAlerView.h"
#import <SafariServices/SafariServices.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#include "ApplovinMaxWrapper.h"
@implementation UtilByZh
{
}
- (BOOL)getCurrentSound{
    //    获取当前音量
    static AVAudioSession *audioSession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:YES error:nil];
    });
    
    CGFloat volume = audioSession.outputVolume;
    NSLog(@"view volume=  %lf",volume);
    
    if (volume*100 < 1) {
        return FALSE;
    }else{
        return TRUE;
    }
    
    
}

- (BOOL)isLandscape {
    // 横屏
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return UIDeviceOrientationIsLandscape(orientation);
}

//
- (BOOL)isNotchScreen {
    
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets;
        if (safeAreaInsets.left>0) {
            NSLog(@"这是safeAreaInsets.left>0屏");
            return YES;
        }
        if (safeAreaInsets.right>0) {
            NSLog(@"这是safeAreaInsets.right>0屏");
            return YES;
        }
        if (safeAreaInsets.bottom>0) {
            NSLog(@"这是safeAreaInsets.bottom>0屏");
            return YES;
        }
        if (safeAreaInsets.top > 0) {
            // 是刘海屏
            NSLog(@"这是刘海屏");
            return YES;
        }
    }
    NSLog(@"zzx have not hair");
    return NO;
}

/*
 //  att 有时候不能在load 加载 但是 iapd必须load 加载所以添加判断

 att  about lazy king Secre file
 _sc_width= [UIScreen mainScreen].bounds.size.width;   // 获取屏幕的宽度
_sc_height= [UIScreen mainScreen].bounds.size.height;  // 获取屏幕的高度
if (_sc_width +_sc_height > 1500) {
    [self firstProtocolAlter];
}
 
 */
/*
 

- (void) firstProtocolAlter {
    NSString * val = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstLaunch"];
    if (!val) {

        //show alert
        
        ProtocolAlerView *alert = [ProtocolAlerView new];
        alert.viewController = self;
                 alert.strContent = @"Thanks for using Solitaire!\nIn this app, we need some permission to access the photo library, and camera to choose or take a photo of you. In this process, We do not collect or save any data getting from your device including processed data. By clicking 'Agree' you confirm that you have read and agree to our privacy policy.\nAt the same time, Ads may be displayed in this app. When requesting to 'track activity' in the next popup, please click 'Allow' to let us find more personalized ads. It's completely anonymous and only used for relevant ads.";
               
               [alert showAlert:self cancelAction:^(id  _Nullable object) {
                   //不同意
                   [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"firstLaunch"];
//                   [self exitApplication];
               } privateAction:^(id  _Nullable object) {
                       //   输入项目的隐私政策的 URL
                       SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"https://www.shoreline.site/support/quarkltd/spadessolitaire/policy.html"]];
                       //sfVC.delegate = self;
                       [self presentViewController:sfVC animated:YES completion:nil];
    //        [self pushWebController:[YSCommonWebUrl userAgreementsUrl] isLoadOutUrl:NO title:@"用户协议"];
               } delegateAction:^(id  _Nullable object) {
                   NSLog(@"用户协议");
                       //   输入项目的隐私政策的 URL
                       SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"https://www.shoreline.site/support/quarkltd/spadessolitaire/policy.html"]];
                       //sfVC.delegate = self;
                       [self presentViewController:sfVC animated:YES completion:nil];
               }
               ];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"firstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
    }
}
 */


@end
