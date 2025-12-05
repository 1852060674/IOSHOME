//
//  Comom.m
//  Hearts
//
//  Created by IOS2 on 2024/3/21.
//  Copyright © 2024 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comom.h"
#import "config.h"
#import "zhconfig.h"
@implementation Comom
-(void)loadSetting{
    /// default
    BOOL classicCard = CLASSIC_CARD;
    BOOL orientation = YES;//!(IPHONE_LANDSCAPE);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        classicCard = YES;
        orientation = YES;
    }
    //定义两套初始化皮肤number.1
    NSLog(@"test first1 coming");
    NSDictionary *defaultValue=nil;
    if ([self Isoladman]) {
        defaultValue = [NSDictionary dictionaryWithObjectsAndKeys:@"CardBack-BlueGrid",@"cardback",
                        @"RedFelt",@"background",
                        [NSNumber numberWithInteger:0],@"level",
                        [NSNumber numberWithBool:YES],@"sound",
                        [NSNumber numberWithBool:YES],@"timemoves",
                        [NSNumber numberWithBool:orientation],@"orientation",
                        [NSNumber numberWithBool:YES],@"hints",
                        [NSNumber numberWithBool:TAP_MOVE],@"tapmove",
                        [NSNumber numberWithBool:NO],@"gamecenter",
                        [NSNumber numberWithBool:NO],@"holiday",
                        [NSNumber numberWithBool:NO],@"congra",
                        [NSNumber numberWithInt:1],@"speed",
                        [NSNumber numberWithInteger:orientation ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeRight],@"currentori",
                        [NSNumber numberWithBool:classicCard],@"classic",
                        [NSNumber numberWithInt:0],@"cnt",
                        [NSNumber numberWithBool:NO],@"rated",
                        [NSNumber numberWithInt:0],@"popratecnt",
                        nil];
    }else{
        defaultValue = [NSDictionary dictionaryWithObjectsAndKeys:@"cardback39",@"cardback",
                        @"bg0",@"background",
                        @"4",@"cardfront",
                        @[], customCardBgListKey,
                        @[], customDeskBgListKey,
                        [NSNumber numberWithInteger:0],@"level",
                        [NSNumber numberWithBool:YES],@"sound",
                        [NSNumber numberWithBool:YES],@"timemoves",
                        [NSNumber numberWithBool:orientation],@"orientation",
                        [NSNumber numberWithBool:YES],@"hints",
                        [NSNumber numberWithBool:TAP_MOVE],@"tapmove",
                        [NSNumber numberWithBool:NO],@"gamecenter",
                        [NSNumber numberWithBool:NO],@"holiday",
                        [NSNumber numberWithBool:NO],@"congra",
                        [NSNumber numberWithInt:1],@"speed",
                        [NSNumber numberWithInt:0],@"cnt",
                        [NSNumber numberWithInteger:orientation ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeRight],@"currentori",
                        [NSNumber numberWithBool:classicCard],@"classic",
                        [NSNumber numberWithBool:NO],@"rated",
                        [NSNumber numberWithInt:0],@"popratecnt",
                        nil];
    }
    
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings registerDefaults:defaultValue];
    [settings synchronize];
}
-(BOOL)Isoladman{
    // New_Boy_Comming 是判断第一次是老用户还是薪用户
    NSUserDefaults* settings1 = [NSUserDefaults standardUserDefaults];
    id obj = [settings1 objectForKey:New_Boy_Comming];
    id obj1 = [settings1 objectForKey:@"changetoNewMan"];
    BOOL NewMan =[settings1 boolForKey:@"changetoNewMan"];
    if (obj == nil) {
        // 说嘛此前已经进入过了是老用户
//        oldman =true;
    }
    if (obj1 == nil && obj == nil) {
        // 说明此前没有改变新老用户状态
        return true;
    }
    if (NewMan) {
        return  false;
    }else{
        return true;
    }
}
@end
