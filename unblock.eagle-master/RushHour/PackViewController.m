//
//  PackViewController.m
//  Flow
//
//  Created by yysdsyl on 13-10-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PackViewController.h"
#import "PuzzleCell.h"
#import "Common.h"
#import "GameData.h"
#import "StagesViewController.h"
#import "Admob.h"
#import "ProtocolAlerView.h"
#import <SafariServices/SafariServices.h>
#include "ApplovinMaxWrapper.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
@interface PackViewController ()
{
    BOOL ipdDevice;
    GameData* gameData;
    __weak IBOutlet NSLayoutConstraint *admobHeightIpd;
    __weak IBOutlet NSLayoutConstraint *admobHeight;
}

@end

@implementation PackViewController

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
    //[self.bgImage.layer insertSublayer:[Common emitter] atIndex:0];
    /// admob
    //[Common addAds:self.adView rootVc:self];
    ///
    [self.packTableView setDelegate:self];
    [self.packTableView setDataSource:self];
    ///
    gameData = [GameData sharedGD];
    [self admobHeightUpdate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[AdmobViewController shareAdmobVC] show_admob_banner_smart:0.0 posy:0.0 view:self.adView];
    [self.packTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
    [TheSound playTapSound];
}

#pragma UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [gameData.packPuzzles count];
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
    NSArray* cellData = [gameData.packPuzzles objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    int levelno = [[gameData.packNames objectAtIndex:indexPath.row] intValue];
    NSString* levelstr = [NSString stringWithFormat:@"level%d", levelno];
    cell.nameLabel.textColor = [UIColor whiteColor];//[Common colors:indexPath.row];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ Puzzles",NSLocalizedStringFromTable(levelstr, @"Language", nil)];
    cell.progressLabel.text = [NSString stringWithFormat:@"%d/%d",[[gameData.packCompleted objectAtIndex:indexPath.row] integerValue],[cellData count]-[cellData count]%(CELL_NUM*CELL_NUM)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self showPack:indexPath.row]) {
        return;
    }
    gameData.section = indexPath.section;
    gameData.row = indexPath.row;
    //[self.packTableView deselectRowAtIndexPath:indexPath animated:NO];
    PuzzleCell* cell = (PuzzleCell*)[self.packTableView cellForRowAtIndexPath:indexPath];
    [cell selectEffect];
    gameData.levelName = cell.nameLabel.text;
    [TheSound playTapSound];
    ///
    [self performSegueWithIdentifier:@"chapterSegue" sender:self];
}

- (BOOL) showPack:(int)idx {
    AdmobViewController* vc = [AdmobViewController shareAdmobVC];
    if([vc hasInAppPurchased])
        return FALSE;
    GRTService* ser = (GRTService*)[vc rtService];
    if([ser isRT] || [ser isGRT]) {
        return FALSE;
    }
    
    NSDictionary* ex = [[[AdmobViewController shareAdmobVC] configCenter] getExConfig];
    long count = 0;
    @try {
        if(ex != nil && [ex valueForKey:@"lt"] != nil) {
            count = [ex[@"lt"] integerValue];
        }
    } @catch(NSException*) {
        count = 0;
    } @finally {
        
    }
    
    if(count > 0 && idx > count) {
        return [vc getRT:self isLock:true rd:@"unlock all levels" cb:^(){}];
    }
    return FALSE;
}
- (void) admobHeightUpdate {
    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];
    CGFloat admobHeight1 = [applovinWrapper getAdmobHeight];
    admobHeight.constant=admobHeight1;
}
@end
