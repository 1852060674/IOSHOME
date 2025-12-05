//
//  HairDyeDescriptor.h
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/12.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface HairDyeDescriptor : NSObject

@property (nonatomic, readwrite) BOOL locked;
@property (nonatomic, readwrite) BOOL RTLocked;

@property (nonatomic, readwrite) NSInteger mode;
@property (nonatomic, readwrite) CGFloat highlight;
@property (nonatomic, readwrite) CGFloat alpha;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSString *dyeGroupName;
@property (nonatomic, readwrite) NSInteger dyeGroupIndex;

-(UIImage *)hairDyeImage:(UIImage *)image withMaskImage:(UIImage *)maskImage;

-(NSArray *)getPreparedSplineCurve:(NSArray *)points;
@end
