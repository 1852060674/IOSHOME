//
//  SmilingFace.h
//  PicFrame
//
//  Created by shen on 13-6-18.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SmilingFace : NSManagedObject

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) NSNumber * userTimes;
@property (nonatomic, retain) NSDate * lastUseTime;

@end
