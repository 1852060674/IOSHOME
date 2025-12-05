//
//  GlobalSettingManger.h
//  eyeColorPlus
//
//  Created by shen on 14-7-22.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettingManger : NSObject
+(UserSettingManger *)defaultManger;
@property (nonatomic, readwrite) NSInteger resolution;
@property (nonatomic, readwrite) BOOL autoSave;
@property (nonatomic, readwrite) BOOL feather;
@property (nonatomic, readwrite) BOOL smoothEdge;
@property (nonatomic, readwrite) BOOL accurateCut;
@property (nonatomic, readwrite) BOOL autoSaveCutSystem;
@property (nonatomic, readwrite) BOOL autoSaveCutApp;

@property (nonatomic, readwrite) BOOL useNetwork;
@property (nonatomic, readwrite) BOOL useNetworkUnderWifiOnly;

-(float)getRealResolution;
@end
