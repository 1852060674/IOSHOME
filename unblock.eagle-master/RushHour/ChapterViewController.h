//
//  ChapterViewController.h
//  Flow
//
//  Created by yysdsyl on 13-10-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChapterViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *adView;
- (IBAction)back:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *viewControllers;

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;

- (void)locatePageNo:(int)page ani:(BOOL)ani;
@property (weak, nonatomic) IBOutlet UILabel *levelName;

@end
