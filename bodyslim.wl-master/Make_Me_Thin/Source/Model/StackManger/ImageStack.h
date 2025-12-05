//
//  ImageStack.h
//  EyeColor4.0
//
//  Created by ZB_Mac on 15-1-20.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageStack : NSObject
-(instancetype)initWithMaxSize:(NSInteger)size andSupportRedo:(BOOL)supportRedo;
-(void)reset;
-(void)pushImage:(UIImage *)image;
-(void)replaceTopImage:(UIImage *)image;
-(void)deleteUnWantedImage;
-(UIImage *)getRedoImage;
-(UIImage *)getUndoImage;
-(BOOL)canRedo;
-(BOOL)canUndo;
@end
