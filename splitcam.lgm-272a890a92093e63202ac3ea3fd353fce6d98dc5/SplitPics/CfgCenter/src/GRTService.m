//
//  GRTService.m
//
//  Created by 昭 陈 on 16/5/5.
//  Copyright © 2016年 昭 陈. All rights reserved.
//
//  version 3.3
//

#import <Foundation/Foundation.h>
#import "GRTService.h"
#import "CfgCenter.h"
#import "Toast+UIView.h"
#import "LocalizationBundle.h"

#ifdef LOG_USER_ACTION
//#import <FirebaseAnalytics/FirebaseAnalytics.h>
#endif

#define REVIEW_GET_ALERTVIEW_TAG 20002
#define GET_LOCALIZATION_STRING(str_key) NSLocalizedStringFromTableInBundle(str_key, @"RTService", [LocalizationBundle bundle], nil)

//http
#define TIME_OUT_INTERVAL 10
#define SHIFT_OFFSET 43

CBFUNC cbfunc;

@implementation GRTService
{
    BOOL bLa;
    
    BOOL isuding;
    //评价参数
    int show;
    long maxFirstIn;
    int openCount;
    int timeshow;
    int timeAfterOpen;
    BOOL workTime;
    int interval;
    long startTimePoint;
    int validUseCount;
}

-(id)initWithAppid:(NSInteger)iAappid FeedbackEmail:(NSString *)email
{
    self = [super initWithAppid:iAappid FeedbackEmail:email];
    if(self)
    {
        bLa = false;
        openTime = time(NULL);
        
        isuding = false;
        
        show = 1;
        maxFirstIn = openTime - 2*24*3600;
        openCount = 3;
        timeshow = 3;
        timeAfterOpen = 60;
        workTime = false;
        interval = 0;
        startTimePoint = 0;
        validUseCount = 0;
    }
    
    return self;
}

-(void) initServiceParamLa: (BOOL) la
{
    bLa = la;
}

-(void) loadRTed
{
    [super loadRTed];
    
    bGRT = [settings boolForKey:@"cz_grated"];
    
    iGshowed = [settings integerForKey:@"cz_grtshowed"];
    bCurGshowed = false;
}

-(void) setGRTed
{
    [settings setBool:YES forKey:@"cz_grated"];
    [settings setBool:YES forKey:@"cz_rated"];
    [settings synchronize];
    
    bGRT = true;
    bRt = true;
}

-(void) addGRTShowed
{
    iGshowed++;
    [settings setInteger:iGshowed forKey:@"cz_grtshowed"];
    [settings setInteger:time(NULL) forKey:@"cz_grtlastshowed"];
    [settings synchronize];
    
    bCurGshowed = true;
}

-(BOOL) isGRT
{
    return bGRT;
}

-(void) resetOpenCount {
    [super resetOpenCount];
    iGshowed=0;
    [settings setInteger:iGshowed forKey:@"cz_grtshowed"];
}

//拉评价, cb: 回调函数
-(BOOL) getRT:(UIViewController*)viewctrl settings:(CfgCenterSettings*)cfgSettings isLock:(BOOL)lock rd:(NSString* )rd cb: (CBFUNC)cb
{
    //已经评价过或者已经强制评价过了不拉
    if([self isRT] || [self isGRT])
        return false;
    
    if(show == 0) {
#ifdef LOG_USER_ACTION
        [FIRAnalytics logEventWithName:@"GRT Return" parameters:@{@"Accept":@(-1)}];
#endif
        return false;
    }
    
    
    //自第一次打开时间少于5小时不弹出
    long now_time = time(NULL);
#ifndef DEBUG
    long firstin = [cfgSettings getAppFirstInTime];
    if(firstin > maxFirstIn)
    {
#ifdef LOG_USER_ACTION
        [FIRAnalytics logEventWithName:@"GRT Return" parameters:@{@"Accept":@(-2)}];
#endif
        return false;
    }
    
    //startPoint
    if(firstin < startTimePoint) {
#ifdef LOG_USER_ACTION
        [FIRAnalytics logEventWithName:@"GRT Return" parameters:@{@"Accept":@(-8)}];
#endif
        return false;
    }
#endif
    
    //openCount
    if([cfgSettings getAppOpenCountTotal] < openCount) {
#ifdef LOG_USER_ACTION
        [FIRAnalytics logEventWithName:@"GRT Return" parameters:@{@"Accept":@(-4)}];
#endif
        return false;
    }
    
    //useCount
    if([cfgSettings getValidUseCount] < validUseCount) {
#ifdef LOG_USER_ACTION
        [FIRAnalytics logEventWithName:@"GRT Return" parameters:@{@"Accept":@(-9)}];
#endif
        return false;
    }
    
    if(!lock) {
        //自本次打开x秒之内不弹
        if(now_time - openTime < timeAfterOpen)
        {
#ifdef LOG_USER_ACTION
            [FIRAnalytics logEventWithName:@"GRT Return" parameters:@{@"Accept":@(-3)}];
#endif
            return false;
        }
        
        NSDate* now = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:now];
        NSInteger hour = [components hour];
        //工作时间
        if(!workTime && hour > 8 && hour<20){
#ifdef LOG_USER_ACTION
            [FIRAnalytics logEventWithName:@"GRT Return" parameters:@{@"Accept":@(-5)}];
#endif
            return false;
        }
        
        //显示间隔
        long lastshow = [settings integerForKey:@"cz_grtlastshowed"];
        if(now_time - lastshow < interval){
#ifdef LOG_USER_ACTION
            [FIRAnalytics logEventWithName:@"GRT Return" parameters:@{@"Accept":@(-6)}];
#endif
            return false;
        }
        
        //显示次数和每次打开显示次数
        if(iGshowed >= timeshow || bCurGshowed){
#ifdef LOG_USER_ACTION
            [FIRAnalytics logEventWithName:@"GRT Return" parameters:@{@"Accept":@(-7)}];
#endif
            return false;
        }
    }
    
    //获取语言
    int type = [self getCurrentLanguageType];

    cbfunc = cb;
    
    UIAlertView* rtDlg;
    if(show == 1)
        rtDlg = [self createAlertViewTypA:rd language:type];
    else
        rtDlg = [self createAlertViewTypB:viewctrl];
    
    [rtDlg show];
    
#ifdef LOG_USER_ACTION
    [FIRAnalytics logEventWithName:@"GRT Return" parameters:@{@"Show":@(0)}];
#endif
    
    [self addGRTShowed];
    
#ifdef LOG_USER_ACTION
    [FIRAnalytics logEventWithName:@"GRT Return" parameters:@{@"Accept":@(1)}];
#endif
    
    return true;
}

-(UIAlertView* ) createAlertViewTypA:(NSString*) rd language:(int)type{
    //弹出对话框
    NSString* message;
    if(rd != nil)
        message = [NSString stringWithFormat:@"%@%@%@",@"Trial has expired, Now give us ⭐️.⭐️.⭐️.⭐️.⭐️rate can ",rd,@", Thanks for your rate."];//@"%@%@%@",@"现在⭐️⭐️⭐️⭐️⭐️评价可以",rd,@",快来评价吧"];
    else
        message = [NSString stringWithFormat:@"%@",@"Do you like this app，Pls give us a ⭐️.⭐️.⭐️.⭐️.⭐️rating"];//@"%@",@"喜欢这个应用么，请给个⭐️⭐️⭐️⭐️⭐️评价吧"];
    NSString* c = @"Cancel";
    NSString* d = @"Rating";
    
    if(type == 1)
    {
        if(rd != nil)
            message = [NSString stringWithFormat:@"%@%@%@",@"试用已到期，现在⭐️.⭐️.⭐️.⭐️.⭐️评价立即",rd,@",快来评价吧"];
        else
            message = [NSString stringWithFormat:@"%@",@"喜欢这个应用么，请给个⭐️.⭐️.⭐️.⭐️.⭐️评价吧"];
        c = @"取消";
        d = @"去好评";
    }
    
    UIAlertView *rtDlg = [[UIAlertView alloc]
                          initWithTitle:@""
                          message:message
                          delegate:self cancelButtonTitle:c
                          otherButtonTitles:d, nil];
    rtDlg.tag = REVIEW_GET_ALERTVIEW_TAG;
    return rtDlg;
}

-(UIAlertView* ) createAlertViewTypB:(UIViewController*)viewctrl {
    self.rootVC = viewctrl;
    
    UIAlertView *rateDlg = [[UIAlertView alloc]
                            initWithTitle:@""
                            message:GET_LOCALIZATION_STRING(@"RATE_MSG")
                            delegate:self cancelButtonTitle:GET_LOCALIZATION_STRING(@"RATE_CANCEL")
                            otherButtonTitles:GET_LOCALIZATION_STRING(@"SETTING_IOS_DESC_WORD"), GET_LOCALIZATION_STRING(@"RATE_NO"), nil];
    rateDlg.tag = REVIEW_REQUEST_ALERTVIEW_TAG;
    return rateDlg;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == REVIEW_GET_ALERTVIEW_TAG)
    {
        switch (buttonIndex) {
            case 1:
#ifdef LOG_USER_ACTION
                [FIRAnalytics logEventWithName:@"GRT Return" parameters:@{@"Show":@(2)}];
#endif
                [self doRT];
                if(cbfunc != nil) {
                    cbfunc();
                }
                [self setGRTed];
                
                break;
            default:
#ifdef LOG_USER_ACTION
                [FIRAnalytics logEventWithName:@"GRT Return" parameters:@{@"Show":@(1)}];
#endif
                break;
        }
    }
    else {
        [super alertView:alertView didDismissWithButtonIndex:buttonIndex];
    }
}

//json格式
//s:是否显示,fi:first in第一次打开时间要求,op:open time打开次数要求,tao:time after open打开多久后弹,wt:work time工作时间是否弹,it:interval显示间隔,vd:valid time不再更新时间,t:time时间戳
//{
//    "retcode":"1",
//    "s":true
//    "fi":1472695222,
//    "op":5,
//    "ts":3,
//    "tao":300,
//    "wt":false,
//    "it":0,
//    "vd":86400
//    "t":1472695222
//}

-(void)udconfig: (NSDictionary*) jsonDict {
    @try {
        show = [jsonDict[@"s"] intValue];
        maxFirstIn = [jsonDict[@"fi"] longValue];
        if(maxFirstIn < 0)
            maxFirstIn = openTime + maxFirstIn;
        openCount = [jsonDict[@"op"] intValue];
        timeshow = [jsonDict[@"ts"] intValue];
        timeAfterOpen = [jsonDict[@"tao"] intValue];
        workTime = [jsonDict[@"wt"] boolValue];
        interval = [jsonDict[@"it"] intValue];
        startTimePoint = [jsonDict[@"stp"] longValue];
        if(startTimePoint < 0)
            startTimePoint = 0;
        validUseCount = [jsonDict[@"vu"] intValue];
    } @catch (NSException *exception) {
    } @finally {
    }

    //valid
    timeshow = timeshow <=0 ? 1 : timeshow;
}
@end
