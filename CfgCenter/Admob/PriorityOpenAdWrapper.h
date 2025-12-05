//
//  PriorityOpenAdWrapper.h
//  Unity-iPhone
//
//  Created by 昭 陈 on 2015/10/18.
//

#ifndef PriorityOpenAdWrapper_h
#define PriorityOpenAdWrapper_h

#import "OpenAdWrapper.h"

@class AdmobViewController;

@interface PriorityOpenAdWrapper : OpenAdWrapper<FullScreenAdWrapperDelegate>

- (id)initWithRootView:(AdmobViewController*) rootview adlist:(NSArray* )ads;

@end

#endif /* PriorityOpenAdWrapper_h */
