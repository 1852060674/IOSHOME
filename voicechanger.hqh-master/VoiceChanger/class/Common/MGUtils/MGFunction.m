//
//  MGFunction.m
//  iHowOld
//
//  Created by tangtaoyu on 15/6/17.
//  Copyright (c) 2015年 tangtaoyu. All rights reserved.
//

#import "MGFunction.h"
#import "MGDefine.h"

@implementation NSString (Contains)

- (BOOL)myContainsString:(NSString*)other
{
    NSRange range = [self rangeOfString:other];
    return range.length != 0;
}

@end

@implementation MGFunction

+ (NSArray*)resultWithArray:(NSArray*)array
{
    if(!array || array.count < 1)
        return @[@"--",@"--",@"--",@"0"];
    
    NSInteger min = 200, max = -100, av = 0;
    
    for(int i=0; i<array.count; i++){
        
        NSInteger cur = [array[i] integerValue];
        
        if(cur < min){
            min = cur;
        }
        
        if(cur > max){
            max = cur;
        }
        
        av += cur;
    }
    
    av /= array.count;
    
    NSArray *output = [[NSArray alloc] initWithObjects:MGStr(min), MGStr(max), MGStr(av), MGStr(array.count), nil];
    
    return output;
}

+ (CGFloat)text:(NSString*)string WithFont:(UIFont*)font MaxSize:(CGSize)maxSize
{
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
//
//    CGRect frame = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil];
//
//     return CGRectGetHeight(frame);

    NSDictionary *attribute = @{NSFontAttributeName:font};
    CGSize textSize = [string boundingRectWithSize:maxSize options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribute context:nil].size;
    
    return textSize.height;
}

+ (CGFloat)textWidth:(NSString*)string WithFont:(UIFont*)font MaxSize:(CGSize)maxSize
{
    NSDictionary *attribute = @{NSFontAttributeName:font};
    CGSize textSize = [string boundingRectWithSize:maxSize options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribute context:nil].size;
    
    return textSize.width;
}

+ (UIAlertView *)alertTitle:(NSString*)title message:(NSString*)message delegate:(id)aDelegate cancelButtonTitle:cancelName otherButtonTitles:otherbuttonName
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:aDelegate cancelButtonTitle:cancelName otherButtonTitles:otherbuttonName, nil];
    [alert show];
    return alert;
}

+ (UIAlertView *)alertTitle:(NSString*)title message:(NSString*)message delegate:(id)aDelegate cancelButtonTitle:cancelName otherButtonTitles:otherbuttonName WithTag:(NSInteger)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:aDelegate cancelButtonTitle:cancelName otherButtonTitles:otherbuttonName, nil];
    alert.tag = tag;
    [alert show];
    return alert;
}

+ (MBProgressHUD *)createHUD
{
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:window animated:YES];
    HUD.detailsLabel.font = [UIFont boldSystemFontOfSize:16];
    
    return HUD;
}

+ (void)fixAdsBug:(UIViewController*)vc
{
    UIView *view = [[UIView alloc] initWithFrame:vc.view.bounds];
    view.backgroundColor = [UIColor clearColor];
    view.userInteractionEnabled = NO;
    [vc.view addSubview:view];
}

+ (UIImage*)createImageWithColor:(UIColor*)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (BOOL)isInLegal:(NSString*)string
{
    for(int i=0; i<string.length; i++){
        int a = [string characterAtIndex:i];
        if((a >= 48 && a <= 57) || (a >= 65 && a <= 90) || (a >= 97 && a<= 122) || a == 95){
            
        }else{
            return NO;
        }
    }
    
    return YES;
}

+ (NSString*)exceptUNASCII:(NSString*)string
{
    NSMutableString *str = [NSMutableString new];
    
    for(int i=0; i<string.length; i++){
        int a = [string characterAtIndex:i];
        if(a > 127){
        }else{
            NSString *str0 = [string substringWithRange:NSMakeRange(i, 1)];
            [str appendString:str0];
        }
    }
    
    return str;
}

+ (NSString*)timeWithCtime:(NSString*)ctime
{
    NSArray *arr = [ctime componentsSeparatedByString:@"."];
    NSString *str1 = arr[0];
    
    NSString *strUTC = [NSString stringWithFormat:@"%@+0000", str1];
    
    NSString *strLocal = [MGFunction getLocalDateFormateUTCDate:strUTC];
    
    NSString *output = strLocal;
    return output;
}

+ (NSDate *)getNowDateFromatUTCDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}

+ (NSDate *)stringToDate:(NSString *)strdate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *retdate = [dateFormatter dateFromString:strdate];
    return retdate;
}

+ (NSString *)dateToString:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

//将UTC日期字符串转为本地时间字符串
//输入的UTC日期格式2013-08-03T04:53:51+0000
+ (NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}

@end
