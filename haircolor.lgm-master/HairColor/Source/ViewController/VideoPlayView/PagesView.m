//
//  PageCollectionView.m
//  CutMeIn
//
//  Created by ZB_Mac on 16/8/8.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "PagesView.h"
#import "VideoPlayCell.h"
#import "PlayerView.h"
#import "Masonry.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CGRectCGPointUtility.h"

@implementation PageContent
//-(PageContent *)initWithVideoURL:(NSURL *)url andTitle:(NSString *)title andContentText:(NSString *)contentText;
-(PageContent *)initWithCoverImage:(NSString *)coverImage VideoURL:(NSURL *)url andIconImage:(NSString *)iconImage andTitle:(NSString *)title andContentText:(NSString *)contentText;
{
    self = [super init];
    
    if (self) {
        self.coverImage = coverImage;
        self.videoURL = url;
        self.title = title;
        self.contentText = contentText;
        self.iconImage = iconImage;
    }
    
    return self;
}
@end

@interface PagesView ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) AVPlayer *pagePlayer;
@property (nonatomic, weak) VideoPlayCell *currentPageCell;
@property (nonatomic, strong) NSIndexPath *currentPageIndex;

@end

@implementation PagesView

-(instancetype)initWithFrame:(CGRect)frame andPages:(NSArray *)pages
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsZero;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//        layout.itemSize = frame.size;
        _layout = layout;
        self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];

        [self.collectionView registerNib:[UINib nibWithNibName:@"VideoPlayCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"cell"];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.contentInset = UIEdgeInsetsZero;
        self.collectionView.pagingEnabled = YES;
        [self addSubview:self.collectionView];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self);
        }];
        
        _pages = pages;
    }
    
    return self;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.pages.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VideoPlayCell *cell = (VideoPlayCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    PageContent *pageContent = self.pages[indexPath.row];
    
    cell.titleLabel.text = pageContent.title;
    cell.textLabel.text = pageContent.contentText;
    cell.iconView.image = [UIImage imageNamed:pageContent.iconImage];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:pageContent.coverImage ofType:nil]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([cell.titleLabel.text isEqualToString:pageContent.title]) {
                cell.coverView.image = image;
            }
        });
    });
    
    return cell;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self updatePage];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updatePage];
}

-(void)updatePage
{
    NSArray * visibleCells = [_collectionView visibleCells];
    
    CGPoint offset = _collectionView.contentOffset;
    
    VideoPlayCell *currentPageCell;
    CGFloat minDistance = MAXFLOAT;
    for (VideoPlayCell *cell in visibleCells) {
        CGFloat distance = [CGRectCGPointUtility distanceBetweenPoint:cell.frame.origin andPoint:offset];
        if (distance < minDistance) {
            minDistance = distance;
            currentPageCell = cell;
        }
    }
    
    NSIndexPath *indexPath = [_collectionView indexPathForCell:currentPageCell];
    
    if ([self.currentPageIndex isEqual:indexPath]) {
        return;
    }
    
    self.currentPageCell = currentPageCell;
    self.currentPageIndex = indexPath;
    
    [self.currentPageCell.playerView setPlayer:nil];

    PageContent *pageContent = self.pages[indexPath.row];
    NSURL *videoUrl = pageContent.videoURL;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
        self.pagePlayer = player;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([currentPageCell.titleLabel.text isEqualToString:pageContent.title]) {
                [currentPageCell.playerView setPlayer:player];
                
                [player play];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
                if (self.actions) {
                    self.actions(indexPath.row);
                }
            }
        });
    });
}

-(void)selectPage:(NSInteger)index
{
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updatePage];
    });
}

-(void)moviePlayDidEnd:(NSNotification *)notification
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.pagePlayer seekToTime:kCMTimeZero];
        [self.pagePlayer play];
    });
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _layout.itemSize = self.collectionView.bounds.size;
    [_layout invalidateLayout];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    NSLog(@"%s", __FUNCTION__);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
