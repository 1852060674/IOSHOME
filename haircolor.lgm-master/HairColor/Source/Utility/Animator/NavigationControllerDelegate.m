//
//  NavigationControllerDelegate.m
//  CartoonCutout
//
//  Created by ZB_Mac on 16/5/4.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "NavigationControllerDelegate.h"

#import "HairColorViewController.h"
#import "ShareViewController.h"

#import "EditToShareAnimator.h"
#import "ShareToEditAnimator.h"

@implementation NavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush && [fromVC isKindOfClass:[HairColorViewController class]] && [toVC isKindOfClass:[ShareViewController class]])
    {
        return [EditToShareAnimator new];
    }
    else if (operation == UINavigationControllerOperationPop && [fromVC isKindOfClass:[ShareViewController class]] && [toVC isKindOfClass:[HairColorViewController class]])
    {
        return [ShareToEditAnimator new];
    }
    
    return nil;
}
@end
