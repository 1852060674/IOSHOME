//
//  MGData.h
//  TextPictureLite
//
//  Created by tangtaoyu on 15-3-2.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAdsTime    45.0

#define kMGAdHeightKey @"MGAdHeight"
#define kMGLockStatus @"MGLockStatus"
#define kMGFavArts @"MGFavArts"
#define kMGLaunchCount @"MGLaunchCount"

#define kMGPhotoIndex @"MGPhotoIndex"

#define kMGFilterCateIndex  @"MGFilterCateIndex"
#define kMGFilterNumIndex  @"MGFilterNumIndex"

#define kTempo  @"Tempo"
#define kPitch  @"Pitch"
#define kRate   @"Rate"

@interface MGData : NSObject

@property (assign, nonatomic) NSInteger launchCount;
@property (assign, nonatomic) float adHeight;
@property (assign, nonatomic) BOOL lockStatus;
@property (assign, nonatomic) NSInteger adsBeginTime;


+ (MGData*)Instance;

+ (NSArray*)getVoiceChanger;

+ (void)setPhotoIndex:(NSInteger)index;
+ (NSInteger)getPhotoIndex;

+ (void)pushFavArts:(NSString*)string;
+ (void)popFavArts:(NSInteger)index;
+ (NSArray*)getFavArts;

+ (BOOL)num:(NSInteger)index isInArray:(NSArray*)array;
+ (NSInteger)numIndex:(NSInteger)index isInArray:(NSArray*)array;

+ (NSArray*)SortOfIndexPath:(NSArray*)array;

+ (BOOL)tryShowAdsInVC:(UIViewController*)viewController;

@end
