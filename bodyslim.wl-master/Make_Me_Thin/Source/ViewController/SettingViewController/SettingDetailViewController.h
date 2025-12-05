//
//  SettingAutoSaveViewController.h
//  MySketch
//
//  Created by ZB_Mac on 15/8/7.
//  Copyright (c) 2015年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingDetailViewController : UIViewController
@property (nonatomic, strong) NSArray *sectionHeaders;
@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, readwrite) NSIndexPath* selectedPath;
@property(nonatomic, copy) void(^actionBlock)(NSIndexPath* indexPath);
@end
