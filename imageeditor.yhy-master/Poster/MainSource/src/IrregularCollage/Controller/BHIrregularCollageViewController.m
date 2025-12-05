//
//  BHIrregularCollageViewController.m
//  PicFrame
//
//  Created by shen on 13-6-18.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import "BHIrregularCollageViewController.h"
#import "ImageUtil.h"
#import "BHShowIrregularTemplateView.h"
#import "JBCroppableView.h"

@interface BHIrregularCollageViewController ()<UIScrollViewDelegate>
{
    BHShowIrregularTemplateView *_templateView;
}
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation BHIrregularCollageViewController
@synthesize imageView;

- (id)initWithPicImageTemplateType:(PicImageTemplateType)picImageTemplateType withSelectedImages:(NSMutableDictionary*)imagesDic
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    _templateView = [[BHShowIrregularTemplateView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kNavigationBarHeight)];
    [self.view addSubview:_templateView];
    
    
//    NSMutableArray *_pointArray = [[NSMutableArray alloc] initWithCapacity:2];
//    CGPoint _point = CGPointMake(0, 0);
//    [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
//    
//    _point = CGPointMake(0, 500);
//    [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
//    
//    _point = CGPointMake(500, 0);
//    [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
//    
//    
//    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
//    UIImage *image = [UIImage imageNamed:@"IMG_0152.JPG"];
//    self.imageView.backgroundColor = [UIColor clearColor];
//    self.imageView.image = [JBCroppableView getSpecialImage:image withPoints:_pointArray];
//    
////    [self.view addSubview:self.imageView];
//    
//    UIScrollView *_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, 20, 300, 300)];
//    _scrollView.delegate = self;
//    [_scrollView addSubview:self.imageView];
//    _scrollView.contentSize = CGSizeMake(306, 306);
//    [self.view addSubview:_scrollView];
}

//- (void)loadView {
//    [super loadView];
////    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation: UIStatusBarAnimationSlide];
////    UIImage *image=[UIImage imageNamed:@"IMG_0025"];
////    
////    UIImageView *backView=[[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
////    backView.image=image;
////    backView.alpha=0.6;
////    
////    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
////    CGContextRef context = CGBitmapContextCreate(nil,300,400,8,0,
////                                                 colorSpace,kCGImageAlphaPremultipliedLast);
////    CFRelease(colorSpace);
////    
////    UIImageView *contentView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
////    CGColorRef fillColor = [[UIColor whiteColor] CGColor];
////    CGContextSetFillColor(context, CGColorGetComponents(fillColor));
////    CGContextBeginPath(context);
////    CGContextMoveToPoint(context, 20.0f, 230.0f);
////    CGContextAddLineToPoint(context, 400.0f, 230.0f);
////    CGContextAddLineToPoint(context, 400.0f, 100.0f);
////    CGContextAddLineToPoint(context, 370.0f, 50.0f);
////    CGContextAddLineToPoint(context, 200.0f, 100.0f);
////    CGContextClosePath(context);
////    CGContextFillPath(context);
////    
////    contentView.image=[[UIImage alloc] initWithCGImage:CGBitmapContextCreateImage(context)];
////    contentView.alpha=0.3;
////    CGContextRelease(context);
////    
//////    self.view=[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
////    [self.view addSubview:backView];
////    [self.view addSubview:contentView];
////    
////    
//
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark -
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end
