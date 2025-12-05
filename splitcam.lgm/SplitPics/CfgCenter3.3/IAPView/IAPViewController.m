//
//  IAPViewController.h
//
//  Modify by cloud on  2014-06-04
//  Copyright (c) 2014年 Vincent. All rights reserved.
//

#import "IAPViewController.h"
//#import "Admob.h"
#import "CfgCenter.h"

#ifdef LOG_USER_ACTION
//#import "Flurry.h"
@import Flurry_iOS_SDK;
#endif

@interface IAPViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@end

@implementation IAPViewController
{
    NSString *_productID;
    int _loginTimes;
   
    // purchase
    EBPurchase *ebPurchase;
    NSDictionary *dictionary;
}

@synthesize product_id = _productID;

-(id) initWithProductID:(NSString*)product_id login:(int) loginTimes
{
    self = [super init];
    _productID = product_id;
    _loginTimes = loginTimes;
	dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"Remove All Ads", kRemoveAd,
                                 nil];
    return self;
}

-(UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _loadingView.frame = self.view.bounds;
        _loadingView.backgroundColor = [UIColor blackColor];
        _loadingView.alpha = 0.8;
        [self.view addSubview:_loadingView];
    }
    return _loadingView;
}

#pragma mark - ui & event
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ebPurchase = [[EBPurchase alloc] init];
    ebPurchase.delegate = self;
    
    [self setupUIs];
}

- (void)setupUIs
{
    UIImageView *bgIV = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:bgIV];

    NSString *bg_img;
    int font_size;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        bg_img = @"ipad_bg.png";
        font_size = 26;
        
    } else if ([UIScreen mainScreen].bounds.size.height > 480) {
        bg_img = @"ip5_bg.png";
        font_size = 18;
    } else {
        bg_img = @"ip4_bg.png";
        font_size = 18;
    }

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(clickClose) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    UIButton *purchaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [purchaseButton addTarget:self action:@selector(purchase) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:purchaseButton];
    
    UIButton *restoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [restoreButton addTarget:self action:@selector(restore) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:restoreButton];
    
    [purchaseButton setImage:[UIImage imageNamed:@"purchase.png"] forState:UIControlStateNormal];
    [restoreButton setImage:[UIImage imageNamed:@"restore.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"close_btn.png"] forState:UIControlStateNormal];
    bgIV.image = [UIImage imageNamed:bg_img];
    [bgIV setContentMode:UIViewContentModeScaleToFill];

    // 按钮位置配置
    
    
    [purchaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(IS_IPAD?CGSizeMake(220, 140):CGSizeMake(110, 70));
        make.centerX.mas_equalTo(purchaseButton.superview).with.offset(IS_IPAD?-160:-80);
        make.bottom.mas_equalTo(IS_IPAD?-80:-50);
    }];
    
    
    [restoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(IS_IPAD?CGSizeMake(220, 140):CGSizeMake(110, 70));
        make.centerX.mas_equalTo(purchaseButton.superview).with.offset(IS_IPAD?160:80);
        make.bottom.mas_equalTo(self.view).mas_offset(IS_IPAD?-80:-50);
    }];
    backButton.frame = kDevice3(CGRectMake(10, 10, 40, 40), CGRectMake(10, 10, 40, 40), CGRectMake(20, 20, 60, 60));
    //purchaseButton.frame = kDevice3(CGRectMake(30, 400, 110, 70), CGRectMake(30, 468, 110, 70), CGRectMake(130, 850, 220, 140));
    //restoreButton.frame = kDevice3(CGRectMake(180, 400, 110, 70), CGRectMake(180, 468, 110, 70), CGRectMake(420, 850, 220, 140));
    
    [self.view bringSubviewToFront:self.loadingView];
}

- (void)clickClose
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)restore
{
    [self.loadingView startAnimating];
    [ebPurchase restorePurchase];
}

- (void)purchase
{
    [self.loadingView startAnimating];
    [ebPurchase requestProduct:_productID];
}
-(void)purchase_all
{
    [self.loadingView startAnimating];
    [ebPurchase requestProduct:kUnlockAll];
}

- (void)purchase:(NSString*)product_id
{
    [self.loadingView startAnimating];
    [ebPurchase requestProduct:product_id];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPaid object:product_id];
}
#pragma mark - ebPurchase delegate

-(void) requestedProduct:(EBPurchase*)ebp identifier:(NSString*)productId name:(NSString*)productName price:(NSString*)productPrice description:(NSString*)productDescription
{
    if (ebPurchase.validProduct != nil)
    {
        if (![ebPurchase purchaseProduct:ebPurchase.validProduct])
        {
            // Returned NO, so notify user that In-App Purchase is Disabled in their Settings.
            UIAlertView *settingsAlert = [[UIAlertView alloc] initWithTitle:@"Allow Purchases"
                                                        message:@"You must first enable In-App Purchase in your iOS Settings before making this purchase."
                                                         delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [settingsAlert show];
        }
    }
}

-(void) successfulPurchase:(EBPurchase*)ebp identifier:(NSString*)productId receipt:(NSData*)transactionReceipt
{
    [self.loadingView stopAnimating];
    NSLog(@"buy:%@", productId);
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPaid object:productId];
    /*
    NSString *tmp_str = [dictionary objectForKey:productId];
    NSString *str_body = [NSString stringWithFormat:@"You have successfully purchased a product"];
    
    UIAlertView *succ_alert = [[UIAlertView alloc] initWithTitle:@"Purchase Success"
                                                         message:str_body delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [succ_alert show];
    */
#ifdef LOG_USER_ACTION
    [Flurry logEvent:[NSString stringWithFormat:@"IAP Succeed:%@",  productId]];
#endif
    
    [self clickClose];
}

-(void) successfulRestore:(EBPurchase *)ebp identifiers:(NSMutableArray *)products
{
    [self.loadingView stopAnimating];
    NSInteger product_num = [products count];
    NSMutableString *str_body = [NSMutableString  stringWithFormat:@"You have restored  %ld products\n", product_num];
    for (int i = 0; i < product_num; i++) {
        NSString *product_str  = [products objectAtIndex:i];
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPaid object:product_str];
        NSLog(@"restore:%@", product_str);
        //NSString *tmp_str = [dictionary objectForKey:product_str];
        //[str_body appendString:[NSString stringWithFormat:@"%@\n", tmp_str]];
    }
    
    UIAlertView *succ_alert = [[UIAlertView alloc] initWithTitle:@"Restore Success" message:str_body delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [succ_alert show];
#ifdef LOG_USER_ACTION
    [Flurry logEvent:[NSString stringWithFormat:@"IAP Restore Succeed:%ld",  product_num]];
#endif
    
    [self clickClose];
}

#if 0
- (void)willPresentAlertView:(UIAlertView *)alertView
{
    for( UIView * view in alertView.subviews )
    {
        if( [view isKindOfClass:[UILabel class]] ) {    
            UILabel* label = (UILabel*) view;
            NSLog(@"%@", label.text);
            if ([label.text isEqualToString:alertView.message]) {
                label.text = @"";
                label.textAlignment = UITextAlignmentLeft;
                label.textColor = [UIColor redColor];
            }
        }
    }
}
#endif


-(void) failedPurchase:(EBPurchase*)ebp error:(NSInteger)errorCode message:(NSString*)errorMessage
{
    UIAlertView *failedAlert = [[UIAlertView alloc] initWithTitle:@"Purchase Stopped" message:@"Either you cancelled the request or Apple reported a transaction error. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [failedAlert show];
    
    NSLog(@"ViewController failedPurchase %ld", errorCode);
    [self.loadingView stopAnimating];
}

-(void) cancelledPurchase:(EBPurchase*)ebp
{
    [self.loadingView stopAnimating];
}

-(void) incompleteRestore:(EBPurchase*)ebp
{
    UIAlertView *restoreAlert = [[UIAlertView alloc] initWithTitle:@"Restore Failed" message:@"A prior purchase transaction could not be found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [restoreAlert show];
    [self.loadingView stopAnimating];
}

-(void) failedRestore:(EBPurchase*)ebp error:(NSInteger)errorCode message:(NSString*)errorMessage
{
    UIAlertView *failedAlert = [[UIAlertView alloc] initWithTitle:@"Restore Stopped" message:@"Either you cancelled the request or Apple reported a transaction error. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [failedAlert show];
    
    NSLog(@"ViewController failedRestore %ld", errorCode);
    [self.loadingView stopAnimating];
}
@end
