//
//  MGMailCShare.h
//  myFace
//
//  Created by tangtaoyu on 16/2/24.
//  Copyright © 2016年 zhongbo network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import MessageUI;

#define SMS_CONTENT   @"Awesome App"
#define kSetLocal(str)  NSLocalizedStringFromTable(str, @"MGCustomShare", nil)


@interface MGMailCShare : NSObject<MFMailComposeViewControllerDelegate>

+ (MGMailCShare*)shareMail;

- (void)sendFeedBackInVC:(UIViewController*)conVC;
- (void)sendMail:(NSString*)title content:(NSString*)content inVC:(UIViewController*)conVC;

@end
