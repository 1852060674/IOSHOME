//
//  ChangeBackgroundViewController.h
//  Solitaire
//
//  Created by apple on 13-7-21.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeBackgroundViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
- (IBAction)done:(id)sender;
- (IBAction)pick:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *backImg;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *picBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIPopoverController* popOver;

- (void)layoutPics;
- (void)picSelected:(NSNotification*)notifacation;
- (void)setLayoutImags;
- (void)setBackImage;
@end
