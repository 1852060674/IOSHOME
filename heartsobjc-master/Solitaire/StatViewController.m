//
//  StatViewController.m
//  Solitaire
//
//  Created by apple on 13-7-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "StatViewController.h"
#import "ViewController.h"
#import "StatCell.h"

@interface StatViewController ()
{
    GameStat* stat;
    ViewController* vc;
}

@end

@implementation StatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    vc = (ViewController*)[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] topViewController];
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    UINavigationController *navigationController = nil;

    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        navigationController = (UINavigationController *)rootViewController;
    } else if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        navigationController = tabBarController.selectedViewController;
    }
    // 对以前代码进行处理
//    self.
    // end
    NSArray *viewControllers = navigationController.viewControllers;
    vc = (ViewController*)viewControllers[0];
    if (vc == nil) {
        NSLog(@"error becouse of ViewconTroller load file");
    }
    stat = vc.gameStat;
    // update byzzx 20240207
    UIButton *addPhotoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    NSString *str = NSLocalizedStringFromTable(@"Reset Statistics", @"Language", nil);
    [addPhotoButton setTitle:str forState: UIControlStateNormal];
    [addPhotoButton addTarget:self action:@selector(addPhotoButtonTapped) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addPhotoButton];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    UIFont *font = [UIFont systemFontOfSize:17.0];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    [addPhotoButton.titleLabel setFont:font];
    [addPhotoButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [addPhotoButton.titleLabel setFont:font];
    
}

- (void)addPhotoButtonTapped {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                   message:NSLocalizedStringFromTable(@"resethint", @"Language", nil)
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedStringFromTable(@"yes", @"Language", nil)
                                         otherButtonTitles:NSLocalizedStringFromTable(@"no", @"Language", nil),nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    BOOL rotateFlag = [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
    if (rotateFlag) {
        return YES;
    }
    else
    {
        return (toInterfaceOrientation == [[NSUserDefaults standardUserDefaults] integerForKey:@"currentori"]);
    }
    //return [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [vc willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
}

#pragma mark

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    // 创建一个UIView作为header的视图
//    UIView *headerView = [[UIView alloc] init];
////    headerView.backgroundColor = [UIColor lightGrayColor];
//
//    // 创建一个UILabel，添加进header视图
//    UILabel *label = [[UILabel alloc] init];
//    [headerView addSubview:label];
//
//    // 设置label的约束，这将根据你的的实际布局需要进行调整
//    label.translatesAutoresizingMaskIntoConstraints = NO;
//    [label.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:15].active = YES;
//    [label.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-15].active = YES;
//    [label.topAnchor constraintEqualToAnchor:headerView.topAnchor constant:5].active = YES;
//    [label.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-5].active = YES;
//
//    // 设置label的字体大小
//    label.font = [UIFont systemFontOfSize:18]; // 设置你想要的字体大小
//
//    // 根据section设置label的文本
//    if (section == 0) {
//        label.text = [NSString stringWithFormat:@"%@ 1", NSLocalizedStringFromTable(@"draw", @"Language", nil)];
//    } else if (section == 1) {
//        [label.topAnchor constraintEqualToAnchor:headerView.topAnchor constant:30].active = YES;
//        [label.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:80].active = YES;
//        label.text = [NSString stringWithFormat:@"%@ 3", NSLocalizedStringFromTable(@"draw", @"Language", nil)];
//    }
//
//    return headerView;
//}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DrawStat* ds = stat.freecell;
    //
    static NSString *itemIdentifier = @"StatCell";
    StatCell *cell = (StatCell*)[tableView dequeueReusableCellWithIdentifier:itemIdentifier];
    if (cell == nil)
    {
        //默认样式
        cell = [[StatCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:itemIdentifier];
    }
    switch (indexPath.row) {
        case 0:
            cell.keyLabel.text = @"Games Won";
            cell.valueLabel.text = [NSString stringWithFormat:@"%d(%0.2f%%)",ds.wonCnt,100.0*ds.wonCnt/(ds.wonCnt+ds.lostCnt+0.000001)];
            return cell;
            break;
        case 1:
            cell.keyLabel.text = @"Games Lost";
            cell.valueLabel.text = [NSString stringWithFormat:@"%d",ds.lostCnt];
            return cell;
            break;
        case 2:
            cell.keyLabel.text = @"Best Score";
            cell.valueLabel.text = [NSString stringWithFormat:@"%d",ds.bestScore];
            return cell;
            break;
        case 3:
            cell.keyLabel.text = @"Worst Score";
            cell.valueLabel.text = [NSString stringWithFormat:@"%d",ds.worstScore];
            return cell;
            break;
            
        default:
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 25;
}

- (IBAction)dismissMyself:(id)sender {
//    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)Reset:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                   message:@"Do you really want to reset the statistics?"
                                                  delegate:self
                                         cancelButtonTitle:@"Yes"
                                         otherButtonTitles:@"No",nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [stat reset];
        NSString* path = [NSString stringWithFormat:@"%@/Documents/stat.dat",NSHomeDirectory()];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:stat];
        [data writeToFile:path atomically:YES];
        ///
        [self.statTable reloadData];
    }
}

- (void)viewDidUnload {
    [self setStatTable:nil];
    [super viewDidUnload];

}
@end
