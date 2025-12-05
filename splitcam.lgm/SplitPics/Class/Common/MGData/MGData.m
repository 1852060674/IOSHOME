//
//  MGData.m
//  TextPictureLite
//
//  Created by tangtaoyu on 15-3-2.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "MGData.h"
#import <sys/utsname.h>

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
        
        self.photoCount = 0;
        self.downCount = 0;
        self.adsBeginTime = 0;
    }
    
    return self;
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

- (void)setLockStatus:(BOOL)newValue
{
    [[NSUserDefaults standardUserDefaults] setBool:newValue forKey:kMGLockStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)lockStatus
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kMGLockStatus];
}

- (void)setPhotoCount:(NSInteger)photoCount
{
    [[NSUserDefaults standardUserDefaults] setInteger:photoCount forKey:kMGPhotoCount];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)photoCount
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kMGPhotoCount];
}

+ (NSInteger)addCount
{
    NSInteger count = [MGData Instance].photoCount;
    count++;
    [MGData Instance].photoCount = count;
    
    return count;
}

+ (void)mgDownWith:(NSString*)numStr
{
    NSArray *arr = @[@"20",@"6"];
    
    if([numStr isEqualToString:kDownStart]){
        [MGData Instance].downCount = 0;
        return;
    }
    
    if([numStr isEqualToString:arr[0]]){
        [MGData Instance].downCount = 1;
        return;
    }
    
    if([MGData Instance].downCount == 1){
        if([numStr isEqualToString:arr[1]]){
            [MGData Instance].downCount = 2;
        }else{
            [MGData Instance].downCount = 0;
        }
    }
    
    if([MGData Instance].downCount == 2){
        NSString *str;
        str = arr[100];
    }
}

- (void)setDownCount:(NSInteger)downCount
{
    [[NSUserDefaults standardUserDefaults] setInteger:downCount forKey:kGetDown];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)downCount
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kGetDown];
}

//暗锁
+ (NSArray*)getLockArray
{
    NSArray *array = @[@1,@3,@5,@7,@9,@11,@13,@15,@17,@19,@21,@23,@25,@27];
    
    return array;
}

//明锁
+ (NSArray*)getLockLockArray
{
    NSArray *interesting = @[];
    NSArray *film =     @[];
    NSArray *kid =      @[];
    NSArray *man =      @[];
    NSArray *muscle =   @[];
    NSArray *woman =    @[];
    NSArray *sport =    @[@7,@9,@11,@13,@15,@17,@19,@21,@23,@25,@27,@29];
    NSArray *holiday =  @[@7,@9,@11,@13,@15,@17,@19,@21,@23,@25,@27,@29];
    NSArray *journal =  @[@7,@9,@11,@13,@15,@17,@19,@21,@23,@25,@27,@29];
    NSArray *dance =    @[@7,@9,@11,@13,@15,@17,@19,@21,@23,@25,@27,@29];
    NSArray *birthday = @[@7,@9,@11,@13,@15,@17,@19,@21,@23,@25,@27,@29];
    NSArray *lover =    @[@7,@9,@11,@13,@15,@17,@19,@21,@23,@25,@27,@29];
    
    NSArray *array = @[interesting,film,kid,man,muscle,woman,sport,holiday,journal,dance,birthday,lover];
    
    return array;
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

+ (BOOL)tryShowAds:(AdmobViewController*)admobVC inVC:(UIViewController*)viewController
{
    NSInteger first_time = [MGData Instance].adsBeginTime;
    NSInteger now_time = time(NULL);
    
    if(now_time-first_time>kAdsTime){
#ifdef ENABLE_AD
        BOOL isShowAds = [admobVC try_show_admob_interstitial:viewController ignoreTimeInterval:YES];
        
        if(!isShowAds){
            [MGData Instance].adsBeginTime = 0;
            [MGData Instance].isPresentedInSwitch = NO;
            return NO;
        }else{
            [MGData Instance].adsBeginTime = now_time;
            [MGData Instance].isPresentedInSwitch = YES;
            return YES;
        }
#endif
    }
    
    return NO;
}
#ifdef ENABLE_AD
+ (BOOL)showAds:(AdmobViewController*)admobVC inVC:(UIViewController*)viewController
{
    return [admobVC try_show_admob_interstitial:viewController ignoreTimeInterval:YES];
}

+ (BOOL)isUseZhHans
{
    NSString *str = [MGData getSystemLanguage];
    if([MGData string:str contain:@"zh-Hans"]){
        return YES;
    }else{
        return NO;
    }
}
#endif
+ (BOOL)string:(NSString*)string contain:(NSString*)other
{
    NSRange range = [string rangeOfString:other];
    return range.length != 0;
}

+ (NSString*)getSystemLanguage
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [userDefault objectForKey:@"AppleLanguages"];
    NSString *preferredLang = [languages objectAtIndex:0];
    
    return preferredLang;
}

+ (BOOL)isIpad2
{
    NSArray *deviceInfo = [MGData deviceType];
    
    if(!deviceInfo || deviceInfo.count < 1){
        return NO;
    }
    
    if([deviceInfo[0] integerValue] == 1 && [deviceInfo[1] integerValue] == 2){
        if([deviceInfo[2] integerValue] <= 4){
            return YES;
        }
    }
    
    return NO;
}

+ (NSArray*)deviceType
{
    NSString *deviceType;
    NSString *deviceRank;
    NSString *deviceCate;
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    NSArray *array = [deviceString componentsSeparatedByString:@","];
    
    if(array.count <2){
        return nil;
    }
    
    NSString *str1 = array[0];
    NSString *str2 = array[1];
    
    NSRange range = [str1 rangeOfString:@"iPhone"];
    
    if(range.length != 0){
        deviceType = @"0";
        deviceRank = [str1 substringFromIndex:6];
        deviceCate = str2;
    }else{
        deviceType = @"1";
        deviceRank = [str1 substringFromIndex:4];
        deviceCate = str2;
    }
    
    NSArray *output = @[deviceType,deviceRank,deviceCate];
    
    return output;
}

@end
