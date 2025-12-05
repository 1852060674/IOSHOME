//
//  MGHorCView.m
//  FunFace
//
//  Created by tangtaoyu on 15-2-5.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "MGHorCView.h"
#import "MGCell.h"
#import "LockIView.h"
#import "MGDefine.h"
#import "AppDelegate.h"
#import "MGData.h"

#define WdisH (4.0/5.0)
#define MGStr(x) [NSString stringWithFormat:@"%ld", (long)(x)]
#define MGLock

@interface MGHorCView()
{
    NSMutableArray *lockArray;
    NSMutableArray *mgLockArray;

    CGRect originRect;
    float cvH;
    float gap;
    
    NSMutableDictionary *dicts;
}
@end;

@implementation MGHorCView
@synthesize myCollection;
@synthesize selectedPictureIdx;
@synthesize selectedEffectIdx;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.clipsToBounds = YES;
    originRect = frame;
    selectedEffectIdx = 0;
    
    [self dataInit];
    [self widgetInit];
    
    return self;
}

- (void)dataInit
{
    cvH = kToolBarH;
    gap = 5.0;
    self.backgroundColor = MGTBBgColor;
    lockArray = @[@7,@10,@13,@16,@19,@22].mutableCopy;
    
    mgLockArray = @[].mutableCopy;
    
    if(_isPaid){
        [lockArray removeAllObjects];
        [mgLockArray removeAllObjects];
    }
}

- (void)widgetInit
{
    UIView *cvView = [[UIView alloc] init];
    cvView.frame = CGRectMake(0, 0, self.bounds.size.width, cvH);
    [self addSubview:cvView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = gap;
    layout.minimumLineSpacing = gap;
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    float cellH = cvView.bounds.size.height;
    float cellW = cvView.bounds.size.height*WdisH;
    layout.itemSize = CGSizeMake(cellW*0.9, cellH*0.9);
    
    myCollection = [[UICollectionView alloc] initWithFrame:cvView.bounds collectionViewLayout:layout];
    [myCollection registerClass:[MGCell class] forCellWithReuseIdentifier:@"MGCell"];
    
    myCollection.backgroundColor = [UIColor clearColor];
    myCollection.delegate = self;
    myCollection.dataSource = self;
    myCollection.showsHorizontalScrollIndicator = NO;
    myCollection.showsVerticalScrollIndicator = NO;
    
    [cvView addSubview:myCollection];
    
    float ctlY = cvH-gap;
    UIView *ctlView = [[UIView alloc] init];
    ctlView.frame = CGRectMake(0, ctlY, self.bounds.size.width, self.bounds.size.height-ctlY);
    [self addSubview:ctlView];
    
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, gap, ctlView.bounds.size.width, self.bounds.size.height-cvH)];
    [ctlView addSubview:subView];
    subView.backgroundColor = MGTBCtlColor;
    
    float arrowH = subView.bounds.size.height*0.8;
    float arrowW = arrowH*1.5;
    
    UIImageView *arrow = [[UIImageView alloc] init];
    arrow.frame = CGRectMake((subView.bounds.size.width-arrowW)/2, (subView.bounds.size.height-arrowH)/2,
                             arrowW, arrowH);
    arrow.image = [UIImage imageNamed:@"arrow"];
    [subView addSubview:arrow];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HiddenView:)];
    [ctlView addGestureRecognizer:tap];
    ctlView.userInteractionEnabled = YES;
    
    self.frame = CGRectMake(0, kScreenHeight, self.bounds.size.width, self.bounds.size.height);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    _nums = [self.dataSource numberOfItemsInMGHorCVIew:self];
    return _nums;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MGCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MGCell" forIndexPath:indexPath];
    
    UIImage *image = [self.dataSource imageInMGHorCView:self AtIndex:indexPath.row];
    cell.image = image;
    cell.index = indexPath.row;
    
#ifdef MGLock
    float lockW = (kW(cell.contentView)<kH(cell.contentView)?kW(cell.contentView):kH(cell.contentView))/2;
    if([MGData num:indexPath.row isInArray:lockArray]){
        LockIView *lockView = [[LockIView alloc] init];
        lockView.frame = CGRectMake((kW(cell.contentView)-lockW)/2, (kH(cell.contentView)-lockW)/2, lockW,lockW);
        [lockView setImage:[UIImage imageNamed:@"lock"]];
        [cell.imageView addSubview:lockView];
    }else{
        for(id obj in [cell.imageView subviews]){
            if([obj isKindOfClass:[LockIView class]]){
                LockIView *subView = (LockIView*)obj;
                [subView removeFromSuperview];
            }
        }
    }
#endif
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if(indexPath.row != 0){
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:path];
        cell.selected = NO;
    }*/
    
    [MGData mgDownWith:[NSString stringWithFormat:@"%d", (int)indexPath.row]];
    
    NSInteger type;
    if([MGData num:indexPath.row isInArray:lockArray])
        type = 0;
    else if([MGData num:indexPath.row isInArray:mgLockArray])
        type = 1;
    else
        type = 2;
    
    if(type != 2){
        if([self.delegate selectUpgrade:type]){
            NSInteger currentIdx = [[dicts objectForKey:MGStr(selectedPictureIdx)] integerValue];
            NSIndexPath *path = [NSIndexPath indexPathForRow:currentIdx inSection:0];
            [myCollection reloadData];
            [self.myCollection selectItemAtIndexPath:path animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            return;
        }
    }
    
    self.selectedEffectIdx = indexPath.row;
    [self.delegate mgHorCViewdidSelectItemAtIndex:indexPath.row];
}

- (void)unlockLocks
{
    [self cellReload];
    self.selectedPictureIdx = selectedPictureIdx;
}

- (void)setDefaultDataWith:(NSInteger)nums
{
    dicts = [[NSMutableDictionary alloc] init];
    for(int i = 0; i<nums; i++){
        [dicts setObject:@0 forKey:MGStr(i)];
    }
}

- (void)setSelectedPictureIdx:(NSInteger)newValue
{
    selectedPictureIdx = newValue;
    
    NSInteger currentIdx = [[dicts objectForKey:MGStr(selectedPictureIdx)] integerValue];
    NSIndexPath *path = [NSIndexPath indexPathForRow:currentIdx inSection:0];
    [self.myCollection selectItemAtIndexPath:path animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

- (void)setSelectedEffectIdx:(NSInteger)newValue;
{
    selectedEffectIdx = newValue;
    [dicts setValue:[NSNumber numberWithInteger:newValue] forKey:MGStr(selectedPictureIdx)];
}


- (void)HiddenView:(UITapGestureRecognizer*)recognizer
{
    [self hideSelf];
}

- (void)hideSelf
{
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, kScreenHeight, self.bounds.size.width, self.bounds.size.height);
    } completion:^(BOOL finished) {
        [self.delegate mghorCViewHide];
    }];
}

- (void)showSelf
{
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = originRect;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)cellReload
{
    [lockArray removeAllObjects];
    [mgLockArray removeAllObjects];
    
    [myCollection reloadData];
    
    CGPoint offset = myCollection.contentOffset;
    [myCollection setContentOffset:CGPointMake(0.0, -offset.y) animated:NO];
}

- (void)removeLocks:(NSNotification*)notification
{
    [myCollection reloadData];
    [lockArray removeAllObjects];
    [mgLockArray removeAllObjects];
}

- (void)dealloc
{

}

@end
