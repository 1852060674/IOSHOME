//
//  TwoLevelViewLayout.h
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/2.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwoLevelViewLayout : UICollectionViewFlowLayout

-(void)prepareForDeleteInSection:(NSInteger)deleteSection andInsertInSection:(NSInteger)insertSection;
@end
