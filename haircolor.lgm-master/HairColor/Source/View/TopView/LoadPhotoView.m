//
//  LoadPhotoView.m
//  HairColor
//
//  Created by ZB_Mac on 2016/11/22.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "LoadPhotoView.h"

@interface LoadPhotoView ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *maskView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showBtnConstraint;
@end

@implementation LoadPhotoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)showBtn:(BOOL)show animated:(BOOL)animated completionAction:(void (^)(BOOL))completion;
{
    CGFloat startAlpha = show?0.0:0.25;
    CGFloat endAlpha = show?0.25:0.0;

    _showBtnConstraint.constant = show?0:-CGRectGetHeight(_containerView.bounds);
    self.maskView.alpha = startAlpha;

    if (animated)
    {
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutIfNeeded];
            self.maskView.alpha = endAlpha;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(YES);
            }
        }];
    }
    else
    {
        [self layoutIfNeeded];
        self.maskView.alpha = endAlpha;

        if (completion) {
            completion(YES);
        }
    }
}

- (IBAction)onTapBG:(id)sender {
    [self showBtn:NO animated:YES completionAction:^(BOOL complete) {
        [self removeFromSuperview];
    }];
}

- (IBAction)loadFromAlbum {
    [self showBtn:NO animated:YES completionAction:^(BOOL complete) {
        [self removeFromSuperview];

        if (self.actions) {
            self.actions(1);
        }
    }];
}

- (IBAction)loadFromCamera {
    [self showBtn:NO animated:YES completionAction:^(BOOL complete) {
        [self removeFromSuperview];

        if (self.actions) {
            self.actions(2);
        }
    }];
}

@end
