//
//  PDFDataSet.h
//  QRReader
//
//  Created by awt on 15/8/3.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFData.h"
#import "CommonEmun.h"
@protocol PDFDataSetDelegate <NSObject>
-(void) showChoicedFile : (NSString *)filename;

@end

@interface PDFDataSet : NSObject <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (nonatomic,weak) id<PDFDataSetDelegate> delegate;
@property (nonatomic,strong) PDFData *hisData;
@property (nonatomic,strong) NSMutableArray *secletedArray;
@property (nonatomic,strong) NSMutableArray *imagVewArray;
@property BOOL isDeleteMode;
@property (nonatomic,strong) NSMutableArray *cellArray;
@property  BOOL shoudReLoadData;
- (void) setupData;
- (void) cleanData;
- (void)removeCell;
- (void) addAnimation;
- (void) removeAnimation;


@end

