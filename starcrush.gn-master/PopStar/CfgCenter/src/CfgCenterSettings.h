//
//  CfgCenterSettings.h
//  version 3.3
//
//  Created by 昭 陈 on 2017/3/27.
//  Copyright © 2017年 spring. All rights reserved.
//

#ifndef CfgCenterSettings_h
#define CfgCenterSettings_h

@interface CfgCenterSettings : NSObject

-(void) onAppLoaded;

-(long) getAppFirstInTime;

// get app open count since lase version update
-(long) getAppOpenCount;

// get app open count totally
-(long) getAppOpenCountTotal;

// used by config center
-(void) setLastUdTime:(long) time;
-(long) getLastUdTime;

-(BOOL) isNewVersionUpdate;

+(NSString*) getVersionStr;
- (CGFloat) getAdmobX;
- (CGFloat) getAdmobY;
- (CGFloat) getAdmobWidth;
- (CGFloat) getAdmobHeight;

- (void) recordValidUseCount;
- (long) getValidUseCount;

@end

#endif /* CfgCenterSettings_h */
