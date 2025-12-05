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
#import "Common.h"
#import "Admob.h"
#import "Masonry.h"
#import "ProtocolAlerView.h"
#import <SafariServices/SafariServices.h>
#include "ApplovinMaxWrapper.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
@interface ViewController ()
{
    __weak IBOutlet NSLayoutConstraint *admobHeightIph;
    __weak IBOutlet UIView *admobHeightIpd;
    
}

@end

@implementation ViewController

@synthesize gameData;

- (void)loadSettings
{
    /// default
    NSDictionary *defaultValue = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:YES],@"sound",
                                  [NSNumber numberWithBool:NO],@"label",
                                  [NSNumber numberWithBool:NO],@"rated",
                                  [NSNumber numberWithInt:0],@"cnt",
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //[self.bgImage.layer insertSublayer:[Common emitter] atIndex:0];
    /// settings
    [self loadSettings];
    /// game data
    [self loadGameData];
    
    //free hints
    [self preSetFreeHints];
    ///
    /// admob
    //[Common addAds:self.adView rootVc:self];
    
    if(![[AdmobViewController shareAdmobVC] ifNeedShowNext:self]) {
        [[AdmobViewController shareAdmobVC] decideShowRT:self];
    }
    
}

- (void) preSetFreeHints {
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    id obj = [settings objectForKey:FREE_HINTS_SETTING_KEY];
    if(obj == nil) {
        int freehints = 5;
        long opencount = [[[AdmobViewController shareAdmobVC] getAppUseStats] getAppOpenCountTotal];
        if(opencount > 3) {
            freehints = 10000;
        }
        [settings setObject:[NSNumber numberWithInt:freehints] forKey:FREE_HINTS_SETTING_KEY];
        [settings synchronize];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [[AdmobViewController shareAdmobVC] show_admob_banner_smart:0.0 posy:0.0 view:self.adView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBgImage:nil];
    [self setAdView:nil];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveGameData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self admobHeightUpdate];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

- (IBAction)play:(id)sender {
    [TheSound playTapSound];
}

- (IBAction)settings:(id)sender {
    [TheSound playTapSound];
    [self performSegueWithIdentifier:@"settingsSegue" sender:self];
}

- (IBAction)help:(id)sender {
    [TheSound playTapSound];
}

- (IBAction)more:(id)sender {
    [TheSound playTapSound];
}

- (void) admobHeightUpdate {
    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];
    CGFloat admobHeight1 = [applovinWrapper getAdmobHeight];
    [self.adView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(admobHeight1)).priorityHigh(); // 更新约束的值
            }];
    admobHeightIph.constant=admobHeight1;
}

- (void) admobHeightUpdate1 :(id)sender {
    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];
    CGFloat admobHeight1 = [applovinWrapper getAdmobHeight];
    [self.adView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(admobHeight1)).priorityHigh(); // 更新约束的值
            }];
    admobHeightIph.constant=admobHeight1;
}
@end
