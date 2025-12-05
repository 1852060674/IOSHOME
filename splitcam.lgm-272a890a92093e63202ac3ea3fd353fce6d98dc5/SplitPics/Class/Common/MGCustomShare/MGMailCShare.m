//
//  MGMailCShare.m
//  myFace
//
//  Created by tangtaoyu on 16/2/24.
//  Copyright © 2016年 zhongbo network. All rights reserved.
//

#import "MGMailCShare.h"
#import <sys/utsname.h>
#import "CfgCenter.h"

//#define kPopInCurrentWindow

@implementation MGMailCShare

+ (MGMailCShare*)shareMail
{
    static id singleton = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[[self class] alloc] init];
    });
    
    return singleton;
}

- (void)sendFeedBackInVC:(UIViewController*)conVC
{
    NSString *title = [NSString stringWithFormat:@"%@%@", kSetLocal(@"SET_APP_NAME"), kSetLocal(@"SET_FEEDBACK_TITLE")];
    NSString *content = [NSString stringWithFormat:@"%@<br />%@:%@<br />%@:%@<br />%@:%@<br />%@:%.2f",
                         kSetLocal(@"SET_FEEDBACK_CONTENT"),
                         kSetLocal(@"SET_APP_NAME_TITLE"),
                         kSetLocal(@"SET_APP_NAME"),
                         kSetLocal(@"SET_APP_VERSION"),
                         [NSString stringWithFormat:@"v%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey]],
                         kSetLocal(@"SET_DEVICE_TITLE"),
                         [self getDeviceModel],
                         kSetLocal(@"SET_IOS_VERSION_TITLE"),
                         [[[UIDevice currentDevice] systemVersion] floatValue]
                         ];
    
    [self sendMail:title content:content inVC:conVC];
}

- (void)sendMail:(NSString*)title content:(NSString*)content inVC:(UIViewController*)conVC
{
    if([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
        mailVC.mailComposeDelegate = self;
        
        [mailVC setSubject:title];
        [mailVC setToRecipients:[NSArray arrayWithObject:FEEDBACK_MAIL]];
        [mailVC setMessageBody:content isHTML:YES];
        
        //        NSData *emojiData = UIImagePNGRepresentation(selectStr2Image);
        //        [mailVC addAttachmentData:emojiData mimeType:@"image/png" fileName:@"emojiText.png"];
        
#ifdef kPopInCurrentWindow
        [[[[UIApplication sharedApplication] windows] lastObject].rootViewController presentViewController:mailVC animated:YES completion:nil];
#else
        [conVC presentViewController:mailVC animated:YES completion:nil];
#endif
    }else{
        UIAlertView *alert =
      [[UIAlertView alloc] initWithTitle:kSetLocal(@"SET_ALERT_TIPS")
                                 message:kSetLocal(@"SET_MAIL_NOT_SUPPORT")
                                delegate:self
                       cancelButtonTitle:kSetLocal(@"SET_ALERT_OK")
                       otherButtonTitles:nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultFailed:{
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:kSetLocal(@"SET_ALERT_TIPS")
                                                                   message:kSetLocal(@"SET_SEND_MAIL_FAILED")
                                                                  delegate:self
                                                         cancelButtonTitle:kSetLocal(@"SET_ALERT_OK")
                                                         otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
        case MFMailComposeResultSent:{
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:kSetLocal(@"SET_ALERT_TIPS")
                                                                   message:kSetLocal(@"SET_SEND_MAIL_SUCCEED")
                                                                  delegate:self
                                                         cancelButtonTitle:kSetLocal(@"SET_ALERT_OK")
                                                         otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (NSString*)getDeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    return deviceString;
}

@end
