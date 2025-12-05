//
//  SimpleNotification.h
//  Unity-iPhone
//
//  Created by 昭 陈 on 2019/3/4.
//

#ifndef SimpleNotification_h
#define SimpleNotification_h

@interface SimpleNoticication : NSObject

+ (void) popupOpenNotification;
+ (void) cancel:(int)notiid;
+ (void) cancelAll;
+ (void) setLocalNotification:(int)notiid time:(long)span content:(NSString*) content;

@end


#endif /* SimpleNotification_h */
