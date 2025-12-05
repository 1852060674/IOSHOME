//
//  BHImageDataModeld.h
//  PicFrame
//
//  Created by shen on 13-6-18.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SmilingFace.h"
#import "PhotoFrame.h"
#import "BackgroundImage.h"

@interface BHImageDataModeld : NSObject

//sticker
- (NSArray*)querySmilingFaceFromDB;

- (void)updateSmilingFaceInfo:(SmilingFace*)entry;

- (void)updateSmilingFaceInfoForImageName:(NSString*)imageName;

//frame
- (NSArray*)queryFrameFromDB;

- (void)updateFrameInfoForImageName:(NSString*)imageName;

//background image
- (NSArray*)queryBackgroundFromDB;

- (void)updateBackgroundInfoForImageName:(NSString*)imageName;
@end
