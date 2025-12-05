//
//  ViewController.h
//  WordSearch
//
//  Created by apple on 13-8-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameData.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) GameData* gameData;

@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UITableView *basicPack;
- (IBAction)showAdUp:(id)sender;
- (IBAction)settings:(id)sender;
- (IBAction)play:(id)sender;

- (void)expandSection:(id)sender;

- (void)loadSettings;
- (void)loadGameData;
- (void)saveGameData;
@property (weak, nonatomic) IBOutlet UIView *adView;

@end
