//
//  MagnifierView.h
//  Transsexual
//
//  Created by ZB_Mac on 15/10/26.
//  Copyright © 2015年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MagnifierView : UIView
@property (nonatomic, readwrite) CGFloat zoomScale;
@property (nonatomic, weak) UIView *viewToMagnify;
@property (nonatomic, readwrite) CGPoint magnifyPoint;
@end
