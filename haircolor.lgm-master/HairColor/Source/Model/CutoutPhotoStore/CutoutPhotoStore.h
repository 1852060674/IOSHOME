//
//  PhotoStore.h
//  OldBooth
//
//  Created by ZB_Mac on 14-10-23.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface CutoutPhotoStore : NSObject
+(CutoutPhotoStore *)defaultStore;
-(NSInteger)removeAllItems;
-(NSInteger)removeItemAtIndex:(NSInteger)index;
-(CGFloat) photoStoreDiskUsage;

// api 1.0
-(NSInteger)addItemBigImage:(UIImage *)bigImage andSmallImage:(UIImage *)smallImage andBackgroundImage:(UIImage *)backImage andForegroundImage:(UIImage *)foreImage;
-(NSInteger)updateItemAtIndex:(NSInteger)index withBigImage:(UIImage *)bigImage andSmallImage:(UIImage *)smallImage andBackgroundImage:(UIImage *)backImage andForegroundImage:(UIImage *)foreImage;

-(NSInteger)itemNumber;
-(UIImage *)bigImageAtIndex:(NSInteger)index;
-(UIImage *)smallImageAtIndex:(NSInteger)index;
-(UIImage *)backImageAtIndex:(NSInteger)index;
-(UIImage *)foreImageAtIndex:(NSInteger)index;

-(NSString *)bigImagePathAtIndex:(NSInteger)index;
-(NSString *)smallImagePathAtIndex:(NSInteger)index;
-(NSString *)backImagePathAtIndex:(NSInteger)index;
-(NSString *)foreImagePathAtIndex:(NSInteger)index;

// api 2.0
-(NSInteger)addItemSmallImage:(UIImage *)smallImage andOriginalImage:(UIImage *)originalImage andMaskImage:(UIImage *)maskImage andBigImage:(UIImage *)bigImage;
-(NSInteger)addItemSmallImage:(UIImage *)smallImage andOriginalImage:(UIImage *)originalImage andMaskImage:(UIImage *)maskImage andBigImage:(UIImage *)bigImage atIndex:(NSInteger)index;
-(NSInteger)updateItemAtIndex:(NSInteger)index withSmallImage:(UIImage *)smallImage andOriginalImage:(UIImage *)originalImage andMaskImage:(UIImage *)maskImage andBigImage:(UIImage *)bigImage;

-(float) itemAPIVersionAtIndex:(NSInteger)index;

-(UIImage *)originalImageAtIndex:(NSInteger)index;
-(UIImage *)maskImageAtIndex:(NSInteger)index;

-(NSString *)originalImagePathAtIndex:(NSInteger)index;
-(NSString *)maskImagePathAtIndex:(NSInteger)index;

@end
