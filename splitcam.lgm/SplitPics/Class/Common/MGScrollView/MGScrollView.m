//
//  MGScrollView.m
//
//  Created by tangtaoyu on 15-1-15.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "MGScrollView.h"

@implementation MGScrollView

- (id)init
{
    self = [super init];
    
    self.canCancelContentTouches = YES;
    self.delaysContentTouches = NO;

    return self;
}


- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    
    if ( [view isKindOfClass:[UIButton class]] ) {
        return YES;
    }
    
    return [super touchesShouldCancelInContentView:view];
    //return YES;
}

@end
