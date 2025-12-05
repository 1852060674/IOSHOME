//
//  AdmobMultiInterWrapper.h
//  SplitPics
//
//  Created by 昭 陈 on 2017/7/11.
//  Copyright © 2017年 ZBNetWork. All rights reserved.
//

#ifndef AdmobMultiInterWrapper_h
#define AdmobMultiInterWrapper_h

#import "AdmobWrapper.h"

@interface AdmobMultiInterWrapper : AdmobWrapper

- (id)initWithRootView:(AdmobViewController*) rootview BannerId:(NSString* )bannerid InterstitialIds:(NSArray* )interids NativeId:(NSString* )nativeid;

@end

#endif /* AdmobMultiInterWrapper_h */
