//
//  ResultViewController.h
//  QRReader
//
//  Created by awt on 15/8/5.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonEmun.h"
@interface ResultViewController : UIViewController

@property (strong,nonatomic) UIView *topViewCantainer;
@property (strong,nonatomic) UIButton *returnBtn;

//@property (strong,nonatomic) UIButton *cameraSwtitchBtn;
@property (strong,nonatomic) UILabel *topLable;
@property (strong,nonatomic) NSString *codeType;
@property (strong,nonatomic) NSString *codeName;
@property (strong,nonatomic) UIImage *imageView;
@property (strong,nonatomic) UITableView *resulView;
@property (nonatomic,strong) UIButton *webViewBtn;
@property (nonatomic,strong) UIButton *appBtn;
@property (nonatomic,strong) UIButton *google;
@property (nonatomic,strong) UIButton *baidu;
@property (nonatomic,strong) UIButton *amazon;
@property (nonatomic,strong) UIButton *amazon_cn;
@property (nonatomic,strong) UIButton *jingdong;
@property (nonatomic,strong) UIButton *ebay;
@property (nonatomic,strong) UIButton *taobao;
@property  BOOL isWedType;

@end
