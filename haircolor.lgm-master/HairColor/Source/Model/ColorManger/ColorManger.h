//
//  ColorManger.h
//  HairColor
//
//  Created by ZB_Mac on 15/5/11.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define CM [ColorManger systemManger]
#define CM2 [ColorManger systemManger_2]

@interface ColorManger : NSObject
+(ColorManger *)systemManger;
+(ColorManger *)systemManger_2;

+(ColorManger *)defaultUserManger;

-(NSInteger)groupNumber;
-(BOOL)groupLockAtIndex:(NSInteger)groupIdx;
-(NSString *)groupCoverIconAtIndex:(NSInteger)groupIdx;
-(NSString *)groupNameAtIndex:(NSInteger)groupIdx;
-(NSInteger)groupIndexAtIndex:(NSInteger)groupIdx;

-(NSInteger)colorNumberAtIndex:(NSInteger)groupIdx;
-(BOOL)colorLockAtPath:(NSIndexPath *)path;
-(BOOL)colorRatingLockAtPath:(NSIndexPath *)path;

-(NSString *)colorIconPathAtPath:(NSIndexPath *)path;
-(UIImage *)colorIconAtPath:(NSIndexPath *)path;

-(NSString *)colorValueAtPath:(NSIndexPath *)path;
-(BOOL)colorationHighlightAtPath:(NSIndexPath *)path;
-(NSInteger)colorationModeAtPath:(NSIndexPath *)path;
-(CGFloat)colorationHighlightFactorAtPath:(NSIndexPath *)path;

// defaultUserManger only
-(void)addCustomColor:(NSString *)colorValue;
//-(void)addMatchColor:(NSString *)colorValue;
@end
