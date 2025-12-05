//
//  BHCommenMethod.m
//  PicFrame
//
//  Created by shen on 13-6-13.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import "BHCommenMethod.h"

static NSUInteger uniqueTag = 0;
@implementation BHCommenMethod

+ (NSUInteger)getAUniqueTag
{
    return uniqueTag++;
}



@end
