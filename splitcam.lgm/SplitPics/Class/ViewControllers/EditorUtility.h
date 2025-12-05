//
//  EditorUtility.h
//  SplitPics
//
//  Created by 昭 陈 on 2017/5/22.
//  Copyright © 2017年 ZBNetWork. All rights reserved.
//

#ifndef EditorUtility_h
#define EditorUtility_h
#import <UIKit/UIKit.h>

@interface EditorUtility : NSObject

+(BOOL) showEditor:(UIViewController*) vc idx:(int) idx;
+(BOOL) showEditor:(UIViewController*) vc count:(long)vucount;

@end

#endif /* EditorUtility_h */
