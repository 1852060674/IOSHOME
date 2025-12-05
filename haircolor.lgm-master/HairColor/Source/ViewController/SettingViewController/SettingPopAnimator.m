//
//  SettingPopAnimator.m
//  CutMeIn
//
//  Created by ZB_Mac on 16/8/4.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "SettingPopAnimator.h"

@implementation SettingPopAnimator
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    //    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    UIView *containerView = [transitionContext containerView];
//    
//    [containerView addSubview:toVC.view];
//    toVC.view.alpha = 0.0;
//    
//    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//        toVC.view.alpha = 1.0;
//    } completion:^(BOOL finished) {
//        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//    }];

    UIViewController *fromViewController = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    CGRect fromVCInitialFrame = [transitionContext initialFrameForViewController:fromViewController];
    NSLog(@"fromVCInitialFrame: %@", NSStringFromCGRect(fromVCInitialFrame));
    CGRect fromVCFinalFrame = [transitionContext finalFrameForViewController:fromViewController];
    NSLog(@"fromVCFinalFrame: %@", NSStringFromCGRect(fromVCFinalFrame));
    
    CGRect toVCInitialFrame = [transitionContext initialFrameForViewController:toViewController];
    NSLog(@"toVCInitialFrame: %@", NSStringFromCGRect(toVCInitialFrame));
    CGRect toVCFinalFrame = [transitionContext finalFrameForViewController:toViewController];
    NSLog(@"toVCFinalFrame: %@", NSStringFromCGRect(toVCFinalFrame));
    
    fromVCFinalFrame = fromVCInitialFrame;
    fromVCFinalFrame.origin.x += CGRectGetWidth(fromVCFinalFrame);
    
    toVCInitialFrame = toVCFinalFrame;
    toVCInitialFrame.origin.x -= CGRectGetWidth(toVCInitialFrame)*0.5;
    
    toViewController.view.frame = toVCInitialFrame;
    
    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    [UIView animateWithDuration:duration animations:^{
        fromViewController.view.frame = fromVCFinalFrame;
        toViewController.view.frame = toVCFinalFrame;
        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        
    }];
}
@end
