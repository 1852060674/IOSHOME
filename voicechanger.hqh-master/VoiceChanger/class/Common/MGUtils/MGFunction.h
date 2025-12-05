//
//  MGFunction.h
//  iHowOld
//
//  Created by tangtaoyu on 15/6/17.
//  Copyright (c) 2015年 tangtaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface NSString (Contains)
- (BOOL)myContainsString:(NSString*)other;
@end

@interface MGFunction : NSObject

+ (NSArray*)resultWithArray:(NSArray*)array;
+ (NSString*)timeWithCtime:(NSString*)ctime;
+ (NSDate *)getNowDateFromatUTCDate:(NSDate *)anyDate;

+ (CGFloat)text:(NSString*)string WithFont:(UIFont*)font MaxSize:(CGSize)maxSize;
+ (CGFloat)textWidth:(NSString*)string WithFont:(UIFont*)font MaxSize:(CGSize)maxSize;

+ (UIAlertView *)alertTitle:(NSString*)title message:(NSString*)message delegate:(id)aDelegate cancelButtonTitle:cancelName otherButtonTitles:otherbuttonName WithTag:(NSInteger)tag;
+ (UIAlertView *)alertTitle:(NSString*)title message:(NSString*)message delegate:(id)aDelegate cancelButtonTitle:cancelName otherButtonTitles:otherbuttonName;

+ (MBProgressHUD *)createHUD;
+ (UILabel*)labelWithLineBreak:(NSString*)str WithFrame:(CGRect)rect;
+ (void)fixAdsBug:(UIViewController*)vc;
+ (UIImage*)createImageWithColor:(UIColor*)color;

+ (BOOL)isInLegal:(NSString*)string;
+ (NSString*)exceptUNASCII:(NSString*)string;

@end
