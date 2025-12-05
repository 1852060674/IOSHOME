//
//  RoundCornerStatView.m
//  Solitaire
//
//  Created by jerry on 2017/8/15.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "RoundCornerStatView.h"
#import "ViewController.h"
#import "StatPlainTableViewCell.h"
#import "StatTableViewHeaderCell.h"

//#define ViewController GameViewController

@implementation RoundCornerStatView



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
  [super awakeFromNib];
  self.titleLabel.text = LocalizedGameStr(stat);
  [self.closeButton setTitle:LocalizedGameStr(ok) forState:(UIControlStateNormal)];
  [self.resetB setTitle:LocalizedGameStr2(reset_stat) forState:(UIControlStateNormal)];
  [self.collectionView registerNib:[UINib nibWithNibName:@"StatPlainTableViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
  [self.collectionView registerNib:[UINib nibWithNibName:@"StatTableViewHeaderCell" bundle:nil] forCellWithReuseIdentifier:@"header"];
}


#define NUM_CELL_PER_SUIT (9)


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return NUM_CELL_PER_SUIT;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

  CGRect rect = self.contentView.bounds;
  CGFloat scale = IS_IPAD?1.5:1;
  if (self.isp) {
    CGFloat   height = 30*scale;
    return CGSizeMake(CGRectGetWidth(rect), height);
  } else {
    CGFloat height = CGRectGetHeight(rect)/5;
    return CGSizeMake(CGRectGetWidth(rect)/2, height);
  }


//  BOOL isp = (CGRectGetWidth(rect) < CGRectGetHeight(rect));
//  NSInteger idx = indexPath.item;
//  BOOL isHeader = isp?(idx%NUM_CELL_PER_SUIT == 0):(idx/2%NUM_CELL_PER_SUIT == 0);
//
//  BOOL isPlaceHolder = isp?(idx%NUM_CELL_PER_SUIT == NUM_CELL_PER_SUIT-1):(idx/2%NUM_CELL_PER_SUIT == NUM_CELL_PER_SUIT-1);
//
//
//
//  if (CGRectGetWidth(rect) < CGRectGetHeight(rect)) {
//    CGFloat height = 0;
//    if (isHeader) {
//      height = 40*scale;
//    } else {
//      height = 20*scale;
//    }
//    if (idx/NUM_CELL_PER_SUIT==3) {
//      height = 0;
//    }
//    return CGSizeMake(CGRectGetWidth(rect), height);
//  } else {
//    CGFloat height = 0;
//    CGFloat scale = IS_IPAD?1.5:1;
//
//    if (isHeader) {
//      height = 40*scale;
//    } else {
//      if (isPlaceHolder) {
//        height = (idx/NUM_CELL_PER_SUIT<2)?(50*scale):0;
//      } else {
//        height = 20*scale;
//      }
//    }
//    return CGSizeMake(CGRectGetWidth(rect)/2, height);
//  }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{


//  CGRect rect = self.contentView.bounds;
//  BOOL isp = (CGRectGetWidth(rect) < CGRectGetHeight(rect));
  NSInteger idx = indexPath.item;
//  BOOL isHeader = isp?(idx%NUM_CELL_PER_SUIT == 0):(idx/2%NUM_CELL_PER_SUIT == 0);
//
//  BOOL isPlaceHolder = isp?(idx%NUM_CELL_PER_SUIT == NUM_CELL_PER_SUIT-1):(idx/2%NUM_CELL_PER_SUIT == NUM_CELL_PER_SUIT-1);
//
//  BOOL suit1 = isp?(idx/NUM_CELL_PER_SUIT == 0):(idx/NUM_CELL_PER_SUIT < 2 && idx%2==0);
//  BOOL suit2 = isp?(idx/NUM_CELL_PER_SUIT == 1):(idx/NUM_CELL_PER_SUIT < 2 && idx%2==1);
//  BOOL suit4 = isp?(idx/NUM_CELL_PER_SUIT == 2):(idx/NUM_CELL_PER_SUIT < 4 && idx%2==0);
//  BOOL suitPlaceHolder = isp?(idx/NUM_CELL_PER_SUIT == 3):(idx/NUM_CELL_PER_SUIT >= 2 && idx%2==1);





  GameStat * stat = [self gameStat];
  DrawStat* ds = stat.freecell;

  static NSString *itemIdentifier = @"cell";
      StatPlainTableViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:itemIdentifier forIndexPath:indexPath];
  switch (idx+1) {
                case 1:
                  cell.keyLabel.text = LocalizedGameStr(gamewon);
                  cell.valueLabel.text = [NSString stringWithFormat:@"%ld(%0.0f%%)",(long)ds.wonCnt,100.0*ds.wonCnt/(ds.wonCnt+ds.lostCnt+0.000001)];
                  return cell;
                  break;
                case 2:
                  cell.keyLabel.text = LocalizedGameStr(gamelost);
                  cell.valueLabel.text = [NSString stringWithFormat:@"%ld",(long)ds.lostCnt];
                  return cell;
                  break;
                case 3:
                  cell.keyLabel.text = LocalizedGameStr(shortesttime);
                  cell.valueLabel.text = [NSString stringWithFormat:@"%ld:%02ld",(long)ds.shortestWonTime/60,(long)ds.shortestWonTime%60];
                  return cell;
                  break;
                case 4:
                  cell.keyLabel.text = LocalizedGameStr(longesttime);
                  cell.valueLabel.text = [NSString stringWithFormat:@"%ld:%02ld",(long)ds.longestWonTime/60,(long)ds.longestWonTime%60];
                  return cell;
                  break;
                case 5:
                  cell.keyLabel.text = LocalizedGameStr(avgtime);
                  cell.valueLabel.text = [NSString stringWithFormat:@"%ld:%02ld",(long)ds.averageWonTime/60,(long)ds.averageWonTime%60];
                  return cell;
                  break;
                case 6:
                  cell.keyLabel.text = LocalizedGameStr(fewestmoves);
                  cell.valueLabel.text = [NSString stringWithFormat:@"%ld",(long)ds.fewestWonMoves];
                  return cell;
                  break;
                case 7:
                  cell.keyLabel.text = LocalizedGameStr(mostmoves);
                  cell.valueLabel.text = [NSString stringWithFormat:@"%ld",(long)ds.mostWonMoves];
                  return cell;
                  break;
                case 8:
                  cell.keyLabel.text = LocalizedGameStr(noundo);
                  cell.valueLabel.text = [NSString stringWithFormat:@"%ld",(long)ds.wonWithoutUndoCnt];
                  return cell;
                  break;
                case 9:
                  cell.keyLabel.text = LocalizedGameStr(highscore);
                  cell.valueLabel.text = [NSString stringWithFormat:@"%ld",(long)ds.highestSocre];
                  return cell;
                  break;
                  
                  
                  
                default:
                  break;
              }
  return cell;

//  if (isHeader) {
//    StatTableViewHeaderCell * header = [collectionView dequeueReusableCellWithReuseIdentifier:@"header" forIndexPath:indexPath];
//    if (suit1) {
//      header.nameL.text = LocalizedGameStr2(easy_statistics);
//      header.sep.hidden = YES;
//    } else if (suit2) {
//      header.nameL.text = LocalizedGameStr2(med_statistics);
//      header.sep.hidden = NO;
//
//    } else if (suit4) {
//      header.nameL.text = LocalizedGameStr2(hard_statistics);
//      header.sep.hidden = NO;
//    } else {
//      header.nameL.text = nil;
//      header.sep.hidden = YES;
//    }
//    return header;
//  } else {
//    static NSString *itemIdentifier = @"cell";
//    StatPlainTableViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:itemIdentifier forIndexPath:indexPath];
//    if (isPlaceHolder) {
//      cell.keyLabel.text = nil;
//      cell.valueLabel.text = nil;
//    } else {
//
//
//
//
//
//      NSInteger listRow = isp?(idx%NUM_CELL_PER_SUIT):(idx/2%NUM_CELL_PER_SUIT);
//
//      if (!suitPlaceHolder) {
//        switch (listRow) {
//          case 1:
//            cell.keyLabel.text = LocalizedGameStr(stat_won);
//            cell.valueLabel.text = [NSString stringWithFormat:@"%ld(%0.0f%%)",(long)ds.wonCnt,100.0*ds.wonCnt/(ds.wonCnt+ds.lostCnt+0.000001)];
//            return cell;
//            break;
//          case 2:
//            cell.keyLabel.text = LocalizedGameStr(stat_lose);
//            cell.valueLabel.text = [NSString stringWithFormat:@"%ld",(long)ds.lostCnt];
//            return cell;
//            break;
//          case 3:
//            cell.keyLabel.text = LocalizedGameStr(stat_swtime);
//            cell.valueLabel.text = [NSString stringWithFormat:@"%ld:%02ld",(long)ds.shortestWonTime/60,(long)ds.shortestWonTime%60];
//            return cell;
//            break;
//          case 4:
//            cell.keyLabel.text = LocalizedGameStr(stat_lwtime);
//            cell.valueLabel.text = [NSString stringWithFormat:@"%ld:%02ld",(long)ds.longestWonTime/60,(long)ds.longestWonTime%60];
//            return cell;
//            break;
//          case 5:
//            cell.keyLabel.text = LocalizedGameStr(stat_awtime);
//            cell.valueLabel.text = [NSString stringWithFormat:@"%ld:%02ld",(long)ds.averageWonTime/60,(long)ds.averageWonTime%60];
//            return cell;
//            break;
//          case 6:
//            cell.keyLabel.text = LocalizedGameStr(stat_fwmove);
//            cell.valueLabel.text = [NSString stringWithFormat:@"%ld",(long)ds.fewestWonMoves];
//            return cell;
//            break;
//          case 7:
//            cell.keyLabel.text = LocalizedGameStr(stat_mwmove);
//            cell.valueLabel.text = [NSString stringWithFormat:@"%ld",(long)ds.mostWonMoves];
//            return cell;
//            break;
//          case 8:
//            cell.keyLabel.text = LocalizedGameStr(stat_nundo);
//            cell.valueLabel.text = [NSString stringWithFormat:@"%ld",(long)ds.wonWithoutUndoCnt];
//            return cell;
//            break;
//          case 9:
//            cell.keyLabel.text = LocalizedGameStr(stat_highest_score);
//            cell.valueLabel.text = [NSString stringWithFormat:@"%ld",(long)ds.highestSocre];
//            return cell;
//            break;
//            
//            
//            
//          default:
//            break;
//        }
//      } else {
//        cell.keyLabel.text = nil;
//        cell.valueLabel.text = nil;
//      }
//    }
//    return cell;
//  }
//  return nil;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
  return 0;
}



- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
  return 0;
}



- (IBAction)Reset:(id)sender {
  UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                 message:LocalizedGameStr2(reset_stat)
                                                delegate:self
                                       cancelButtonTitle:LocalizedGameStr2(yes)
                                       otherButtonTitles:LocalizedGameStr2(cancel),nil];
  [alert show];
}

- (GameStat *)gameStat {
  ViewController * vc = (ViewController*)[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] topViewController];
  GameStat * stat = vc.gameStat;
  return stat;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    GameStat * stat = [self gameStat];
    [stat reset];
    NSString* path = [NSString stringWithFormat:@"%@/Documents/stat.dat",NSHomeDirectory()];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:stat];
    [data writeToFile:path atomically:YES];
    ///
    [self.collectionView reloadData];
  }
}


- (void)prepareForPortrait:(NSNumber *)ispV {
  BOOL isp = [ispV boolValue];
  self.isp = isp;
  self.sepVertical.hidden = isp;
  ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).scrollDirection = isp?UICollectionViewScrollDirectionVertical:UICollectionViewScrollDirectionHorizontal;
  self.resetCloseMidLine.constant = isp?0:(CGRectGetWidth(self.bounds)/2 - (CGRectGetWidth(self.closeButton.bounds)+ 20+10));
  [self.collectionView reloadData];
}




@end
