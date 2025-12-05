//
//  ViewController.m
//  WordSearch
//
//  Created by apple on 13-8-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ViewController.h"
#import "PuzzleCell.h"
#import "PlayViewController.h"
#import "TheSound.h"
#import "Config.h"
#import "TKAlertCenter.h"
#import "Admob.h"
#import "ProtocolAlerView.h"
#import <SafariServices/SafariServices.h>
#include "ApplovinMaxWrapper.h"
@interface ViewController ()
{
    CGFloat SECTION_HEIGHT;
    BOOL ipdDevice;
    BOOL show_banner;
    __weak IBOutlet NSLayoutConstraint *admobHeight;
    __weak IBOutlet UILabel *CHOOSEPUZZLE;
}

@end

@implementation ViewController

@synthesize gameData;

- (void)loadSettings
{
    NSLog(@"zzx SECTION_HEIGHT = %f",SECTION_HEIGHT);
    if ([[UIScreen mainScreen] bounds].size.height >= 812) {
        CHOOSEPUZZLE.font=[UIFont systemFontOfSize:24];
        }
    /// default
    NSDictionary *defaultValue = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:YES],@"sound",
                                  [NSNumber numberWithBool:YES],@"notify",
                                  [NSNumber numberWithInt:0],@"cnt",
                                  [NSNumber numberWithBool:NO],@"rated",
                                  nil];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings registerDefaults:defaultValue];
    [settings synchronize];
    /// load
}

- (void)loadGameData
{
    NSString* path = [NSString stringWithFormat:@"%@/Documents/game.dat",NSHomeDirectory()];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        gameData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (gameData.version == 0) {
            gameData = [[GameData alloc] init];
            [gameData loadPuzzlesFromFile];
        }
    }
    else
    {
        gameData = [[GameData alloc] init];
        [gameData loadPuzzlesFromFile];
    }
}

- (void)saveGameData
{
    NSString* path = [NSString stringWithFormat:@"%@/Documents/game.dat",NSHomeDirectory()];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:gameData];
    [data writeToFile:path atomically:YES];
    //NSLog(@"%d-%@-%@",[gameData.packNames count],[[gameData.packPuzzles objectAtIndex:1] objectForKey:@"AUTOMOBILIA"],[gameData.packExplaned objectAtIndex:2]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.basicPack.separatorStyle = UITableViewCellSeparatorStyleNone;
    /// settings
    [self loadSettings];
    /// game data
    [self loadGameData];
    ///
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        ipdDevice = YES;
    else
        ipdDevice = NO;
    ///
    if (ipdDevice){
        SECTION_HEIGHT = 40;
    }
    else
    {
        SECTION_HEIGHT = 20;
    }
    
    [[AdmobViewController shareAdmobVC] decideShowRT:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBgImage:nil];
    [self setBasicPack:nil];
    [self setAdView:nil];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveGameData];
}

- (void)selectCurrent
{
    //
    if (gameData.row >= 0 && gameData.section >= 0)
    {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:gameData.row inSection:gameData.section];
        [self.basicPack selectRowAtIndexPath:ip animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [[AdmobViewController shareAdmobVC] show_admob_banner_smart:0.0 posy:0.0 view:self.adView];
    
    [self firstProtocolAlter];
    
    [self.basicPack reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    admobHeight.constant=MAAdFormat.banner.adaptiveSize.height;
    NSLog(@"MAAdFormat.banner.adaptiveSize.height; =%lf",MAAdFormat.banner.adaptiveSize.height);
    //
    [self selectCurrent];
}

#pragma UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [gameData.packPuzzles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![[gameData.packExplaned objectAtIndex:section] boolValue]) {
        return 0;
    }
    else
    {
        return [[gameData.packPuzzles objectAtIndex:section] count];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *itemIdentifier = @"puzzle";
    
    PuzzleCell *cell = (PuzzleCell*)[tableView dequeueReusableCellWithIdentifier:itemIdentifier];
    if (cell == nil)
    {
        //默认样式
        cell = [[PuzzleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemIdentifier];
    }
    //
    /*
    NSArray* cellData = [[[[gameData.packPuzzles objectAtIndex:indexPath.section] allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString*)[obj1 objectAtIndex:0] compare:(NSString*)[obj2 objectAtIndex:0]];
    }] objectAtIndex:indexPath.row];
     */
    NSArray* cellData = [[[gameData.packPuzzles objectAtIndex:indexPath.section] allValues] objectAtIndex:indexPath.row];
    cell.labelName.text = [cellData objectAtIndex:0];
    NSInteger bestTime = [(NSString*)[cellData objectAtIndex:1] integerValue];
    if (bestTime > 0) {
        cell.labelBestTime.text = [NSString stringWithFormat:@"Best Time: %02d:%02d",bestTime/60,bestTime%60];
    }
    else
    {
        cell.labelBestTime.text = @"";
    }
    /*
    if (indexPath.row == 2) {
        bestTime = 110;
    }
    else if (indexPath.row == 1)
    {
        bestTime = 10;
    }
    else if (indexPath.row == 3)
    {
        bestTime = 220;
    }
     */
    [cell setTime:bestTime];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return SECTION_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (ipdDevice) {
        return 70;
    }
    else
    {
        return 44;
    }
}

- (void)expandSection:(id)sender
{
    NSUInteger idx = [(UIView *)sender tag];
    BOOL opened = [[gameData.packExplaned objectAtIndex:idx] boolValue];
    [gameData.packExplaned replaceObjectAtIndex:idx withObject:[NSNumber numberWithBool:!opened]];
    [self.basicPack reloadData];
    [TheSound playTapSound];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor blackColor];
    btn.frame = CGRectMake(0, 0, tableView.frame.size.width, SECTION_HEIGHT);
    btn.tag = section;
    [btn addTarget:self action:@selector(expandSection:) forControlEvents:UIControlEventTouchUpInside];
    ///
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(btn.frame.size.height-2, 1, btn.frame.size.width, btn.frame.size.height-2)];
    lbl.text = [NSString stringWithFormat:@"%@  (%d puzzles)",[gameData.packNames objectAtIndex:section],[[gameData.packPuzzles objectAtIndex:section] count]];
    if ([[UIScreen mainScreen] bounds].size.height >= 812) {
        lbl.font = [UIFont systemFontOfSize:SECTION_HEIGHT];
    }else{
        lbl.font = [UIFont systemFontOfSize:SECTION_HEIGHT-3];
    }
    lbl.backgroundColor = [UIColor colorWithRed:0x2a/255.0 green:0x5c/255.0 blue:0xaa/255.0 alpha:1];
    lbl.textColor = [UIColor whiteColor];
    tableView.sectionHeaderTopPadding =0;
    btn.contentEdgeInsets = UIEdgeInsetsZero;
    ///
    ///
    UIImageView *triImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, btn.frame.size.height-2, btn.frame.size.height-2)];
    NSString* listImgName = [[gameData.packExplaned objectAtIndex:section] boolValue] ? @"list_down" : @"list_up";
    triImage.image = [UIImage imageNamed:listImgName];
    triImage.backgroundColor = lbl.backgroundColor;
    [btn addSubview:triImage];
    ///
    [btn addSubview:lbl];
    return btn;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.basicPack deselectRowAtIndexPath:indexPath animated:YES];
    gameData.section = indexPath.section;
    gameData.row = indexPath.row;
    [TheSound playConfirmSound];
}

- (IBAction)showAdUp:(id)sender {
    [TheSound playTapSound];
}

- (IBAction)settings:(id)sender {
    [TheSound playTapSound];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"playSegue"]) {
        if (gameData.section == -1) {
            gameData.section = 0;
            gameData.row = 0;
        }
        PlayViewController* pvc = segue.destinationViewController;
        [pvc setGameData:gameData];
    }
}

- (IBAction)play:(id)sender {
    [TheSound playTapSound];
    [[AdmobViewController shareAdmobVC] checkConfigUD];
}
- (IBAction)rate:(id)sender {
    [self rating];
}

-(void)rating
{
    [[[AdmobViewController shareAdmobVC] rtService] doRT];
}

// att
- (void) firstProtocolAlter {
    NSString * val = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstLaunch"];
    if (!val) {
        
        //show alert
        
        ProtocolAlerView *alert = [ProtocolAlerView new];
        alert.viewController = self;
        alert.strContent = @"Thanks for using Word Search!\nin this app, We do not collect any data from your device including processed data. By clicking 'Agree' you confirm that you have read and agree to our privacy policy. \nAt the same time, Ads may be displayed in this app. When requesting to 'track activity' in the next popup, please click 'Allow' to let us find more personalized ads. It's completely anonymous and only used for relevant ads.";
        
        [alert showAlert:self cancelAction:^(id  _Nullable object) {
            //不同意
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"firstLaunch"];
            //                   [self exitApplication];
        } privateAction:^(id  _Nullable object) {
            //   输入项目的隐私政策的 URL
            SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://52.52.138.46/support/colorfulgame/wordfind/policy.html"]];
            //sfVC.delegate = self;
            [self presentViewController:sfVC animated:YES completion:nil];
            //        [self pushWebController:[YSCommonWebUrl userAgreementsUrl] isLoadOutUrl:NO title:@"用户协议"];
        } delegateAction:^(id  _Nullable object) {
            NSLog(@"用户协议");
            //   输入项目的隐私政策的 URL
            SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://52.52.138.46/support/colorfulgame/wordfind/policy.html"]];
            //sfVC.delegate = self;
            [self presentViewController:sfVC animated:YES completion:nil];
        }
        ];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"firstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
    }
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 视图布局完成后
    if (!show_banner) {
        [AdmobViewController shareAdmobVC].delegate=self;
//        [[AdmobViewController shareAdmobVC] show_admob_banner:0 posy:0 width:self.gameView.admobView.frame.size.width height:self.gameView.admobView.frame.size.height view:self.gameView.admobView];
        [[AdmobViewController shareAdmobVC] show_admob_banner_smart:0.0 posy:0.0 view:self.adView];
        show_banner=YES;
    }
}
@end
