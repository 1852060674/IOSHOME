 //
//  PDFDataSet.m
//  QRReader
//
//  Created by awt on 15/8/3.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import "PDFDataSet.h"
#import "Config.h"
@interface PDFDataSet()

@end
@implementation PDFDataSet
- (void)setupData
{
    self.cellArray = [[NSMutableArray alloc] init];
    self.imagVewArray = [[NSMutableArray alloc] init];
    self.secletedArray = [[NSMutableArray alloc] init];
}

- (void) cleanData
{
    for (UICollectionViewCell *cell in [self cellArray]) {
        [cell removeFromSuperview];
        for (UIView *view in [cell subviews]) {
            [view removeFromSuperview];
        }
    }
    [self.cellArray removeAllObjects];
    [self.imagVewArray  removeAllObjects];
    [self.secletedArray removeAllObjects];
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"%d",[self.hisData.count integerValue]);
    for (NSString *s in [self.hisData bookArray]) {
        NSLog(@"s %@",s);
    }
    return [self.hisData.count integerValue];
}
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"historyData";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indentifier forIndexPath:indexPath];
    CGRect frame =cell.frame;
    frame.origin.x = frame.size.width*0.15;
    frame.origin.y = frame.size.height*0.02;
    frame.size.height = frame.size.height*0.6;
    frame.size.width =frame.size.width*0.7;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    [imageView setImage:[UIImage imageNamed:@"pdf.jpg"]];
    [imageView setTag:106];
    NSString *name = [self.hisData.bookArray objectAtIndexedSubscript:indexPath.row];
    frame =cell.frame;
    frame.origin.x = frame.size.width*0.02;
    frame.origin.y = frame.size.height*0.7;
    frame.size.height = frame.size.height*0.25;
    frame.size.width =frame.size.width*0.96;
    UILabel *nameLable = [[UILabel alloc] initWithFrame:frame];
    [nameLable setNumberOfLines:0];
    [nameLable setLineBreakMode:NSLineBreakByCharWrapping];
    [nameLable setTextAlignment:NSTextAlignmentCenter];
    [nameLable setText:name];
    [cell addSubview:imageView];
    [cell addSubview:nameLable];
  //  [cell.contentView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.4]];
    [self.cellArray addObject:cell];
    return cell;
}


- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD) {
        return CGSizeMake(CELL_WIDTH*4, CELL_WIDTH*5.6);
    }
    return CGSizeMake(CELL_WIDTH*5, CELL_WIDTH*7);
    
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isDeleteMode]) {

        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        if (![self.secletedArray containsObject:cell] ){
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width -2.1*CELL_WIDTH, 0.3*CELL_WIDTH, 1.5*CELL_WIDTH, 1.5*CELL_WIDTH)];
            [imageView setImage:[UIImage imageNamed:@"ok"]];
            UIView *blackview = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.width -2.1*CELL_WIDTH, 0.3*CELL_WIDTH, 0.6*CELL_WIDTH, 0.6*CELL_WIDTH)];
            [blackview  setBackgroundColor:[UIColor blackColor]];
            [blackview setTag:120];
            
            if (IS_IPAD) {
                [imageView setFrame:CGRectMake(cell.frame.size.width -1.8*CELL_WIDTH, 0.2*CELL_WIDTH, 1.5*CELL_WIDTH, 1.5*CELL_WIDTH)];
                
            }
            [blackview setCenter:imageView.center];
            [cell addSubview:blackview];
            [cell addSubview:imageView];
            [self.secletedArray addObject:cell];
            [self.imagVewArray addObject:imageView];
            
        }
        else {
            UIImageView *imageView = [self.imagVewArray objectAtIndex:[self.secletedArray indexOfObject:cell]];
            [imageView removeFromSuperview];
            for (UIView *view in [cell subviews]) {
                if (view.tag == 120 ) {
                    [view removeFromSuperview];
                }
            }
            [self.imagVewArray removeObject:imageView];
            [self.secletedArray removeObject:cell];
        }
    }
    else{
        NSString *fileName = [self.hisData.bookArray objectAtIndex:indexPath.row];

        [self.delegate showChoicedFile:fileName];
    }

}
- (void)removeCell{
    NSInteger count = [self.hisData.count integerValue];
    for (UICollectionViewCell *cell in [self secletedArray]) {
        NSInteger index = [self.cellArray  indexOfObject:cell];

        
        [self.cellArray removeObject:cell];
        [cell removeFromSuperview];
        for (UIView *view in [cell subviews]) {
            [view removeFromSuperview];
        }
        NSLog(@"d %d",index);
        [self.hisData.bookArray removeObjectAtIndex:index];
        count--;
        [self setShoudReLoadData:YES];
        
    }
    
    [self.hisData setCount:[NSNumber numberWithInteger:count]];
    if (self.shoudReLoadData) {
        for (UICollectionViewCell *cell in [self cellArray]) {
            [cell removeFromSuperview];
            for (UIView *view in [cell subviews]) {
                [view removeFromSuperview];
            }
        }
         [self.cellArray removeAllObjects];
    }

   
    [self.secletedArray removeAllObjects];
    [self.imagVewArray removeAllObjects];
}

- (void) addAnimation
{

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat|UIViewAnimationOptionAllowUserInteraction animations:^{
        for (UICollectionViewCell *cell in [self cellArray]) {
            for (UIView *image in [cell subviews]) {
                if (image.tag == 106) {
                    image.transform = CGAffineTransformMakeRotation(3*M_PI/180);
                }
                
            }
           // cell.transform = CGAffineTransformMakeRotation(3*M_PI/180);
            //cell.transform =CGAffineTransformMakeTranslation(1, 1);
        }
    } completion:nil];
}

- (void) removeAnimation
{
    for (UICollectionViewCell *cell in [self cellArray]) {
        for (UIView *image in [cell subviews]) {
            if (image.tag == 106) {
                [image.layer removeAllAnimations];
                image.transform = CGAffineTransformMakeRotation(0);
            }
           
        }
        //[cell.layer removeAllAnimations];
        //cell.transform = CGAffineTransformMakeRotation(0);
    }
}

@end
