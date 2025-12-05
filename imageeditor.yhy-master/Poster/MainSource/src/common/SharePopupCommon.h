//
//  ShareCommon.h
//  PhotoEditor
//
//  Created by 昭 陈 on 2017/5/10.
//  Copyright © 2017年 ZBNetwork. All rights reserved.
//

#ifndef ShareCommon_h
#define ShareCommon_h

typedef enum {
    Collection_Sticker,
    Collection_Background,
    Collection_Template,
    Collection_Save
}CollectionType;

@interface ShareCommon : NSObject

+(BOOL) needPopup:(UIViewController* )view pagetype:(CollectionType)col item:(NSInteger)iidx;
+(BOOL) needPopup:(UIViewController* )view;

@end

#endif /* ShareCommon_h */
