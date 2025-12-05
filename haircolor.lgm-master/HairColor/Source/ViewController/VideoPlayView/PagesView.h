//
//  PageCollectionView.h
//  CutMeIn
//
//  Created by ZB_Mac on 16/8/8.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContent : NSObject
@property (nonatomic, strong) NSString *coverImage;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSString *iconImage;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *contentText;

-(PageContent *)initWithCoverImage:(NSString *)coverImage VideoURL:(NSURL *)url andIconImage:(NSString *)iconImage andTitle:(NSString *)title andContentText:(NSString *)contentText;
@end

@interface PagesView : UIView
-(instancetype)initWithFrame:(CGRect)frame andPages:(NSArray *)pages;
@property (nonatomic, strong) NSArray *pages;

@property (nonatomic, copy) void(^actions)(NSInteger index);
-(void)selectPage:(NSInteger)index;

@end
