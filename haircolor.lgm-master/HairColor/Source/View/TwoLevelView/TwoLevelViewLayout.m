//
//  TwoLevelViewLayout.m
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/2.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "TwoLevelViewLayout.h"

@interface TwoLevelViewLayout ()
@property (nonatomic, readwrite) NSInteger insertedSection;
@property (nonatomic, readwrite) CGPoint initialCenter;

@property (nonatomic, readwrite) NSInteger deletedSection;
@property (nonatomic, readwrite) CGPoint finalCenter;

@end

@implementation TwoLevelViewLayout

//-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
//    attributes.zIndex = 1000 - indexPath.row;
//    
//    return attributes;
//}
//
-(UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [[super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath] copy];

    NSInteger mode = -1;
    if (itemIndexPath.section == self.insertedSection && itemIndexPath.row != 0)
    {
        attributes.center = self.initialCenter;
        attributes.alpha = 0.0;
        attributes.zIndex = -1;
        
        mode = 0;
    }
    else
    {
        attributes = nil;
        
        mode = 1;
    }
    
    NSLog(@"appearing layoutAttributes: %d-%d, mode: %d, center:%@", (int)itemIndexPath.section, (int)itemIndexPath.row, (int)mode, NSStringFromCGPoint(attributes.center));
    
    return attributes;
}

-(UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [[super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath] copy];

    NSInteger mode = -1;
    if (itemIndexPath.section == self.deletedSection && itemIndexPath.row != 0)
    {
        attributes.center = self.finalCenter;
        attributes.alpha = 0.0;
        attributes.zIndex = -1;
        
        mode = 0;
    }
    else
    {
        attributes = nil;
        
        mode = 1;
    }
    
    NSLog(@"disappearing layoutAttributes: %d-%d, mode:%d, center:%@", (int)itemIndexPath.section, (int)itemIndexPath.row, (int)mode, NSStringFromCGPoint(attributes.center));
    
    return attributes;
}

-(void)prepareForDeleteInSection:(NSInteger)deleteSection andInsertInSection:(NSInteger)insertSection;
{
    self.insertedSection = insertSection;
    if (self.insertedSection >= 0) {
        UICollectionViewLayoutAttributes *attributes = [[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.insertedSection]] copy];
        self.initialCenter = attributes.center;
    }
    
    self.deletedSection = deleteSection;
    if (self.deletedSection >= 0) {
        UICollectionViewLayoutAttributes *attributes = [[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.deletedSection]] copy];
        self.finalCenter = attributes.center;
    }
}

//-(void)prepareForCollectionViewUpdates:(NSArray<UICollectionViewUpdateItem *> *)updateItems
//{
//    self.insertedSection = -1;
//    for (UICollectionViewUpdateItem *updateItem in updateItems) {
//        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
//            self.insertedSection = updateItem.indexPathAfterUpdate.section;
//            
//            UICollectionViewLayoutAttributes *attributes = [[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.insertedSection]] copy];
//            self.initialCenter = attributes.center;
//            break;
//        }
//    }
//    
//    self.deletedSection = -1;
//    for (UICollectionViewUpdateItem *updateItem in updateItems) {
//        if (updateItem.updateAction == UICollectionUpdateActionDelete) {
//            self.deletedSection = updateItem.indexPathBeforeUpdate.section;
//
//            UICollectionViewLayoutAttributes *attributes = [[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.deletedSection]] copy];
//            self.finalCenter = attributes.center;
//            break;
//        }
//    }
//    
//    NSLog(@"%s", __FUNCTION__);
//}

-(void)finalizeCollectionViewUpdates
{
    if (self.insertedSection >= 0)
    {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.insertedSection] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
    
    self.insertedSection = -1;
    self.deletedSection = -1;
    
    NSLog(@"%s", __FUNCTION__);
}

@end
