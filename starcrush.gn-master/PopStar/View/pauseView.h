 //
//  AlertView.h
//  连连看
//
//  Created by apple air on 15/11/20.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface pauseView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIButton *middleButton;
@property (weak, nonatomic) IBOutlet UIView *scoreView;
@property (weak, nonatomic) IBOutlet UIView *levelView;
// 第 (奇葩的命名..)
@property (weak, nonatomic) IBOutlet UIImageView *di;
// 关
@property (weak, nonatomic) IBOutlet UIImageView *guan;

@end
