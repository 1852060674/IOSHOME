//
//  MGFile.h
//  MagicCamera
//
//  Created by tangtaoyu on 15-4-21.
//  Copyright (c) 2015年 tangtaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPhotoDir  @"Voice"
#define kPathSaveFile  @"mgVoice.plist"

#define kNormalPhotoName @"mgNormalPhoto"
#define kThumbPhotoName  @"mgThumbPhoto"

#define kVoiceNum    @"voiceNum"
#define kVoiceName   @"voiceName"
#define kVoiceCate   @"voiceCate"
#define kVoiceTime   @"voiceTime"
#define kVoiceCustom @"voiceCustom"
#define kVoiceDate   @"voiceDate"


#define kVoiceIndex  @"voiceIndex"


@interface MGFile : NSObject

@property (assign, nonatomic) NSInteger voiceIndex;

+ (MGFile*)Instance;

//获取应用沙盒根路径
+ (NSString*)dirHome;

//获取Documents目录
+ (NSString*)dirDoc;

//获取Library目录
+ (NSString*)dirLib;

//获取Cache目录
+ (NSString*)dirCache;

//获取Tmp目录
+ (NSString*)dirTmp;

//获取path下所有文件路径
+ (NSArray*)getSubPathFromDic:(NSString*)path;
//获取path下所有文件夹路径
+ (NSArray*)getSubDicPathFromDic:(NSString*)path;

//Magic Camera
+ (NSString*)getFilePathOfFile:(NSString*)string;
+ (NSArray*)getImageFileNameArray;
+ (void)popImagePathWith:(NSString*)fileName WithType:(NSInteger)type;
+ (void)pushImagePathWith:(NSString*)fileName WithType:(NSInteger)type;
+ (void)saveImageWithData:(NSData*)imageData WithFileName:(NSString*)fileName;
+ (void)removeImageWith:(NSString*)filePath;
+ (NSInteger)getImageCount;

//VoiceChanger
+ (NSArray*)getVoiceFileNameArray;
+ (void)pushVoiceOriWith:(NSString*)fileName;
+ (void)popVoiceOriWith:(NSString*)fileName;
+ (void)pushVoicePathWith:(NSDictionary*)dict;
+ (void)popVoicePathWith:(NSDictionary*)dict;
+ (BOOL)dict:(NSDictionary*)dict isInArray:(NSArray*)array;
+ (void)removeVoiceWith:(NSString*)fileName;

@end
