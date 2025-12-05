//
//  ViewController.h
//  WordSearch
//
//  Created by apple on 13-8-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameData.h"

@interface ViewController : UIViewController

@property (strong, nonatomic) GameData* gameData;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UIView *adView;

- (void)loadSettings;
- (void)loadGameData;
- (void)saveGameData;
- (IBAction)play:(id)sender;
- (IBAction)settings:(id)sender;
- (IBAction)help:(id)sender;
- (IBAction)more:(id)sender;

@end
