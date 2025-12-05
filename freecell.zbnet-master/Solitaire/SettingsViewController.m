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

@interface SettingsViewController ()
{
    ViewController* vc;
}

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
	// Do any additional setup after loading the view.
#if 0
    vc = (ViewController*)[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] topViewController];
    self.adView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    /// admob
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        bannerView_ = [[GADBannerView alloc]
                       initWithFrame:CGRectMake(0.0,
                                                0.0,
                                                GAD_SIZE_728x90.width,
                                                GAD_SIZE_728x90.height)];
    }
    else
    {
        bannerView_ = [[GADBannerView alloc]
                       initWithFrame:CGRectMake(0.0,
                                                0.0,
                                                GAD_SIZE_320x50.width,
                                                GAD_SIZE_320x50.height)];
    }
    bannerView_.adUnitID = GOOGLE_AD_ID;
    bannerView_.rootViewController = self;
    [self.adView addSubview:bannerView_];
    if (!SHOW_AD) {
        self.adView.hidden = YES;
    }
    [bannerView_ loadRequest:[GADRequest request]];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableSet deselectRowAtIndexPath:[self.tableSet indexPathForSelectedRow] animated:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //[vc willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (IBAction)done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 11;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
        return cell;
    }
    else if (indexPath.row == 3) {
        static NSString *draw3Identifier = @"Draw3";
        
        SwitchCell *cell = (SwitchCell*)[tableView dequeueReusableCellWithIdentifier:
                                         draw3Identifier];
        if (cell == nil)
        {
            //默认样式
            cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier: draw3Identifier];
        }
        cell.sw.on = vc.game.draw3;
        cell.sc.hidden = YES;
        cell.label.text = [NSString stringWithFormat:@"%@ 3",NSLocalizedStringFromTable(@"draw", @"Language", nil)];
        [cell.sw addTarget:self action:@selector(switchDraw:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
    else if (indexPath.row == 4) {
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
        cell.sc.selectedSegmentIndex = vc.gameView.sound;
        [cell.sc addTarget:self action:@selector(switchSound:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
    else if (indexPath.row == 5) {
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
        return cell;
    }
    else if (indexPath.row == 6) {
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
        return cell;
    }
    else if (indexPath.row == 7) {
        static NSString *hintsIdentifier = @"Hints";
        
        SwitchCell *cell = (SwitchCell*)[tableView dequeueReusableCellWithIdentifier:
                                         hintsIdentifier];


        cell.sc.hidden = YES;
        cell.label.text = NSLocalizedStringFromTable(@"hint", @"Language", nil);
        cell.sw.on = vc.autohintEnabled;
        [cell.sw addTarget:self action:@selector(switchHints:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
    else if (indexPath.row == 8) {
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
    else if (indexPath.row == 9) {
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
        return cell;
    }
    else if (indexPath.row == 10) {
        static NSString *rulesIdentifier = @"Rules";
        
        SwitchCell *cell = (SwitchCell*)[tableView dequeueReusableCellWithIdentifier:
                                         rulesIdentifier];
        if (cell == nil)
        {
            //默认样式
            cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier: rulesIdentifier];
        }
        cell.textLabel.text = NSLocalizedStringFromTable(@"rules", @"Language", nil);
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
    [self dismissModalViewControllerAnimated:YES];
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
    [settings setInteger:[[UIDevice currentDevice] orientation] forKey:@"currentori"];
    [settings synchronize];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *lbl = [[UILabel alloc] init];
    lbl.textAlignment = UITextAlignmentCenter;
    lbl.text = NSLocalizedStringFromTable(@"scroll", @"Language", nil);
    lbl.font = [UIFont systemFontOfSize:20];
    lbl.backgroundColor = tableView.backgroundColor;
    return lbl;
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

@end
