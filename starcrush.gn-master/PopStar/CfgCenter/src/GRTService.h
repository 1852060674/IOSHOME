//
//  GRTService.h
//
//  Created by 昭 陈 on 16/5/5.
//  Copyright © 2016年 昭 陈. All rights reserved.
//
//  version 3.3
//

#ifndef RTService_GRT_h
#define RTService_GRT_h

#import "RTService.h"

#define REVIEW_GET_ALERTVIEW_TAG 20002
typedef void(^CBFUNC)();

@interface GRTService : RTService
{
    CBFUNC cbfunc;
    
    NSInteger loc;
    float lat;
    float lon;
    
    BOOL bGRT;
    NSInteger iGshowed;
    BOOL bCurGshowed;
    long openTime;
}

-(void) initServiceParamLa: (BOOL) la;
//拉评价, cb: 回调函数
-(BOOL) getRT:(UIViewController*)viewctrl settings:(CfgCenterSettings*)cfgSettings isLock:(BOOL)lock rd:(NSString* )rd cb: (CBFUNC)cb;

-(BOOL) isGRT;

-(void) addGRTShowed;

-(void) udconfig: (NSDictionary*) jsonDict;

@end

#endif /* RTService_GRT_h */
