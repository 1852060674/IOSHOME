//
//  ChapterViewController.m
//  Flow
//
//  Created by yysdsyl on 13-10-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ChapterViewController.h"
#import "StagesViewController.h"
#import "PlayViewController.h"
#import "Config.h"
#import "Common.h"
#import "LevelView.h"
#import "GameData.h"
#import "Admob.h"
#import "ProtocolAlerView.h"
#import <SafariServices/SafariServices.h>
#include "ApplovinMaxWrapper.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
static NSUInteger kNumberOfPages = 6;

static PlayViewController* g_pvc = nil;

@interface ChapterViewController ()
{
    NSMutableArray *viewControllers;
    BOOL pageControlUsed;
    GameData* gameData;
    BOOL firstFlag;
    BOOL ios7;
    __weak IBOutlet UIView *admobHeightIpd;
    __weak IBOutlet NSLayoutConstraint *admobHeight;
}

@end

@implementation ChapterViewController

@synthesize viewControllers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
    
    // replace the placeholder if necessary
    StagesViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            controller = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"StagesViewController"];
        }
        else
            controller = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"StagesViewController"];
        controller.seq = page;
        [viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.scrollView.frame;
        controller.view.center = CGPointMake(frame.size.width*page + frame.size.width/2 - 0/*- (frame.size.width-controller.mainView.frame.size.width)/2*/, frame.size.height/2);
        [self.scrollView addSubview:controller.view];
    }
    else
    {
        CGRect frame = self.scrollView.frame;
        controller.view.center = CGPointMake(frame.size.width*page + frame.size.width/2 - 0/*- (frame.size.width-controller.mainView.frame.size.width)/2*/, frame.size.height/2);
    }
    ///
    return;
}

- (void)levelselected:(NSNotification*)notifacation
{
    LevelView* lv = notifacation.object;
    gameData.no = lv.no - 1;
    [gameData.packCurrent replaceObjectAtIndex:gameData.row withObject:[NSNumber numberWithInt:gameData.no]];
    [self performSegueWithIdentifier:@"playSegue" sender:self];
    [TheSound playTapSound];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page + 1];
    if (page - 1 >= 0) {
        StagesViewController *controller = [viewControllers objectAtIndex:page-1];
        [self.scrollView bringSubviewToFront:controller.view];
    }
    if (page + 1 < kNumberOfPages) {
        StagesViewController *controller = [viewControllers objectAtIndex:page+1];
        [self.scrollView bringSubviewToFront:controller.view];
    }
    
    StagesViewController *controller = [viewControllers objectAtIndex:page];
    [self.scrollView bringSubviewToFront:controller.view];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /// admob
    //[Common addAds:self.adView rootVc:self];
    firstFlag = YES;
    ios7 = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0);
    ///
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"leveltap" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelselected:) name:@"leveltap" object:nil];
    ////
    //[self.bgImage.layer insertSublayer:[Common emitter] atIndex:0];
	// Do any additional setup after loading the view.
    gameData = [GameData sharedGD];
    kNumberOfPages = [[gameData.packPuzzles objectAtIndex:gameData.row] count]/(CELL_NUM*CELL_NUM);
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    // a page is the width of the scroll view
    self.scrollView.pagingEnabled = YES;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * kNumberOfPages, self.scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.pageControl.numberOfPages = kNumberOfPages;
    self.pageControl.currentPage = 0;
    //
    for (int i = 0; i < kNumberOfPages; i++) {
        [self loadScrollViewWithPage:i];    }
    //
    int locpage = [[gameData.packCurrent objectAtIndex:gameData.row] integerValue]/(CELL_NUM*CELL_NUM);
    if (ios7) {
        [self locatePageNo:locpage ani:YES];
    }
    ///
    self.levelName.text = gameData.levelName;
    self.levelName.textColor = [UIColor whiteColor];//[Common colors:gameData.row];
    [self admobHeightUpdate];
    ///
}

- (void)viewWillAppear:(BOOL)animated
{
    [[AdmobViewController shareAdmobVC] show_admob_banner_smart:0.0 posy:0.0 view:self.adView];
    for (StagesViewController* svc in self.viewControllers) {
        if (svc != nil) {
            [svc updateStates];
            if (firstFlag && !ios7) {
                svc.view.alpha = 0;
            }
        }
    }
    
    [[AdmobViewController shareAdmobVC] ifNeedShowNext:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (firstFlag && !ios7) {
        int locpage = [[gameData.packCurrent objectAtIndex:gameData.row] integerValue]/(CELL_NUM*CELL_NUM);
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentSize.width, 0) animated:NO];
        [self locatePageNo:locpage ani:YES];
        [UIView animateWithDuration:0.1 animations:^{
            for (StagesViewController* svc in self.viewControllers) {
                if (svc != nil) {
                    svc.view.alpha = 1;
                }
            }
        } completion:^(BOOL finished) {
            firstFlag = NO;
        }];
    }
}

- (void)locatePageNo:(int)page ani:(BOOL)ani
{
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page + 1];
    if (page - 1 >= 0) {
        StagesViewController *controller = [viewControllers objectAtIndex:page-1];
        [self.scrollView bringSubviewToFront:controller.view];
    }
    if (page + 1 < kNumberOfPages) {
        StagesViewController *controller = [viewControllers objectAtIndex:page+1];
        [self.scrollView bringSubviewToFront:controller.view];
    }
    
    StagesViewController *controller = [viewControllers objectAtIndex:page];
    [self.scrollView bringSubviewToFront:controller.view];
    
	// update the scroll view to the appropriate page
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:ani];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"leveltap" object:nil];
    [self.navigationController popViewControllerAnimated:NO];
    [TheSound playTapSound];
}
- (void) admobHeightUpdate {
    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];
    CGFloat admobHeight1 = [applovinWrapper getAdmobHeight];
    admobHeight.constant=admobHeight1;
}
@end
