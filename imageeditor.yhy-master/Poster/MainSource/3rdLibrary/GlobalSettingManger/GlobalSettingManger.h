//
//  GlobalSettingManger.h
//  eyeColorPlus
//
//  Created by shen on 14-7-22.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalSettingManger : NSObject
+(GlobalSettingManger* )defaultManger;
@property (nonatomic, readwrite) NSInteger resolution;
@property (nonatomic, readwrite) BOOL autoSave;
@property (nonatomic, readwrite) BOOL feather;
@property (nonatomic, readwrite) BOOL smoothEdge;

@property (nonatomic, readwrite) BOOL useNetwork;
@property (nonatomic, readwrite) BOOL useNetworkUnderWifiOnly;
@property (nonatomic, readwrite) NSInteger lanchCnt;

@property (nonatomic, readwrite) NSInteger cutHelpCnt;
@property (nonatomic, readwrite) NSInteger thinHeadHelpCnt;
@property (nonatomic, readwrite) NSInteger thinFaceHelpCnt;
@property (nonatomic, readwrite) NSInteger thinChinHelpCnt;
@property (nonatomic, readwrite) NSInteger slimHelpCnt;
@property (nonatomic, readwrite) NSInteger manualHelpCnt;

@property (nonatomic, readwrite) NSInteger createColorUsedCnt;
@property (nonatomic, readwrite) NSInteger matchColorUsedCnt;

@property (nonatomic, readwrite) NSInteger useCnt;

@property (nonatomic, readwrite) BOOL everShowGuide;
@property (nonatomic, readwrite) BOOL everAutoShowHelp;

@end
