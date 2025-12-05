//
//  iOS12AFAnalyticsBug.m
//  SketchMaster-Bird
//
//  Created by IOS1 on 2023/10/30.
//  Copyright © 2023 ZB_Mac. All rights reserved.
//

#import "iOS12AFAnalyticsBug.h"
#include <objc/message.h>

void SwizzleClassMethod(Class originClass, SEL originSelector, Class destClass, SEL newSelector) {

    Method originMethod = class_getClassMethod(originClass, originSelector);
    Method newMethod = class_getClassMethod(destClass, newSelector);

    originClass = object_getClass((id)originClass);

    if (class_addMethod(originClass, originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(originClass, newSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, newMethod);
    }
}

@implementation iOS12AFAnalyticsBug

+ (instancetype)newSharedAnalytics {

    return nil; //All messages to nil won't cause a crash

}

+ (void)fix {

    Class originClass = NSClassFromString(@"AFAnalytics");
    SEL originSelector = NSSelectorFromString(@"sharedAnalytics");

    SwizzleClassMethod(originClass, originSelector, self.class, @selector(newSharedAnalytics));
}

@end
