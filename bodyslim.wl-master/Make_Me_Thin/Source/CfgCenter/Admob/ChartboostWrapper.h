//
//  CharrboostWrapper.h
//  version 3.3
//
//  Created by 昭 陈 on 2016/11/24.
//  Copyright © 2016年 昭 陈. All rights reserved.
//

#ifndef CharrboostWrapper_h
#define CharrboostWrapper_h

#import "ADWrapper.h"
#import <Chartboost/Chartboost.h>

@interface ChartBoostWrapper : ADWrapper<ChartboostDelegate>

- (id)initWithRootView:(AdmobViewController*) rootview appid:(NSString* )bannerid signature:(NSString* )interid;

@end

#endif /* CharrboostWrapper_h */
