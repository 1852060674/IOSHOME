//
//  AppDelegate.m
//  HairColor
//
//  Created by ZB_Mac on 2016/11/21.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "AppDelegate.h"
#import "Admob.h"
#import "ShareService.h"

#import "HairDyeDescriptor.h"
#import "ColorHairDyeDescriptor.h"
#import "ImageHairDyeDescriptor.h"
#import "ColorManger.h"
#import "UIColor+Hex.h"
#import "UIImage+Blend.h"
@import Flurry_iOS_SDK;

@interface AppDelegate ()
@property (nonatomic, weak) ColorManger *colorManger;

@end

@implementation AppDelegate

-(HairDyeDescriptor *)dyeDescriptorOfIndex:(NSIndexPath *)indexPath
{
    BOOL colorlocked = NO;
    BOOL colorRatingLocked = NO;
    NSString *value = nil;
    NSInteger mode;
    BOOL highlight;
    
    if (indexPath.section < [self.colorManger groupNumber]) {
        colorlocked = [self.colorManger colorLockAtPath:indexPath];
        colorRatingLocked = [self.colorManger colorRatingLockAtPath:indexPath];
        value = [self.colorManger colorValueAtPath:indexPath];
        mode = [self.colorManger colorationModeAtPath:indexPath];
        highlight = [self.colorManger colorationHighlightAtPath:indexPath];
    }
    else
    {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-[self.colorManger groupNumber]];
        colorlocked = [[ColorManger defaultUserManger] colorLockAtPath:indexPath];
        colorRatingLocked = [[ColorManger defaultUserManger] colorRatingLockAtPath:indexPath];
        value = [[ColorManger defaultUserManger] colorValueAtPath:indexPath];
        mode = [[ColorManger defaultUserManger] colorationModeAtPath:indexPath];
        highlight = [[ColorManger defaultUserManger] colorationHighlightAtPath:indexPath];
    }
    
    HairDyeDescriptor *dyeDescriptor;
    
    /// TODO: 0,1,2,3 & 4,5 should use different coloring algorithm
    switch (mode) {
        case 0:
        case 1:
        case 2:
        case 3:
        {
            ColorHairDyeDescriptor *colorDyeDescriptor = [[ColorHairDyeDescriptor alloc] init];
            colorDyeDescriptor.color = [UIColor colorWithHexString:value];
            
            dyeDescriptor = colorDyeDescriptor;
            break;
        }
        case 4:
        case 5:
        {
            ImageHairDyeDescriptor *imageDyeDescriptor = [[ImageHairDyeDescriptor alloc] init];
            imageDyeDescriptor.dyeImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:value ofType:nil]];
            
            dyeDescriptor = imageDyeDescriptor;
            break;
        }
        default:
            break;
    }
    
    dyeDescriptor.locked = colorlocked;
    dyeDescriptor.RTLocked = colorRatingLocked;
    dyeDescriptor.indexPath = indexPath;
    dyeDescriptor.highlight = 0.65;
    dyeDescriptor.alpha = 1.0;
    dyeDescriptor.dyeGroupName = [self.colorManger groupNameAtIndex:indexPath.section];
    dyeDescriptor.dyeGroupIndex = [self.colorManger groupIndexAtIndex:indexPath.section];
    
    return dyeDescriptor;
}

-(void)genHairColorIcon
{
    self.colorManger = CM;
    
    NSInteger headerCnt = self.colorManger.groupNumber;
    
    UIImage *srcImage = [UIImage imageNamed:@"btn_hair_sample"];
    
    UIImage *dstImage;
    
    //    NSInteger idx = 2;
    for (NSInteger idx=2; idx<headerCnt; ++idx)
    {
        NSInteger detailCnt = [self.colorManger colorNumberAtIndex:idx];
        
        for (NSInteger cIndex=0; cIndex<detailCnt; ++cIndex) {
            
            HairDyeDescriptor *descriptor =  [self dyeDescriptorOfIndex:[NSIndexPath indexPathForRow:cIndex inSection:idx]];
            
            dstImage = [descriptor hairDyeImage:srcImage withMaskImage:srcImage];
            
            dstImage = [dstImage imageMaskedWithImage:srcImage];
            
            NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *ddPath =  [pathArray objectAtIndex:0];
            
            NSString *relativePathSmall = [NSString stringWithFormat:@"%d_%d.png", (int)descriptor.dyeGroupIndex, (int)descriptor.indexPath.row];
            NSString *originalPathSmall = [ddPath stringByAppendingPathComponent:relativePathSmall];
            NSData *data = UIImagePNGRepresentation(dstImage);
            [data writeToFile:originalPathSmall atomically:YES];
            
            //            dstImage = dstImage;
        }
    }
}

-(void)genConfiguration
{
    
    NSMutableArray *groups_1 = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"systemcolors" ofType:@"plist"]];
    
    NSMutableArray *groups_2 = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"systemcolors" ofType:@"plist"]];
    
    [groups_1 removeObjectsInRange:NSMakeRange(3, groups_1.count-3)];
    
    NSArray *groupIndexs= @[
                            @(1),
                            @(3),
                            @(4),
                            @(5),
                            @(6),
                            @(7),
                            ];
    
    for (NSInteger i=0; i<groups_2.count; ++i) {
        
        NSMutableDictionary *group_2 = groups_2[i];
        NSMutableArray *colors_2 = group_2[@"groupColors"];
        
        NSMutableDictionary *group_1 = [NSMutableDictionary new];
        NSMutableArray *colors_1 = [NSMutableArray new];
        
        group_1[@"groupLock"] = @(NO);
        group_1[@"groupName"] = group_2[@"groupName"];
        group_1[@"groupCoverIcon"] = group_2[@"groupCoverIcon"];
        group_1[@"groupIndex"] = groupIndexs[i];
        
        for (NSInteger j=0; j<colors_2.count; ++j) {
            NSMutableDictionary *color_2 = colors_2[j];
            NSMutableDictionary *color_1 = [NSMutableDictionary new];
            
            color_1[@"colorLock"] = color_2[@"colorLock"];
            color_1[@"colorRatingLock"] = @(NO);
            color_1[@"colorValue"] = color_2[@"colorValue"];
            color_1[@"colorIcon"] = [NSString stringWithFormat:@"%d_%d.png", (int)[group_1[@"groupIndex"] intValue], (int)j];
            color_1[@"colorationMode"] = @(2);
            color_1[@"colorationHighlight"] = @(YES);
            color_1[@"colorationHighlightFactor"] = @(0.65);
            
            [colors_1 addObject:color_1];
        }
        
        group_1[@"groupColors"] = colors_1;
        
        [groups_1 addObject:group_1];
    }
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ddPath =  [pathArray objectAtIndex:0];
    NSString *path = [ddPath stringByAppendingPathComponent:@"systemcolor_3.plist"];
    
    [groups_1 writeToFile:path atomically:YES];
}

-(void)genConfiguration_1
{
    NSMutableArray *groups_2 = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"systemcolors" ofType:@"plist"]];
    
    NSMutableArray *groups_1 = [NSMutableArray array];
    
    for (NSInteger i=0; i<groups_2.count; ++i) {
        
        NSMutableDictionary *group_2 = groups_2[i];
        NSMutableArray *colors_2 = group_2[@"groupColors"];
        
        NSMutableDictionary *group_1 = [NSMutableDictionary new];
        NSMutableArray *colors_1 = [NSMutableArray new];
        
        group_1[@"groupLock"] = group_2[@"groupLock"];
        group_1[@"groupName"] = group_2[@"groupName"];
        group_1[@"groupCoverIcon"] = group_2[@"groupCoverIcon"];
        group_1[@"groupIndex"] = group_2[@"groupIndex"];
        
        for (NSInteger j=0; j<colors_2.count; ++j) {
            NSMutableDictionary *color_2 = colors_2[j];
            NSMutableDictionary *color_1 = [NSMutableDictionary new];
            
            color_1[@"colorLock"] = color_2[@"colorLock"];
            color_1[@"colorRatingLock"] = color_2[@"colorRatingLock"];
            color_1[@"colorValue"] = color_2[@"colorValue"];
            color_1[@"colorIcon"] = color_2[@"colorIcon"];
            color_1[@"colorationMode"] = color_2[@"colorationMode"];
            color_1[@"colorationHighlight"] = color_2[@"colorationHighlight"];
            
            if (!color_2[@"colorationHighlightFactor"]) {
                color_1[@"colorationHighlightFactor"] = @(0.65);
            }
            else
            {
                color_1[@"colorationHighlightFactor"] = color_2[@"colorationHighlightFactor"];
            }
            
            [colors_1 addObject:color_1];
        }
        
        group_1[@"groupColors"] = colors_1;
        
        [groups_1 addObject:group_1];
    }
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ddPath =  [pathArray objectAtIndex:0];
    NSString *path = [ddPath stringByAppendingPathComponent:@"systemcolor_3.plist"];
    
    [groups_1 writeToFile:path atomically:YES];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [AdmobViewController shareAdmobVC];
    [[ShareService defaultService] initializeService];
    [Flurry startSession:@"R8N426F3YDWSTJSCT8SJ"];
    [self genConfiguration_1];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
