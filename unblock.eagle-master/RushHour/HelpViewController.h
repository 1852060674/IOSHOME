//
//  HelpViewController.h
//  WordSearch
//
//  Created by apple on 13-8-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *adView;
- (IBAction)back:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *helpImage;

@end
