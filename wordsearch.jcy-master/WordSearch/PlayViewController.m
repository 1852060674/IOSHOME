//
//  PlayViewController.m
//  WordSearch
//
//  Created by apple on 13-8-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PlayViewController.h"
#import "CharView.h"
#import "OpViewController.h"
#import "TheSound.h"
#import "Config.h"
#import "TKAlertCenter.h"
#include "ApplovinMaxWrapper.h"
#import "Config.h"

#define TAG_RATE 1001
#define TAG_HINT 1002

@interface PlayViewController ()
{
    NSArray* answerWordLabels;
    __weak IBOutlet NSLayoutConstraint *PuzzlecenterY;
    NSMutableArray* answerWords;
    NSMutableArray* allCharViews;
    GameData* gameData;
    int foundCnt;
    NSTimer *timer;
    int timeCnt;
    NSMutableArray *candidateHint;
    __weak IBOutlet NSLayoutConstraint *admobHeight;
    BOOL show_banner;
}
@end

char board[NNUM][NNUM];

@implementation PlayViewController

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
    if (!IS_IPAD) {
        NSArray *labelArray = @[_Label1, _Label2, _Label3, _Label4, _Label5, _Label6, _Label7, _Label8];
        if ([[UIScreen mainScreen] bounds].size.height >= 812 ) {
            PuzzlecenterY.constant=15;
            for (UILabel *label in labelArray) {
                label.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightBold];
            }
        }else{
            PuzzlecenterY.constant=5;
            for (UILabel *label in labelArray) {
                label.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightBold];
            }
        }
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ///
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"displayword" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayword:) name:@"displayword" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"judgedone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(judgedone:) name:@"judgedone" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"nextgame" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextgame:) name:@"nextgame" object:nil];
    ///
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    ///
    self.currentWordLabel.textColor = RGB(0xef,0xa5,0x40,1);
    candidateHint = [[NSMutableArray alloc] init];
    ///
    [self newGame];
    //
}

-(void)adMobVCDidReceiveInterstitialAd:(AdmobViewController *)adMobVC
{
    
}
-(void)adMobVCWillCloseInterstitialAd:(AdmobViewController *)adMobVC
{
    
}

-(void)adMobVCDidCloseInterstitialAd:(AdmobViewController *)adMobVC
{
    [self performSegueWithIdentifier:@"opsegue" sender:self];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"displayword" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"judgedone" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"nextgame" object:nil];
}

- (IBAction)onHint:(id)sender {
    if (foundCnt >= [answerWords count])
        return;
    //
    [TheSound playTapSound];
    //
    [candidateHint removeAllObjects];
    for (UILabel* lbl in answerWordLabels) {
        if (lbl.backgroundColor == [UIColor clearColor])
        {
            [candidateHint addObject:lbl.text];
        }
    }
    
    
    //
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"ㅤㅤChoose One Word For Hint"
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:nil];
    for (int i = 0; i < [candidateHint count]; i++) {
        [actionSheet addButtonWithTitle:[candidateHint objectAtIndex:i]];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.tag = 1002;
    [actionSheet showInView:self.view];
}

- (void)newGame
{
    //
    /*
    NSArray* thePuzzle = [[[[gameData.packPuzzles objectAtIndex:gameData.section] allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString*)[obj1 objectAtIndex:0] compare:(NSString*)[obj2 objectAtIndex:0]];
    }] objectAtIndex:gameData.row];
     */
    NSArray* thePuzzle = [[[gameData.packPuzzles objectAtIndex:gameData.section] allValues] objectAtIndex:gameData.row];
    /* for test
    int testno = 0;
    while (YES) {
        [self randomPuzzleBoard:[thePuzzle subarrayWithRange:NSMakeRange(1, [thePuzzle count]-1)]];
        testno++;
        NSLog(@"%d",testno);
    }
     */
    [self randomPuzzleBoard:[thePuzzle subarrayWithRange:NSMakeRange(2, [thePuzzle count]-2)]];
    [self layoutAnswerWords];
    [self layoutCharViews];
    ///
    foundCnt = 0;
    timeCnt = 0;
    int bestTime = [[thePuzzle objectAtIndex:1] integerValue];
    if (bestTime == 0) {
        self.bestTimeLabel.text = @"-";
    }
    else
    {
        self.bestTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",bestTime/60,bestTime%60];
    }
    [self updateFound];
    self.currentWordLabel.text = @"";
    [self.puzzleView resetDraw];
    ///
}

- (void)delayShowAd
{
    /*
    ///cnt for show ad
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    int timecnt = [[settings objectForKey:@"cnt"] integerValue];
    timecnt++;
    [settings setObject:[NSNumber numberWithInt:timecnt] forKey:@"cnt"];
    [settings synchronize];

    if (timecnt % TIMECNT_FOR_AD == 0) {
        if ([interstitial_ isReady]) {
            [interstitial_ presentFromRootViewController:self];
        }
    }
     */
    if ([[AdmobViewController shareAdmobVC] admob_interstial_ready]) {
        [[AdmobViewController shareAdmobVC] show_admob_interstitial:self];
    }
}

- (IBAction)pause:(id)sender {
    [TheSound playTapSound];
}

- (IBAction)showAd:(id)sender {
    [TheSound playTapSound];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWordsView:nil];
    [self setAdView:nil];
    [self setPuzzleView:nil];
    [self setCurrentWordLabel:nil];
    [self setWordLabel1:nil];
    [self setWordLabel2:nil];
    [self setWordLabel3:nil];
    [self setWordLabel4:nil];
    [self setWordLabel5:nil];
    [self setWordLabel6:nil];
    [self setWordLabel7:nil];
    [self setWordLabel8:nil];
    [self setBestTimeLabel:nil];
    [self setTimerLabel:nil];
    [self setFoundLabel:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    admobHeight.constant=MAAdFormat.banner.adaptiveSize.height;
    //admob
    [[AdmobViewController shareAdmobVC] show_admob_banner_smart:0.0 posy:0.0 view:self.adView];
    [[AdmobViewController shareAdmobVC] setDelegate:self];
    
    /// start timer
    [timer setFireDate:[NSDate distantPast]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    /// stop timer
    [timer setFireDate:[NSDate distantFuture]];
    [self saveGameData];
}

- (void)saveGameData
{
    NSString* path = [NSString stringWithFormat:@"%@/Documents/game.dat",NSHomeDirectory()];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:gameData];
    [data writeToFile:path atomically:YES];
}

- (void)updateTime
{
    timeCnt++;
    self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d",timeCnt/60,timeCnt%60];
}

- (void)updateFound
{
    self.foundLabel.text = [NSString stringWithFormat:@"%d / %d",foundCnt,[answerWords count]];
}

- (void)setGameData:(GameData*)data
{
    gameData = data;
}

- (void)displayword:(NSNotification*)notifacation
{
    self.currentWordLabel.text = notifacation.object;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"opsegue"]) {
        OpViewController* ovc = (OpViewController*)segue.destinationViewController;
        if (foundCnt < [answerWords count]) {
            [ovc setType:OP_PAUSE];
        }
        else
        {
            [ovc setType:OP_NEXT];
            [ovc setTime:timeCnt];
            [TheSound playLevelUpSound];
        }
    }
}

- (void)judgedone:(NSNotification*)notifacation
{
    NSString* findstr = nil;
    if (notifacation == nil)
        findstr = self.currentWordLabel.text;
    else
        findstr = notifacation.object;
    if (findstr != nil) {
        NSMutableString* trimstr = [[NSMutableString alloc] init];
        for (int i = 0; i < [findstr length]; i++) {
            char c = [findstr characterAtIndex:i];
            if (c != ' ') {
                [trimstr appendFormat:@"%c",c];
            }
        }
        ///
        for (UILabel* lbl in answerWordLabels) {
            if (lbl.backgroundColor == [UIColor clearColor]
                && [trimstr isEqualToString:lbl.text]) {
                [self.puzzleView newDone:YES];
                lbl.backgroundColor = RGB(0xef,0xa5,0x40,1);
                foundCnt++;
                [self updateFound];
                [TheSound playCoinSound];
                if (foundCnt == [answerWords count]) {
                    [timer setFireDate:[NSDate distantFuture]];
                    NSString* key = [[[gameData.packPuzzles objectAtIndex:gameData.section] allKeys] objectAtIndex:gameData.row];
                    NSMutableArray* data = [[gameData.packPuzzles objectAtIndex:gameData.section] objectForKey:key];
                    /*
                    NSArray* sortedValues = [[[gameData.packPuzzles objectAtIndex:gameData.section] allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        return [(NSString*)[obj1 objectAtIndex:0] compare:(NSString*)[obj2 objectAtIndex:0]];
                    }];
                    NSArray* tempValue = [sortedValues objectAtIndex:gameData.row];
                    NSMutableArray* data = nil;
                    for (NSString* key in [[gameData.packPuzzles objectAtIndex:gameData.section] allKeys]) {
                        NSMutableArray* tdata = [[gameData.packPuzzles objectAtIndex:gameData.section] objectForKey:key];
                        BOOL same = YES;
                        for (int i = 1; i < 5; i++) {
                            NSString* tempStr = [tempValue objectAtIndex:i];
                            NSString* str = [tdata objectAtIndex:i];
                            if (![tempStr isEqualToString:str]) {
                                same = NO;
                                break;
                            }
                        }
                        if (same) {
                            data = tdata;
                            break;
                        }
                    }
                     */
                    int oldTime = [[data objectAtIndex:1] integerValue];
                    if (oldTime == 0 || timeCnt < oldTime) {
                        [data replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:@"%d",timeCnt]];
                    }
                    //[self performSegueWithIdentifier:@"opsegue" sender:self];
                    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
                    int timecnt = [[settings objectForKey:@"cnt"] integerValue];
                    timecnt++;
                    [settings setObject:[NSNumber numberWithInt:timecnt] forKey:@"cnt"];
                    [settings synchronize];
                    if (timecnt % TIMECNT_FOR_AD == 0) {
                        if ([[AdmobViewController shareAdmobVC] admob_interstial_ready]) {
                            //
                            if (IS_IPAD && [[[UIDevice currentDevice] systemVersion] floatValue] > 8.0) {
                                [self performSelector:@selector(delayShowAd) withObject:self afterDelay:0.25];
                            }
                            else
                                [[AdmobViewController shareAdmobVC] show_admob_interstitial:self];
                        }
                        else
                        {
                            if (IS_IPAD && [[[UIDevice currentDevice] systemVersion] floatValue] > 8.0) {
                                [self performSelector:@selector(delayShowOp) withObject:self afterDelay:0.25];
                            }
                            else
                                [self performSegueWithIdentifier:@"opsegue" sender:self];
                        }
                    }
                    else
                    {
                        if (IS_IPAD && [[[UIDevice currentDevice] systemVersion] floatValue] > 8.0) {
                            [self performSelector:@selector(delayShowOp) withObject:self afterDelay:0.25];
                        }
                        else
                            [self performSegueWithIdentifier:@"opsegue" sender:self];
                    }
                }
                return;
            }
        }
    }
    self.currentWordLabel.text = @"";
    [self.puzzleView newDone:NO];
}

- (void)delayShowOp
{
    [self performSegueWithIdentifier:@"opsegue" sender:self];
}

- (void)nextgame:(NSNotification*)notifacation
{
    if (gameData.row + 1 < [[gameData.packPuzzles objectAtIndex:gameData.section] count]) {
        gameData.row += 1;
    }
    else
    {
        if (gameData.section + 1 < [gameData.packPuzzles count]) {
            gameData.section += 1;
            gameData.row = 0;
        }
        else
        {
            gameData.section = 0;
            gameData.row = 0;
        }
    }
    ///
    [self newGame];
    //
    //[self delayShowAd];
}

///
- (void)layoutAnswerWords
{
    answerWordLabels = [NSArray arrayWithObjects:self.wordLabel1, self.wordLabel2, self.wordLabel3,
        self.wordLabel4, self.wordLabel5, self.wordLabel6,
                        self.wordLabel7, self.wordLabel8, nil];
    for (UILabel* lbl in answerWordLabels) {
        lbl.alpha = 0;
    }
    int idx = 0;
    for (NSString* word in answerWords) {
        UILabel* wordLabel = [answerWordLabels objectAtIndex:idx];
        idx++;
        wordLabel.text = word;
        wordLabel.backgroundColor = [UIColor clearColor];//RGB(240,159,40,1);
        [wordLabel sizeToFit];
        wordLabel.alpha = 1;
    }
    CGFloat height = self.wordsView.frame.size.height/3;
    CGFloat width = self.wordsView.frame.size.width/3;
    self.wordLabel1.center = CGPointMake(width/2, height/2);
    self.wordLabel2.center = CGPointMake(width/2+width, height/2);
    self.wordLabel3.center = CGPointMake(width/2+2*width, height/2);
    self.wordLabel4.center = CGPointMake(width/2, height/2+height);
    self.wordLabel5.center = CGPointMake(width/2+width, height/2+height);
    self.wordLabel6.center = CGPointMake(width/2+2*width, height/2+height);
    self.wordLabel7.center = CGPointMake(width/2, height/2+2*height);
    self.wordLabel8.center = CGPointMake(width/2+width, height/2+2*height);
}

- (void)layoutCharViews
{
    if (allCharViews == nil) {
        allCharViews = [[NSMutableArray alloc] init];
    }
    else
    {
        for (CharView* cv in allCharViews) {
            [cv removeFromSuperview];
        }
        [allCharViews removeAllObjects];
    }
    CGFloat eachWidth = self.view.frame.size.width/NNUM;
    if (self.view.frame.size.width +self.view.frame.size.height >1500) {
        eachWidth = self.puzzleView.frame.size.width/NNUM;
    }
// CGFloat eachWidth = self.puzzleView.frame.size.width/NNUM;
    for (int i = 0; i <NNUM; i++) {
        for (int j = 0; j < NNUM; j++)
        {
            CharView* cv = [[CharView alloc] initWithFrame:CGRectMake(0, 0, eachWidth, eachWidth) theChar:board[i][j] row:i col:j];
            [self.puzzleView addSubview:cv];
            cv.center = CGPointMake(j*eachWidth+eachWidth/2, i*eachWidth+eachWidth/2);
            [allCharViews addObject:cv];
        }
    }
    [self.puzzleView setAllCharViews:allCharViews];
}

#pragma generate board

#define MAXWORDS 200
#define MAXWORDLEN 15
#define MAXTRYCNT 5000

char wl[MAXWORDS][MAXWORDLEN];
int used[MAXWORDS];
int numwords = 0;
int xsize = NNUM;
int ysize = NNUM;
int dirs[8][2] = {{1,0},
    {0,1},
    {1,1},
    {1,-1},
    {-1,0},
    {0,-1},
    {-1,-1},
    {-1,1}};
int permitted[8] = {1,1,1,1,1,1,1,1};

int try(int x, int y, int dir, int word, int place)
{
    int len;
    int cnt;
    /*
     *  The length of the word can be used to rule out some places
     *  immediately.
     *
     */
    len = strlen(wl[word]);
    if (dirs[dir][0] == 1 && (len + x) > xsize) return(0);
    if (dirs[dir][0] == -1 && (len - 1) > x) return(0);
    if (dirs[dir][1] == 1 && (len + y) > ysize) return(0);
    if (dirs[dir][1] == -1 && (len - 1) > y) return(0);
    
    /*
     *  Otherwise, we have to try to place the word.
     *
     */
    for(cnt=0;cnt<len;cnt++) {
        if (board[x][y] != 0 && board[x][y] != wl[word][cnt]) {
            return(0);
        };
        if (place) board[x][y] = wl[word][cnt];
        x += dirs[dir][0];
        y += dirs[dir][1];
    };
    return(1);
};

int placeword(int word)
{
    int tried[8];
    int i,x,y,start_dir,start_x,start_y;
    /*
     *  Initialize the directions we've tried.
     *
     */
    for(i=0;i<8;i++) tried[i] = !permitted[i];
    /*
     *  Start somewhere randomly and then cycle around until you get
     *  back to your starting point or you manage to place the word.
     *
     */
    i = start_dir = random()%8;
    do {
        if (!tried[i]) {
            tried[i] = 1;
            /*
             *  Pick a random starting spot somewhere on the board and start
             *  trying this direction from that spot.
             *
             */
            y = start_y = random()%ysize;
            do {
                x = start_x = random()%xsize;
                do {
                    if (try(x,y,i,word,0)) {
                        try(x,y,i,word,1);
                        goto success;
                    };
                    x=(x+1)%xsize;
                } while (x != start_x);
                y=(y+1)%ysize;
            } while (y != start_y);
        };
        i=(i+1)%8;
    } while (i != start_dir);
    used[word] = -1;
    return(0);
success:
    used[word] = 1;
    return(1);
}

- (void)randomPuzzleBoard:(NSArray*)puzzles
{
    numwords = 0;
    int i,j;
    /// init
    for (i = 0; i < NNUM; i++) {
        for (j = 0; j < NNUM; j++) {
            board[i][j] = 0;
        }
    }
    ///
    for (NSString* word in puzzles) {
        if ([word length] >= MAXWORDLEN
            || [word rangeOfString:@" "].location != NSNotFound) {
            continue;
        }
        strcpy(wl[numwords], [word cStringUsingEncoding:NSUTF8StringEncoding]);
        numwords++;
    }
    ///
    for (i = 0; i < MAXWORDS; i++) {
        used[i] = 0;
    }
    ///
    int picked = 0;
    int trycnt = 0;
    BOOL allused = NO;
    srandom(time(NULL));
    while (picked < NEEDTOFOUND && trycnt < MAXTRYCNT) {
        int j = random()%numwords;
        int randcnt = 0;
        while (used[j]) {
            randcnt++;
            if (randcnt > 50*numwords) {
                BOOL tempused = YES;
                for (int k = 0; k < numwords; k++) {
                    if (used[k] == 0) {
                        tempused = NO;
                        break;
                    }
                }
                if (tempused) {
                    allused = YES;
                    break;
                }
            }
            j = (j+1)%numwords;
        };
        if (placeword(j))
        {
            picked++;
            used[j] = 1;
        }
        else
            used[j] = -1;
        trycnt++;
    }
    ///
    for (i = 0; i < NNUM; i++) {
        for (j = 0; j < NNUM; j++) {
            if (board[i][j] == 0) {
                board[i][j] = random()%26+'A';
            }
        }
    }
    ///
    if (answerWords != nil) {
        [answerWords removeAllObjects];
    }
    else
        answerWords = [[NSMutableArray alloc] init];
    ///
    for (i = 0; i < MAXWORDS; i++) {
        if (used[i] == 1 && [answerWords count] < NEEDTOFOUND)
        {
            [answerWords addObject:[NSString stringWithUTF8String:wl[i]]];
        }
    }
    ///check
    /*
    if (![self forceSearchForTest]) {
        NSLog(@"%d-%d",picked,trycnt);
        for (NSString* ns in answerWords) {
            printf("%s ",[ns UTF8String]);
        }
        printf("\n");
        for (int i = 0; i < NNUM; i++) {
            for (int j = 0; j < NNUM; j++) {
                printf("%c ",board[i][j]);
            }
            printf("\n");
        }
        printf("\n");
    }
     */
}

- (BOOL)forceSearchForTest
{
    for (int i = 0; i < MAXWORDS; i++) {
        BOOL found = YES;
        if (used[i] == 1) {
            found = NO;
            char* searchword = wl[i];
            int len = strlen(searchword);
            for (int y = 0; y < NNUM; y++)
            {
                for (int x = 0; x < NNUM;x++) {
                    if (board[x][y] == searchword[0]) {
                        for (int dir = 0; dir < 8; dir++) {
                            if (dirs[dir][0] == 1 && (len + x) > NNUM)
                            {
                                continue;
                            }
                            if (dirs[dir][0] == -1 && (len - 1) > x)
                            {
                                continue;
                            }
                            if (dirs[dir][1] == 1 && (len + y) > NNUM)
                            {
                                continue;
                            }
                            if (dirs[dir][1] == -1 && (len - 1) > y)
                            {
                                continue;
                            }
                            int x0 = x, y0 = y;
                            int cnt = 0;
                            for(cnt=0;cnt<len;cnt++) {
                                if (board[x0][y0] != wl[i][cnt]) {
                                    break;
                                };
                                x0 += dirs[dir][0];
                                y0 += dirs[dir][1];
                            };
                            if (cnt >= len) {
                                found = YES;
                                goto foundtag;
                            }
                        }
                    }
                }
            }
        }
    foundtag:
        if (!found) {
            NSLog(@"%s : not exist",wl[i]);
            return NO;
        }
    }
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == TAG_HINT)
    {
        if (buttonIndex < [candidateHint count])
        {
            NSString *targetStr = [candidateHint objectAtIndex:buttonIndex];
            if (targetStr.length > 0)
            {
                bool foundflag = NO;
                for (int i = 0; i < NNUM; i++)
                {
                    if (foundflag)
                        break;
                    for (int j = 0; j < NNUM; j++)
                    {
                        CharView* cv = allCharViews[i * NNUM + j];
                        if (cv.c != [targetStr characterAtIndex:0])
                            continue;
                        else
                        {
                            NSArray* foundedViews = [self isMatched:targetStr row:i col:j];
                            if ([foundedViews count] >= 2)
                            {
                                NSMutableString *hintStr = [[NSMutableString alloc] init];
                                for (int n = 0; n < targetStr.length; n++)
                                {
                                    char c = [targetStr characterAtIndex:n];
                                    [hintStr appendString:[NSString stringWithFormat:@"%c",c]];
                                    if (n != targetStr.length-1)
                                        [hintStr appendString:@" "];
                                }
                                self.currentWordLabel.text = hintStr;
                                self.puzzleView.fromCv = [foundedViews objectAtIndex:0];
                                self.puzzleView.toCv = [foundedViews objectAtIndex:[foundedViews count]-1];
                                for (CharView* fv in foundedViews)
                                {
                                    [fv bounce];
                                }
                                [self judgedone:nil];
                                foundflag = YES;
                                return;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}

- (NSArray*)isMatched:(NSString*)targetStr row:(int)row col:(int)col
{
    NSMutableArray* matchedView = [[NSMutableArray alloc] init];
    //right
    if (col + targetStr.length <= NNUM)
    {
        bool match = true;
        for (int i = 1; i < targetStr.length; i++)
        {
            if ([targetStr characterAtIndex:i] != board[row][col + i])
            {
                match = false;
                break;
            }
        }
        //
        if (match)
        {
            for (int i = 0; i < targetStr.length; i++)
            {
                [matchedView addObject:[allCharViews objectAtIndex:row * NNUM + col + i]];
            }
            return matchedView;
        }
    }
    //left
    if (col + 1 >= targetStr.length)
    {
        bool match = true;
        for (int i = 1; i < targetStr.length; i++)
        {
            if ([targetStr characterAtIndex:i] != board[row][col - i])
            {
                match = false;
                break;
            }
        }
        //
        if (match)
        {
            for (int i = 0; i < targetStr.length; i++)
            {
                [matchedView addObject:[allCharViews objectAtIndex:row * NNUM + col - i]];
            }
            return matchedView;
        }
    }
    //down
    if (row + targetStr.length <= NNUM)
    {
        bool match = true;
        for (int i = 1; i < targetStr.length; i++)
        {
            if ([targetStr characterAtIndex:i] != board[row+i][col])
            {
                match = false;
                break;
            }
        }
        //
        if (match)
        {
            for (int i = 0; i < targetStr.length; i++)
            {
                [matchedView addObject:[allCharViews objectAtIndex:(row+i) * NNUM + col]];
            }
            return matchedView;
        }
    }
    //up
    if (row + 1 >= targetStr.length)
    {
        bool match = true;
        for (int i = 1; i < targetStr.length; i++)
        {
            if ([targetStr characterAtIndex:i] != board[row - i][col])
            {
                match = false;
                break;
            }
        }
        //
        if (match)
        {
            for (int i = 0; i < targetStr.length; i++)
            {
                [matchedView addObject:[allCharViews objectAtIndex:(row - i) * NNUM + col]];
            }
            return matchedView;
        }
    }
    //upright
    if (col + targetStr.length <= NNUM && row + 1 >= targetStr.length)
    {
        bool match = true;
        for (int i = 1; i < targetStr.length; i++)
        {
            if ([targetStr characterAtIndex:i] != board[row-i][col + i])
            {
                match = false;
                break;
            }
        }
        //
        if (match)
        {
            for (int i = 0; i < targetStr.length; i++)
            {
                [matchedView addObject:[allCharViews objectAtIndex:(row-i) * NNUM + col + i]];
            }
            return matchedView;
        }
    }
    //downright
    if (col + targetStr.length <= NNUM && row + targetStr.length <= NNUM)
    {
        bool match = true;
        for (int i = 1; i < targetStr.length; i++)
        {
            if ([targetStr characterAtIndex:i] != board[row + i][col + i])
            {
                match = false;
                break;
            }
        }
        //
        if (match)
        {
            for (int i = 0; i < targetStr.length; i++)
            {
                [matchedView addObject:[allCharViews objectAtIndex:(row + i) * NNUM + col + i]];
            }
            return matchedView;
        }
    }
    //upleft
    if (col + 1 >= targetStr.length && row + 1 >= targetStr.length)
    {
        bool match = true;
        for (int i = 1; i < targetStr.length; i++)
        {
            if ([targetStr characterAtIndex:i] != board[row - i][col - i])
            {
                match = false;
                break;
            }
        }
        //
        if (match)
        {
            for (int i = 0; i < targetStr.length; i++)
            {
                [matchedView addObject:[allCharViews objectAtIndex:(row - i) * NNUM + col - i]];
            }
            return matchedView;
        }
    }
    //downleft
    if (col + 1 >= targetStr.length && row + targetStr.length <= NNUM)
    {
        bool match = true;
        for (int i = 1; i < targetStr.length; i++)
        {
            if ([targetStr characterAtIndex:i] != board[row + i][col - i])
            {
                match = false;
                break;
            }
        }
        //
        if (match)
        {
            for (int i = 0; i < targetStr.length; i++)
            {
                [matchedView addObject:[allCharViews objectAtIndex:(row + i) * NNUM + col - i]];
            }
            return matchedView;
        }
    }
    //
    return matchedView;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 视图布局完成后
    if (!show_banner) {
        [AdmobViewController shareAdmobVC].delegate=self;
        [[AdmobViewController shareAdmobVC] show_admob_banner_smart:0.0 posy:0.0 view:self.adView];
        show_banner=YES;
    }
}
@end
