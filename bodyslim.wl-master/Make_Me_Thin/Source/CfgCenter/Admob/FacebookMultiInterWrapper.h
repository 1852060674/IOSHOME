//
//  FacebookMultiInterWrapper.h
//  SplitPics
//
//  Created by 昭 陈 on 2017/7/12.
//  Copyright © 2017年 ZBNetWork. All rights reserved.
//

#ifndef FacebookMultiInterWrapper_h
#define FacebookMultiInterWrapper_h

#import "FacebookWrapper.h"

@interface FacebookMultiInterWrapper : FacebookWrapper

- (id)initWithRootView:(AdmobViewController*) rootview BannerId:(NSString* )bannerid InterstitialIds:(NSArray* )interids NativeId:(NSString* )nativeid;

@end

#endif /* FacebookMultiInterWrapper_h */
