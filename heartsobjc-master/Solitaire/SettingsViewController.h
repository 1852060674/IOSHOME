//
//  SettingsViewController.h
//  Solitaire
//
//  Created by apple on 13-6-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (IBAction)done:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageTop;
@property (weak, nonatomic) IBOutlet UITableView *tableSet;

- (void)switchDraw:(id)sender;
- (void)switchSound:(id)sender;
- (void)switchTime:(id)sender;
- (void)switchOrientation:(id)sender;
- (void)switchHints:(id)sender;
- (void)switchTapmove:(id)sender;
- (void)switchGamecenter:(id)sender;
- (void)switchHoliday:(id)sender;
- (void)switchCongra:(id)sender;
- (void)switchClassic:(id)sender;
- (void)switchSpeed:(id)sender;
- (IBAction)todo:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *adView;

@end
