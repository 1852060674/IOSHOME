//
//  AutoDyeBottomView.m
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/2.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "TwoLevelView.h"
#import "Masonry.h"
#import "TwoLevelViewDetailCell.h"
#import "TwoLevelViewHeaderCell.h"
#import "TwoLevelViewLayout.h"
#import "TwoLevelCollectionReusableView.h"

@implementation TwoLevelViewHeaderCellAttributes
@end

@implementation TwoLevelViewDetailCellAttributes
@end

@interface TwoLevelView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) TwoLevelViewLayout *layout;
@property (nonatomic, readwrite) NSInteger selectedGroup;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@end

@implementation TwoLevelView

-(TwoLevelView *)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _layout = [[TwoLevelViewLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.itemSize = CGSizeMake(CGRectGetHeight(_collectionView.bounds), CGRectGetHeight(_collectionView.bounds));
        _layout.minimumLineSpacing = 4;
        _layout.minimumInteritemSpacing = 4;
        _layout.footerReferenceSize = CGSizeMake(2, CGRectGetHeight(_collectionView.bounds)-12);
        
        [_collectionView registerClass:[TwoLevelViewHeaderCell class] forCellWithReuseIdentifier:@"TwoLevelViewHeaderCell"];
        [_collectionView registerClass:[TwoLevelViewDetailCell class] forCellWithReuseIdentifier:@"TwoLevelViewDetailCell"];
//        [_collectionView registerClass:[TwoLevelCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"tail"];
        
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [self addSubview:_collectionView];

        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.top.equalTo(self);
        }];
        _collectionView.clipsToBounds = NO;
        _selectedGroup = -1;
    }
    
    return self;
}

-(void)setCellAttributess:(NSArray *)cellAttributess
{
    _cellAttributess = cellAttributess;
    [self.collectionView reloadData];
}

-(void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    if (row == 0) {
        TwoLevelViewHeaderCell *toDeleteHeaderCell;
        TwoLevelViewHeaderCell *toInsertHeaderCell = (TwoLevelViewHeaderCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        
        NSMutableArray *toDeletes = [NSMutableArray array];
        
        if (_selectedGroup >= 0) {
            toDeleteHeaderCell = (TwoLevelViewHeaderCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_selectedGroup]];

            TwoLevelViewHeaderCellAttributes *headerCellAttribute = self.cellAttributess[_selectedGroup];
            NSArray *detailCellAttributes = headerCellAttribute.detailCellAttributes;
            
            for (NSInteger idx=1; idx<=detailCellAttributes.count; ++idx) {
                [toDeletes addObject:[NSIndexPath indexPathForRow:idx inSection:_selectedGroup]];
            }
        }
        
        TwoLevelViewHeaderCellAttributes *headerCellAttribute = self.cellAttributess[section];
        NSArray *detailCellAttributes = headerCellAttribute.detailCellAttributes;
        NSMutableArray *toInserts = [NSMutableArray array];
        for (NSInteger idx=1; idx<=detailCellAttributes.count; ++idx) {
            [toInserts addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
        }
        
        if (section == _selectedGroup) {
            toDeleteHeaderCell.backgroundView = nil;

            [self.layout prepareForDeleteInSection:section andInsertInSection:-1];
            _selectedGroup = -1;
            
            [_collectionView performBatchUpdates:^{
                [_collectionView deleteItemsAtIndexPaths:toDeletes];
            } completion:^(BOOL finished) {
            }];
        }
        else
        {
            [self.layout prepareForDeleteInSection:_selectedGroup andInsertInSection:section];
            _selectedGroup = section;
            
            [_collectionView performBatchUpdates:^{
                [_collectionView deleteItemsAtIndexPaths:toDeletes];
                [_collectionView insertItemsAtIndexPaths:toInserts];
            } completion:^(BOOL finished) {
            }];
            
            toDeleteHeaderCell.backgroundView = nil;
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"level_1_haircolor_bg"]];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            toInsertHeaderCell.backgroundView = imageView;
        }
        _selectedIndexPath = indexPath;
    }
    else
    {
        NSMutableArray *toDeletes = [NSMutableArray array];
        
        if (_selectedGroup >= 0) {
            TwoLevelViewHeaderCellAttributes *headerCellAttribute = self.cellAttributess[_selectedGroup];
            NSArray *detailCellAttributes = headerCellAttribute.detailCellAttributes;
            
            for (NSInteger idx=1; idx<=detailCellAttributes.count; ++idx) {
                [toDeletes addObject:[NSIndexPath indexPathForRow:idx inSection:_selectedGroup]];
            }
        }
        
        TwoLevelViewHeaderCellAttributes *headerCellAttribute = self.cellAttributess[section];
        NSArray *detailCellAttributes = headerCellAttribute.detailCellAttributes;
        NSMutableArray *toInserts = [NSMutableArray array];
        for (NSInteger idx=1; idx<=detailCellAttributes.count; ++idx) {
            [toInserts addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
        }
        
        if (section == _selectedGroup) {
            [_collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        }
        else
        {
            [self.layout prepareForDeleteInSection:_selectedGroup andInsertInSection:section];
            _selectedGroup = section;
            
            [_collectionView performBatchUpdates:^{
                [_collectionView deleteItemsAtIndexPaths:toDeletes];
                [_collectionView insertItemsAtIndexPaths:toInserts];
            } completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
                });
            }];
        }
        
        _selectedIndexPath = indexPath;
    }
}

-(void)insertCellAtIndexPath:(NSIndexPath *)indexPath;
{
    [_collectionView insertItemsAtIndexPaths:@[indexPath]];
}
#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.cellAttributess.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    TwoLevelViewHeaderCellAttributes *headerCellAttribute = self.cellAttributess[section];
    NSArray *detailCellAttributes = headerCellAttribute.detailCellAttributes;
    return section==_selectedGroup?detailCellAttributes.count+1:1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    TwoLevelViewHeaderCellAttributes *headerCellAttribute = self.cellAttributess[indexPath.section];

    if (indexPath.row == 0) {
        TwoLevelViewHeaderCell *headerCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TwoLevelViewHeaderCell" forIndexPath:indexPath];

        if (!headerCellAttribute.loadIconFromPath) {
            headerCell.imageView.image = headerCellAttribute.icon;
        }
        else
        {
            if (!headerCellAttribute.delayLoadIcon) {
                UIImage *image = [UIImage imageWithContentsOfFile:headerCellAttribute.iconPath];
                headerCell.imageView.image = image;
            }
            else
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    UIImage *image = [UIImage imageWithContentsOfFile:headerCellAttribute.iconPath];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([headerCell.identifier isEqualToString:headerCellAttribute.iconPath]) {
                            headerCell.imageView.image = image;
                        }
                    });
                });
            }
        }
        
        if (_selectedGroup == indexPath.section) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"level_1_haircolor_bg"]];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            headerCell.backgroundView = imageView;
        }
        else
        {
            headerCell.backgroundView = nil;
        }
        
        headerCell.sepView.hidden = (indexPath.section==0);
        
        cell = headerCell;
    }
    else
    {
        NSArray *detailCellAttributes = headerCellAttribute.detailCellAttributes;
        TwoLevelViewDetailCellAttributes *detailCellAttribute = detailCellAttributes[indexPath.row-1];
        
        TwoLevelViewDetailCell *detailCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TwoLevelViewDetailCell" forIndexPath:indexPath];

        detailCell.labelView.text = detailCellAttribute.title;
        if (!detailCellAttribute.loadIconFromPath) {
            detailCell.imageView.image = detailCellAttribute.icon;
        }
        else
        {
            if (!detailCellAttribute.delayLoadIcon) {
                UIImage *image = [UIImage imageWithContentsOfFile:detailCellAttribute.iconPath];
                detailCell.imageView.image = image;
            }
            else
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    UIImage *image = [UIImage imageWithContentsOfFile:detailCellAttribute.iconPath];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([detailCell.identifier isEqualToString:detailCellAttribute.iconPath]) {
                            detailCell.imageView.image = image;
                        }
                    });
                });
            }
        }
        
        if (detailCellAttribute.showLock) {
//            detailCell.lockImageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.5 alpha:0.5];
            detailCell.lockImageView.image = [UIImage imageNamed:@"lock_dot"];
        }
        else
        {
//            detailCell.lockImageView.backgroundColor = nil;
            detailCell.lockImageView.image = nil;
        }

//        detailCell.titleRatio = 0.2;
        cell = detailCell;
    }
    
    return cell;
}

//-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionReusableView * view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"tail" forIndexPath:indexPath];
//    view.backgroundColor = [UIColor blackColor];
//    return view;
//}

#pragma mark - UICollectionViewDelegate

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    if (row > 0)
    {
        TwoLevelViewHeaderCellAttributes *headerCellAttribute = self.cellAttributess[section];
        NSArray *detailCellAttributes = headerCellAttribute.detailCellAttributes;
        TwoLevelViewDetailCellAttributes *detailCellAttribute = detailCellAttributes[row-1];
        
        if ([detailCellAttribute showLock])
        {
            if (_lockActions) {
                _lockActions(0);
            }
            return NO;
        }
        
        if ([detailCellAttribute noHighligh])
        {
            if (_actions)
            {
                _actions([NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]);
            }
            return NO;
        }
    }
    
    return YES;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    if (row == 0) {
        NSMutableArray *toDeletes = [NSMutableArray array];
        
        TwoLevelViewHeaderCell *toDeleteHeaderCell;
        TwoLevelViewHeaderCell *toInsertHeaderCell = (TwoLevelViewHeaderCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        if (_selectedGroup >= 0) {
            TwoLevelViewHeaderCellAttributes *headerCellAttribute = self.cellAttributess[_selectedGroup];
            NSArray *detailCellAttributes = headerCellAttribute.detailCellAttributes;

            for (NSInteger idx=1; idx<=detailCellAttributes.count; ++idx) {
                [toDeletes addObject:[NSIndexPath indexPathForRow:idx inSection:_selectedGroup]];
            }
            
            toDeleteHeaderCell = (TwoLevelViewHeaderCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_selectedGroup]];
        }
        
        TwoLevelViewHeaderCellAttributes *headerCellAttribute = self.cellAttributess[section];
        NSArray *detailCellAttributes = headerCellAttribute.detailCellAttributes;
        NSMutableArray *toInserts = [NSMutableArray array];
        for (NSInteger idx=1; idx<=detailCellAttributes.count; ++idx) {
            [toInserts addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
        }
        
        if (section == _selectedGroup) {
            toDeleteHeaderCell.backgroundView = nil;
            
            [self.layout prepareForDeleteInSection:section andInsertInSection:-1];
            _selectedGroup = -1;
            
            [collectionView performBatchUpdates:^{
                [collectionView deleteItemsAtIndexPaths:toDeletes];
            } completion:^(BOOL finished) {
            }];
        }
        else
        {
            toDeleteHeaderCell.backgroundView = nil;
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"level_1_haircolor_bg"]];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            toInsertHeaderCell.backgroundView = imageView;
            
            [self.layout prepareForDeleteInSection:_selectedGroup andInsertInSection:section];
            _selectedGroup = section;

            [collectionView performBatchUpdates:^{
                [collectionView deleteItemsAtIndexPaths:toDeletes];
                [collectionView insertItemsAtIndexPaths:toInserts];
            } completion:^(BOOL finished) {
            }];
        }
    }
    else
    {
        _selectedIndexPath = indexPath;
        
        if (_actions) {
            _actions([NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]);
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row == 0) {
        return CGSizeMake(CGRectGetHeight(_collectionView.bounds)*1.2, CGRectGetHeight(_collectionView.bounds));
    }
    else
    {
        return CGSizeMake(CGRectGetHeight(_collectionView.bounds)-10, CGRectGetHeight(_collectionView.bounds)-10);
    }
}

#pragma mark -
-(UIColor *) randomColor
{
    NSInteger r = arc4random()%256;
    NSInteger g = arc4random()%256;
    NSInteger b = arc4random()%256;
    
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

#pragma mark -
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _layout.itemSize = CGSizeMake(CGRectGetHeight(_collectionView.bounds), CGRectGetHeight(_collectionView.bounds));
    _layout.minimumLineSpacing = 8;
    _layout.minimumInteritemSpacing = 8;
    _layout.footerReferenceSize = CGSizeMake(2, CGRectGetHeight(_collectionView.bounds)-12);

    [_layout invalidateLayout];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)updateCellLock
{
    NSArray *visibleCells = [_collectionView visibleCells];
    
    for (UIView *cell in visibleCells) {
        if ([cell isKindOfClass:[TwoLevelViewHeaderCell class]])
        {
//            TwoLevelViewHeaderCell *headerCell = (TwoLevelViewHeaderCell *)cell;
//            NSIndexPath *indexPath = [_collectionView indexPathForCell:headerCell];
            
        }
        else if ([cell isKindOfClass:[TwoLevelViewDetailCell class]])
        {
            TwoLevelViewDetailCell *detailCell = (TwoLevelViewDetailCell *)cell;
            NSIndexPath *indexPath = [_collectionView indexPathForCell:detailCell];

            TwoLevelViewHeaderCellAttributes *headerCellAttribute = self.cellAttributess[indexPath.section];
            NSArray *detailCellAttributes = headerCellAttribute.detailCellAttributes;
            TwoLevelViewDetailCellAttributes *detailCellAttribute = detailCellAttributes[indexPath.row-1];
            
            if (detailCellAttribute.showLock) {
                detailCell.lockImageView.image = [UIImage imageNamed:@"lock_dot"];
            }
            else
            {
                detailCell.lockImageView.image = nil;
            }
        }
    }
}

@end
