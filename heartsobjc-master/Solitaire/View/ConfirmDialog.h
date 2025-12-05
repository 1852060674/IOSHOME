//
//  ConfirmDialog.h
//  Solitaire
//
//  Created by jerry on 2017/9/1.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmDialog : UIView
@property (nonatomic, copy) NSString * titleStr;
@property (nonatomic, copy) NSString * confirmStr;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *confirmL;

@end
