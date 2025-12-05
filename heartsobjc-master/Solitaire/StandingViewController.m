//
//  StandingViewController.m
//  Hearts
//
//  Created by yysdsyl on 13-9-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "StandingViewController.h"
#import "ViewController.h"

@interface IdxScore : NSObject
@property (assign, nonatomic) int idx;
@property (assign, nonatomic) int score;
- (id)initWithIdxScore:(int)idx score:(int)score;
@end

@implementation IdxScore

@synthesize idx = _idx;
@synthesize score = _score;

- (id)initWithIdxScore:(int)idx score:(int)score
{
    self = [super init];
    if (self) {
        _score = score;
        _idx = idx;
    }
    return self;
}

@end

@interface StandingViewController ()
{
    NSArray* playerNamesLabel;
    NSArray* currentScoresLabel;
    NSArray* totalScoresLabel;
    BOOL rotate;
}

@end

@implementation StandingViewController

@synthesize close;

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
    self.close = YES;
	// Do any additional setup after loading the view.
    self.view.opaque = YES;
    self.mainView.backgroundColor = [UIColor clearColor];
    ///
    playerNamesLabel = [[NSArray alloc] initWithObjects:self.name1,self.nam2,self.name3,self.name4,nil];
    currentScoresLabel = [[NSArray alloc] initWithObjects:self.hand1,self.hand2,self.hand3,self.hand4,nil];
    totalScoresLabel = [[NSArray alloc] initWithObjects:self.total1,self.total2, self.total3,self.total4, nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    ViewController* vc = (ViewController*)[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] topViewController];
    [self setSocres:vc.game.currentscores totalScores:vc.game.totalscores handCnt:vc.game.handcnt];
    vc.svc.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    rotate = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSocres:(NSArray*)curScores totalScores:(NSArray*)totalScores handCnt:(int)handCnt
{
    rotate = YES;
    NSMutableArray* nssort = [[NSMutableArray alloc] init];
    for (int i = 0; i < NUM_PLAYERS; i++) {
        [nssort addObject:[[IdxScore alloc] initWithIdxScore:i score:[[totalScores objectAtIndex:i] integerValue]]];
    }
    [nssort sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        IdxScore* c1 = obj1;
        IdxScore* c2 = obj2;
        if (c1.score < c2.score) {
            return NSOrderedAscending;
        }
        else if (c1.score > c2.score)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
    ///
    for (int i = 0; i < NUM_PLAYERS; i++) {
        IdxScore* is = [nssort objectAtIndex:i];
        int idx = is.idx;
        UILabel* namelbl = [playerNamesLabel objectAtIndex:i];
        switch (idx) {
            case 0:
                namelbl.text = @"You";
                namelbl.textColor = [UIColor yellowColor];
                break;
            case 1:
                namelbl.text = @"West";
                namelbl.textColor = [UIColor greenColor];
                break;
            case 2:
                namelbl.text = @"North";
                namelbl.textColor = [UIColor greenColor];
                break;
            case 3:
                namelbl.text = @"East";
                namelbl.textColor = [UIColor greenColor];
                break;
            default:
                break;
        }
        UILabel* handlbl = [currentScoresLabel objectAtIndex:i];
        handlbl.text = [NSString stringWithFormat:@"%d",[[curScores objectAtIndex:idx] integerValue]];
        if (idx == 0)
            handlbl.textColor = [UIColor yellowColor];
        else
            handlbl.textColor = [UIColor greenColor];
        UILabel* totallbl = [totalScoresLabel objectAtIndex:i];
        if (idx == 0)
            totallbl.textColor = [UIColor yellowColor];
        else
            totallbl.textColor = [UIColor greenColor];
        totallbl.text = [NSString stringWithFormat:@"%d", [[totalScores objectAtIndex:idx] integerValue]];
    }
    self.handplayed.text = [NSString stringWithFormat:@"Hand Played : %d", handCnt];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    BOOL rotateFlag = [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
    if (rotateFlag && rotate) {
        return YES;
    }
    else
    {
        return (toInterfaceOrientation == [[NSUserDefaults standardUserDefaults] integerForKey:@"currentori"]);
    }
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return (rotate && [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"]);
}

- (void)viewDidUnload {
    [self setName1:nil];
    [self setNam2:nil];
    [self setName3:nil];
    [self setName4:nil];
    [self setHand1:nil];
    [self setHand2:nil];
    [self setHand3:nil];
    [self setHand4:nil];
    [self setTotal1:nil];
    [self setTotal2:nil];
    [self setTotal3:nil];
    [self setTotal4:nil];
    [self setHandplayed:nil];
    [self setMainView:nil];
    [super viewDidUnload];
}
- (IBAction)dismiss:(id)sender {
    self.close = NO;
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"closestanding" object:nil];
    }];
}
@end
