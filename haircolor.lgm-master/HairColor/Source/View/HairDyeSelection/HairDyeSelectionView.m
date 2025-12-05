//
//  UIColorGroupSelectionView.m
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/4.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "HairDyeSelectionView.h"
#import "Masonry.h"
#import "TwoLevelView.h"
#import "ColorManger.h"
#import "UIColor+Hex.h"
#import "AdUtility.h"
#import "ColorHairDyeDescriptor.h"
#import "ImageHairDyeDescriptor.h"
#import "CfgCenter.h"

@interface HairDyeSelectionView ()
@property (nonatomic, strong) TwoLevelView *twoLevelView;
@property (nonatomic, weak) ColorManger *colorManger;

@end

@implementation HairDyeSelectionView

-(HairDyeSelectionView *)initWithFrame:(CGRect)frame andEnableImageDye:(BOOL)imageDye;
{
    self = [super initWithFrame:frame];
    
    if (self) {
        if (imageDye) {
            self.colorManger = CM;
        }
        else
        {
            self.colorManger = CM2;
        }
        
        [AdmobViewController shareAdmobVC] ;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseHappens) name:kResourceStateChanged object:nil];
    }
    
    return self;
}

-(void)purchaseHappens
{
    NSArray *headerCellAttributes = _twoLevelView.cellAttributess;
    
    for (NSInteger idx=0; idx<headerCellAttributes.count; ++idx) {
        TwoLevelViewHeaderCellAttributes *headAttribute = headerCellAttributes[idx];
        NSArray *detailCellAttributes = headAttribute.detailCellAttributes;
        
        for (NSInteger j=0; j<detailCellAttributes.count; ++j) {
            TwoLevelViewDetailCellAttributes *detailAttribute = detailCellAttributes[j];
            
            detailAttribute.showLock = detailAttribute.showLock&&(![AdUtility advanceColorAvailable]);
            detailAttribute.showLock = detailAttribute.showLock&&(![AdUtility advanceColorAvailable]);
        }
    }
    [_twoLevelView updateCellLock];
}

-(void)setupViews
{
    _twoLevelView = [[TwoLevelView alloc] initWithFrame:self.bounds];
    _twoLevelView.backgroundColor = [UIColor clearColor];
    NSMutableArray *headerCellAttributes = [NSMutableArray array];
    _twoLevelView.clipsToBounds = NO;
    // system colors
    NSInteger headerCnt = self.colorManger.groupNumber;
    for (NSInteger idx=0; idx<headerCnt; ++idx) {
        TwoLevelViewHeaderCellAttributes *cell = [TwoLevelViewHeaderCellAttributes new];
        NSInteger groupIndex = [self.colorManger groupIndexAtIndex:idx];

//        cell.icon = [UIImage imageNamed:[self.colorManger groupCoverIconAtIndex:idx]];
//        cell.icon = [UIImage imageNamed:[NSString stringWithFormat:@"%d_%d", (int)groupIndex, 0]];
        cell.loadIconFromPath = YES;
        cell.iconPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_%d", (int)groupIndex, 0] ofType:@"png"];

        NSInteger detailCnt = [self.colorManger colorNumberAtIndex:idx];
        NSMutableArray *detailCellAttributes = [NSMutableArray array];
        
        for (NSInteger cIndex=0; cIndex<detailCnt; ++cIndex) {
            
            TwoLevelViewDetailCellAttributes *detailCell = [TwoLevelViewDetailCellAttributes new];
//            detailCell.icon = [self.colorManger colorIconAtPath:[NSIndexPath indexPathForRow:cIndex inSection:idx]];
            detailCell.loadIconFromPath = YES;
            detailCell.iconPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_%d", (int)groupIndex, (int)cIndex] ofType:@"png"];

            if (_showLock) {
                BOOL colorlocked = [self.colorManger colorLockAtPath:[NSIndexPath indexPathForRow:cIndex inSection:idx]];
                
                detailCell.showLock = colorlocked;
            }
            
            //                BOOL colorRatingLocked = [self.colorManger colorRatingLockAtPath:[NSIndexPath indexPathForRow:cIndex inSection:idx]];
            
            
            [detailCellAttributes addObject:detailCell];
        }
        
        cell.detailCellAttributes = detailCellAttributes;
        
        [headerCellAttributes addObject:cell];
    }
    
    // user color
    TwoLevelViewHeaderCellAttributes *cell = [TwoLevelViewHeaderCellAttributes new];
    cell.icon = [UIImage imageNamed:[[ColorManger defaultUserManger] groupCoverIconAtIndex:0]];
    NSInteger detailCnt = [[ColorManger defaultUserManger] colorNumberAtIndex:0];
    NSMutableArray *detailCellAttributes = [NSMutableArray array];
    
    for (NSInteger cIndex=0; cIndex<detailCnt; ++cIndex) {
        TwoLevelViewDetailCellAttributes *detailCell = [TwoLevelViewDetailCellAttributes new];
        detailCell.icon = [[ColorManger defaultUserManger] colorIconAtPath:[NSIndexPath indexPathForRow:cIndex inSection:0]];

        if (cIndex==0 || cIndex==1) {
            detailCell.noHighligh = YES;
        }
        
        [detailCellAttributes addObject:detailCell];
    }
    cell.detailCellAttributes = detailCellAttributes;
    [headerCellAttributes addObject:cell];
    
    
    _twoLevelView.cellAttributess = headerCellAttributes;
    
    __weak HairDyeSelectionView* wSelf = self;
    [_twoLevelView setActions:^(NSIndexPath *indexPath) {
        if (indexPath.section >= [self.colorManger groupNumber] && indexPath.row == 0)
        {
            if (wSelf.addCustomActions) {
                wSelf.addCustomActions(0);
            }
        }
        else if (indexPath.section >= [self.colorManger groupNumber] && indexPath.row == 1)
        {
            if (wSelf.addCustomActions) {
                wSelf.addCustomActions(1);
            }
        }
        else
        {
            HairDyeDescriptor *dyeDescriptor = [wSelf dyeDescriptorOfIndex:indexPath];
            if (wSelf.actions) {
                wSelf.actions(dyeDescriptor);
            }
        }
    }];
    
    [_twoLevelView setLockActions:^(NSInteger lockMode) {
        if (wSelf.lockActions) {
            wSelf.lockActions(lockMode);
        }
    }];
    
    [self addSubview:_twoLevelView];
    
    [_twoLevelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(self);
    }];
}
-(HairDyeDescriptor *)dyeDescriptorOfIndex:(NSIndexPath *)indexPath
{
    BOOL colorlocked = NO;
    BOOL colorRatingLocked = NO;
    NSString *value = nil;
    NSInteger mode;
    BOOL highlight;
    CGFloat highlightFactor = 0.65;
    
    if (indexPath.section < [self.colorManger groupNumber]) {
        colorlocked = [self.colorManger colorLockAtPath:indexPath];
        colorRatingLocked = [self.colorManger colorRatingLockAtPath:indexPath];
        value = [self.colorManger colorValueAtPath:indexPath];
        mode = [self.colorManger colorationModeAtPath:indexPath];
        highlight = [self.colorManger colorationHighlightAtPath:indexPath];
        highlightFactor = [self.colorManger colorationHighlightFactorAtPath:indexPath];
    }
    else
    {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-[self.colorManger groupNumber]];
        colorlocked = [[ColorManger defaultUserManger] colorLockAtPath:indexPath];
        colorRatingLocked = [[ColorManger defaultUserManger] colorRatingLockAtPath:indexPath];
        value = [[ColorManger defaultUserManger] colorValueAtPath:indexPath];
        mode = [[ColorManger defaultUserManger] colorationModeAtPath:indexPath];
        highlight = [[ColorManger defaultUserManger] colorationHighlightAtPath:indexPath];
        highlightFactor = [[ColorManger defaultUserManger] colorationHighlightFactorAtPath:indexPath];
    }
    
    HairDyeDescriptor *dyeDescriptor;
    
    /// TODO: 0,1,2,3 & 4,5 should use different coloring algorithm
    switch (mode) {
        case 0:
        case 1:
        case 2:
        case 3:
        {
            ColorHairDyeDescriptor *colorDyeDescriptor = [[ColorHairDyeDescriptor alloc] init];
            colorDyeDescriptor.color = [UIColor colorWithHexString:value];
            
            dyeDescriptor = colorDyeDescriptor;
            break;
        }
        case 4:
        case 5:
        {
            ImageHairDyeDescriptor *imageDyeDescriptor = [[ImageHairDyeDescriptor alloc] init];
            imageDyeDescriptor.dyeImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:value ofType:nil]];
            
            dyeDescriptor = imageDyeDescriptor;
            break;
        }
        default:
            break;
    }
    
    dyeDescriptor.locked = colorlocked;
    dyeDescriptor.RTLocked = colorRatingLocked;
    dyeDescriptor.indexPath = indexPath;
    dyeDescriptor.highlight = highlightFactor;
    dyeDescriptor.alpha = 1.0;
    dyeDescriptor.dyeGroupName = [self.colorManger groupNameAtIndex:indexPath.section];
    dyeDescriptor.dyeGroupIndex = [self.colorManger groupIndexAtIndex:indexPath.section];
    dyeDescriptor.mode = mode;
    
    return dyeDescriptor;
}

-(HairDyeDescriptor *)getDefaultDyeDesc
{
    HairDyeDescriptor *dyeDesc = [self dyeDescriptorOfIndex:[NSIndexPath indexPathForRow:0 inSection:0]];
    return dyeDesc;
}

-(HairDyeDescriptor *)getRandomDyeDesc;
{
    NSInteger section = arc4random()%[self.colorManger groupNumber];
    NSInteger row = arc4random()%[self.colorManger colorNumberAtIndex:section];
    
    HairDyeDescriptor *dyeDesc = [self dyeDescriptorOfIndex:[NSIndexPath indexPathForRow:row inSection:section]];
    
    while (dyeDesc.RTLocked || dyeDesc.locked) {
        section = arc4random()%[self.colorManger groupNumber];
        row = arc4random()%[self.colorManger colorNumberAtIndex:section];
        
        dyeDesc = [self dyeDescriptorOfIndex:[NSIndexPath indexPathForRow:row inSection:section]];
    }
    
    return dyeDesc;
}

-(HairDyeDescriptor *)getRandomDyeDescExceptGroupName:(NSString *)groupName;
{
    NSInteger section = arc4random()%[self.colorManger groupNumber];
    NSString *gn = [self.colorManger groupNameAtIndex:section];
    
    while ([gn isEqualToString:groupName]) {
        section = arc4random()%[self.colorManger groupNumber];
        gn = [self.colorManger groupNameAtIndex:section];
    }
    
    HairDyeDescriptor *dyeDesc = [self dyeDescriptorOfIndex:[NSIndexPath indexPathForRow:0 inSection:section]];
    return dyeDesc;
}

-(void)selectDyeDescriptorAtIndex:(NSIndexPath *)indexPath;
{
    [_twoLevelView selectItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section] animated:YES];
}

-(void)updateUIForCustomColorAddition;
{
    TwoLevelViewHeaderCellAttributes *cell = _twoLevelView.cellAttributess.lastObject;
    
    TwoLevelViewDetailCellAttributes *detailCell = [TwoLevelViewDetailCellAttributes new];
    detailCell.icon = [[ColorManger defaultUserManger] colorIconAtPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    [cell.detailCellAttributes insertObject:detailCell atIndex:2];
    
    [_twoLevelView insertCellAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:_twoLevelView.cellAttributess.count-1]];
}

-(void)selectNewCustomColor
{
    TwoLevelViewHeaderCellAttributes *customGroupDesc = _twoLevelView.cellAttributess.lastObject;
    if (customGroupDesc.detailCellAttributes.count >= 3) {
        [_twoLevelView selectItemAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:_twoLevelView.cellAttributess.count-1] animated:YES];
        
        HairDyeDescriptor *dyeDescriptor = [self dyeDescriptorOfIndex:[NSIndexPath indexPathForRow:2 inSection:_twoLevelView.cellAttributess.count-1]];
        if (self.actions) {
            self.actions(dyeDescriptor);
        }
    }
}

-(void)setShowLock:(BOOL)showLock
{
    if (_showLock != showLock) {
        _showLock = showLock;
        
        NSInteger headerCnt = self.twoLevelView.cellAttributess.count;
        for (NSInteger idx=0; idx<headerCnt; ++idx) {
            TwoLevelViewHeaderCellAttributes *cell = self.twoLevelView.cellAttributess[idx];
            
            NSInteger detailCnt = cell.detailCellAttributes.count;
            NSMutableArray *detailCellAttributes = cell.detailCellAttributes;
            
            for (NSInteger cIndex=0; cIndex<detailCnt; ++cIndex) {
                
                TwoLevelViewDetailCellAttributes *detailCell = detailCellAttributes[cIndex];
                
                detailCell.icon = [self.colorManger colorIconAtPath:[NSIndexPath indexPathForRow:cIndex inSection:idx]];
                
                if (_showLock) {
                    BOOL colorlocked = [self.colorManger colorLockAtPath:[NSIndexPath indexPathForRow:cIndex inSection:idx]];
                    
                    detailCell.showLock = colorlocked;
                }
                else
                {
                    detailCell.showLock = NO;
                }
                
            }
        }
        [self.twoLevelView updateCellLock];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
