//
//  AutoDyeBottomView.h
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/2.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwoLevelViewDetailCellAttributes : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *selectedTitleColor;

@property (nonatomic, readwrite) UIViewContentMode imageViewContentMode;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSString *iconPath;

@property (nonatomic, strong) UIImage *selectedIcon;
@property (nonatomic, strong) NSString *selectedIconPath;

@property (nonatomic, readwrite) BOOL loadIconFromPath;
@property (nonatomic, readwrite) BOOL delayLoadIcon;

@property (nonatomic, readwrite) BOOL showLock;
@property (nonatomic, readwrite) BOOL noHighligh;
@end

@interface TwoLevelViewHeaderCellAttributes : NSObject
@property (nonatomic, readwrite) UIViewContentMode imageViewContentMode;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSString *iconPath;

@property (nonatomic, strong) UIImage *selectedIcon;
@property (nonatomic, strong) NSString *selectedIconPath;

@property (nonatomic, readwrite) BOOL loadIconFromPath;
@property (nonatomic, readwrite) BOOL delayLoadIcon;

@property (nonatomic, readwrite) BOOL showLock;

@property (nonatomic, strong) NSMutableArray* detailCellAttributes;
@end

@interface TwoLevelView : UIView
-(NSIndexPath *)selectedIndexPath;
-(void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
-(void)insertCellAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, copy) void(^actions)(NSIndexPath* indexPath);

// 0 - purchase; 1 - RT
@property (nonatomic, copy) void(^lockActions)(NSInteger lockMode);

@property (nonatomic, strong) NSArray *cellAttributess;

-(void)updateCellLock;
@end
