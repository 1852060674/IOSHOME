//
//  DismissibleView.h
//  Solitaire
//
//  Created by jerry on 2017/8/15.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DismissibleView : UIView
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, strong) UIView * contentView;
@property (nonatomic, assign) BOOL disableTapToDismiss;
@property (nonatomic, assign) BOOL useAutoL;
- (void)addContentView:(UIView *)view;
@end
