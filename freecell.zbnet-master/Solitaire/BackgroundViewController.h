//
//  BackgroundViewController.h
//  Solitaire
//
//  Created by apple on 13-7-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackgroundViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backImg;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
- (IBAction)dismissMyself:(id)sender;
- (IBAction)pickUserdefined:(id)sender; 

@property (strong, nonatomic) UIPopoverController* popOver;
@property (weak, nonatomic) IBOutlet UIButton *picBtn;

@end
