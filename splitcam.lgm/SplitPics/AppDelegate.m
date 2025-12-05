//
//  AppDelegate.m
//  SplitPics
//
//  Created by tangtaoyu on 15-3-4.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "MGData.h"
#import "SaveViewController.h"
@import Flurry_iOS_SDK;
@interface AppDelegate ()

@end

@implementation AppDelegate

- (id)init
{
    if(self = [super init]){
        [MGData Instance];
    }
    
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [application setStatusBarHidden:YES];
//  SaveViewController * homeVC = [[SaveViewController alloc] init];
    HomeViewController * homeVC = [[HomeViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:homeVC];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    if(@available(iOS 11.0, *)) {
        self.navigationController.additionalSafeAreaInsets = UIEdgeInsetsMake(-kNavigationBarHeight, 0, 0, 0);
    }
    
    self.window.rootViewController = self.navigationController;

    [self.window makeKeyAndVisible];
    FlurrySessionBuilder* builder = [[FlurrySessionBuilder new] withCrashReporting:YES];
//    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"75DP8GV4BBYWRN946Q57" withSessionBuilder:builder];
    
    [AdmobViewController shareAdmobVC];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
  NSLog(@"%@(%p) %@",NSStringFromClass([self class]),self,NSStringFromSelector(_cmd));
}

@end
