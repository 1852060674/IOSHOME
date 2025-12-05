//
//  SettingsViewController.m
//  Solitaire
//
//  Created by apple on 13-6-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SettingsViewController.h"
#import "SwitchCell.h"
#import "ViewController.h"
#import "Solitaire.h"
#import "Config.h"
#import "ZhConfig.h"
#import "Admob.h"
#import "ApplovinMaxWrapper.h"
#import <UIKit/UIKit.h>
#import "TopCell.h"
#import "TopCell.h"
#import "ChangeCardbackViewController.h"
#include "ApplovinMaxWrapper.h"
typedef enum : NSUInteger {
OldMan,
NewMan
} Man;
@interface SettingsViewController ()
{
    ViewController* vc;
    UIInterfaceOrientation ori;
    BOOL liuhaiScreen;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *admobHeight11;
@end

@implementation SettingsViewController

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
    NSLog(@"cell.sw.on 0= %d",[[NSUserDefaults standardUserDefaults] boolForKey:@"classic"]);
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationItem.title = @"Setting";
    UIFont *font = [UIFont systemFontOfSize:24.0];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    self.navigationController.navigationBar.titleTextAttributes = attributes;
//    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"按钮" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonTapped)];
//    self.navigationItem.rightBarButtonItem = rightBarButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    // Do any additional setup after loading the view.
//    vc = (ViewController*)[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] topViewController];

    _admobHeight11.constant=admobHeight;
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    UINavigationController *navigationController = nil;

    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        navigationController = (UINavigationController *)rootViewController;
    } else if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        navigationController = tabBarController.selectedViewController;
    }

    NSArray *viewControllers = navigationController.viewControllers;
    vc = (ViewController*)viewControllers[0];
    if (vc == nil) {
        NSLog(@"error becouse of ViewconTroller load file");
    }
//    self.tableSet.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.tableSet.sectionHeaderHeight = 0;
    self.tableSet.sectionHeaderHeight = 0;
    self.tableSet.allowsSelection = YES;
   
    if (![self isNotchScreen]) {
        NSLog(@"test 0403 00000001  %lf whidt =%lf",self.tableSet.frame.size.height +30,kScreenHeight);
        CGRect frame1 = self.tableSet.frame;
        if (frame1.size.width > frame1.size.height) {
            frame1.size.width = self.tableSet.frame.size.width;
            frame1.size.height=266;
            self.tableSet.frame =frame1;
            NSLog(@"test 0403 %lf whidt =%lf",self.tableSet.frame.size.height +30,kScreenHeight);
            [self.tableSet layoutIfNeeded];
        }
    }

    
    int opbarHeightpianyi1 = [self isNotchScreen] && (kScreenHeight > 811 || kScreenWidth >811) ? [self isLandscape] ? 20 : opbarHeightpianyi : 0;
    self.adView.center = CGPointMake(kScreenWidth/2, kScreenHeight - opbarHeightpianyi1  - (admobHeight1)/2);
    
    NSLog(@"cell.sw.on 2= %d",[[NSUserDefaults standardUserDefaults] boolForKey:@"classic"]);
}
//
//- (void)dealloc {
//    // 在视图控制器销毁时移除通知观察者
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//  
//- (void)navigationControllerWillPop:(NSNotification *)notification {
//    // 这里是即将返回时的代码
//    NSLog(@"即将返回");
//    // 你可以在这里执行你需要的操作
//}


//- (void)didReceiveMemoryWarning
//{
//    [self.adView setHidden:YES];
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

- (void)viewWillAppear:(BOOL)animated
{ 
    [self.tableSet deselectRowAtIndexPath:[self.tableSet indexPathForSelectedRow] animated:YES];
    ori = (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
    vc.thvc.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    vc.thvc.ori = ori;
    [[AdmobViewController shareAdmobVC] show_admob_banner_smart:0.0 posy:0.0 view:self.adView];
}

- (void) viewDidLayoutSubviews {
    [self.tableSet deselectRowAtIndexPath:[self.tableSet indexPathForSelectedRow] animated:YES];
//    [[AdmobViewController shareAdmobVC] show_admob_banner_smart:0.0 posy:0.0 view:self.adView];
//    [[AdmobViewController shareAdmobVC] show_admob_banner:self.adView placeid:@"settingpage"];
//    [[AdmobViewController shareAdmobVC] setBannerAlign:AD_BOTTOM];
    if (IS_IPAD) {
//        CGRect frame=self.adView.frame;
//        frame.origin.x=self.adView.frame.size.width/2;
//        frame.origin.y=kScreenHeight- self.adView.frame.size.height/2 -20;
//        self.adView.frame =frame;
    }
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
      
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        int opbarHeightpianyi1 = [self isNotchScreen] && (kScreenHeight > 811 || kScreenWidth >811) ? [self isLandscape] ? 20 : opbarHeightpianyi : 0;
        // 在屏幕旋转发生之前执行一些操作
        NSLog(@"test 0403 45645343");
        if (![self isNotchScreen]) {
            NSLog(@"test 0403 00000001  %lf whidt =%lf",self.tableSet.frame.size.height +30,kScreenHeight);
            CGRect frame1 = self.tableSet.frame;
            if (frame1.size.width > frame1.size.height) {
                frame1.size.width = self.tableSet.frame.size.width;
                frame1.size.height=266;
                self.tableSet.frame =frame1;
                NSLog(@"test 0403 %lf whidt =%lf",self.tableSet.frame.size.height +30,kScreenHeight);
                [self.tableSet layoutIfNeeded];
            }
            self.adView.center = CGPointMake(kScreenWidth/2, kScreenHeight - opbarHeightpianyi1  - (admobHeight1)/2);
            [self.view bringSubviewToFront:self.adView];
            

        }
        self.adView.center = CGPointMake(kScreenWidth/2, kScreenHeight - opbarHeightpianyi1  - (admobHeight1)/2);
        NSLog(@"test 0403  hidden =%d",self.adView.hidden);
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        // 在屏幕旋转动画完成后执行一些操作
    }];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [vc willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    int opbarHeightpianyi1 = [self isNotchScreen] && (kScreenHeight > 811 || kScreenWidth >811) ? [self isLandscape] ? 20 : opbarHeightpianyi : 0;
    // 横屏转竖屏
    if (kScreenWidth > kScreenHeight) {
        // 出现问题，宽度中点为width高度重点为height/2
//    self.adView.center = CGPointMake(kScreenWidth/2, kScreenHeight - opbarHeightpianyi1  - (admobHeight1)/2);
    }
    if (![self isNotchScreen]) {
        NSLog(@"test 0403 00000001  %lf whidt =%lf",self.tableSet.frame.size.height +30,kScreenHeight);
        CGRect frame1 = self.tableSet.frame;
        if (frame1.size.width > frame1.size.height) {
            frame1.size.width = self.tableSet.frame.size.width;
            frame1.size.height=266;
            self.tableSet.frame =frame1;
            NSLog(@"test 0403 %lf whidt =%lf",self.tableSet.frame.size.height +30,kScreenHeight);
            [self.tableSet layoutIfNeeded];
        }
    }
    // 奇怪的是模拟机需要打开它才正常
//    self.adView.center = CGPointMake(kScreenWidth/2, kScreenHeight - opbarHeightpianyi1  - (admobHeight1)/2);
}

- (IBAction)done:(id)sender {
    vc.setshow = YES;
    
//    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 3;
    }else if (section == 1)
    {
        return 4;
    }
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) {
            static NSString *cardBackIdentifier = @"ChangeCardBack";
            
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:
                                   cardBackIdentifier];
            if (cell == nil)
            {
                //默认样式
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:cardBackIdentifier];
            }
            cell.textLabel.text = @"Change Card Back";
            return cell;
        }
        else if (indexPath.row == 1) {
            static NSString *gameBackIdentifier = @"ChangeGameBack";
            
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:
                                                       gameBackIdentifier];
            if (cell == nil)
            {
                //默认样式
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:gameBackIdentifier];
            }
            cell.textLabel.text = @"Change Game Back";
            return cell;
            }
        else if (indexPath.row == 2)
        {
            static NSString *statIdentifier = @"Stat";
            
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:
                                                       statIdentifier];
            if (cell == nil)
            {
                //默认样式
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:statIdentifier];
            }
            cell.textLabel.text = @"Statistics";
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }else if (indexPath.section == 1)
    {
        if (indexPath.row == 0) {
            static NSString *soundIdentifier = @"Sound";
           
           SwitchCell *cell = (SwitchCell*)[tableView dequeueReusableCellWithIdentifier:
                                            soundIdentifier];
           if (cell == nil)
           {
               //默认样式
               cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier: soundIdentifier];
           }
            cell.sw.hidden = YES;
            cell.label.text = @"Sound Control";
            cell.sc.selectedSegmentIndex = vc.gameView.sound;
            [cell.sc addTarget:self action:@selector(switchSound:) forControlEvents:UIControlEventValueChanged];
            return cell;
       }
       else if (indexPath.row == 1) {
           static NSString *speedIdentifier = @"Speed";
           
           SwitchCell *cell = (SwitchCell*)[tableView dequeueReusableCellWithIdentifier:
                                            speedIdentifier];
           if (cell == nil)
           {
               //默认样式
               cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier: speedIdentifier];
           }
           cell.sw.hidden = YES;
           cell.label.text = @"Speed";
           cell.sc.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"speed"];
           [cell.sc addTarget:self action:@selector(switchSpeed:) forControlEvents:UIControlEventValueChanged];
           return cell;
       }
       else if (indexPath.row == 2) {
           static NSString *oriIdentifier = @"Orientation";
           
           SwitchCell *cell = (SwitchCell*)[tableView dequeueReusableCellWithIdentifier:
                                            oriIdentifier];
           if (cell == nil)
           {
               //默认样式
               cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier: oriIdentifier];
           }
           cell.sc.hidden = YES;
           cell.label.text = @"Lock Orientation";
           cell.sw.on = ![[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
           [cell.sw addTarget:self action:@selector(switchOrientation:) forControlEvents:UIControlEventValueChanged];
           return cell;
       }/*  del zzx 2024030420:04
       else if (indexPath.row == 4) {
           static NSString *hintsIdentifier = @"Hints";
           
           SwitchCell *cell = (SwitchCell*)[tableView dequeueReusableCellWithIdentifier:
                                            hintsIdentifier];
           if (cell == nil)
           {
               //默认样式
               cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier: hintsIdentifier];
           }
           cell.sc.hidden = YES;
           cell.label.text = NSLocalizedStringFromTable(@"hint", @"Language", nil);
           cell.sw.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hints"];
           [cell.sw addTarget:self action:@selector(switchHints:) forControlEvents:UIControlEventValueChanged];
   //        [self addcor:cell];
           return cell;
       }
       else if (indexPath.row == 5) {
           static NSString *tapmoveIdentifier = @"TapMove";
           
           SwitchCell *cell = (SwitchCell*)[tableView dequeueReusableCellWithIdentifier:
                                            tapmoveIdentifier];
           if (cell == nil)
           {
               //默认样式
               cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier: tapmoveIdentifier];
           }
           cell.sc.hidden = YES;
           cell.label.text = NSLocalizedStringFromTable(@"tapmove", @"Language", nil);
           cell.sw.on = vc.gameView.autoOn;
           [cell.sw addTarget:self action:@selector(switchTapmove:) forControlEvents:UIControlEventValueChanged];
           return cell;
       } */
       /*
       else if (indexPath.row == 9) {
           static NSString *gcIdentifier = @"GameCenter";
           
           SwitchCell *cell = (SwitchCell*)[tableView dequeueReusableCellWithIdentifier:
                                            gcIdentifier];
           if (cell == nil)
           {
               //默认样式
               cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier: gcIdentifier];
           }
           cell.sc.hidden = YES;
           cell.label.text = @"Game Center";
           cell.sw.on = !vc.gameView.btnGC.hidden;
           [cell.sw addTarget:self action:@selector(switchGamecenter:) forControlEvents:UIControlEventValueChanged];
           return cell;
       }
       else if (indexPath.row == 10) {
           static NSString *holidayIdentifier = @"Holiday";
           
           SwitchCell *cell = (SwitchCell*)[tableView dequeueReusableCellWithIdentifier:
                                            holidayIdentifier];
           if (cell == nil)
           {
               //默认样式
               cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier: holidayIdentifier];
           }
           cell.sc.hidden = YES;
           cell.label.text = @"Holiday Decorations";
           cell.sw.on = !vc.gameView.gameDecoration.hidden;
           [cell.sw addTarget:self action:@selector(switchHoliday:) forControlEvents:UIControlEventValueChanged];
           return cell;
       }
       else if (indexPath.row == 11) {
           static NSString *congraIdentifier = @"Congra";
           
           SwitchCell *cell = (SwitchCell*)[tableView dequeueReusableCellWithIdentifier:
                                            congraIdentifier];
           if (cell == nil)
           {
               //默认样式
               cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier: congraIdentifier];
           }
           cell.sc.hidden = YES;
           cell.label.text = @"Congratutions Screen";
           cell.sw.on = vc.showCongra;
           [cell.sw addTarget:self action:@selector(switchCongra:) forControlEvents:UIControlEventValueChanged];
           return cell;
       }
        */
        if (indexPath.row == 3) {
            NSLog(@"cell.sw.on self0= %d",[[NSUserDefaults standardUserDefaults] boolForKey:@"classic"]);
           static NSString *classicIdentifier = @"Classic";
           
           SwitchCell *cell = (SwitchCell*)[tableView dequeueReusableCellWithIdentifier:
                                            classicIdentifier];
           if (cell == nil)
           {
               //默认样式
               cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier: classicIdentifier];
           }
            cell.sc.hidden = YES;
            cell.label.text = @"Classic Cards";
            cell.sw.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"classic"];
            NSLog(@"cell.sw.on self= %d",cell.sw.on);
            [cell.sw addTarget:self action:@selector(switchClassic:) forControlEvents:UIControlEventValueChanged];
            return cell;
       }
    }
    
     
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            static NSString *rulesIdentifier = @"Rules";
            
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:
                                                       rulesIdentifier];
            if (cell == nil)
            {
                //默认样式
                cell = [[TopCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier: rulesIdentifier];
            }
            cell.textLabel.text = @"Rules";
            return cell;
        }
        if (indexPath.row == 1) {
            static NSString *gameBackIdentifier = @"ChangeGameBack1";
            
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:
                                                       gameBackIdentifier];
            if (cell == nil)
            {
                //默认样式
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:gameBackIdentifier];
            }
            cell.textLabel.text = @"New Theme";
            return cell;
            }
    }
        return nil;
}
    


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableSet deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"zzx 1234560 indexPath.row =%ld ",indexPath.row);
    NSLog(@"zzx 1234560 indexPath.row1 =%ld ",indexPath.section);
    if (indexPath.row ==1 && indexPath.section ==2) {
        NSLog(@"zzx 1234560");
        
        // 改变内容三步
        //第一步改变setting 内容
        [self changeSttingToNewMan:NewMan];
        // 第二部改变其他地方的OldMan的判断
        // 2.1调用viewcontroller的方法修改oldman
        // 2.2直接再加一个参数放入user中，这个参数也成为决定因素之一
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

- (void) switchDraw:(id)sender
{

}

- (void) switchHints:(id)sender
{
    UISwitch * sw = (UISwitch *)sender;
    vc.gameView.btnHint.hidden = !sw.on;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:sw.on forKey:@"hints"];
    [settings synchronize];
}

- (void) switchClassic:(id)sender
{
    UISwitch * sw = (UISwitch *)sender;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:sw.on forKey:@"classic"];
    [settings synchronize];
    if ([settings boolForKey:@"classic"]) {
        [Card setClassic:YES];
    }
    else
        [Card setClassic:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settings" object:@"classic"];
    
    NSLog(@"cell.sw.on = %d",[[NSUserDefaults standardUserDefaults] boolForKey:@"classic"]);
    [vc.gameView updateCardForground];
    [vc.gameView setNeedsDisplay];
    

}

- (void)switchTapmove:(id)sender
{
    UISwitch * sw = (UISwitch *)sender;
    vc.gameView.autoOn = sw.on;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:sw.on forKey:@"tapmove"];
    [settings synchronize];
}

- (void)switchGamecenter:(id)sender
{
    UISwitch * sw = (UISwitch *)sender;
    vc.gameView.btnGC.hidden = !sw.on;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:sw.on forKey:@"gamecenter"];
    [settings synchronize];
}

- (void)switchHoliday:(id)sender
{
    UISwitch * sw = (UISwitch *)sender;
    vc.gameView.gameDecoration.hidden = !sw.on;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:sw.on forKey:@"holiday"];
    [settings synchronize];
}

- (void)switchCongra:(id)sender
{
    UISwitch * sw = (UISwitch *)sender;
    vc.showCongra = sw.on;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:sw.on forKey:@"congra"];
    [settings synchronize];
}

- (IBAction)todo:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissModalViewControllerAnimated:YES];
}

- (void) switchTime:(id)sender
{
    UISwitch * sw = (UISwitch *)sender;
    //vc.gameView.timeLabel.hidden = !sw.on;
    //vc.gameView.movesLabel.hidden = !sw.on;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:sw.on forKey:@"timemoves"];
    [settings synchronize];
}

- (void) switchSound:(id)sender
{
    UISegmentedControl * sc = (UISegmentedControl *)sender;
    vc.gameView.sound = sc.selectedSegmentIndex;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:sc.selectedSegmentIndex forKey:@"sound"];
    [settings synchronize];
}

- (void) switchSpeed:(id)sender
{
    UISegmentedControl * sc = (UISegmentedControl *)sender;
    vc.gameView.speed = sc.selectedSegmentIndex;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setInteger:sc.selectedSegmentIndex forKey:@"speed"];
    [settings synchronize];
}

- (void)switchOrientation:(id)sender
{
    UISwitch * sw = (UISwitch *)sender;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:!sw.on forKey:@"orientation"];
    int ori2 = [[UIApplication sharedApplication] statusBarOrientation];
    if (sw.on)
        [settings setInteger:ori2 forKey:@"currentori"];
    //[settings setInteger:[[UIDevice currentDevice] orientation] forKey:@"currentori"];
    [settings synchronize];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        return 40;
    }
    if (section == 0) {
        if (kScreenWidth >kScreenHeight) {
            return 0.01;
        }
        return 0;
    }
    return -100;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *lbl = [[UILabel alloc] init];
    lbl.textAlignment = UITextAlignmentCenter;
    lbl.text = NSLocalizedStringFromTable(@"scroll", @"Language", nil);
    lbl.font = [UIFont systemFontOfSize:20];
    UIColor *customColor = [UIColor colorWithRed:0xf2/255.0 green:0xf0/255.0 blue:0xf7/255.0 alpha:1.0];
    tableView.backgroundColor=customColor;
    lbl.backgroundColor = tableView.backgroundColor;
    lbl.hidden=YES;
    
    return nil;
}
//-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    return UIView.new;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//
//    return -20;
//}
- (void)customBackAction {
    // 执行自定义操作，例如保存数据或进行清理工作
    NSLog(@"tewadawdwa");
    // 调用父类的返回方法
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"cardbacksegue" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"backgroundsegue" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"statsegue" sender:self];
            break;
        case 7:
            [self performSegueWithIdentifier:@"rulesegue" sender:self];
            break;
        case 8:
            [self performSegueWithIdentifier:@"cardbacksegue" sender:self];
            break;
            break;
        default:
            break;
    }
}

- (void)viewDidUnload {
    [self setImageTop:nil];
    [self setTableSet:nil];
    [self setAdView:nil];
    [super viewDidUnload];
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

-(NSUInteger)supportedInterfaceOrientations{
    //return UIInterfaceOrientationMaskAll;
    BOOL rotateFlag = [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
    if (rotateFlag) {
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        int ori = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentori"];
        return (1 << ori);
    }
}

- (BOOL)shouldAutorotate
{
    return YES;//[[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
}
- (BOOL)isNotchScreen {
    
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets;
        if (safeAreaInsets.left>0) {
            NSLog(@"这是safeAreaInsets.left>0屏");
            return YES;
        }
        if (safeAreaInsets.right>0) {
            NSLog(@"这是safeAreaInsets.right>0屏");
            return YES;
        }
        if (safeAreaInsets.bottom>0) {
            NSLog(@"这是safeAreaInsets.bottom>0屏");
            return YES;
        }
        if (safeAreaInsets.top > 0) {
            // 是刘海屏
            NSLog(@"这是刘海屏");
            return YES;
        }
    }
    NSLog(@"zzx have not hair");
    return NO;
}

- (BOOL)isLandscape {
    // 横屏
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return UIDeviceOrientationIsLandscape(orientation);
}
-(void)changeSttingToNewMan:(Man)newMan{
    // 20240328 切换用户前保存老用户主题
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString* OldBack = [settings objectForKey:@"background"];
    NSString* OldCardback = [settings objectForKey:@"cardback"];
    if (OldBack ==nil) {
        OldBack = [settings objectForKey:@"background"];
    }
    if (OldCardback ==nil) {
        OldCardback = [settings objectForKey:@"cardback"];
    }
    
    [settings setObject:OldBack forKey:@"Oldbackground"];
    [settings setObject:OldCardback forKey:@"OldNewcardback"];
    // 切换用户后获取    以前保存着新用户主题 如果为空则重新赋值
    NSString* newBack = [settings objectForKey:@"Newbackground"];
    NSString* Newcardback = [settings objectForKey:@"Newcardback"];
    // 切换用户后获取以前保存着新用户主题 如果为空则重新赋值
    if (newBack) {
        [settings setObject:newBack forKey:@"background"];
        NSLog(@"Old background is: %@", newBack);
    } else {
        [settings setObject:@"bg0" forKey:@"background"];
        NSLog(@"Old background is not set for the given key. %@",OldBack);
    }
    
    if (Newcardback) {
        [settings setObject:Newcardback forKey:@"cardback"];
        NSLog(@"Old background is: %@", Newcardback);
    } else {
        [settings setObject:@"cardback1" forKey:@"cardback"];
        NSLog(@"Old background is not set for the given key.");
    }
     
    
    NSLog(@"test zzx 0 setObject:selectedBackName forKey:background 1 %@",OldBack);
    /// default
    NSLog(@"cell.sw.on 1= %d",[[NSUserDefaults standardUserDefaults] boolForKey:@"classic"]);
    BOOL classicCard = CLASSIC_CARD;
    BOOL orientation = YES;//!(IPHONE_LANDSCAPE);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        classicCard = YES;
        orientation = YES;
    }
    //定义两套初始化皮肤number.1
    NSLog(@"test first1 coming");
    NSDictionary *defaultValue=nil;
    if (!newMan) {
        defaultValue = [NSDictionary dictionaryWithObjectsAndKeys:@"CardBack-BlueGrid",@"cardback",
                        @"RedFelt",@"background",
                        [NSNumber numberWithInteger:0],@"level",
                        [NSNumber numberWithBool:YES],@"sound",
                        [NSNumber numberWithBool:YES],@"timemoves",
                        [NSNumber numberWithBool:orientation],@"orientation",
                        [NSNumber numberWithBool:YES],@"hints",
                        [NSNumber numberWithBool:TAP_MOVE],@"tapmove",
                        [NSNumber numberWithBool:NO],@"gamecenter",
                        [NSNumber numberWithBool:NO],@"holiday",
                        [NSNumber numberWithBool:NO],@"congra",
                        [NSNumber numberWithInt:1],@"speed",
                        [NSNumber numberWithInteger:orientation ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeRight],@"currentori",
                        [NSNumber numberWithBool:classicCard],@"classic",
                        [NSNumber numberWithInt:0],@"cnt",
                        [NSNumber numberWithBool:NO],@"rated",
                        [NSNumber numberWithInt:0],@"popratecnt",
                        nil];
    }else{
        defaultValue = [NSDictionary dictionaryWithObjectsAndKeys:@"cardback39",@"cardback",
                        @"bg0",@"background",
                        @"4",@"cardfront",
                        @[], customCardBgListKey,
                        @[], customDeskBgListKey,
                        [NSNumber numberWithInteger:0],@"level",
                        [NSNumber numberWithBool:YES],@"sound",
                        [NSNumber numberWithBool:YES],@"timemoves",
                        [NSNumber numberWithBool:orientation],@"orientation",
                        [NSNumber numberWithBool:YES],@"hints",
                        [NSNumber numberWithBool:TAP_MOVE],@"tapmove",
                        [NSNumber numberWithBool:NO],@"gamecenter",
                        [NSNumber numberWithBool:NO],@"holiday",
                        [NSNumber numberWithBool:NO],@"congra",
                        [NSNumber numberWithInt:1],@"speed",
                        [NSNumber numberWithInt:0],@"cnt",
                        [NSNumber numberWithInteger:orientation ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeRight],@"currentori",
                        [NSNumber numberWithBool:classicCard],@"classic",
                        [NSNumber numberWithBool:NO],@"rated",
                        [NSNumber numberWithInt:0],@"popratecnt",
                        nil];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:newMan] forKey:@"changetoNewMan"];
    [settings registerDefaults:defaultValue];
    [settings synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settings" object:@"background"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settings" object:@"cardback"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settings" object:@"cardfront"];
    [vc.gameView IsOldman];
    [vc.gameView updateInfoList];
    [vc.gameView updateThemesButtonStatus];
//    [self reloadUI];
}
@end
