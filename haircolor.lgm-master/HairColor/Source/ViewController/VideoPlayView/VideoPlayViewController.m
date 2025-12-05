//
//  VideoPlayViewController.m
//  CutMeIn
//
//  Created by ZB_Mac on 16/8/8.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "VideoPlayViewController.h"
#import "PagesView.h"
#import "Masonry.h"
@interface VideoPlayViewController ()
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *mainArea;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) PagesView *pagesView;
@end

@implementation VideoPlayViewController
- (IBAction)onClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onPageChanged:(id)sender {
    [self.pagesView selectPage:_pageControl.currentPage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSArray *pages = @[
                       [[PageContent alloc] initWithCoverImage:@"help_cut_hair.jpg" VideoURL:nil andIconImage:@"btn_smart_scissor_h"  andTitle:NSLocalizedString(@"HELP_CUT_HAIR_TITLE", @"") andContentText:NSLocalizedString(@"HELP_CUT_HAIR_MSG", @"")],
                       [[PageContent alloc] initWithCoverImage:@"help_auto_hair.jpg" VideoURL:nil andIconImage:nil andTitle:NSLocalizedString(@"HELP_AUTO_HAIR_TITLE", @"") andContentText:NSLocalizedString(@"HELP_AUTO_HAIR_MSG", @"")],
//                       [[PageContent alloc] initWithCoverImage:@"help_manual_hair.jpg" VideoURL:nil andIconImage:@"btn_mannual" andTitle:NSLocalizedString(@"HELP_MANUAL_HAIR_TITLE", @"") andContentText:NSLocalizedString(@"HELP_MANUAL_HAIR_MSG", @"")],
//                       [[PageContent alloc] initWithCoverImage:@"help_longpress_delete.jpg" VideoURL:nil andIconImage:nil andTitle:NSLocalizedString(@"HELP_LP_DELETE_TITLE", @"") andContentText:NSLocalizedString(@"HELP_LP_DELETE_MSG", @"")],
                       ];
    [self.closeBtn setTitle:NSLocalizedString(@"HELP_CLOSE", @"") forState:UIControlStateNormal];
    self.titleLabel.text = NSLocalizedString(@"HELP_TITLE", @"");
    
    PagesView *pageCollectionView = [[PagesView alloc] initWithFrame:self.view.bounds andPages:pages];
    [self.view addSubview:pageCollectionView];
    
    [pageCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.mainArea);
    }];
    
    __weak VideoPlayViewController *wSelf = self;
    [pageCollectionView setActions:^(NSInteger index) {
        [wSelf.pageControl setCurrentPage:index];
    }];
    self.pagesView = pageCollectionView;
    
    self.pageControl.numberOfPages = pages.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.pagesView selectPage:_defaultPageIndex];
    self.pageControl.currentPage = _defaultPageIndex;
}

-(void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
