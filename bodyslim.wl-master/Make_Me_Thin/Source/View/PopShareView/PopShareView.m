//
//  PopShareView.m
//  Transsexual
//
//  Created by ZB_Mac on 15/10/21.
//  Copyright © 2015年 ZB_Mac. All rights reserved.
//

#import "PopShareView.h"
#import "UIView+LayoutConstraint.h"

@interface PopShareView ()
@end

@implementation PopShareView
- (IBAction)onCancel:(id)sender {
    [self hide];
}
- (IBAction)bgTap:(UITapGestureRecognizer *)sender {
    [self hide];   
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    self.shareOnLabel.text = NSLocalizedStringFromTable(@"SHARE_TO", @"PopShareView", @"");
    [self.cancelBtn setTitle:NSLocalizedStringFromTable(@"CANCEL", @"PopShareView", @"") forState:UIControlStateNormal];
}

-(void)show
{
    NSLayoutConstraint *showConstraint = [self layoutConstraintForIdentifier:@"showShareContainer"];

    showConstraint.constant = 0;

    [UIView animateWithDuration:0.5 animations:^{
        self.bgMaskView.alpha = 0.5;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        NSLog(@"%@", NSStringFromCGRect(self.frame));
    }];
}

-(void)hide
{
    NSLayoutConstraint *showConstraint = [self layoutConstraintForIdentifier:@"showShareContainer"];

    showConstraint.constant = -CGRectGetHeight(self.shareContainer.frame);
    
    [UIView animateWithDuration:0.5 animations:^{
        self.bgMaskView.alpha = 0.0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
