//
//  ZBHelpViewController.m
//  Spring
//
//  Created by shen on 14-7-31.
//  Copyright (c) 2014年 ZB. All rights reserved.
//

#import "ZBHelpViewController.h"
#import "ImageUtil.h"
#import "ZBCommonMethod.h"
#import <Masonry/Masonry.h>

#define kHelpPage  3
#define kSettingButtonStartTag   2000
#define IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define kScreenWidth   ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight  ([[UIScreen mainScreen] bounds].size.height)

@interface ZBHelpViewController ()<UIScrollViewDelegate>

@property (nonatomic)UIScrollView *scrollView;

@end

@implementation ZBHelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(kScreenWidth*kHelpPage, 0);
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.view);
//        make.centerY.equalTo(self.view).offset(-100);
        make.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(kScreenHeight);
        make.width.mas_equalTo(kScreenWidth);
    }];
    
    for (NSInteger i=0; i<kHelpPage; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth*i, 0, kScreenWidth, kScreenHeight)];
        
        if (IS_IPAD) {
            imageView.image = [ImageUtil loadResourceImage:[NSString stringWithFormat:@"ipad-%d",(int)i+1]];
        }
        else
        {
            if ([ZBCommonMethod currentResolution]==UIDevice_iPhoneTallerHiRes) {
                imageView.image = [ImageUtil loadResourceImage:[NSString stringWithFormat:@"i5-%d",(int)i+1]];
            }
            else
            {
                imageView.image = [ImageUtil loadResourceImage:[NSString stringWithFormat:@"i4-%d",(int)i+1]];
            }
        }
        
        [self.scrollView addSubview:imageView];
        

        
        if (i==kHelpPage-1) {
//            imageView.userInteractionEnabled = YES;
//            UITapGestureRecognizer *_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goBack)];
//            [imageView addGestureRecognizer:_tap];
            
            UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            startBtn.frame = CGRectMake(0, 0, (IS_IPAD?180:100), (IS_IPAD?180:100));
            startBtn.center = CGPointMake(imageView.center.x, imageView.center.y*0.5);
            [startBtn setImage:[ImageUtil loadResourceImage:@"start"] forState:UIControlStateNormal];
            [startBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:startBtn];
        }
    }
    
    /*
    UIButton *_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = CGRectMake(10, 10, (IS_IPAD?80:60), (IS_IPAD?40:30));
    [_backButton setImage:[ImageUtil loadResourceImage:@"back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
     */
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
