//
//  AppDelegate.m
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "Admob.h"
@import Flurry_iOS_SDK;
#import "Config.h"

@implementation AppDelegate

- (id)init
{
    if(self = [super init]) {
        
    }
    return self;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if(@available(iOS 11.0, *)) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iOS9" bundle:nil];
        self.window.rootViewController = [storyboard instantiateInitialViewController];
        [self.window makeKeyAndVisible];
    }
    
    [Flurry startSession:@"4WRMTJTDV28WRZXGGKTZ"];
    [AdmobViewController shareAdmobVC];
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  [[NSNotificationCenter defaultCenter] postNotificationName:pause_time_key object:nil userInfo:@{@"pause":@(YES)}];

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[(UINavigationController*)self.window.rootViewController topViewController] viewWillAppear:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  [[NSNotificationCenter defaultCenter] postNotificationName:pause_time_key object:nil userInfo:@{@"pause":@(NO)}];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //[[(UINavigationController*)self.window.rootViewController topViewController] viewWillDisappear:YES];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:[settings boolForKey:@"tempori"] forKey:@"orientation"];
    [settings synchronize];
  [[NSNotificationCenter defaultCenter] postNotificationName:pause_time_key object:nil userInfo:@{@"pause":@(YES)}];

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
