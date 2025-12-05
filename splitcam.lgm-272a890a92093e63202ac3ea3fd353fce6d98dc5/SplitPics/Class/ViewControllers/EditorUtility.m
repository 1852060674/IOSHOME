//
//  EditorUtility.m
//  SplitPics
//
//  Created by 昭 陈 on 2017/5/22.
//  Copyright © 2017年 ZBNetWork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EditorUtility.h"

@implementation EditorUtility

+ (BOOL) showLockEdit:(UIViewController* )view type:(BOOL)lt {
    NSString* msg = @"unlock all photo template";
    if([[[AdmobViewController shareAdmobVC] rtService] getCurrentLanguageType] == 1)
        msg = @"解锁全部拼图模版";
    
    if(lt) {
        msg = @"unlimited to save photo and use filters";
        if([[[AdmobViewController shareAdmobVC] rtService] getCurrentLanguageType] == 1)
            msg = @"无限制保存文件和使用滤镜";
    }
    
    return [[AdmobViewController shareAdmobVC] getRT:view isLock:true rd:msg cb:^{}];
}

+ (BOOL) isEditorLocked {
    if([[AdmobViewController shareAdmobVC] hasInAppPurchased]) {
        return FALSE;
    }
    GRTService* service = (GRTService*)[[AdmobViewController shareAdmobVC] rtService];
    if([service isRT] || [service isGRT])
        return FALSE;
    return TRUE;
}

+ (int) getExType {
    NSDictionary* exconfig = [[[AdmobViewController shareAdmobVC] configCenter] getExConfig];
    int count = 0;
    @try {
        count = [exconfig[@"lt"] intValue];
    } @catch(NSException* exception) {
        count = 0;
    } @finally {
        
    }
    
    return count;
}

+(BOOL) showEditor:(UIViewController*) vc idx:(int)idx {
    int count = [self getExType];
    if(count <= 0 && idx >= -count) {
        return [self isEditorLocked] && [self showLockEdit:vc type:FALSE];
    } else {
        return FALSE;
    }
}

+(BOOL) showEditor:(UIViewController*) vc count:(long)vucount {
    int count = [self getExType];
    if(count > 0 && vucount >= count) {
        return [self isEditorLocked] && [self showLockEdit:vc type:TRUE];
    } else {
        return FALSE;
    }
}

@end
