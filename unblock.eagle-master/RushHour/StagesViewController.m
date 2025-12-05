//
//  StagesViewController.m
//  Flow
//
//  Created by yysdsyl on 13-10-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "StagesViewController.h"
#import "LevelView.h"
#import "GameData.h"
#import "PlayViewController.h"
#import "Common.h"

@interface StagesViewController ()
{
    GameData* gameData;
}

@end

@implementation StagesViewController

@synthesize seq;

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
    ///
    gameData = [GameData sharedGD];
	// Do any additional setup after loading the view.
    [self layoutLevelsViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutLevelsViews
{
    CGFloat eachSize = self.cellView.frame.size.width/CELL_NUM;
    for (int i = 0; i < CELL_NUM; i++) {
        for (int j = 0; j < CELL_NUM; j++) {
            LevelView* lv = [[LevelView alloc] initWithFrame:CGRectMake(j*eachSize, i*eachSize, eachSize, eachSize) theType:0 theNo:CELL_NUM*CELL_NUM*self.seq + i*CELL_NUM+j+1 theState:[[[[gameData.packPuzzles objectAtIndex:gameData.row] objectAtIndex:CELL_NUM*CELL_NUM*self.seq + i*CELL_NUM+j] objectAtIndex:3] integerValue] color:self.seq];
            [lv updateDisplay];
            [self.cellView addSubview:lv];
        }
    }
    self.stageName.text = [NSString stringWithFormat:@"Pack %d",self.seq+1];
    self.stageName.textColor = [UIColor whiteColor];//[Common colors:self.seq];
}

- (void)updateStates
{
    for (UIView* lv in self.cellView.subviews) {
        if ([lv isKindOfClass:[LevelView class]]) {
            LevelView* t = (LevelView*)lv;
            t.state = [[[[gameData.packPuzzles objectAtIndex:gameData.row] objectAtIndex:t.no-1] objectAtIndex:3] integerValue];
            [t updateDisplay];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*
    if ([segue.identifier isEqualToString:@"playSegue"]) {
        PlayViewController* pvc = segue.destinationViewController;
        [self.navigationController pushViewController:pvc animated:YES];
    }
     */
}

@end
