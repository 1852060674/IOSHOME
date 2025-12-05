//
//  SimpleNotification.m
//  Unity-iPhone
//
//  Created by 昭 陈 on 2019/3/4.
//

#import <Foundation/Foundation.h>

#import "SimpleNotification.h"

#define NOTIKEY @"simple_local_notifi"

@implementation SimpleNoticication

+ (void) popupOpenNotification {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationSettings *notisettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notisettings];
    }
}

+ (void) cancel:(int)notiid {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *localArr = [app scheduledLocalNotifications];
    if (!localArr) {
        return;
    }
    
    for (UILocalNotification *noti in localArr) {
        NSDictionary *dict = noti.userInfo;
        if (dict) {
            NSNumber* idvalud = [dict objectForKey:NOTIKEY];
            if ([idvalud integerValue] == notiid) {
                [app cancelLocalNotification:noti];
            }
        }
    }
}

+ (void) cancelAll {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *localArr = [app scheduledLocalNotifications];
    if (!localArr) {
        return;
    }
    
    [app cancelAllLocalNotifications];
}

+ (void) setLocalNotification:(int) notiid time:(long)span content:(NSString*) content {
    
    UIApplication *app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = 0;
    
    NSDate *date = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitSecond value:span toDate:[NSDate date] options:nil];
    
    /* 创建local通知 */
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    if (noti) {
        noti.fireDate = date;
        noti.timeZone = [NSTimeZone defaultTimeZone];
        noti.repeatInterval = NSCalendarUnitDay;
        noti.soundName = UILocalNotificationDefaultSoundName;
        noti.alertBody = content;
        noti.applicationIconBadgeNumber = 1;
        
        NSDictionary *infoDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:notiid] forKey:NOTIKEY];
        noti.userInfo = infoDic;
        
        [app scheduleLocalNotification:noti];
    }
}

@end
