//
//  ChangeCardbackViewController.h
//  Solitaire
//
//  Created by apple on 13-7-21.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeCardbackViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
- (IBAction)pick:(id)sender;
- (IBAction)done:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *picBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIPopoverController* popOver;
- (void)layoutPics;
- (void)picSelected:(NSNotification*)notifacation;
- (void)setBackImage;
@end
