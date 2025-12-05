//
//  MGData.h
//  TextPictureLite
//
//  Created by tangtaoyu on 15-3-2.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AdmobViewController;

#define kAdsTime 20

#define kGetDown   @"GetDown"
#define kDownStart @"downStart"

#define kMGAdHeightKey @"MGAdHeight"
#define kMGLockStatus @"MGLockStatus"
#define kMGFavArts @"MGFavArts"
#define kMGLaunchCount @"MGLaunchCount"
#define kMGPhotoCount @"MGPhotoCount"
#define kMGPhotoIndex @"MGPhotoIndex"

#define kMGFilterCateIndex  @"MGFilterCateIndex"
#define kMGFilterNumIndex  @"MGFilterNumIndex"

@interface MGData : NSObject

@property (assign, nonatomic) NSInteger launchCount;
@property (assign, nonatomic) BOOL lockStatus;
@property (assign, nonatomic) NSInteger photoCount;
@property (assign, nonatomic) NSInteger adsBeginTime;
@property (assign, nonatomic) NSInteger downCount;

@property (assign, nonatomic) BOOL isPresentedInSwitch;

+ (MGData*)Instance;


+ (void)setPhotoIndex:(NSInteger)index;
+ (NSInteger)getPhotoIndex;

+ (void)pushFavArts:(NSString*)string;
+ (void)popFavArts:(NSInteger)index;
+ (NSArray*)getFavArts;

+ (BOOL)num:(NSInteger)index isInArray:(NSArray*)array;
+ (NSInteger)numIndex:(NSInteger)index isInArray:(NSArray*)array;

+ (NSArray*)getLockArray;
+ (NSArray*)getLockLockArray;

+ (NSInteger)addCount;
+ (void)mgDownWith:(NSString*)numStr;
+ (BOOL)tryShowAds:(AdmobViewController*)admobVC inVC:(UIViewController*)viewController;
+ (BOOL)showAds:(AdmobViewController*)admobVC inVC:(UIViewController*)viewController;

+ (BOOL)isUseZhHans;
+ (BOOL)isIpad2;

@end
