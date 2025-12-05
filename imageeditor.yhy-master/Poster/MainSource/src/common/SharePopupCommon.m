//
//  ShareCommon.m
//  PhotoEditor
//
//  Created by 昭 陈 on 2017/5/10.
//  Copyright © 2017年 ZBNetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SharePopupCommon.h"
#include "Admob.h"

@implementation ShareCommon


+ (BOOL) isPopUp {
    if([[AdmobViewController shareAdmobVC] hasInAppPurchased]) {
        return FALSE;
    }
    GRTService* service = (GRTService*)[[AdmobViewController shareAdmobVC] rtService];
    if([service isRT] || [service isGRT])
        return FALSE;
    return TRUE;
}

+ (BOOL) matchItem:(CollectionType)col item:(NSInteger)iidx {
    
    if(col == Collection_Sticker) {
        if (iidx > 20 && iidx < 50)
            return TRUE;
    } else if(col == Collection_Background) {
        if (iidx > 20 && iidx < 50)
            return TRUE;
    } else if(col == Collection_Template) {
        if (iidx > 4 && iidx < 9)
            return TRUE;
        else if(iidx == 104)
            return TRUE;
        else if(iidx > 12 && iidx < 28)
            return TRUE;
        else if(iidx > 33 && iidx < 42)
            return TRUE;
        else if(iidx > 45 && iidx < 51)
            return TRUE;
        else if(iidx > 55 && iidx < 58)
            return TRUE;
        else if(iidx > 61 && iidx < 80)
            return TRUE;
        else if(iidx > 86 && iidx < 92)
            return TRUE;
        else if(iidx > 98 && iidx < 102)
            return TRUE;
    } else if(col == Collection_Save) {
        if(iidx > 0 && [[AdmobViewController shareAdmobVC] getValidUseCount] > iidx)
            return TRUE;
    }
    
    return FALSE;
}

+ (BOOL) showPopUp:(UIViewController* )view lt:(BOOL) save {
    NSString* msg = @"unlock the editor and all collage resources";
    if([[[AdmobViewController shareAdmobVC] rtService] getCurrentLanguageType] == 1)
        msg = @"解锁编辑器和所有拼图资源";
    
    if(save) {
        msg = @"unlimited to save image and use all collage resources";
        if([[[AdmobViewController shareAdmobVC] rtService] getCurrentLanguageType] == 1)
            msg = @"无限制保存图像, 和使用所有拼图资源";
    }
    
    return [[AdmobViewController shareAdmobVC] getRT:view isLock:true rd:msg cb:^{}];
}

+(BOOL) needPopup:(UIViewController* )view pagetype:(CollectionType)col item:(NSInteger)iidx {
    if([ShareCommon isPopUp]) {
        int count = [ShareCommon getSaveLock];
        BOOL match = false;
        if(col == Collection_Save) {
            match = [ShareCommon matchItem:col item:count];
        } else {
            match = [ShareCommon matchItem:col item:iidx];
        }
        
        if(match && [ShareCommon showPopUp:view lt:(count>0)])
            return TRUE;
    }
    return FALSE;
}

+(int) getSaveLock {
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

+(BOOL) needPopup:(UIViewController* )view {
    if([ShareCommon isPopUp] && [ShareCommon getSaveLock] < 0 && [ShareCommon showPopUp:view lt:FALSE]){
        return TRUE;
    }
    return FALSE;
}

@end
