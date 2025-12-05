//
//  TopHighViewController.m
//  Golf
//
//  Created by apple on 13-9-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "TopHighViewController.h"
#import "ViewController.h"

@interface TopHighViewController ()
{
    NSArray* topNames;
    NSArray* topScores;
    BOOL rotate;
    ViewController* fvc;
}
@end

@implementation TopHighViewController

@synthesize ori;

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
    self.view.opaque = YES;
    self.mainView.backgroundColor = [UIColor clearColor];
    ///
    topNames = [[NSArray alloc] initWithObjects:self.name1,self.name2,self.name3,self.name4,self.name5, nil];
    topScores = [[NSArray alloc] initWithObjects:self.score1,self.score2,self.score3,self.score4,self.score5, nil];
}

- (void)setTopNameScore:(NSArray*)scores
{
    rotate = YES;
    if (scores == nil) {
        return;
    }
    for (int i = 0; i < [scores count]; i++) {
        NameScore* ns = [scores objectAtIndex:i];
        UILabel* nameLabel = [topNames objectAtIndex:i];
        UILabel* scoreLabel = [topScores objectAtIndex:i];
        nameLabel.text = [NSString stringWithFormat:@"%d:%@",i+1,ns.name];
        scoreLabel.text = [NSString stringWithFormat:@"%d",ns.score];
        [nameLabel setNeedsDisplay];
        [scoreLabel setNeedsDisplay];
    }
}

- (void)setVC:(id)vc
{
    fvc = vc;
}

- (void)viewWillAppear:(BOOL)animated
{
    ViewController* vc;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        vc = fvc;
    }
    else
    {
        vc = (ViewController*)[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] topViewController];
    }
    [self setTopNameScore:vc.gameStat.topScores];
    vc.thvc.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    rotate = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    //return self.ori == toInterfaceOrientation;
    BOOL rotateFlag = [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
    if (rotateFlag && rotate) {
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
    return ([[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"] && rotate);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    /*
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 6.0) {
        ViewController* vc = (ViewController*)[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] topViewController];
        [self.parentViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        [vc willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
    else
    {
        [self.parentViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
     */
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidUnload {
    [self setMainView:nil];
    [self setName1:nil];
    [self setName2:nil];
    [self setName3:nil];
    [self setName4:nil];
    [self setName5:nil];
    [self setScore1:nil];
    [self setScore2:nil];
    [self setScore3:nil];
    [self setScore4:nil];
    [self setScore5:nil];
    [super viewDidUnload];
}
@end
