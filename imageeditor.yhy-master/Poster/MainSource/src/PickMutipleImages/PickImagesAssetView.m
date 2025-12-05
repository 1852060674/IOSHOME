//
//  PickImagesAssetView.m
//  PuzzleImages
//
//  Created by 吕 广燊￼ on 13-5-18.
//  Copyright (c) 2013年 com.gs. All rights reserved.
//

#import "PickImagesAssetView.h"
#import "ZBSelectedThumbnailView.h"
#import "PickImagesAssetCell.h"
#import "ZBCommonMethod.h"
#import "DoPhotoCell.h"
#import "AssetHelper.h"

@interface PickImagesAssetView()<UITableViewDataSource, UITableViewDelegate,PickImagesAssetCellDelegate,ZBSelectedThumbnailViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    UILabel *_remindLabel;
    NSUInteger _imageIndex;
    float _imageViewOriginY;
    float _imageViewGap;
}

@property (nonatomic,retain)UITableView *assetTableView;

@property (nonatomic,strong) UICollectionView *assetCollectionView;

@property (nonatomic, assign) CGSize imageSize;

@property (nonatomic, assign) BOOL showsCancelButton;
@property (nonatomic, assign) BOOL showsHeaderButton;
@property (nonatomic, assign) BOOL showsFooterDescription;
@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, strong) NSMutableArray *assetArray;


- (void)getAssetsFromAssetsGroup;
@end

@implementation PickImagesAssetView

@synthesize assetTableView = _assetTableView;
@synthesize assetsGroup = _assetsGroup;
@synthesize filterType = _filterType;
@synthesize showsCancelButton= _showsCancelButton;
@synthesize showsHeaderButton = _showsHeaderButton;
@synthesize showsFooterDescription = _showsFooterDescription;
@synthesize assets = _assets;
@synthesize selectedAssets = _selectedAssets;
@synthesize bottomScrollView;
@synthesize assetArray = _assetArray;

- (id)initWithAssetsGroup:(ALAssetsGroup*)assetsGroup frame:(CGRect)rect;
{
    self = [super initWithFrame:rect];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        _imageIndex = 0 ;
        
        float _adHeight = 0;
        if (IS_IPAD)
        {
            _imageViewOriginY = 15;
            _imageViewGap = 20;
            _adHeight = kAdHeiht + 10;
        }
        else
        {
            _imageViewOriginY = 10;
            _imageViewGap = 5;
        }
        
        
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kNavigationBarHeight - kAssetRemindTextHeight - (kAssetScrollViewHeight) - _adHeight) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = NO;
//        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:tableView];
        self.assetTableView = tableView;
        
        self.assetsGroup = assetsGroup;
        self.assets = [[NSMutableArray alloc] initWithCapacity:3];
        
        [self getAssetsFromAssetsGroup];
        
        _selectedAssets = [[NSMutableArray alloc]initWithCapacity:2];
        
        _remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, kScreenHeight - kAssetRemindTextHeight - (kAssetScrollViewHeight) - _adHeight - kNavigationBarHeight, kScreenWidth, kAssetRemindTextHeight)];
        _remindLabel.text = @"You have selected 0 photo.";
        _remindLabel.font = [UIFont systemFontOfSize:kAssetRemindFontSize];
        _remindLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_remindLabel];
        
        self.bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kScreenHeight - (kAssetScrollViewHeight) -_adHeight - kNavigationBarHeight, kScreenWidth, kAssetScrollViewHeight)];
        self.bottomScrollView.delegate = self;
        self.bottomScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bottomScrollView];
#if 1
        if(@available(iOS 11, *)) {
            tableView.frame = CGRectMake(0, 0, kScreenWidth, self.frame.size.height-kAssetRemindTextHeight-kAssetScrollViewHeight);
            _remindLabel.frame = CGRectMake(10, self.frame.size.height-kAssetScrollViewHeight-kAssetRemindTextHeight, kScreenWidth, kAssetRemindTextHeight);
            self.bottomScrollView.frame = CGRectMake(0, self.frame.size.height-kAssetScrollViewHeight, kScreenWidth, kAssetScrollViewHeight);
        } else if (kSystemVersion < 7.0) {
            _remindLabel.frame = CGRectMake(10, kScreenHeight - kAssetRemindTextHeight - (kAssetScrollViewHeight) - _adHeight - 2*kNavigationBarHeight, kScreenWidth, kAssetRemindTextHeight);
            self.bottomScrollView.frame = CGRectMake(0, kScreenHeight - (kAssetScrollViewHeight) -_adHeight - 2*kNavigationBarHeight, kScreenWidth, kAssetScrollViewHeight);
        }
#endif
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        _imageIndex = 0 ;
        
        float _adHeight = 0;
        if (IS_IPAD)
        {
            _imageViewOriginY = 15;
            _imageViewGap = 20;
            _adHeight = kAdHeiht + 10;
        }
        else
        {
            _imageViewOriginY = 10;
            _imageViewGap = 5;
        }
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        const NSInteger colNum = 4;
        const NSInteger cellMargin = 5;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat cellSize = (screenWidth-(colNum+1)*cellMargin)/colNum;
        layout.itemSize = CGSizeMake(cellSize, cellSize);
        layout.minimumInteritemSpacing = cellMargin;
        layout.minimumLineSpacing = cellMargin;
        layout.sectionInset = UIEdgeInsetsMake(cellMargin, cellMargin, cellMargin, cellMargin);
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kNavigationBarHeight - kAssetRemindTextHeight - (kAssetScrollViewHeight) - _adHeight) collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        UINib *nib = [UINib nibWithNibName:@"DoPhotoCell" bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:@"DoPhotoCell"];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [self addSubview:collectionView];
        self.assetCollectionView = collectionView;
    
//        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kNavigationBarHeight - kAssetRemindTextHeight - (kAssetScrollViewHeight) - _adHeight) style:UITableViewStylePlain];
//        tableView.dataSource = self;
//        tableView.delegate = self;
//        tableView.separatorStyle = NO;
//        //        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        [self addSubview:tableView];
//        self.assetTableView = tableView;
        
        _selectedAssets = [[NSMutableArray alloc]initWithCapacity:2];
        
        _remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, kScreenHeight - kAssetRemindTextHeight - (kAssetScrollViewHeight) - _adHeight - kNavigationBarHeight, kScreenWidth, kAssetRemindTextHeight)];
        _remindLabel.text = @"You have selected 0 photo.";
        _remindLabel.font = [UIFont systemFontOfSize:kAssetRemindFontSize];
        _remindLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_remindLabel];
        
        self.bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kScreenHeight - (kAssetScrollViewHeight) -_adHeight - kNavigationBarHeight, kScreenWidth, kAssetScrollViewHeight)];
        self.bottomScrollView.delegate = self;
        self.bottomScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bottomScrollView];
#if 1
        if(@available(iOS 11, *)) {
            collectionView.frame = CGRectMake(0, 0, kScreenWidth, self.frame.size.height-kAssetRemindTextHeight-kAssetScrollViewHeight);
            _remindLabel.frame = CGRectMake(10, self.frame.size.height-kAssetScrollViewHeight-kAssetRemindTextHeight, kScreenWidth, kAssetRemindTextHeight);
            self.bottomScrollView.frame = CGRectMake(0, self.frame.size.height-kAssetScrollViewHeight, kScreenWidth, kAssetScrollViewHeight);
        } else if (kSystemVersion < 7.0) {
            _remindLabel.frame = CGRectMake(10, kScreenHeight - kAssetRemindTextHeight - (kAssetScrollViewHeight) - _adHeight - 2*kNavigationBarHeight, kScreenWidth, kAssetRemindTextHeight);
            self.bottomScrollView.frame = CGRectMake(0, kScreenHeight - (kAssetScrollViewHeight) -_adHeight - 2*kNavigationBarHeight, kScreenWidth, kAssetScrollViewHeight);
        }
#endif
    }
    return self;
}

- (void)dealloc
{
//    [super dealloc];
}

- (void)addImageOnScrollView:(ALAsset*)asset
{
//    if (_imageIndex>7) {
//        return;
//    }
    ZBSelectedThumbnailView *_thumbnailView = [[ZBSelectedThumbnailView alloc] initWithFrame:CGRectMake(_imageViewGap + (_imageViewGap + kAssetEdgeLength)*_imageIndex, _imageViewOriginY, kAssetEdgeLength, kAssetEdgeLength)];
    _thumbnailView.imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
    _thumbnailView.tag = kAddImageViewStartTag + _imageIndex;
    _thumbnailView.delegate = self;
    _thumbnailView.asset = asset;
    [self.bottomScrollView addSubview:_thumbnailView];
    _imageIndex++;
    if (_imageIndex>1) {
        _remindLabel.text = [NSString stringWithFormat:@"You have selected %d photos.",_imageIndex];
    }
    else
    {
        _remindLabel.text = [NSString stringWithFormat:@"You have selected %d photo.",_imageIndex];
    }
    
    self.bottomScrollView.contentSize = CGSizeMake(_imageViewGap + (_imageViewGap + kAssetEdgeLength)*_imageIndex, self.bottomScrollView.frame.size.height);
    if (_imageViewGap + (_imageViewGap + kAssetEdgeLength)*_imageIndex>kScreenWidth) {
        self.bottomScrollView.contentOffset = CGPointMake(_imageViewGap + (_imageViewGap + kAssetEdgeLength)*_imageIndex - kScreenWidth, 0);
    }
    
    
}

- (void)addImageOnScrollViewWithIdentifier:(NSString*)identifier
{
    //    if (_imageIndex>7) {
    //        return;
    //    }
    ZBSelectedThumbnailView *_thumbnailView = [[ZBSelectedThumbnailView alloc] initWithFrame:CGRectMake(_imageViewGap + (_imageViewGap + kAssetEdgeLength)*_imageIndex, _imageViewOriginY, kAssetEdgeLength, kAssetEdgeLength)];
    
    [ASSETHELPER getImageForAssetIdentifier:identifier targetSize:CGSizeMake(200, 200) type:ASSET_PHOTO_THUMBNAIL withStartHandler:^(NSString *identifier) {
        _thumbnailView.assetIdentifier = identifier;
    } withCompletionHandler:^(NSString *identifier, UIImage *image) {
        if ([_thumbnailView.assetIdentifier isEqualToString:identifier]) {
            _thumbnailView.imageView.image = image;
        }
    }];
    
    _thumbnailView.tag = kAddImageViewStartTag + _imageIndex;
    _thumbnailView.delegate = self;
    _thumbnailView.assetIdentifier = identifier;
    [self.bottomScrollView addSubview:_thumbnailView];
    _imageIndex++;
    if (_imageIndex>1) {
        _remindLabel.text = [NSString stringWithFormat:@"You have selected %d photos.",_imageIndex];
    }
    else
    {
        _remindLabel.text = [NSString stringWithFormat:@"You have selected %d photo.",_imageIndex];
    }
    
    self.bottomScrollView.contentSize = CGSizeMake(_imageViewGap + (_imageViewGap + kAssetEdgeLength)*_imageIndex, self.bottomScrollView.frame.size.height);
    if (_imageViewGap + (_imageViewGap + kAssetEdgeLength)*_imageIndex>kScreenWidth) {
        self.bottomScrollView.contentOffset = CGPointMake(_imageViewGap + (_imageViewGap + kAssetEdgeLength)*_imageIndex - kScreenWidth, 0);
    }
    
    
}
- (void)addSelectedAssetsOnScrollview
{
    NSArray *_userSelectedAssets = [ZBCommonMethod getUserSelectedAssets];
    if (_userSelectedAssets != nil && _userSelectedAssets.count>0) {
        for (NSUInteger i=0; i<_userSelectedAssets.count; i++) {
//            [self addImageOnScrollView:[_userSelectedAssets objectAtIndex:i]];
            [self addImageOnScrollViewWithIdentifier:[_userSelectedAssets objectAtIndex:i]];
            [self.selectedAssets addObject:[_userSelectedAssets objectAtIndex:i]];
        }
    }
    
}

#pragma mark -- custom method
- (void)getAssetsFromAssetsGroup
{
    // Reload assets
    [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result) {
            [self.assets addObject:result];
        }
    }];
    [self.assetTableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = 0;
    numberOfRowsInSection = self.assets.count / kCountOfImagesPerLine;
    if((self.assets.count - numberOfRowsInSection * kCountOfImagesPerLine) > 0) numberOfRowsInSection++;
    return numberOfRowsInSection;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"AssetCell";
    PickImagesAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {        
        cell = [[PickImagesAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.delegate = self;
    NSInteger offset = kCountOfImagesPerLine * indexPath.row;
    NSInteger numberOfAssetsToSet = (offset + kCountOfImagesPerLine > self.assets.count) ? (self.assets.count - offset) : kCountOfImagesPerLine;
    
    NSMutableArray *assets = [NSMutableArray array];
    for(NSUInteger i = 0; i < numberOfAssetsToSet; i++) {
        ALAsset *asset = [self.assets objectAtIndex:(offset + i)];
        
        [assets addObject:asset];
    }
    cell.assets = assets;

    [cell refreshCellView];

    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kAssetEdgeLength+4;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -- PickImagesAssetCellDelegate
- (void)handleAnAssetSeletedType:(ALAsset *)asset withSelectedType:(BOOL)isSeleted
{
    if (self.selectedAssets.count >= 7)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WARN_WORD", @"") message:NSLocalizedString(@"EXCEED_PHOTO_MAXNUM_LIMIT", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL_WORD", @"") otherButtonTitles:nil];
        [alertView show];
        return;
    }
//    if (isSeleted) {
//        [_selectedAssets addObject:asset];
//    }
//    else
//        [_selectedAssets removeObject:asset];
    [self.selectedAssets addObject:asset];
    [self addImageOnScrollView:asset];
}

#pragma mark -- ZBSelectedThumbnailViewDelegate

- (void)deleteImageViewFromSuperView:(id)sender
{
    [UIView animateWithDuration:0.6 animations:^
     {
         ZBSelectedThumbnailView *_thumbnailView = (ZBSelectedThumbnailView*)sender;
         NSUInteger _index = _thumbnailView.tag - kAddImageViewStartTag;
         CGRect _newframe = _thumbnailView.frame;
         
         
         for (NSUInteger i=_index+1; i<_imageIndex; i++)
         {
             ZBSelectedThumbnailView *_aView = (ZBSelectedThumbnailView*)[self.bottomScrollView viewWithTag:kAddImageViewStartTag+i];
             _aView.tag--;
             CGRect _nextFrame = _aView.frame;
             _aView.frame = _newframe;
             _newframe = _nextFrame;
         }
         
         [_thumbnailView removeFromSuperview];
         [self.selectedAssets removeObjectAtIndex:_index];
         _imageIndex--;
         if (_imageIndex>1) {
             _remindLabel.text = [NSString stringWithFormat:@"You have selected %d photos.",_imageIndex];
         }
         else
         {
             _remindLabel.text = [NSString stringWithFormat:@"You have selected %d photo.",_imageIndex];
         }
         
         self.bottomScrollView.contentSize = CGSizeMake(_imageViewGap + (_imageViewGap + kAssetEdgeLength)*_imageIndex, self.bottomScrollView.frame.size.height);
         
     } completion:^(BOOL finished)
     {
         
     }];
}

#pragma mark - UICollectionViewDatasource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [ASSETHELPER getPhotoCountOfCurrentGroup];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DoPhotoCell *cell = (DoPhotoCell *)[_assetCollectionView dequeueReusableCellWithReuseIdentifier:@"DoPhotoCell" forIndexPath:indexPath];
    
    if (indexPath.row < [collectionView numberOfItemsInSection:indexPath.section]) {
        //        cell.ivPhoto.image = [ASSETHELPER getImageAtIndex:indexPath.row type:ASSET_PHOTO_THUMBNAIL];
        
        [ASSETHELPER getImageAtIndex:indexPath.row targetSize:cell.bounds.size type:ASSET_PHOTO_THUMBNAIL withStartHandler:^(NSString *identifier) {
            cell.identifier = identifier;
        } withCompletionHandler:^(NSString *identifier, UIImage *image) {
            if ([cell.identifier isEqualToString:identifier]) {
                cell.ivPhoto.image = image;
            }
        }];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedAssets.count >= 7)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WARN_WORD", @"") message:NSLocalizedString(@"EXCEED_PHOTO_MAXNUM_LIMIT", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL_WORD", @"") otherButtonTitles:nil];
        [alertView show];
        return;
    }

    NSString *string = [ASSETHELPER getAssetIdentifierAtIndex:indexPath.row];
    [self.selectedAssets addObject:string];
    
    //    [self.selectedAssets addObject:asset];
    [self addImageOnScrollViewWithIdentifier:string];
}

@end
