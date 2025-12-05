//
//  UIColorGroupSelectionView.h
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/4.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HairDyeDescriptor;
@interface HairDyeSelectionView : UIView

-(HairDyeSelectionView *)initWithFrame:(CGRect)frame andEnableImageDye:(BOOL)imageDye;
-(void)setupViews;

@property (nonatomic, readwrite) BOOL showLock;
//@property (nonatomic, readwrite) BOOL showRTLock;

@property (nonatomic, copy) void(^actions)(HairDyeDescriptor* dyeDesc);

// 0 - purchase; 1 - RT
@property (nonatomic, copy) void(^lockActions)(NSInteger lockMode);

// mode: 0 - camera; 1 - slider
@property (nonatomic, copy) void(^addCustomActions)(NSInteger mode);

-(HairDyeDescriptor *)getDefaultDyeDesc;
-(HairDyeDescriptor *)getRandomDyeDesc;
-(HairDyeDescriptor *)getRandomDyeDescExceptGroupName:(NSString *)groupName;

-(void)selectDyeDescriptorAtIndex:(NSIndexPath *)indexPath;

-(void)updateUIForCustomColorAddition;
-(void)selectNewCustomColor;
@end
