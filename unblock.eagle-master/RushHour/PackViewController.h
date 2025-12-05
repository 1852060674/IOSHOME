//
//  PackViewController.h
//  Flow
//
//  Created by yysdsyl on 13-10-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PackViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *adView;
- (IBAction)back:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *packTableView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;

@end
