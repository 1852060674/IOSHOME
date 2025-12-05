//
//  PhotoStore.h
//  OldBooth
//
//  Created by ZB_Mac on 14-10-23.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface PhotoStore : NSObject
+(PhotoStore *)defaultStore;

+(PhotoStore *)photoStoreWithIdentifier:(NSString *)identifier;
-(PhotoStore *)initWithIdentifier:(NSString *)identifier;
-(NSInteger)removeAllItems;
-(NSInteger)removeItemAtIndex:(NSInteger)index;
-(CGFloat) photoStoreDiskUsage;

-(NSInteger)addItemImage:(UIImage *)image andSmallImage:(UIImage *)smallImage andMaskImage:(UIImage *)maskImage;
-(NSInteger)updateItemAtIndex:(NSInteger)index withImage:(UIImage *)image andSmallImage:(UIImage *)smallImage andMaskImage:(UIImage *)maskImage;

-(NSInteger)itemNumber;
-(UIImage *)imageAtIndex:(NSInteger)index;
-(NSString *)imagePathAtIndex:(NSInteger)index;

-(NSString *)smallImagePathAtIndex:(NSInteger)index;
-(UIImage *)smallImageAtIndex:(NSInteger)index;

-(NSString *)maskImagePathAtIndex:(NSInteger)index;
-(UIImage *)maskImageAtIndex:(NSInteger)index;
@end
