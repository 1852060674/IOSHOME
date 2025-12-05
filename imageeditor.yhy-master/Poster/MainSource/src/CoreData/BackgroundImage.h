//
//  BackgroundImage.h
//  Collage
//
//  Created by shen on 13-6-27.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BackgroundImage : NSManagedObject

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) NSNumber * userTimes;
@property (nonatomic, retain) NSDate * lastUseTime;

@end
