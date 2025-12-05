//
//  MGLineView.h
//  SplitPics
//
//  Created by tangtaoyu on 15-3-11.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MGLineViewDelegate;
@protocol MGLineViewDataSource;



@interface MGLineView : UIView

@property (strong, nonatomic) NSArray *points;
@property (strong, nonatomic) UIBezierPath *bezierArea;
@property (assign, nonatomic) float width;
@property (assign, nonatomic) LayoutPattern layoutIndex;
@property (assign, nonatomic) NSInteger lineIndex;
@property (assign, nonatomic) CGRect viewRect;
@property (assign, nonatomic) CGFloat blurValue;

@property (weak, nonatomic) id<MGLineViewDelegate> delegate;
@property (weak, nonatomic) id<MGLineViewDataSource> dataSource;

- (void)updateBlurView;
- (void)hideLine;
- (void)showLine;
- (UIBezierPath*)createPath;
@end

@protocol MGLineViewDelegate <NSObject>

@required

- (void)mgLineMovedWithViewIndex:(NSInteger)index;
- (void)mgLineChangedWithArray:(NSArray*)point WithIndex:(NSInteger)index;
- (void)mgAffectLineChangedWithArray:(NSArray *)point WithIndex:(NSInteger)index;
@end


@protocol MGLineViewDataSource <NSObject>
@optional
- (NSArray*)mgLineView:(MGLineView*)lineView AffectInIndex:(NSInteger)index;
- (NSInteger)numberOfLines;
@end
