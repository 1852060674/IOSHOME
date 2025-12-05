//
//  ViewController.m
//  QRReader
//
//  Created by awt on 15/7/20.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import "ViewController.h"
//#import "QRGenerator.h"
#import "Config.h"
#import "Admob.h"
#import "ProtocolAlerView.h"
#import <SafariServices/SafariServices.h>
#include "ApplovinMaxWrapper.h"
#import "Masonry.h"
@interface ViewController ()//<MKMapViewDelegate>


@property (strong,nonatomic) NSTimer *timer;
@property int a;

@property (nonatomic, strong) UIView* adview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *backGround = [[UIImageView alloc] initWithFrame:self.view.frame];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (IS_IPAD) {
        [backGround setImage:[UIImage imageNamed:@"LaunchBoard2048"]];
    }
    else if (IS_IPHONE4)
    {
         [backGround setImage:[UIImage imageNamed:@"LaunchBoard960"]];
    }
    else {
        [backGround setImage:[UIImage imageNamed:@"LaunchBoard1136"]];
    }
    [self.view addSubview:backGround];
    /*
    [self setAdview:[[AdView alloc] initWith:nil]];
    CGPoint point;
    if (IS_IPAD) {
        point = CGPointMake(self.view.center.x, 45);
    }
    else if (IS_IPHONE6|| IS_IPHONE6PLUS)
    {
        point = CGPointMake(self.view.center.x, 30);
    }
    else {
        point = CGPointMake(self.view.center.x, 25);
    }
    [self.adview addAds:self.view rootVc:self atPoint:point];
     */

    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCount) userInfo:nil repeats:YES];
    
    self.adview = [[UIView alloc] initWithFrame:CGRectMake(0, 104, kScreenWidth, MAAdFormat.banner.adaptiveSize.height)];
//    [self.adview  mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(0);
//        make.bottom.mas_equalTo(0);
//        make.right.mas_equalTo(0);
//        make.height.mas_equalTo(50);
//    }];
//
//    [self.adview mas_makeConstraints:^(MASConstraintMaker *make) {
//    make.bottom.mas_equalTo(0);
//    make.left.mas_equalTo(0);
//    make.right.mas_equalTo(0);
//    make.height.mas_equalTo(50);
//    }];

    [self.view addSubview:self.adview];
    
    //
    if(![[AdmobViewController shareAdmobVC] ifNeedShowNext:self]) {
        [[AdmobViewController shareAdmobVC] decideShowRT:self];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [[AdmobViewController shareAdmobVC] show_admob_banner:self.adview placeid:@"mainpage"];
    
    [[AdmobViewController shareAdmobVC] checkConfigUD];
    [self firstProtocolAlter];
}

- (void)timeCount
{
    self.a++;
    if (self.a <= 6) {
           NSLog(@"%d",self.a);
//        if ([[AdmobViewController shareAdmobVC] admob_interstial_ready]) {
            NSLog(@"adshoud show %d",self.a);
//            [[AdmobViewController shareAdmobVC] show_admob_interstitial:self];
            [self performSegueWithIdentifier:@"toCodeScanner" sender:nil];
            
            [self.timer invalidate];
            
//        }
    }
    else {
        [self performSegueWithIdentifier:@"toCodeScanner" sender:nil];
        [self.timer invalidate];
        //[self enterNewViewContoller];
    }
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


//    CLLocationCoordinate2D to;
//
//   //MKUserLocation *currentlocation =[MKUserLocation ]
//  MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
//    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:to addressDictionary:nil] ];
//    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH*20, HEIGHT)];
//    MKUserLocation *userLocation = [mapView userLocation];
//    CLLocation *loc =[userLocation location];
//    [loc altitude];
//    to = [loc coordinate];
//    [mapView setDelegate:self];
//    //[self.view addSubview:mapView];
//   // [mapView setCenterCoordinate:to animated:YES];
//    MKCoordinateRegion region ;
//    region.center.latitude = 22.530312;
//    region.center.longitude = 113.915823;
//    region.span.latitudeDelta = 0.05;
//    region.span.longitudeDelta =0.05;
//    [mapView setRegion:region animated:YES];
//    UIButton *button =  [[UIButton alloc] initWithFrame:CGRectMake(112, 110, 12, 12)];
//    [button setBackgroundColor:[UIColor blackColor]];
//    UIGestureRecognizer *dd = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gge:)];
//    [button addGestureRecognizer:dd];
//    [self.view addSubview:button];
    //up after loading the view, typically from a nib.
//    NSLog(@"%d",[self UrlType:@"_http://d.d.d/cn/a/www/ddd/a/!d/id85308792?mt=8*dedds1"]);

//- (NSInteger)UrlType : (NSString *)code
//{
//    NSString *      regex = @"\\s*http(s)?:\\/\\/([a-z0-9A-Z]+\\.)+[a-z0-9A-Z]+(\\/[\\w-@ .\\/?%&=!\\*:]*)?";
//    NSString *aw =@"[\\s]*http(s)?:[]";
//    NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//    NSString *regex1 =@"http(s)?:\\/\\/([\\w-]+\\.){1,}+[\\w-]+(\\/[\\w- .\\/?%&!#=]*)?";
//    NSPredicate *   pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
//    NSString *regex2 = @"([\\w-]+\\.)+[\\w-]+(\\/[\\w- .\\/?%&=]*)?";
//    NSPredicate *   pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
//    if ([pred evaluateWithObject:code]) {
//        return 1;
//    }
//    else if ([pred1 evaluateWithObject:code]) {
//        return 2;
//    }
//    else if ([pred2 evaluateWithObject:code]) {
//        return 3;
//    }
//    return  0;//[pred evaluateWithObject:code];
//}

//- (void)gge : (UIPanGestureRecognizer *)event
//{
//    
//    if (event.state == UIGestureRecognizerStateBegan) {
//        NSLog(@"dd");
//    }
//    else if (event.state == UIGestureRecognizerStateBegan)
//    {
//        NSLog(@"dda");
//    }
//    NSLog(@"ddd");
//}
//- (void) addpin :(UIButton *)sender
//{
//
//}
//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
//
//   
//        // 获得地图标注对象
//        MKPinAnnotationView * annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"PIN_ANNOTATION"];
//        if (annotationView == nil) {
//            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PIN_ANNOTATION"];
//        }
//        // 设置大头针标注视图为紫色
//        annotationView.pinColor = MKPinAnnotationColorGreen ;
//        // 标注地图时 是否以动画的效果形式显示在地图上
//        annotationView.animatesDrop = YES ;
//        // 用于标注点上的一些附加信息
//        annotationView.canShowCallout = YES ;
//        
//        return annotationView;  
//        
// 
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
//- (void) initCamera{
//
//}
//-(BOOL)prefersStatusBarHidden{
//    return YES;
//}


// att
- (void) firstProtocolAlter {
    NSString * val = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstLaunch"];
    if (!val) {
        
        //show alert
        
        ProtocolAlerView *alert = [ProtocolAlerView new];
        alert.viewController = self;
        alert.strContent = @"Thanks for using QR Code!\nIn this app, we need some permission to access the photo library, and camera to scan qr code. In this process, We do not collect or save any data getting from your device including processed data. By clicking 'Agree' you confirm that you have read and agree to our privacy policy.\nAt the same time, Ads may be displayed in this app. When requesting to 'track activity' in the next popup, please click 'Allow' to let us find more personalized ads. It's completely anonymous and only used for relevant ads.";
        
        [alert showAlert:self cancelAction:^(id  _Nullable object) {
            //不同意
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"firstLaunch"];
            //                   [self exitApplication];
        } privateAction:^(id  _Nullable object) {
            //   输入项目的隐私政策的 URL
            SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://54.177.255.231/support/funnystudio/qrcode/policy.html"]];
            //sfVC.delegate = self;
            [self presentViewController:sfVC animated:YES completion:nil];
            //        [self pushWebController:[YSCommonWebUrl userAgreementsUrl] isLoadOutUrl:NO title:@"用户协议"];
        } delegateAction:^(id  _Nullable object) {
            NSLog(@"用户协议");
            //   输入项目的隐私政策的 URL
            SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://54.177.255.231/support/funnystudio/qrcode/policy.html"]];
            //sfVC.delegate = self;
            [self presentViewController:sfVC animated:YES completion:nil];
        }
        ];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"firstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
    }
}
@end
