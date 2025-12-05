//
//  OpenAdWrapper.h
//  Unity-iPhone
//
//  Created by 昭 陈 on 2025/10/18.
//

#ifndef OpenAdWrapper_h
#define OpenAdWrapper_h

#import <UIKit/UIKit.h>
#import "FullScreenAdWrapper.h"

@class AdmobViewController;

@interface OpenAdWrapper : FullScreenAdWrapper

+(OpenAdWrapper*) createAD:(NSDictionary*) config vc: (AdmobViewController*)vc;

@end

#endif /* OpenAdWrapper_h */
