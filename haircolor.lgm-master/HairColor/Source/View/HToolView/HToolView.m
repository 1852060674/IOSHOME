//
//  HToolView.m
//  CutMeIn
//
//  Created by ZB_Mac on 16/6/23.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "HToolView.h"
#import "SimpleImageCollectionViewCell.h"
#import "Masonry.h"

@implementation HToolViewCellAttributes

-(UIColor *)titleColorForCell:(SimpleImageCollectionViewCell *)cell selected:(BOOL)selected
{
    return selected?_selectedTitleColor:_titleColor;
}

-(UIImage *)iconForCell:(SimpleImageCollectionViewCell *)cell selected:(BOOL)selected
{
    return selected?_selectedIcon:_icon;
}

-(UIEdgeInsets)imageViewEdgeInsetsForCell:(SimpleImageCollectionViewCell *)cell
{
    return _imageViewInsets;
}
@end

@interface HToolView ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, readwrite) NSInteger selectedIndex;

@end

@implementation HToolView
{
    UICollectionView *_collectionView;
}

-(void)setCellDatas:(NSArray *)cellDatas
{
    _cellDatas = cellDatas;
    
    [_collectionView reloadData];
}

-(instancetype)initWithFrame:(CGRect)frame andCellDatas:(NSArray *)cellDatas
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _cellDatas = cellDatas;
        
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout = layout;
        
        [_collectionView registerClass:[SimpleImageCollectionViewCell class] forCellWithReuseIdentifier:@"SimpleImageCollectionViewCell"];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;

        [self addSubview:_collectionView];
        
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.top.equalTo(self);
            make.left.equalTo(self).offset(4);
            make.right.equalTo(self).offset(-4);
        }];
        
        _collectionView.showsHorizontalScrollIndicator = NO;
        _selectedIndex = -1;
        
        self.backgroundColor = [UIColor clearColor];
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _cellDatas.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SimpleImageCollectionViewCell *cell = (SimpleImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SimpleImageCollectionViewCell" forIndexPath:indexPath];
    HToolViewCellAttributes *attributes = _cellDatas[indexPath.row];
    
    cell.titleRatio = attributes.title?self.titleRatio:0.0;
    cell.additionalDataSource = attributes;

    [cell setupViews];
    cell.titleLabel.text = attributes.title;

//    cell.backgroundColor = [UIColor yellowColor];
    
    if (!attributes.loadIconFromPath) {
        cell.imageView.image = attributes.icon;        
    }
    else
    {
        if (!attributes.delayLoadIcon) {
            UIImage *image = [UIImage imageWithContentsOfFile:attributes.iconPath];
            cell.imageView.image = image;
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                UIImage *image = [UIImage imageWithContentsOfFile:attributes.iconPath];

                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([cell.titleLabel.text isEqualToString:attributes.title]) {
                        cell.imageView.image = image;
                    }
                });
            });
        }
    }
    cell.imageView.contentMode = attributes.imageViewContentMode;
    
    cell.titleLabel.textColor = attributes.titleColor;
    cell.titleLabel.font = [UIFont systemFontOfSize:CGRectGetHeight(cell.bounds)*cell.titleRatio*0.8];
    cell.overlayImageView.image = self.selectedCenterMask;
    cell.overlayImageView.backgroundColor = self.selectedMaskBGColor;
    cell.showSelectedMode = self.showSelectedMode;
    cell.showRTView = attributes.showRT;
    
    if (self.roundCorner) {
        cell.imageView.layer.cornerRadius = 2;
        cell.imageView.clipsToBounds = YES;
        cell.overlayImageView.layer.cornerRadius = 2;
        cell.overlayImageView.clipsToBounds = YES;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetHeight(collectionView.bounds)*(self.widthRatio), CGRectGetHeight(collectionView.bounds)-2);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    CGFloat width = CGRectGetHeight(collectionView.bounds)*(self.widthRatio);
    NSInteger itemCount = [collectionView numberOfItemsInSection:section];
    
    CGFloat minSpacing = 8;
    CGFloat spacing = minSpacing;
    
    if (width*itemCount + (minSpacing)*(itemCount-1) < CGRectGetWidth(collectionView.bounds) && itemCount>1)
    {
        spacing = (CGRectGetWidth(collectionView.bounds) - width*itemCount)/(itemCount+1);
    }
    return MAX(spacing, minSpacing);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat width = CGRectGetHeight(collectionView.bounds)*(self.widthRatio);
    NSInteger itemCount = [collectionView numberOfItemsInSection:section];
    
    CGFloat minSpacing = 8;
    CGFloat spacing = minSpacing;
    
    if (width*itemCount + (minSpacing)*(itemCount+1) < CGRectGetWidth(collectionView.bounds))
    {
        spacing = (CGRectGetWidth(collectionView.bounds) - width*itemCount)/(itemCount+1);
    }
    
    spacing = MAX(spacing, minSpacing);
    return UIEdgeInsetsMake(0, spacing, 0, spacing);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndex = indexPath.row;
    if (_actions) {
        _actions(indexPath.row);
    }
}

#pragma mark -
-(void)reloadData
{
    _selectedIndex = -1;
    [_collectionView reloadData];
}

-(HToolViewCellAttributes *)cellAttributesForCellIndex:(NSInteger)index
{
    return _cellDatas[index];
}

-(UIView *)cellForCellIndex:(NSInteger)index;
{
    return [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

-(void)selectAtIndex:(NSInteger)index
{
    _selectedIndex = index;
    [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

-(void)scrollToIndex:(NSInteger)index
{
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

-(void)updateRT
{
    NSArray *cells = [_collectionView visibleCells];
    for (SimpleImageCollectionViewCell *cell in cells) {
        NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
        HToolViewCellAttributes *cellData = (HToolViewCellAttributes *)_cellDatas[indexPath.row];
        
        cell.showRTView = cellData.showRT;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    [_layout invalidateLayout];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
