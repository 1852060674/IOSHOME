//
//  RTService.h
//
//  Created by 昭 陈 on 16/2/29.
//  Copyright © 2016年 昭 陈. All rights reserved.
//
//  version 3.3
//

#ifndef RTService_h
#define RTService_h

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "CfgCenterSettings.h"
#import "LocalizationBundle.h"

#define REVIEW_REQUEST_ALERTVIEW_TAG 20001

@protocol RTServiceResultDelegate <NSObject>

-(void)onRTServiceResult:(int)result;

@end

@interface RTService : NSObject<UIAlertViewDelegate,MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>
{
    NSInteger appid;
    NSString* feedback_email;
    NSUserDefaults* settings;
    @protected
    BOOL bRt;
    long iShowCount;
}

@property (nonatomic, weak) UIViewController *rootVC;
@property (nonatomic, weak) id<RTServiceResultDelegate> delegate;

-(id) initWithAppid:(NSInteger)iAappid FeedbackEmail: (NSString*) email;

-(void) udconfig: (NSDictionary*) jsonDict;

-(void) loadRTed;

-(bool) isRT;

-(void) doRT;

-(void) resetOpenCount;

-(BOOL) decideShowRT: (UIViewController *)viewCtrl settings:(CfgCenterSettings*)cfgSettings;

-(void) showRT: (UIViewController *)viewCtrl;

-(BOOL) doFeedback: (UIViewController *)viewCtrl;

-(int) getCurrentLanguageType;

@end

#endif /* RTService_h */
