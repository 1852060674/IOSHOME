//
//  MGData.m
//  TextPictureLite
//
//  Created by tangtaoyu on 15-3-2.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "MGData.h"
#import "MGDefine.h"
#import "Admob.h"

@implementation MGData

+ (MGData*)Instance
{
    static dispatch_once_t once;
    static id singleton;
    dispatch_once(&once, ^{
        singleton = [[self alloc] init];
    });
    
    return singleton;
}

- (id)init
{
    if(self = [super init]){
        self.launchCount = [MGData currentLaunchCount];
        if(self.launchCount == 1){
            self.lockStatus = YES;
            self.adHeight = kSmartAdHeight;
        }
        
        self.adsBeginTime = 0;
    }
    
    return self;
}

+ (NSArray*)getVoiceChanger
{
    //速度 <变速不变调> 范围 -50 ~ 100
    //音调  范围 -12 ~ 12
    //声音速率 范围 -50 ~ 100
    
    NSArray *array = @[@{kTempo:@0, kPitch:@0, kRate:@0},
                       @{kTempo:@22, kPitch:@8, kRate:@0},
                       @{kTempo:@0, kPitch:@(-4), kRate:@0},
                       @{kTempo:@0, kPitch:@(4), kRate:@0},
                       @{kTempo:@(-30), kPitch:@0, kRate:@(-8)},
                       @{kTempo:@60, kPitch:@0, kRate:@0},
                       @{kTempo:@(-40), kPitch:@0, kRate:@0},
                       @{kTempo:@0, kPitch:@0, kRate:@0},
                       ];
    
    //22,8,0 小孩
    
    
    return array;
}

+ (BOOL)tryShowAdsInVC:(UIViewController*)viewController
{
    NSInteger first_time = [MGData Instance].adsBeginTime;
    NSInteger now_time = time(NULL);
    
    if(now_time-first_time>kAdsTime){
        BOOL isShowAds = [[AdmobViewController shareAdmobVC] show_admob_interstitial:viewController];
        
        if(!isShowAds){
            [MGData Instance].adsBeginTime = 0;
            return NO;
        }else{
            [MGData Instance].adsBeginTime = now_time;
            return YES;
        }
    }
    
    return NO;
}

+ (NSInteger)currentLaunchCount
{
    NSInteger lc = [[NSUserDefaults standardUserDefaults] integerForKey:kMGLaunchCount];
    lc++;
    [[NSUserDefaults standardUserDefaults] setInteger:lc forKey:kMGLaunchCount];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] integerForKey:kMGLaunchCount];
}

- (void)setLaunchCount:(NSInteger)newValue
{
    [[NSUserDefaults standardUserDefaults] setInteger:newValue forKey:kMGLaunchCount];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)launchCount
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kMGLaunchCount];
}

- (void)setAdHeight:(float)newValue
{
    [[NSUserDefaults standardUserDefaults] setFloat:newValue forKey:kMGAdHeightKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (float)adHeight
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:kMGAdHeightKey];
}

- (void)setLockStatus:(BOOL)newValue
{
    [[NSUserDefaults standardUserDefaults] setBool:newValue forKey:kMGLockStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)lockStatus
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kMGLockStatus];
}

- (void)setFilterCateIndex:(NSInteger)newValue
{
    [[NSUserDefaults standardUserDefaults] setInteger:newValue forKey:kMGFilterCateIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)filterCateIndex
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kMGFilterCateIndex];
}

- (void)setFilterNumIndex:(NSInteger)newValue
{
    [[NSUserDefaults standardUserDefaults] setInteger:newValue forKey:kMGFilterNumIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)filterNumIndex
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kMGFilterNumIndex];
}

+ (void)setPhotoIndex:(NSInteger)index
{
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:kMGPhotoIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)getPhotoIndex
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kMGPhotoIndex];
}

+ (void)pushFavArts:(NSString*)string
{
    NSMutableArray *hisArr = [[MGData getFavArts] mutableCopy];
    
    BOOL isInHis = NO;
    for(NSString *str in hisArr){
        if([str isEqualToString:string]){
            isInHis = YES;
        }
    }
    
    if(!isInHis){
        [hisArr addObject:string];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:hisArr forKey:kMGFavArts];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)popFavArts:(NSInteger)index
{
    NSMutableArray *hisArr = [[MGData getFavArts] mutableCopy];
    
    [hisArr removeObjectAtIndex:index];
    
    [[NSUserDefaults standardUserDefaults] setObject:hisArr forKey:kMGFavArts];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray*)getFavArts
{
    NSMutableArray *mutableArr = [[NSUserDefaults standardUserDefaults] objectForKey:kMGFavArts];
    NSArray *favArts = [NSArray arrayWithArray:mutableArr];
    
    return favArts;
}

+ (BOOL)num:(NSInteger)index isInArray:(NSArray*)array
{
    BOOL isIn = NO;
    for(int i=0; i<array.count; i++){
        if(index == [array[i] integerValue]){
            isIn = YES;
            break;
        }
    }
    
    return isIn;
}

+ (NSInteger)numIndex:(NSInteger)index isInArray:(NSArray*)array
{
    BOOL isIn = NO;
    NSInteger inIndex = 0;
    for(int i=0; i<array.count; i++){
        if(index == [array[i] integerValue]){
            isIn = YES;
            inIndex = i;
            break;
        }
    }
    
    return inIndex;
}

+ (NSArray*)SortOfIndexPath:(NSArray*)array
{
    NSMutableArray *Arr = [[NSMutableArray alloc] init];
    for(int i=0; i<array.count; i++){
        NSIndexPath *indexPath = array[i];
        NSInteger index = indexPath.row;
        
        [Arr addObject:[NSNumber numberWithInteger:index]];
    }
    
    NSArray *sortArr = [Arr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *num1 = obj1;
        NSNumber *num2 = obj2;
        
        NSComparisonResult result = [num1 compare:num2];
        
        //return result == NSOrderedDescending; //升序
        return result == NSOrderedAscending;  //降序
    }];
    
    return sortArr;
}


@end
