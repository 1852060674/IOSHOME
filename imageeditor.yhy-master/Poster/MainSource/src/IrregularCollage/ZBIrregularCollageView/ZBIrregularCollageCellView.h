//
//  ZBIrregularCollageCellView.h
//  PhotoEditor
//
//  Created by ZB_Mac on 15/7/6.
//  Copyright (c) 2015年 ZBNetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZBIrregularCollageCellView : UIView

-(ZBIrregularCollageCellView *)initWithFrame:(CGRect)frame andPoints:(NSArray *)points;

@property (nonatomic, strong) UIImage *image;

@end
