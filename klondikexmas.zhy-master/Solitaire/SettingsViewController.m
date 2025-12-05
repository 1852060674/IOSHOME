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
@interface SettingsViewController ()
{
    ViewController* vc;
    __weak IBOutlet NSLayoutConstraint *TableSetTop;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *admobHeight1;


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

    _admobHeight1.constant=admobHeight;
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
    if (![self isNotchScreen] && kScreenWidth <811 && kScreenHeight <811) {
        TableSetTop.constant=-70;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
//    [self.tableSet deselectRowAtIndexPath:[self.tableSet indexPathForSelectedRow] animated:YES];
//
//    [[AdmobViewController shareAdmobVC] show_admob_banner:self.adView placeid:@"settingpage"];
////    [[AdmobViewController shareAdmobVC] setBannerAlign:AD_BOTTOM];
//    if (IS_IPAD) {
//        CGRect frame=self.adView.frame;
//        frame.origin.x=self.adView.frame.size.width/2;
//        frame.origin.y=kScreenHeight- self.adView.frame.size.height/2 -20;
//        self.adView.frame =frame;
//    }
//    NSLog(@"zzx = kScreenWidth %lf",kScreenWidth);
//    NSLog(@"zzx = adview . center .x %lf",self.adView.frame.origin.x);
//    NSLog(@"zzx = adview . center .y %lf",self.adView.frame.origin.y);
//    NSLog(@"zzx = adview . center .width %lf",self.adView.frame.size.width);
//    NSLog(@"zzx = adview . center .hidden %d",self.adView.hidden);
}

- (void) viewDidLayoutSubviews {
    [self.tableSet deselectRowAtIndexPath:[self.tableSet indexPathForSelectedRow] animated:YES];
    
    [[AdmobViewController shareAdmobVC] show_admob_banner:self.adView placeid:@"settingpage"];
//    [[AdmobViewController shareAdmobVC] setBannerAlign:AD_BOTTOM];
    if (IS_IPAD) {
//        CGRect frame=self.adView.frame;
//        frame.origin.x=self.adView.frame.size.width/2;
//        frame.origin.y=kScreenHeight- self.adView.frame.size.height/2 -20;
//        self.adView.frame =frame;
    }
    NSLog(@"zzx = kScreenWidth %lf",kScreenWidth);
    NSLog(@"zzx = adview . center .x %lf",self.adView.frame.origin.x);
    NSLog(@"zzx = adview . center .y %lf",self.adView.frame.origin.y);
    NSLog(@"zzx = adview . center .width %lf",self.adView.frame.size.width);
    NSLog(@"zzx = adview . center .hidden %d",self.adView.hidden);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [vc willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
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
		return 7;
	}
    return 1;
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
			cell.textLabel.text = NSLocalizedStringFromTable(@"change_cardback", @"Language", nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.layer.masksToBounds = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
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
			cell.textLabel.text = NSLocalizedStringFromTable(@"change_gameback", @"Language", nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
			cell.textLabel.text = NSLocalizedStringFromTable(@"stat", @"Language", nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			return cell;
		}
	}else if (indexPath.section == 1)
	{
		if (indexPath.row == 0) {
		   static NSString *draw3Identifier = @"Draw3";
		   
		   SwitchCell *cell = (SwitchCell*)[tableView dequeueReusableCellWithIdentifier:
											draw3Identifier];
		   if (cell == nil)
		   {
			   //默认样式
			   cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
										reuseIdentifier: draw3Identifier];
		   }
		   NSLog(@"zzx vc.gameView= %@",vc.gameView);
		   cell.sw.on = vc.game.draw3;
		   cell.sc.hidden = YES;
		   cell.label.text = [NSString stringWithFormat:@"%@ 3",NSLocalizedStringFromTable(@"draw", @"Language", nil)];
		   [cell.sw addTarget:self action:@selector(switchDraw:) forControlEvents:UIControlEventValueChanged];
//           [self addcor:cell];
		   return cell;
	   }
	   else if (indexPath.row == 1) {
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
		   cell.label.text = NSLocalizedStringFromTable(@"sound", @"Language", nil);
		   NSLog(@"zzx vc.gameView= %@",vc.gameView);
		   cell.sc.selectedSegmentIndex = vc.gameView.sound;
		   [cell.sc addTarget:self action:@selector(switchSound:) forControlEvents:UIControlEventValueChanged];
   //        [self addcor:cell];
		   return cell;
	   }
	   else if (indexPath.row == 2) {
		   static NSString *timeIdentifier = @"TimeMoves";
		   
		   SwitchCell *cell = (SwitchCell*)[tableView dequeueReusableCellWithIdentifier:
											timeIdentifier];
		   if (cell == nil)
		   {
			   //默认样式
			   cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
										reuseIdentifier: timeIdentifier];
		   }
		   cell.sc.hidden = YES;
		   cell.label.text = NSLocalizedStringFromTable(@"timemove", @"Language", nil);
		   cell.sw.on = !(vc.gameView.timeLabel.hidden);
		   [cell.sw addTarget:self action:@selector(switchTime:) forControlEvents:UIControlEventValueChanged];
   //        [self addcor:cell];
		   return cell;
	   }
	   else if (indexPath.row == 3) {
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
		   cell.label.text = NSLocalizedStringFromTable(@"lock", @"Language", nil);
		   cell.sw.on = ![[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
		   [cell.sw addTarget:self action:@selector(switchOrientation:) forControlEvents:UIControlEventValueChanged];
   //        [self addcor:cell];
		   return cell;
	   }
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
   //        [self addcor:cell];
		   return cell;
	   }
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
	    if (indexPath.row == 6) {
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
		   cell.label.text = NSLocalizedStringFromTable(@"classic", @"Language", nil);
		   cell.sw.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"classic"];
		   [cell.sw addTarget:self action:@selector(switchClassic:) forControlEvents:UIControlEventValueChanged];
   //        [self addcor:cell];
		   return cell;
	   }
	}
    
     
     if (indexPath.section == 2) {
        static NSString *rulesIdentifier = @"Rules";
        
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:
                                         rulesIdentifier];
        if (cell == nil)
        {
            //默认样式
            cell = [[TopCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier: rulesIdentifier];
        }
        cell.textLabel.text = NSLocalizedStringFromTable(@"rules", @"Language", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableSet deselectRowAtIndexPath:indexPath animated:YES];
}


- (void) switchDraw:(id)sender
{
    UISwitch * sw = (UISwitch *)sender;
    vc.game.draw3 = sw.on;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:sw.on forKey:@"draw3"];
    [settings synchronize];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settings" object:@"classic"];
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
    vc.gameView.timeLabel.hidden = !sw.on;
    vc.gameView.movesLabel.hidden = !sw.on;
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
        return -80;
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
//	return UIView.new;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//
//	return 20;
//}

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
        case 10:
            [self performSegueWithIdentifier:@"rulesegue" sender:self];
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
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
}
- (void)addcor:(SwitchCell *)cell
{
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = YES;
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [UIColor grayColor].CGColor;
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

@end
