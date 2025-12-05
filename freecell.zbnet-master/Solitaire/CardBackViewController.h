//
//  CardBackViewController.h
//  Solitaire 
//
//  Created by apple on 13-7-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardBackViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
- (IBAction)dismissMyself:(id)sender;
- (IBAction)pickPhoto:(id)sender;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UIButton *picBtn;

@property (strong, nonatomic) UIPopoverController* popOver;
@end
