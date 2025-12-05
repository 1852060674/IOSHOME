//
//  PurchaseViewController.m
//  EyeColor4.0
//
//  Created by ZB_Mac on 14-12-23.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#import "PurchaseViewController.h"
#import "ZBCommonMethod.h"
#import "ZBCommonDefine.h"

@interface PurchaseViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) IBOutlet UIButton *buyBtn;
@property (strong, nonatomic) IBOutlet UIButton *restoreBtn;

@end

@implementation PurchaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.product_id = kRemoveAd;
    // Do any additional setup after loading the view.

    if ([ZBCommonMethod isIpad]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"purchase_ipad_bg" ofType:@"jpg"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        self.bgImageView.image = image;
    }
    if ((NSInteger)[ZBCommonMethod screenHeight]==480) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"purchase_i4_bg" ofType:@"jpg"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        self.bgImageView.image = image;
    }
}

#pragma mark -
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - action

- (IBAction)close:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)buy:(id)sender {
    [self purchase];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPaid object:self.product_id];
}
- (IBAction)restore:(id)sender {
    [self restore];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
