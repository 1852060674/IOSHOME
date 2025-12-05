//
//  StatViewController.h
//  Solitaire
//
//  Created by apple on 13-7-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatViewController : UIViewController
- (IBAction)dismissMyself:(id)sender;
- (IBAction)Reset:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *statTable;
@end
