//
//  ConfigCenter.h
//  version 3.3
//
//  Created by 昭 陈 on 2016/11/25.
//  Copyright © 2016年 昭 陈. All rights reserved.
//

#ifndef ConfigCenter_h
#define ConfigCenter_h

#import "CfgCenterSettings.h"

@interface ConfigCenter : NSObject
+(NSString*) getContryCode;
+(NSString*) getLanguageCode;

-(id) initWithDefault:(NSString*) config appid: (NSInteger) app;

-(NSDictionary*) getAdConfig:(BOOL)usdefault;
-(NSDictionary*) getRtConfig:(BOOL)usdefault;
-(NSDictionary*) getNtConfig;
-(NSDictionary*) getExConfig;
-(NSDictionary*) getRewardAdConfig:(BOOL)usdefault;

-(void) checkUD: (CfgCenterSettings*)settings ;

@end

#endif /* ConfigCenter_h */
