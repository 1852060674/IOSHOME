//
//  RTService.m
//
//  Created by 昭 陈 on 16/2/29.
//  Copyright © 2016年 昭 陈. All rights reserved.
//
//  version 3.3
//

#import "RTService.h"
#import "Admob.h"
#import "Toast+UIView.h"
@import StoreKit;

#include <sys/types.h>
#include <sys/sysctl.h>
#ifdef LOG_USER_ACTION
#import <FirebaseAnalytics/FirebaseAnalytics.h>
#endif

#define REVIEW_REQUEST_ALERTVIEW_TAG 20001
#define GET_LOCALIZATION_STRING(str_key) NSLocalizedStringFromTableInBundle(str_key, @"RTService", [LocalizationBundle bundle], nil)

@implementation RTService
{
    BOOL bOpenCounted;
}

-(id) initWithAppid:(NSInteger)iAappid FeedbackEmail: (NSString*) email
{
    self = [super init];
    if(self)
    {
        settings = [NSUserDefaults standardUserDefaults];
        appid = iAappid;
        [self loadRTed];
        feedback_email = email;
        bOpenCounted = false;
    }
    return self;
}

-(void) loadRTed
{
    bRt = [settings boolForKey:@"cz_rated"];
    iShowCount = [settings integerForKey:@"cz_rtshow"];
}

-(void) setRTed
{
    [settings setBool:YES forKey:@"cz_rated"];
    [settings synchronize];
    
    bRt = true;
}

-(void) addRtShow {
    [settings setInteger:++iShowCount forKey:@"cz_rtshow"];
    [settings synchronize];
}

-(void) resetOpenCount{
    [settings setInteger:0 forKey:@"cz_rtshow"];
    iShowCount = 0;
}

-(void) udconfig: (NSDictionary*) jsonDict {
    
}

-(bool) isRT
{
    return bRt;
}

-(void) doRT
{
    BOOL firsttime = !bRt;
    [self setRTed];
    if(firsttime) {
        if(@available(iOS 10.3,*)){
            [SKStoreReviewController requestReview];
            return;
        }
    }
    
    NSString* rtUrl;
    float sysver = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (sysver < 7.0)
    {
        rtUrl = [NSString stringWithFormat: @"https://itunes.apple.com/us/app/%ld", (long)appid];
    }
    else if(sysver < 10.0)
    {
        //rtUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%ld", (long)appid];
        rtUrl = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%ld&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8&onlyLatestVersion=true", (long)appid];
    } else if(sysver < 11.0) {
        rtUrl = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%ld&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8&onlyLatestVersion=true&action=write-review", (long)appid];
    } else {
        rtUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/abc/id%ld?action=write-review", (long)appid];
    }
    
    NSLog(@"rate url=%@", rtUrl);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:rtUrl]];
}

-(BOOL) decideShowRT: (UIViewController *)viewCtrl settings:(CfgCenterSettings*) cfgSettings
{
    NSInteger now_time = time(NULL);
    long firstin = [cfgSettings getAppFirstInTime];
    if(now_time - firstin < 10)
    {
        return false;
    }
    
    long count = [cfgSettings getAppOpenCount];
    
    if(bOpenCounted)
        return false;
    bOpenCounted = true;
    
    if(count >= 2 && count <= 10 && iShowCount < 3)
    {
        [self addRtShow];
        
        if (![self isRT]) {
            [self showRT: viewCtrl];
            
#ifdef LOG_USER_ACTION
            [FIRAnalytics logEventWithName:@"RT Return" parameters:@{@"Accept":@(1)}];
#endif
            
            return true;
        }
    }
    
    return false;
}

-(void) showRT: (UIViewController *)viewCtrl
{
    self.rootVC = viewCtrl;
    UIAlertView *rateDlg = [[UIAlertView alloc]
                            initWithTitle:@""
                            message:GET_LOCALIZATION_STRING(@"RATE_MSG")
                            delegate:self cancelButtonTitle:GET_LOCALIZATION_STRING(@"RATE_CANCEL")
                            otherButtonTitles:GET_LOCALIZATION_STRING(@"RATE_YES"), GET_LOCALIZATION_STRING(@"RATE_NO"), nil];
    rateDlg.tag = REVIEW_REQUEST_ALERTVIEW_TAG;
    [rateDlg show];
#ifdef LOG_USER_ACTION
    [FIRAnalytics logEventWithName:@"RT Return" parameters:@{@"Show":@(0)}];
#endif
}

- (BOOL) doFeedback: (UIViewController *)viewCtrl
{
    [self setRTed];
    
    self.rootVC = viewCtrl;
    
    //[[ShareService defaultService] setDelegate:self];
    BOOL send = [self sendMailWithTitle:[self getSettingFeedbackTitle] content:[self getSettingFeedbackMessage] image:nil recipients:@[feedback_email]];
    
    if (send == NO) {
        [[viewCtrl view] makeToast:GET_LOCALIZATION_STRING(@"EMAIL_NOT_AVAILABLE") duration:1.5 position:@"center"];
    }
    return send;
}

-(NSString *)getSettingFeedbackMessage
{
    
    NSString* appname = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
    if(appname == nil)
        appname = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString* appversion = [NSString stringWithFormat:@"v%@", [CfgCenterSettings getVersionStr]];
    
    NSString *message = [NSString stringWithFormat:@"%@<br />%@:%@<br />%@:%@<br />%@:%@<br />%@:%.2f",
                         GET_LOCALIZATION_STRING(@"SETTING_FEEDBACK_CONTENT"),
                         GET_LOCALIZATION_STRING(@"SETTING_APP_NAME_WORD"),
                         appname,
                         GET_LOCALIZATION_STRING(@"SETTING_APPVERSION_WORD"),
                         appversion,
                         GET_LOCALIZATION_STRING(@"SETTING_DEVICE_WORD"),
                         [self getDeviceModel],
                         GET_LOCALIZATION_STRING(@"SETTING_IOS_VERSION_WORD"),
                         [self systemVersion]
                         ];
    return message;
}

-(NSString *)getSettingFeedbackTitle
{
    NSString* appname = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
    if(appname == nil)
        appname = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *title = [NSString stringWithFormat:@"%@%@", appname, GET_LOCALIZATION_STRING(@"SETTING_FEEDBACK_TITLE")];
    return title;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    int result = 0;
    if (alertView.tag == REVIEW_REQUEST_ALERTVIEW_TAG) {
        switch (buttonIndex) {
            case 1:
#ifdef LOG_USER_ACTION
                [FIRAnalytics logEventWithName:@"RT Return" parameters:@{@"Show":@(2)}];
#endif
                [self doRT];
                result = 1;
                break;
            case 2:
#ifdef LOG_USER_ACTION
                [FIRAnalytics logEventWithName:@"RT Return" parameters:@{@"Show":@(-1)}];
#endif
                [self doFeedback: self.rootVC];
                result = 2;
                break;
            default:
#ifdef LOG_USER_ACTION
                [FIRAnalytics logEventWithName:@"RT Return" parameters:@{@"Show":@(1)}];
#endif
                break;
        }
        
        if ([self.delegate respondsToSelector:@selector(onRTServiceResult:)]) {
            [self.delegate onRTServiceResult:result];
        }
    }
}

-(BOOL)sendMailWithTitle:(NSString *)title content:(NSString *)content image:(UIImage *)image recipients:(NSArray *)recipients
{
    BOOL send = NO;
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        if ([mailClass canSendMail])
        {
            MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
            
            mailPicker.mailComposeDelegate = self;
            mailPicker.delegate = self;
            UIImage *shareImage = image;
            
            if (shareImage) {
                // 添加图片
                NSData *imageData = UIImageJPEGRepresentation(shareImage, 1);
                [mailPicker addAttachmentData: imageData mimeType: @"" fileName: @"final.jpg"];
                
            }
            [mailPicker setSubject:title];
            [mailPicker setToRecipients:recipients];
            [mailPicker setMessageBody:content isHTML:YES];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                mailPicker.modalPresentationStyle = UIModalPresentationFormSheet;
            [self.rootVC presentViewController:mailPicker animated:YES completion:nil];
            send = YES;
        }
    }
    return send;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self.rootVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - system method
    
-(NSString*)currentLanguage
{
    NSArray *languages = [settings objectForKey:@"AppleLanguages"];
    NSString *currentLang = [languages objectAtIndex:0];
    return currentLang;
}

-(int)getCurrentLanguageType
{
    int ret;
    NSString* language = [self currentLanguage];
    NSString* lower = [language lowercaseString];
    if([lower hasPrefix:@"zh-hans"])
    {
        ret = 1;
    }
    else if ([lower hasPrefix:@"zh-hant"])
    {
        ret = 0;
    }
    else{
        ret = 0;
    }
    return ret;
}

- (NSString*)getDeviceModel
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    //NSString *platform = [NSStringstringWithUTF8String:machine];二者等效
    free(machine);
    return platform;
}

-(CGFloat) systemVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

@end
