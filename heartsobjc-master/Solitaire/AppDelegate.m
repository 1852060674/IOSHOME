//
//  AppDelegate.m
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "Config.h"
//#import "Cfg.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [Cfg share];
    //
    NSArray *localArr = [application scheduledLocalNotifications];
    UILocalNotification *localNoti = nil;
    if (localArr) {
        for (UILocalNotification *noti in localArr) {
            NSDictionary *dict = noti.userInfo;
            if (dict) {
                NSString *inKey = [dict objectForKey:@"HeartsSolitaire"];
                if ([inKey isEqualToString:@"HeartsSolitaire"]) {
                    localNoti = noti;
                    break;
                }
            }
        }
        if (localNoti) {
            [application cancelLocalNotification:localNoti];
        }
    }
    // Set up the time
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDate *nextDay = [NSDate dateWithTimeIntervalSinceNow:0/*+24*3600*/];
    NSDateComponents *currentComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:nextDay];
    //NSDateComponents *timeComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:nextDay];
    NSDateComponents *setDateComponents = [[NSDateComponents alloc] init];
    [setDateComponents setDay:[currentComponents day]];
    [setDateComponents setMonth:[currentComponents month]];
    [setDateComponents setYear:[currentComponents year]];
    [setDateComponents setHour:MSG_PUSH_TIME];
    [setDateComponents setMinute:MSG_PUSH_MINUTE];
	[setDateComponents setSecond:1];
    NSDate *itemDate = [calendar dateFromComponents:setDateComponents];
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    if (0) {
        noti.fireDate = itemDate;
        noti.timeZone = [NSTimeZone defaultTimeZone];
        noti.repeatInterval = NSWeekCalendarUnit;//NSMinuteCalendarUnit;//NSDayCalendarUnit;
        noti.soundName = UILocalNotificationDefaultSoundName;
        noti.alertBody = @"Don't Give Up! Hearts Solitaire is waiting for you to Conquer!";
        noti.applicationIconBadgeNumber = 1;
        //for remove
        NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"HeartsSolitaire" forKey:@"HeartsSolitaire"];
        noti.userInfo = infoDic;
        //
        UIApplication *app = [UIApplication sharedApplication];
        [app scheduleLocalNotification:noti];
    }

    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    [[(UINavigationController*)self.window.rootViewController topViewController] viewWillDisappear:YES];
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
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:notification.alertBody
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    //
    application.applicationIconBadgeNumber = 0;
}

@end
