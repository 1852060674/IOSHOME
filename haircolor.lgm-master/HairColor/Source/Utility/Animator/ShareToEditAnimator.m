//
//  ShareToEditAnimator.m
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/9.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "ShareToEditAnimator.h"
#import "ShareViewController.h"
#import "HairColorViewController.h"

@implementation ShareToEditAnimator
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    ShareViewController *fromVC = (ShareViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    HairColorViewController *toVC = (HairColorViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    [containerView addSubview:toVC.view];
    toVC.view.alpha = 0.0;
    
    UIView *fromView = [fromVC getContentView];
    UIView *toView = [toVC getContentView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[containerView convertRect:fromView.frame fromView:fromView.superview]];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = fromVC.originalImage;
    [containerView addSubview:imageView];
    
    NSLog(@"%s", __FUNCTION__);
    CGRect frame = [toVC.view convertRect:toView.frame fromView:toView.superview];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        imageView.frame = frame;
        toVC.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        [imageView removeFromSuperview];
        NSLog(@"Animate Transition End!");
    }];
}
@end
