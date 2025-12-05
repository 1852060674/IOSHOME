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
    vc = (ViewController*)[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] topViewController];
    stat = vc.gameStat;
    //NSLog(@"the stat view lost is %d",stat.draw1.lostCnt);
}

- (void)viewWillAppear:(BOOL)animated{
    
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
    return 9;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    if (section == 0) {
//        return [NSString stringWithFormat:@"%@ 1",NSLocalizedStringFromTable(@"draw", @"Language", nil)];
//    }
    //return [NSString stringWithFormat:@"%@ 3",NSLocalizedStringFromTable(@"draw", @"Language", nil)];
    return @"Statistics";
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DrawStat* ds = nil;
    if (indexPath.section == 0) {
        ds = stat.freecell;
    }
    else
    {
        ds = stat.freecell;
    }
    //
    static NSString *itemIdentifier = @"StatCell";
    StatCell *cell = (StatCell*)[tableView dequeueReusableCellWithIdentifier:itemIdentifier];
    
    if (cell == nil)
    {
        //默认样式
        cell = [[StatCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:itemIdentifier];
    }
    cell.keyLabel.font = [UIFont boldSystemFontOfSize:15];
    cell.valueLabel.font = [UIFont boldSystemFontOfSize:15];
    switch (indexPath.row) {
        case 0:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"gamewon", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%d(%0.1f%%)",ds.wonCnt,100.0*ds.wonCnt/(ds.wonCnt+ds.lostCnt+0.000001)];
            return cell;
            break;
        case 1:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"gamelost", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%d",ds.lostCnt];
            return cell;
            break;
        case 2:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"shortesttime", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%d:%02d",ds.shortestWonTime/60,ds.shortestWonTime%60];
            return cell;
            break;
        case 3:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"longesttime", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%d:%02d",ds.longestWonTime/60,ds.longestWonTime%60];
            return cell;
            break;
        case 4:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"avgtime", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%d:%02d",ds.averageWonTime/60,ds.averageWonTime%60];
            return cell;
            break;
        case 5:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"fewestmoves", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%d",ds.fewestWonMoves];
            return cell;
            break;
        case 6:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"mostmoves", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%d",ds.mostWonMoves];
            return cell;
            break;
        case 7:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"noundo", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%d",ds.wonWithoutUndoCnt];
            return cell;
            break;
        case 8:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"highscore", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%d",ds.highestSocre];
            return cell;
            break;
            
        default:
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (IBAction)dismissMyself:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)Reset:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                   message:NSLocalizedStringFromTable(@"resethint", @"Language", nil)
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedStringFromTable(@"yes", @"Language", nil)
                                         otherButtonTitles:NSLocalizedStringFromTable(@"no", @"Language", nil),nil];
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
