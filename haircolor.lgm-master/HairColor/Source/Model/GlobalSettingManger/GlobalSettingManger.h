//
//  GlobalSettingManger.h
//  eyeColorPlus
//
//  Created by shen on 14-7-22.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalSettingManger : NSObject
+(GlobalSettingManger *)defaultManger;
@property (nonatomic, readwrite) NSInteger resolution;
@property (nonatomic, readwrite) BOOL autoSave;
@property (nonatomic, readwrite) BOOL useNetwork;
@property (nonatomic, readwrite) BOOL useNetworkUnderWifiOnly;
@property (nonatomic, readwrite) NSInteger lanchCnt;

@property (nonatomic, readwrite) NSInteger cropUseCnt;
@property (nonatomic, readwrite) NSInteger surgeryUseCnt;
@property (nonatomic, readwrite) NSInteger filterUseCnt;
@property (nonatomic, readwrite) NSInteger aviaryUseCnt;

@property (nonatomic, readwrite) NSTimeInterval giveRatingTime;
@property (nonatomic, readwrite) BOOL hasForceShared;

@property (nonatomic, readwrite) BOOL everShowGuide;

-(BOOL)hasRating;
@end
