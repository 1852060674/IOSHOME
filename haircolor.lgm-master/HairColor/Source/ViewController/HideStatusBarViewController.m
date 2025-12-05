//
//  HideStatusBarViewController.m
//  PlasticDoctor
//
//  Created by ZB_Mac on 16/1/24.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "HideStatusBarViewController.h"

@implementation HideStatusBarViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

-(BOOL)prefersStatusBarHidden
{
    //return YES;
    return NO;
}
@end
