
//  CodeScanner.m
//  QRReader
//
//  Created by awt on 15/7/20.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import "CodeScanner.h"
#import "Config.h"
#import "ZBarSDK.h"
#import "HistoryData.h"
#import "HistoryTableViewSet.h"
#import "QRGenerator.h"
#import "Admob.h"
#import "resultTableView.h"
#include "ApplovinMaxWrapper.h"
#import "TextUpperLeftLabel.h"
@interface CodeScanner() <AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,ZBarReaderDelegate,HistoryTableviewdelegate,UITextViewDelegate,AdmobViewControllerDelegate,SKStoreProductViewControllerDelegate>;

@property (nonatomic,strong) NSNumber *codeResutlType;
@property (nonatomic,strong) NSMutableString *code;
@property (nonatomic,strong) UIView *resultCantianer;
@property (nonatomic,strong) UIImageView *resultpic;
@property (nonatomic,strong) UILabel *resultNameLable;
@property (nonatomic,strong) UILabel *resultNumLable;
@property (nonatomic,strong) UIButton *resultConfirmBtn;
@property (nonatomic,strong) UIButton *resultCancleBtn;
@property (nonatomic,strong) UIButton *closeWebCantainer;
@property (nonatomic,strong) UIButton *closeQRBtn;
//@property (nonatomic,strong) UIButton *webViewBtn;
//@property (nonatomic,strong) UIButton *appBtn;
//@property (nonatomic,strong) UIButton *google;
//@property (nonatomic,strong) UIButton *baidu;
//@property (nonatomic,strong) UIButton *amazon;
//@property (nonatomic,strong) UIButton *amazon_cn;
//@property (nonatomic,strong) UIButton *jingdong;
//@property (nonatomic,strong) UIButton *ebay;
//@property (nonatomic,strong) UIButton *taobao;
//@property (nonatomic,strong) UIButton *walmart;
//@property (nonatomic,strong) UIButton *bing;
@property (nonatomic,strong) UITableView *searchTable;
@property (nonatomic,strong) UIView *webCantainer;
@property (nonatomic,strong) UIImageView *albumImageView;
@property (nonatomic,strong) UIButton *deleteHistoryBtn;
@property (nonatomic,strong) UIView *createCantainer;
@property (nonatomic,strong) UITextView *creatText;
@property BOOL shoudHideMuneLst;
@property (nonatomic,strong) UIButton *confirmCreatorBtn;
@property (nonatomic,strong) UIButton *cancleCreatorBtn;
@property (nonatomic,strong) UIImageView *qrImageView;
@property (nonatomic,strong) UIView *whitBG;
@property (nonatomic,strong) HistoryData *hisData;
@property (nonatomic,strong) UIButton *moveBtn;
@property (nonatomic,strong) UIButton *shareBtn;
@property (nonatomic,strong) UITableView *resultTable;
//@property (nonatomic,strong) UIButton *returnBtn;
@property (nonatomic,strong) ResultTableView *restTableDelegate;

@property (nonatomic, strong) UIView* adview;
@property (nonatomic, strong) UIView* liuHaiBtmBgview;
@end

@implementation CodeScanner

@synthesize  shoudResaveHistoryData;
@synthesize isEditionMode;
bool liuhai;
//CGFloat leftmenListWidth;
- (void)viewDidLoad {
    liuhai =[self isNotchScreen] && kScreenHeight >811;
    
//    leftmenListWidth= liuhai ? CELL_WIDTH*5-32: CELL_WIDTH*5-25;
    [super viewDidLoad];
    [self setupDevice];
    self.moveBtn =[[UIButton alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.moveBtn];
    [self.moveBtn addTarget:self action:@selector(moveView:) forControlEvents:UIControlEventTouchDown];
    self.restTableDelegate = [[ResultTableView alloc] init];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if ([settings integerForKey:@"historyCount"] == nil) {
        [settings setInteger:0 forKey:@"historyCount"];
        [settings synchronize];
    }
    [self layoutTopView];
     self.whitBG = [[UIView alloc]initWithFrame:CGRectMake(0, self.topViewCantainer.frame.size.height+self.topViewCantainer.frame.origin.y,WIDTH,HEIGHT -self.topViewCantainer.frame.size.height - self.topViewCantainer.frame.origin.y)];
    [self.whitBG setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:self.whitBG];
    [self.whitBG setHidden:YES];
    [self layoutMenuList];
    [self initData];
    [self layoutTableView];
    [self layoutScanCantainer];
    [self layoutPDFView];
    [self layoutResultCatainer];
    [self layoutDeleteHistoryDataButton];
   
    [self layoutCreateCaintainner];
    if (liuhai) {
        self.adview = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - buttomLiuhaiPianyiY - admobHeight, kScreenWidth, admobHeight)];
        self.liuHaiBtmBgview= [[UIView alloc] initWithFrame:CGRectMake(0,kScreenHeight - buttomLiuhaiPianyiY - admobHeight , kScreenWidth,44 +admobHeight)];
        self.liuHaiBtmBgview.backgroundColor=[UIColor colorWithWhite:0.10 alpha:1.0];
//        self.liuHaiBtmBgview.backgroundColor=[UIColor colorWithRed:1 green:0 blue:0 alpha:1.0];
        [self.view addSubview:self.liuHaiBtmBgview];
        
    }else{
        self.adview = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - admobHeight, kScreenWidth, admobHeight)];
    }
  
    [self.view addSubview:self.adview];
    
    
    //[self tryAlertRating];
    //[self.view setBackgroundColor:[UIColor whiteColor]];
   //[self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
   //[self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    //[self initAd];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self prefersStatusBarHidden];
    
    //make inter could show
    [self setA:30];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any  that can be recreated.
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setOpaque:YES];
    [[UIApplication  sharedApplication] setStatusBarHidden:NO];
    [self initAd];
    NSLog(@"dds");
    [self addAnimation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAnimation) name:UIApplicationDidBecomeActiveNotification object:nil];
  //  [self  addHistoryRecordWithType:@"ddf" content:@"1233"];
  //  [self addHistoryRecordWithType:@"ddas" content:@"dds44"];
    //[self loadHistoryFile];
}
- (void) addAnimation
{
    [self.scanBar.layer removeAllAnimations];
    [self.scanBar setCenter:CGPointMake(self.scanBar.center.x,2.5)];
    [UIView animateWithDuration:3 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse animations:^{
        [self.scanBar setCenter:CGPointMake(self.scanBar.center.x, self.scannerCantainer.frame.size.height-2.5)];
        
    } completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"finished");
            if (self.scannerMode== SMPDFMaker) {
                [UIView setAnimationsEnabled:NO];
            }
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //
    [[AdmobViewController shareAdmobVC] show_admob_banner:self.adview placeid:@"scanpage"];
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [super viewDidDisappear:animated];
}
- (void) setupDevice
{
   // _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  // _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    _output = [[AVCaptureMetadataOutput alloc] init];
    _session = [[AVCaptureSession alloc] init];
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    BOOL hasBack = NO;
    BOOL hasFront = NO;
    [self setIsBack:YES];
    for (AVCaptureDevice *avalaibleDevice in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (avalaibleDevice.position == AVCaptureDevicePositionFront) {
            self.frontDevice = avalaibleDevice;
            hasFront = YES;
        }
        else if (avalaibleDevice.position == AVCaptureDevicePositionBack ) {
            self.device = avalaibleDevice ;
            hasBack = YES;
        }
    }
    if (hasBack && hasFront) {
        [self setAvailableDeviceType:ACTBoth];
    }
    else if(hasFront)
    {
        [self setAvailableDeviceType:ACTFront];
        [self setDevice:self.frontDevice];
    }
    else if (hasBack){
        [self setAvailableDeviceType:ACTBack];
    }
    else{
        [self setAvailableDeviceType:ACTNone];
    }
    if (_frontDevice) {
        self.frontInput = [AVCaptureDeviceInput deviceInputWithDevice:self.frontDevice error:nil];
    }
    if (_device) {
         self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    if (self.device) {
        
        if ([self.session canAddInput:self.input]) {
            [self.session addInput:self.input];
        }
        if ([self.session canAddOutput:self.output]) {
            [self.session addOutput:self.output];
        }
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
        [self.stillImageOutput setOutputSettings:outputSettings];
        if ([self.session canAddOutput:self.stillImageOutput]) {
            [self.session addOutput:self.stillImageOutput];
        }
        [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        NSMutableArray *scanDataTypes = [[NSMutableArray alloc] init];
        if ([[self.output availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeUPCECode]) {
            [scanDataTypes addObject:AVMetadataObjectTypeUPCECode];
        }
//        if ([self.output ad]) {
//            <#statements#>
//        }
        if ([[_output availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeQRCode]) {
            [scanDataTypes addObject:AVMetadataObjectTypeQRCode];
        }
        if ([[self.output availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeEAN13Code]) {
            [scanDataTypes addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([[self.output availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeEAN8Code]) {
            [scanDataTypes addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([[self.output availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeCode128Code]) {
            [scanDataTypes addObject:AVMetadataObjectTypeCode128Code];
        }
        if ([[self.output availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeCode39Code]) {
            [scanDataTypes addObject:AVMetadataObjectTypeCode39Code];
        }
        if ([[self.output availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeCode93Code]) {
            [scanDataTypes addObject:AVMetadataObjectTypeCode93Code];
        }
        if ([[self.output availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeCode39Mod43Code]) {
            [scanDataTypes addObject:AVMetadataObjectTypeCode39Mod43Code];
        }
        if ([[self.output availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeUPCECode]) {
            [scanDataTypes addObject:AVMetadataObjectTypeUPCECode];
        }
//        if ([[self.output availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeITF14Code]) {
//            [scanDataTypes addObject:AVMetadataObjectTypeITF14Code];
//        }
        if ([scanDataTypes count]!= 0) {
            [self.output setMetadataObjectTypes:scanDataTypes];
        }
        
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
        _preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        [self.preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [self.preview setFrame:self.view.bounds];
        if (IS_IPAD) {
            
        }
        else {

          //  [self.output setRectOfInterest:CGRectMake(0.1f, 0.3f, 0.8f,CELL_WIDTH*16.0f/HEIGHT)];
            
        }
        [self.view.layer insertSublayer:self.preview atIndex:0];
        [_session startRunning];
        [self setHasTorch:[self.device hasTorch]];
    }    
    
}
#pragma mark -setupui
- (void) layoutUI
{
    
}
#pragma mark -setupui
- (void) layoutScanCantainer
{
    [self setScannerCantainer:[[UIView alloc] initWithFrame:CGRectMake(0, 0,CELL_WIDTH*10, CELL_WIDTH*10)]];
    [self setCornerLT:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner2"]]];
    [self setCornerRT:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner3"]]];
    [self setCornerLB:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner"]]];
    [self setCornerRB:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner1"]]];
    [self.cornerLT setFrame:CGRectMake(0, 0, CELL_WIDTH*2, CELL_WIDTH*2)];
    [self.cornerRT setFrame:CGRectMake(self.scannerCantainer.frame.size.width-CELL_WIDTH*2, 0, CELL_WIDTH*2, CELL_WIDTH*2)];
    [self.cornerLB setFrame:CGRectMake(0, self.scannerCantainer.frame.size.height-2*CELL_WIDTH, 2*CELL_WIDTH, 2*CELL_WIDTH)];
    [self.cornerRB setFrame:CGRectMake(self.scannerCantainer.frame.size.width - 2*CELL_WIDTH, self.scannerCantainer.frame.size.height- 2*CELL_WIDTH, 2*CELL_WIDTH, 2*CELL_WIDTH)];
    [self.scannerCantainer addSubview:self.cornerRB];
    [self.scannerCantainer addSubview:self.cornerRT];
    [self.scannerCantainer addSubview:self.cornerLT];
    [self.scannerCantainer addSubview:self.cornerLB];
    [self.scannerCantainer setCenter:self.view.center];
    [self.view addSubview:self.scannerCantainer];
    [self.scannerCantainer setUserInteractionEnabled:NO];
    [self setScanBar:[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scannerCantainer.frame.size.width, 5)]];
    [self.scanBar setImage:[UIImage imageNamed:@"scanBar"]];
    [self.scannerCantainer addSubview:self.scanBar];
    [UIView animateWithDuration:3 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse animations:^{
        [self.scanBar setCenter:CGPointMake(self.scanBar.center.x, self.scannerCantainer.frame.size.height-2.5)];
        
    } completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"finished");
            if (self.scannerMode== SMPDFMaker) {
                [UIView setAnimationsEnabled:NO];
            }
        }
    }];

}


- (void) initData
{
    [self setScannerMode:SMCamera];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];//Documents目录
    NSString *historyPath = [documentsDirectory stringByAppendingPathComponent:@"path"];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:historyPath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:historyPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName = [historyPath stringByAppendingPathComponent:@"history.txt"];
    
    if ([fileManager fileExistsAtPath:fileName isDirectory:nil]) {
        
        
    }
    else{
        [fileManager createFileAtPath:fileName contents:nil attributes:nil];
    }
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"historyCount"]!=0) {
        
        
        self.hisData= [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    }
    else {
        self.hisData = nil;
    }
}

-( void) toAlbum :(UIButton*)sender
{
    [self.session stopRunning];
    if ([sender isEqual:self.PDFAlbum]) {
        [self setIsPDFAlbum:YES];
        
        if (![self shoudHideMuneLst]) {
            [self setShoudHideMuneLst:YES];
            [self changeView];
            [self.menuListCantainer setHidden:YES];
        }
        
        
    }
    else {
        [self hideView];
        [self setShoudHideMuneLst:YES];
        [self changeView];
        [self.menuListCantainer setHidden:YES];
        [self setIsPDFAlbum:NO];
        [self setScannerMode:SMAlBum];
        [self.topLable setText:@"Album Scanner"];
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [imagePicker setDelegate:self];
        [imagePicker setAllowsEditing:NO];
        
        imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        
    }
    
}
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker removeFromParentViewController];
    if ([self isPDFAlbum]) {
        UIImageView *imagev = [[UIImageView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:imagev];
        [imagev setImage:image];
        [self.session stopRunning];
        [self performSelector:@selector(hide:) withObject:imagev afterDelay:1];
        [self.PDFImageArray addObject:image];

        return;
    }
    //    /*    ZBAR_NONE        =      0,  < no symbol decoded
    //    ZBAR_PARTIAL     =      1,  < intermediate status
    //     ZBAR_EAN2        =      2,  < GS1 2-digit add-on
    //    ZBAR_EAN5        =      5,  /**< GS1 5-digit add-on */
    //    ZBAR_EAN8        =      8,  /**< EAN-8 */
    //    ZBAR_UPCE        =      9,  /**< UPC-E */
    //    ZBAR_ISBN10      =     10,  /**< ISBN-10 (from EAN-13). @since 0.4 */
    //    ZBAR_UPCA        =     12,  /**< UPC-A */
    //    ZBAR_EAN13       =     13,  /**< EAN-13 */
    //    ZBAR_ISBN13      =     14,  /**< ISBN-13 (from EAN-13). @since 0.4 */
    //    ZBAR_COMPOSITE   =     15,  /**< EAN/UPC composite */
    //    ZBAR_I25         =     25,  /**< Interleaved 2 of 5. @since 0.4 */
    //    ZBAR_DATABAR     =     34,  /**< GS1 DataBar (RSS). @since 0.11 */
    //    ZBAR_DATABAR_EXP =     35,  /**< GS1 DataBar Expanded. @since 0.11 */
    //    ZBAR_CODE39      =     39,  /**< Code 39. @since 0.4 */
    //    ZBAR_PDF417      =     57,  /**< PDF417. @since 0.6 */
    //    ZBAR_QRCODE      =     64,  /**< QR Code. @since 0.10 */
    //    ZBAR_CODE93      =     93,  /**< Code 93. @since 0.11 */
    //    ZBAR_CODE128     =    128,  /**< Code 128 */
    ZBarReaderController * read = [ZBarReaderController new];
    //设置代理
    read.readerDelegate = self;

    CGImageRef cgImageRef = image.CGImage;
    ZBarSymbol * symbol = nil;
    id <NSFastEnumeration> results = [read scanImage:cgImageRef];
    [self setCodeType:CTNone];
    for (symbol in results)
    {
        [symbol type];
        NSString * result;
        if ([symbol.data canBeConvertedToEncoding:NSShiftJISStringEncoding])
            
        {
            
            result = [NSString stringWithCString:[symbol.data cStringUsingEncoding: NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
            
        }
        else {
            result =symbol.data;
        }
      //  NSString * result = [symbol.data dataUsingEncoding:NSUTF8StringEncoding];
        if (symbol.type == ZBAR_EAN2||symbol.type == ZBAR_EAN5||symbol.type == ZBAR_EAN8||symbol.type == ZBAR_EAN13||symbol.type == ZBAR_ISBN10||symbol.type == ZBAR_ISBN13||symbol.type == ZBAR_UPCA||symbol.type == ZBAR_CODE128||symbol.type == ZBAR_CODE39||symbol.type == ZBAR_CODE93||symbol.type == ZBAR_COMPOSITE||symbol.type == ZBAR_I25||symbol.type == ZBAR_DATABAR||symbol.type == ZBAR_DATABAR_EXP||symbol.type == ZBAR_UPCE) {
            [self setCodeType:CTEAN13Code];
            [self addHistoryRecordWithType:[self codeTypeString] content:result];
            [self setCode:[NSMutableString stringWithString:result]];
        }
        else if (symbol.type == ZBAR_QRCODE)
        {
       
            [self setCodeType:[self UrlType:result]];
            [self setCode:[NSMutableString stringWithString:result]];
            [self addHistoryRecordWithType:[self codeTypeString] content:result];
            
        }
        if (self.codeType != CTNone) {
            [self.albumImageView setImage:image];
            [self.albumImageView setHidden:NO];
            if (self.a >= 30 && [[AdmobViewController shareAdmobVC] admob_interstial_ready]) {
                [[AdmobViewController shareAdmobVC] show_admob_interstitial:self];
                [AdmobViewController shareAdmobVC].delegate = self;
                [self setA:0];
            }
            else {
                [self showResult];
            }
            return;
        }
        
        NSLog(@"%@,%@",result,[symbol typeName]);
    }
    [self.albumImageView setImage:image];
    [self.albumImageView setHidden:NO];
    if (self.codeType != CTNone) {
        if (self.a >= 30 && [[AdmobViewController shareAdmobVC] admob_interstial_ready]) {
            [[AdmobViewController shareAdmobVC] show_admob_interstitial:self];
            [AdmobViewController shareAdmobVC].delegate = self;
            [self setA:0];
        }
        else {
            [self showResult];
        }
        return;
    }
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"can't detect bar code or qr code" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alerView show];
//http://search.jd.com/Search?keyword=手&enc=utf-8&wq=机&pvid=tms9peci.0qiy76
//https://www.baidu.com/s?wd=天堂鸟&rsv_spt=1&issp=1&f=8&rsv_bp=0&rsv_idx=2&ie=utf-8&tn=baiduhome_pg&rsv_enter=1
//    NSArray *features = [self.detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
//    for (CIQRCodeFeature *feature in features) {
//        NSString *scannedResult = feature.messageString;
//        NSLog(@"%@",scannedResult);
//    }
//    /*    ZBAR_NONE        =      0,  < no symbol decoded
//    ZBAR_PARTIAL     =      1,  < intermediate status 
//     ZBAR_EAN2        =      2,  < GS1 2-digit add-on
//    ZBAR_EAN5        =      5,  /**< GS1 5-digit add-on */
//    ZBAR_EAN8        =      8,  /**< EAN-8 */
//    ZBAR_UPCE        =      9,  /**< UPC-E */
//    ZBAR_ISBN10      =     10,  /**< ISBN-10 (from EAN-13). @since 0.4 */
//    ZBAR_UPCA        =     12,  /**< UPC-A */
//    ZBAR_EAN13       =     13,  /**< EAN-13 */
//    ZBAR_ISBN13      =     14,  /**< ISBN-13 (from EAN-13). @since 0.4 */
//    ZBAR_COMPOSITE   =     15,  /**< EAN/UPC composite */
//    ZBAR_I25         =     25,  /**< Interleaved 2 of 5. @since 0.4 */
//    ZBAR_DATABAR     =     34,  /**< GS1 DataBar (RSS). @since 0.11 */
//    ZBAR_DATABAR_EXP =     35,  /**< GS1 DataBar Expanded. @since 0.11 */
//    ZBAR_CODE39      =     39,  /**< Code 39. @since 0.4 */
//    ZBAR_PDF417      =     57,  /**< PDF417. @since 0.6 */
//    ZBAR_QRCODE      =     64,  /**< QR Code. @since 0.10 */
//    ZBAR_CODE93      =     93,  /**< Code 93. @since 0.11 */
//    ZBAR_CODE128     =    128,  /**< Code 128 */
}

#pragma mark- captureOutDelegate
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
//    int a = 0;
    if (self.scannerMode == SMPDFMaker) {
        return;
    }
    for(AVMetadataObject *current in metadataObjects) {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]){
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];
            [self setResult:[NSMutableString stringWithString:scannedResult]];
            NSLog(@"%@",scannedResult);
//            a++;
            [self.session stopRunning];
//            NSLog(@"%d",a);
            if ([current.type isEqualToString:AVMetadataObjectTypeQRCode]) {
                [self setCodeType:[self UrlType:scannedResult]];
                [self addHistoryRecordWithType:[self codeTypeString] content:scannedResult];
                 //[self codeProcess:scannedResult];
            }
            else {
                
                [self setCodeType:CTEAN13Code];
                [self addHistoryRecordWithType:[self codeTypeString] content:scannedResult];
            }
            [self setCode:[NSMutableString stringWithString:scannedResult]];

            if (self.a >= 30 && [[AdmobViewController shareAdmobVC] admob_interstial_ready]) {
                [[AdmobViewController shareAdmobVC] show_admob_interstitial:self];
                [AdmobViewController shareAdmobVC].delegate = self;
                [self setA:0];
            }
            else {
                [self showResult];
            }
            //[self.session performSelector:@selector(startRunning) withObject:nil afterDelay:2];
            [self.session stopRunning];
           
            break;
            
        }
    }
}
- (NSString *)codeTypeString
{
    switch (self.codeType) {
        case CTApplication:
            return  @"Application";
            break;
        case CTWebSite:
            return @"Web Site";
            break;
        case CTEAN13Code:
        case CTEAN8Code:
            return @"Bar Code";
            break;
        default:
            return @"Text";
            break;
    }

}
- (void)readerControllerDidFailToRead:(ZBarReaderController *)reader withRetry:(BOOL)retry
{
    NSLog(@"fail");

}
- (BOOL)prefersStatusBarHidden
{
    if (liuhai) {
        return NO;
    }
    return YES;
}
#pragma mark -layoutView

- (void) layoutTopView
{
    int  HeightPianyi=0;
    if (IS_IPAD) {
        
//        CGFloat sizeoOpbarWidth=IpdStanardSizeWidth;
//        CGFloat sizeoOpbarHeight=IpdStanardSizeHeight;
        self.topViewCantainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, CELL_WIDTH *3)];
        self.menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(CELL_WIDTH*0.5, 0, IpdStanardSizeWidth, IpdStanardSizeHeight)];
        //        self.scanTypeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CELL_WIDTH*2, CELL_WIDTH*2*209/163, CELL_WIDTH*2)];
        [self.scanTypeBtn setCenter:CGPointMake(self.topViewCantainer.center.x, self.scanTypeBtn.center.y)];
        self.cameraSwtitchBtn = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - CELL_WIDTH*0.5 -IpdStanardSizeWidth, 0, IpdStanardSizeWidth, IpdStanardSizeHeight)];//
        self.topLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH*7.5, CELL_WIDTH*2.25)];
        [self.topLable setFont:[UIFont systemFontOfSize:CELL_WIDTH*1]];
        [self.topLable setTextColor:[UIColor darkGrayColor ]];
        [self.topLable setCenter:CGPointMake(self.topViewCantainer.center.x,self.topViewCantainer.center.y )];
    }
    else {
        int  liuhaiTop=0;
        if (liuhai) {
            HeightPianyi=20;
            self.topViewCantainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH,54+50)];
        }else{
            self.topViewCantainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH,CELL_WIDTH *4)];
        }
        self.menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, stanardSizeWidth, stanardSizeHeight)];
        //        self.scanTypeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CELL_WIDTH*2, CELL_WIDTH*2*209/163, CELL_WIDTH*2)];
        [self.scanTypeBtn setCenter:CGPointMake(self.topViewCantainer.center.x, self.scanTypeBtn.center.y)];
        self.cameraSwtitchBtn = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - stanardSizeWidth-10, 0, stanardSizeWidth,stanardSizeHeight)];//
        self.topLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH*10, CELL_WIDTH*3 >50 ? 50:CELL_WIDTH*3)];
        [self.topLable setFont:[UIFont systemFontOfSize:CELL_WIDTH*1.2]];
        [self.topLable setTextColor:[UIColor darkGrayColor ]];
        [self.topLable setCenter:CGPointMake(self.topViewCantainer.center.x,self.topViewCantainer.center.y )];
        
    }
    [self.menuBtn setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
//    }
//    else{
//        self.topViewCantainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, CELL_WIDTH *4)];
//        self.menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, CELL_WIDTH*3*209/163, CELL_WIDTH*3)];
////        self.scanTypeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CELL_WIDTH*2, CELL_WIDTH*2*209/163, CELL_WIDTH*2)];
//        [self.scanTypeBtn setCenter:CGPointMake(self.topViewCantainer.center.x, self.scanTypeBtn.center.y)];
//        self.cameraSwtitchBtn = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 4*CELL_WIDTH, 0, CELL_WIDTH*3*249/231, CELL_WIDTH*3)];//
//        self.topLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH*10, CELL_WIDTH*3)];
//        [self.topLable setFont:[UIFont systemFontOfSize:CELL_WIDTH*1.2]];
//        [self.topLable setTextColor:[UIColor darkGrayColor ]];
//        [self.topLable setCenter:CGPointMake(self.topViewCantainer.center.x,self.topViewCantainer.center.y )];
//        UIImageView *menuView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH*2*209/163, CELL_WIDTH*2)];
//        [menuView setCenter:CGPointMake(self.menuBtn.frame.size.width/2, self.menuBtn.frame.size.height/2)];
//        [menuView setImage:[UIImage imageNamed:@"menu"]];
//        [self.menuBtn addSubview:menuView];
//    }
    int changey=10;
    [self.topLable setText:@"Camera Scanner"];
    [self.topLable setAdjustsFontSizeToFitWidth:YES];
    [self.topLable setTextAlignment:NSTextAlignmentCenter];
    [self.topLable setCenter:CGPointMake(self.topViewCantainer.center.x, self.topViewCantainer.center.y+HeightPianyi + changey)];
    //[self.topLable setTintAdjustmentMode:UIViewTintAdjustmentModeAutomatic];
    [self.topViewCantainer addSubview:self.topLable];
    
    [self.cameraSwtitchBtn setCenter:CGPointMake(self.cameraSwtitchBtn.center.x, self.topViewCantainer.center.y +HeightPianyi + changey)];
    [self.menuBtn setCenter:CGPointMake(self.menuBtn.center.x, self.topViewCantainer.center.y  +HeightPianyi + changey )];
    [self.cameraSwtitchBtn setBackgroundImage:[UIImage imageNamed:@"cameraSwitch"] forState:UIControlStateNormal];
    self.shareBtn = [[UIButton alloc] initWithFrame:self.cameraSwtitchBtn.frame];
    [self.topViewCantainer setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
    [self.topViewCantainer addSubview:self.menuBtn];
    [self.topViewCantainer addSubview:self.scanTypeBtn];
    [self.topViewCantainer addSubview:self.cameraSwtitchBtn];
    [self.topViewCantainer addSubview:self.shareBtn];
    [self.shareBtn setHidden:YES];
    [self.shareBtn setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [self.shareBtn addTarget:self action:@selector(shareQRCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.topViewCantainer];
    [self.menuBtn addTarget:self action:@selector(changeMenuListCantainer:) forControlEvents:UIControlEventTouchUpInside];

    //
//    [self.scanTypeBtn addTarget:self action:@selector(showScantypeList:) forControlEvents:UIControlEventTouchUpInside];
//    [self.scanTypeBtn setBackgroundImage:[UIImage imageNamed:@"trangle"] forState:UIControlStateNormal];
    [self.cameraSwtitchBtn addTarget:self action:@selector(swithcCameraLocation:) forControlEvents:UIControlEventTouchUpInside];
    if ([self availableDeviceType] != ACTBoth) {
        [self.cameraSwtitchBtn setAlpha:0.4];
        [self.cameraSwtitchBtn setUserInteractionEnabled:NO];
    }

}
//
- (void) layoutMenuList
{
    UIImageView *imageView;// = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_WIDTH*0.5, 0,CELL_WIDTH*2.8*209/163*0.6, CELL_WIDTH*2.8*0.6)];
    UIImageView *imageView1;// = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_WIDTH*0.5, 0,CELL_WIDTH*2.8*209/163*0.6, CELL_WIDTH*2.8*0.6)];
    UIImageView *imageView2;// = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_WIDTH*0.5, 0,CELL_WIDTH*2.8*209/163*0.6, CELL_WIDTH*2.8*0.6)];
    UIImageView *imageView3;// = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_WIDTH*0.5, 0,CELL_WIDTH*2.8*209/163*0.6, CELL_WIDTH*2.8*0.6)];
    UIImageView *imageView4;// = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_WIDTH*0.5, 0,CELL_WIDTH*2.8*209/163*0.6, CELL_WIDTH*2.8*0.6)];
    float button_height = 48;//CELL_WIDTH*3.5;
    float button_width = 48;//CELL_WIDTH*3.5*209/163;
    float padding = 5;//CELL_WIDTH*0.2;
    if (IS_IPAD) {
        button_height = 72;
        button_width = 72;
        padding = 8;//CELL_WIDTH*0.9;
        float imgx = (button_width - IpdStanardSizeWidth)/2;
        float imgy = (button_height - IpdStanardSizeHeight)/2;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imgx, imgy, IpdStanardSizeWidth, IpdStanardSizeHeight)];
        imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(imgx, imgy, IpdStanardSizeWidth, IpdStanardSizeHeight)];
        imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(imgx, imgy, IpdStanardSizeWidth, IpdStanardSizeHeight)];
        imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(imgx, imgy, IpdStanardSizeWidth, IpdStanardSizeHeight)];
        imageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(imgx, imgy, IpdStanardSizeWidth, IpdStanardSizeHeight)];
     } else {//zzx。2024.01.22 18.03
        float imgx = (button_width - stanardSizeWidth)/2;
        float imgy = (button_height - stanardSizeHeight)/2;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imgx, imgy, stanardSizeWidth, stanardSizeHeight)];
        imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(imgx, imgy, stanardSizeWidth, stanardSizeHeight)];
        imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(imgx, imgy, stanardSizeWidth, stanardSizeHeight)];
        imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(imgx, imgy, stanardSizeWidth, stanardSizeHeight)];
        imageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(imgx, imgy, stanardSizeWidth, stanardSizeHeight)];
        
        //[self.menuListCantainer setBackgroundColor:[UIColor blackColor]];
//
   }
    self.menuListCantainer =[[UIImageView alloc] initWithFrame:CGRectMake(0, self.topViewCantainer.frame.origin.y+self.topViewCantainer.frame.size.height, button_width+padding*2, button_height*5+padding*6)];
    self.cameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(padding, padding, button_width, button_height)];
    self.creatorBtn = [[UIButton alloc] initWithFrame:CGRectMake(padding, button_height+padding*2, button_width, button_height)];
    self.historyBtn = [[UIButton alloc] initWithFrame:CGRectMake(padding, button_height*2+padding*3, button_width, button_height)];
    self.settings = [[UIButton alloc] initWithFrame:CGRectMake(padding, button_height*3+padding*4, button_width, button_height)];
    self.PDFBtn = [[UIButton alloc] initWithFrame:CGRectMake(padding, button_height*4+padding*5, button_width, button_height)];
    
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    [self.menuListCantainer setImage:[UIImage imageNamed:@"BG"]];
    [self.menuListCantainer setUserInteractionEnabled:YES];
    [self.menuListCantainer addSubview:self.cameraBtn];
    [self.menuListCantainer addSubview:self.creatorBtn];
    [self.menuListCantainer addSubview:self.historyBtn];
    [self.menuListCantainer addSubview:self.settings];
    [self.menuListCantainer addSubview:self.PDFBtn];
    [self.view addSubview:self.menuListCantainer];
    [self.menuListCantainer setHidden:YES];
    [self.cameraBtn addTarget:self action:@selector(showCamera:) forControlEvents:UIControlEventTouchUpInside];
    NSLog(@"zzx111 %@",self.menuListCantainer.tintColor);
   [imageView setImage: [UIImage imageNamed:@"camera"]];
    [self.cameraBtn addSubview:imageView];
    
    //[self.cameraBtn setBackgroundImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
   [self.creatorBtn addTarget:self action:@selector(showCreator:) forControlEvents:UIControlEventTouchUpInside];
 //   UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_WIDTH*0.5, 0,CELL_WIDTH*2.8*209/163, CELL_WIDTH*2.8)];
    [imageView1 setImage: [UIImage imageNamed:@"creator"]];
    [self.creatorBtn addSubview:imageView1];
   // [self.creatorBtn setBackgroundImage:[UIImage imageNamed:@"creator"] forState:UIControlStateNormal];
    [self.historyBtn addTarget:self action:@selector(showHistory:) forControlEvents:UIControlEventTouchUpInside];
//UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_WIDTH*0.5, 0,CELL_WIDTH*2.8*209/163, CELL_WIDTH*2.8)];
    [imageView2 setImage: [UIImage imageNamed:@"history"]];
    [self.historyBtn addSubview:imageView2];
   // [self.historyBtn setBackgroundImage:[UIImage imageNamed:@"history"] forState:UIControlStateNormal];
    [self.settings addTarget:self action:@selector(toAlbum:) forControlEvents:UIControlEventTouchUpInside];
  //  UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_WIDTH*0.5, 0,CELL_WIDTH*2.8*209/163, CELL_WIDTH*2.8)];
    [imageView3 setImage: [UIImage imageNamed:@"image"]];
    [self.settings addSubview:imageView3];
  //  [self.settings setBackgroundImage:[UIImage imageNamed:@"image"] forState:UIControlStateNormal];
   // [self.PDFBtn setBackgroundImage:[UIImage imageNamed:@"PDF"] forState:UIControlStateNormal];
  //  UIImageView *imageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_WIDTH*0.5, 0,CELL_WIDTH*2.8*209/163, CELL_WIDTH*2.8)];
    [imageView4 setImage: [UIImage imageNamed:@"PDF"]];
    [self.PDFBtn addSubview:imageView4];
    [self.PDFBtn addTarget:self action:@selector(showPDF:) forControlEvents:UIControlEventTouchUpInside];
    [self setShoudHideMuneLst:YES];
    
}

- (void) changeMenuListCantainer:(UIButton *)sender
{
    [self setShoudHideMuneLst:![self shoudHideMuneLst]];
    [self.menuListCantainer setHidden:self.shoudHideMuneLst];
    [self changeView];
}
- (void) swithcCameraLocation : (UIButton *)sender
{
    if ([self availableDeviceType] == ACTBoth) {
        [self.session stopRunning];
        if ([self isBack]) {
            
            [self.session beginConfiguration];
            [self.session removeInput:self.input];
            if ([self.session canAddInput:self.frontInput] ) {
                [self.session addInput:self.frontInput];
            }
            else{
                [self.session addInput:self.input];
            }
            [self.session commitConfiguration];
            [self setIsBack:NO];
            
         
        }
        else {
        
            [self.session beginConfiguration];
            [self.session removeInput:[self frontInput]];
            if ([self.session canAddInput:self.frontInput] ) {
               [self.session addInput:self.input];
            }
            else{
                [self.session addInput:self.frontInput];
            }
            
            [self.session commitConfiguration];
            [self setIsBack:YES];
           
            
        }
        [self.session startRunning];
    }
}
- (void) showScantypeList : (UIButton *)sender
{

}
- (void) showPDF :(UIButton *)sender
{
    [self.scannerCantainer setHidden:YES];
    [self.menuListCantainer setHidden:YES];
    [self setShoudHideMuneLst:YES];
    [self hideView];
    [self changeView];
    [self setScannerMode:SMPDFMaker];
    if (self.availableDeviceType != ACTNone) {
        [self.session startRunning];
    }
    if (self.availableDeviceType == ACTBoth) {
        [self.cameraSwtitchBtn setAlpha:1];
        [self.cameraSwtitchBtn setUserInteractionEnabled:YES];
    }

    [self.topLable setText:@"PDF Scanner"];
    [self.PDFCamtainer setHidden:NO];
    
}
- (void)takePhoto: (UIButton *)sender
{

   
        AVCaptureConnection * videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        if (!videoConnection) {
            NSLog(@"take photo failed!");
            return;
        }
        
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (imageDataSampleBuffer == NULL) {
                return;
            }
            NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage * image = [UIImage imageWithData:imageData];
            UIImageView *imagev = [[UIImageView alloc] initWithFrame:self.view.frame];
            [self.view addSubview:imagev];
            [imagev setImage:image];
            [self.session stopRunning];
            [self performSelector:@selector(hide:) withObject:imagev afterDelay:1];
            [self.PDFImageArray addObject:image];
        }];
   
}
- (void) hide:(UIImageView *)i
{
    [i removeFromSuperview];
    if (self.availableDeviceType != ACTNone) {
         [self.session startRunning];
    }
   
}

- (void)layoutPDFView
{
    self.albumImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.topViewCantainer.frame.origin.y+self.topViewCantainer.frame.size.height, WIDTH, HEIGHT - self.topViewCantainer.frame.size.height- self.topViewCantainer.frame.origin.y)];
    [self.view addSubview:self.albumImageView];
    [self.albumImageView setHidden:YES];
    if (IS_IPAD) {
        self.PDFCamtainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, CELL_WIDTH*2.4)];
        self.takePhotoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH*3*203/169*0.6, CELL_WIDTH*3*0.6)];
        [self setPDFAlbum:[[UIButton alloc] initWithFrame:CGRectMake(0.01*WIDTH, CELL_WIDTH*0.3, 2.7*CELL_WIDTH*0.6, 2.7*CELL_WIDTH*0.6)]];
        self.toPDFViewController = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH -3.3*CELL_WIDTH, 0, CELL_WIDTH*2.7*0.6, CELL_WIDTH*2.7*0.6)];
       
    }
    else {
       // zzzx 20240123 update PDFCamtainer and  toPDFViewController takePhotoBtn
        self.PDFCamtainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, CELL_WIDTH*4)];
        self.takePhotoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH*3*203/169, CELL_WIDTH*3)];
        [self setPDFAlbum:[[UIButton alloc] initWithFrame:CGRectMake(0.01*WIDTH, CELL_WIDTH*0.3, 2.7*CELL_WIDTH, 2.7*CELL_WIDTH)]];
        self.toPDFViewController = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH -3.3*CELL_WIDTH, 0, CELL_WIDTH*2.7, CELL_WIDTH*2.7)];
        
//        if (liuhai && kScreenHeight >811) {
//            self.PDFCamtainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50*4/3)];
//            self.takePhotoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50*203/169, 50)];
//            [self setPDFAlbum:[[UIButton alloc] initWithFrame:CGRectMake(0.01*WIDTH, CELL_WIDTH*0.3, 50*9/10, 50*9/10)]];
//            self.toPDFViewController = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH -3.3*CELL_WIDTH, 0, 50*9/10, 50*9/10)];
//            NSLog(@"awdaw");
//        }
    }
    [self.takePhotoBtn setCenter:CGPointMake(self.PDFCamtainer.center.x, self.PDFCamtainer.center.y)];
    [self.toPDFViewController setCenter:CGPointMake(self.PDFCamtainer.center.x+CELL_WIDTH*6, self.PDFCamtainer.center.y)];
    [self.PDFAlbum  setCenter:CGPointMake(self.PDFCamtainer.center.x-CELL_WIDTH*6, self.PDFCamtainer.center.y)];
    [self.PDFCamtainer setBackgroundColor:[[UIColor whiteColor]colorWithAlphaComponent:0.9]];
    [self.view addSubview:self.PDFCamtainer];
    self.PDFImageArray = [[NSMutableArray alloc] init];

    [self.takePhotoBtn setBackgroundImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [self.takePhotoBtn addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.PDFCamtainer addSubview:self.takePhotoBtn];
    if (self.availableDeviceType == ACTNone) {
        [self.takePhotoBtn setAlpha:0.4];
        [self.takePhotoBtn setUserInteractionEnabled:NO];
    }
    
    [self.PDFAlbum setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [self.PDFCamtainer addSubview:self.PDFAlbum];
    [self.PDFAlbum addTarget:self action:@selector(toAlbum:) forControlEvents:UIControlEventTouchDown];
    
    [self.toPDFViewController  addTarget:self action:@selector(enterPDFViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.toPDFViewController setBackgroundImage:[UIImage imageNamed:@"go"] forState:UIControlStateNormal];
    [self.PDFCamtainer addSubview:self.toPDFViewController];
    //zzx 20240123 zzx update ipd centerBar.Y
    if (IS_IPAD) {
        [self.PDFCamtainer setCenter:CGPointMake(self.view.center.x, HEIGHT -CELL_WIDTH*7+114)];
    }else{
        if (liuhai) {
            [self.PDFCamtainer setCenter:CGPointMake(self.view.center.x, HEIGHT -CELL_WIDTH*7+5)];
        }else{
            [self.PDFCamtainer setCenter:CGPointMake(self.view.center.x, HEIGHT -CELL_WIDTH*7+35)];
        }
//        [self.PDFCamtainer setCenter:CGPointMake(self.view.center.x, HEIGHT -CELL_WIDTH*7+5)];
    }
  
    [self.PDFCamtainer setHidden:YES];
    
}
- (void) enterPDFViewController :(UIButton *)sender
{
    [self performSegueWithIdentifier:@"toPDFViewController" sender:sender];
}
- (void) addHistoryRecordWithType:(NSString *) type content: (NSString *)content
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];//Documents目录
    NSString *historyPath = [documentsDirectory stringByAppendingPathComponent:@"path"];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:historyPath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:historyPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName = [historyPath stringByAppendingPathComponent:@"history.txt"];
    
    if ([fileManager fileExistsAtPath:fileName isDirectory:nil]) {
        
        
    }
    else{
        [fileManager createFileAtPath:fileName contents:nil attributes:nil];
    }
    
    //zzx text
    NSDate *date =[NSDate date];
    NSDateFormatter  *dateString = [[NSDateFormatter alloc] init];
    [dateString setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDate = [dateString stringFromDate:date];
    
    HistoryData *nowData = self.hisData;
    [self setHisData:[[HistoryData alloc] init]];
    [self.hisData setNext:nowData];
    [self.hisData setDate:currentDate];
    [self.hisData setCodeType:type];
    [self.hisData setCodeNumber:content];
    //[history setDate:currentDate];
    
    

    //[data writeToFile:fileName atomically:YES];
 

    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:type];
    [array addObject:content];
    [array addObject:currentDate];
   
    if ([self.historyTablViewSet.historyArry count] == 0) {
        [self.historyTablViewSet.historyArry addObject:array];
        [self.historyTablViewSet addImageView];
        [self.historyBtn setAlpha:1];
        [self.historyBtn setUserInteractionEnabled:YES];
    }
    else{
        [self.historyTablViewSet.historyArry insertObject:array atIndex:0];
        [self.historyTablViewSet addImageView];
    }
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSInteger historyCount = [settings integerForKey:@"historyCount"];
    if (historyCount<40) {
        historyCount++;
        [settings setInteger:historyCount forKey:@"historyCount"];
        [settings synchronize];
        
    }
    else {
        [self.historyTablViewSet.historyArry removeLastObject];
        [self.historyTablViewSet.imageArray removeLastObject];
        HistoryData *last = [self.hisData next];
        while ([last next]) {
            HistoryData *removed = [last next];
            if ([removed next]) {
                last = removed;
            }
            else{
                [last setNext:nil];
            }
        }
        
    }
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.hisData];
    [data writeToFile:fileName atomically:YES];
    [self.historyTableView reloadData];
   // NSLog(@"%@",imageDir);
}
//
//- (void) loadHistoryFile{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory=[paths objectAtIndex:0];//Documents目录
//    NSString *historyPath = [documentsDirectory stringByAppendingPathComponent:@"path"];
//    BOOL isDir = NO;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL existed = [fileManager fileExistsAtPath:historyPath isDirectory:&isDir];
//    if ( !(isDir == YES && existed == YES) )
//    {
//        [fileManager createDirectoryAtPath:historyPath withIntermediateDirectories:YES attributes:nil error:nil];
//        NSLog(@"no fil");
//        return;
//    }
// 
//    NSString *fileName = [historyPath stringByAppendingPathComponent:@"history.txt"];
//    if ([fileManager fileExistsAtPath:fileName isDirectory:nil]) {
//        
//        NSString *ppStr = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
//        NSArray * lines = [ppStr componentsSeparatedByString:@";"];
//        for (NSString *history in lines) {
//            NSArray *array = [history componentsSeparatedByString:@","];
//            for (NSString *dda in array) {
//                NSLog(@"%@//",dda);
//                
//            }
//        }
//        
//    }
//    else{
//            [fileManager createFileAtPath:fileName contents:nil attributes:nil];
//            return;
//    }
//   
//}
- (void) showCamera : (UIButton *)sender
{
    if (self.availableDeviceType != ACTNone) {
       [self.session startRunning];
    }
    [self.topLable setText:@"Camera Scanner"];
    [self.scannerCantainer setHidden:NO];
    [self setShoudHideMuneLst:YES];
    [self.menuListCantainer setHidden:YES];
    [self changeView];
    [self hideView];
    [self setScannerMode:SMCamera];
    if (self.availableDeviceType == ACTBoth) {
        [self.cameraSwtitchBtn setAlpha:1];
        [self.cameraSwtitchBtn setUserInteractionEnabled:YES];
    }
    
    
    
}
- (void)layoutCreateCaintainner

{
    CGRect frame =self.resultCantianer.frame;
    frame.origin.y +=CELL_WIDTH*4;
    frame.size.height -= CELL_WIDTH*3;
    self.qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH*12,CELL_WIDTH*12)];
    [self.qrImageView setCenter:self.view.center];
    [self.view addSubview:self.qrImageView];
    [self.qrImageView setHidden:YES];
    self.createCantainer =[[UIView alloc] initWithFrame:frame];
    self.creatText = [[UITextView alloc] initWithFrame:CGRectMake(CELL_WIDTH*2, CELL_WIDTH*1.4, CELL_WIDTH*16,CELL_WIDTH*7)];
    [self.creatText.layer setCornerRadius:CELL_WIDTH*0.6];
    UIImageView *imageView =[[UIImageView alloc] initWithFrame:CGRectMake(CELL_WIDTH, CELL_WIDTH*0.5, CELL_WIDTH*18,CELL_WIDTH*9)];
    [self.view addSubview:[self createCantainer]];
     self.confirmCreatorBtn = [[UIButton alloc] initWithFrame:CGRectMake(CELL_WIDTH*3, CELL_WIDTH*10, CELL_WIDTH*3*203/163, CELL_WIDTH*3)];
    self.cancleCreatorBtn = [[UIButton alloc] initWithFrame:CGRectMake(CELL_WIDTH*13, CELL_WIDTH*10, CELL_WIDTH*3*203/163, CELL_WIDTH*3)];
    self.closeQRBtn = [[UIButton alloc] initWithFrame:self.menuBtn.frame];
//    self.closeQRBtn.frame=CGRectMake(self.menuBtn.frame.origin.x, self.menuBtn.frame.origin.y, stanardSizeWidth, stanardSizeHeight);
    if (IS_IPAD) {
//        self.closeQRBtn = [[UIButton alloc] initWithFrame:self.menuBtn.frame];
//        frame.origin.y -=CELL_WIDTH*2;
//        frame.size.width=IpdStanardSizeWidth;
//        frame.size.height=IpdStanardSizeHeight;
//        [self.createCantainer setFrame:frame];
        self.closeQRBtn.frame=CGRectMake(self.resultCantianer.frame.origin.x+20, self.resultCantianer.frame.origin.y - CELL_WIDTH*2, IpdStanardSizeWidth, IpdStanardSizeHeight);
    }
    [self.confirmCreatorBtn setBackgroundImage:[UIImage imageNamed:@"ok"] forState:UIControlStateNormal];
    [self.cancleCreatorBtn setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    [self.cancleCreatorBtn addTarget:self action:@selector(cancleCreatorCantainer:) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmCreatorBtn addTarget:self action:@selector(generateCreatorCamtainer:) forControlEvents:UIControlEventTouchUpInside];
    [self.createCantainer addSubview:self.cancleCreatorBtn];
    [self.createCantainer addSubview:self.confirmCreatorBtn];
    [self.createCantainer setHidden:YES];
   // UILabel *labl
   [self.createCantainer setBackgroundColor:[UIColor lightGrayColor]];
    [self.topViewCantainer addSubview:self.closeQRBtn];
    //[self.closeQRBtn setBackgroundImage:[UIImage imageNamed:@"return"] forState:UIControlStateNormal];
//    UIImageView *menuView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH*2*209/163, CELL_WIDTH*2)];
    UIImageView *menuView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, stanardSizeWidth, stanardSizeHeight)];
    if (IS_IPAD) {
        menuView.frame = CGRectMake(0, 0, IpdStanardSizeWidth, IpdStanardSizeHeight);
    }
    [menuView setCenter:CGPointMake(self.menuBtn.frame.size.width/2, self.menuBtn.frame.size.height/2)];
    [menuView setImage:[UIImage imageNamed:@"return"]];
    [self.closeQRBtn addSubview:menuView];
    [self.closeQRBtn addTarget:self action:@selector(closeQRMode:) forControlEvents:UIControlEventTouchUpInside];
    [self.closeQRBtn setHidden:YES];
    UIImage *image =[UIImage imageNamed:@"overbg"];
    UIGraphicsBeginImageContext(CGSizeMake(imageView.frame.size.width, imageView.frame.size.height));  //scaleSize 为CGSize类型，即你所需要的图片尺寸
    [image drawInRect:CGRectMake(0, 0, imageView.frame.size.width,imageView.frame.size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [imageView setImage:scaledImage];
    [self.createCantainer addSubview:imageView];
    //[self.creatText setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.4]];
    [self.createCantainer addSubview:self.creatText];
    [self.creatText setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self.creatText setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.creatText setFont:[UIFont systemFontOfSize:CELL_WIDTH*1.2]];
    [self.creatText setDelegate:self];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextViewTextDidChangeNotification" object:self.creatText];
    [self.creatText setReturnKeyType:UIReturnKeyDone];
    
    //[self.creatText setBackgroundColor:[UIColor colorWithPatternImage:scaledImage]];
    //[self.creatText set]

}
- (void) cancleCreatorCantainer: (UIButton *)sender
{
    [self.creatText resignFirstResponder];
    [self.menuBtn setHidden:NO];
    [self.cameraSwtitchBtn setHidden:NO];
    [self.createCantainer setHidden:YES];
    [self setScannerMode:SMCamera];
    [self.whitBG setHidden:YES];
    [self.topLable setText:@"Camera Scanner"];
    if (self.availableDeviceType == ACTBoth) {
        [self.cameraSwtitchBtn   setUserInteractionEnabled:YES];
        [self.cameraSwtitchBtn setAlpha:1];
        [self.session  startRunning];
    }
    else if(self.availableDeviceType != ACTNone)
    {
         [self.session  startRunning];
    }
    

}
- (void) generateCreatorCamtainer :(UIButton* )sender
{
     [self.creatText resignFirstResponder];
    if ([self.creatText.text length]) {
        UIImage *image = [QRGenerator qrImageForString:[self.creatText text] imageSize:500.0];
        [self.qrImageView setImage:image];
        if (self.a >= 30 && [[AdmobViewController shareAdmobVC] admob_interstial_ready]) {
            [[AdmobViewController shareAdmobVC] show_admob_interstitial:self];
            [AdmobViewController shareAdmobVC].delegate = self;
        }
        else {
            [self.qrImageView setHidden:NO];
            [self.createCantainer setHidden:YES];
            [self.menuBtn setAlpha:1];
            [self.scannerCantainer setHidden:YES];
            [self.menuBtn setUserInteractionEnabled:YES];
            [self.shareBtn setHidden:NO];
            [self.cameraSwtitchBtn setHidden:YES];
            [self.closeQRBtn setHidden:NO];
        }
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"there is no content to transForm qr Code" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alertView show];
    }
}
-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextView *textView = (UITextView *)obj.object;
    
    NSMutableString *toBeString = [[NSMutableString alloc] initWithString:[textView text]];
    // 简体中文输入，包括简体拼音，健体五笔，简体手写
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    
    if (!position) {
        NSRange range = [textView selectedRange];
 
            //                if (self.section == 1 && (self.row == )) {
            //                //    <#statements#>
            //                }
            if (textView.text.length > 60) {
                
                range.location -= textView.text.length -60;
                range.length +=textView.text.length -60;
                [toBeString deleteCharactersInRange:range];
                NSLog(@"%d,%d,%d",textView.text.length, range.location,range.length);
                //                    for (int i = 0; i< lengthNeedDelete; i++) {
                //                        range.location -= 1;
                //                        range.length = 1;
                //                        [toBeString ins;
                //                    }
                
                NSLog(@"%@",toBeString);
                textView.text = toBeString;
         
            }
        range.length = 0;
        [textView setSelectedRange:range];
        NSLog(@"rangeis %d,%u",range.location,range.length);
    }
    // 有高亮选择的字符串，则暂不对文字进行统计和限制
    else{
        
    }
    
    
    
}
- (void) showCreator: (UIButton *)sender
{
        [self setShoudHideMuneLst:YES];
        [self.menuListCantainer setHidden:YES];
        [self hideView];
        [self changeView];
        [self.menuBtn setHidden:YES];
        [self.cameraSwtitchBtn setHidden:YES];
        
        [self.session stopRunning];
        [self setScannerMode:SMCreator];
        [self.whitBG setHidden:NO];
        [self.createCantainer setHidden:NO];
        [self.topLable setText:@"QR Code Creator"];

}
- (void) showHistory : (UIButton *)sender
{
    [self.session stopRunning];
    [self setShoudHideMuneLst:YES];
    [self changeView];
    [self hideView];
    [self setScannerMode:SMHisTory];
    [self.historyTableView setHidden:NO];
    [self.menuListCantainer setHidden:YES];
    [self.view bringSubviewToFront:self.historyTableView];
    [self.deleteHistoryBtn  setHidden:NO];
    [self.cameraSwtitchBtn setHidden:YES];
    [self.topLable setText:@"History Data"];
//    [self.view insertSubview:self.adview atIndex:0];
    [self.view bringSubviewToFront:self.adview];
    [self.view bringSubviewToFront:self.liuHaiBtmBgview];
    
}
- (void) moveHistoryTableView
{
    [self.historyTableView setCenter:CGPointMake(self.historyTableView.center.x+self.menuListCantainer.frame.size.width,self.historyTableView.center.y)];
}
- (void) resetHistoryTableView
{
    CGRect frame = [[self historyTableView] frame];
    frame.origin.x =0;
    [self.historyTableView setFrame:frame];
}
- (void) showSettings : (UIButton *)sender
{
    
}
//
- (void) getHistoryRecoad
{
    
}
- (CodeType)UrlType : (NSString *)code
{
    NSString *      regex = @"\\s*http(s)?:\\/\\/([a-z0-9A-Z]+\\.)+[a-z0-9A-Z]+(\\/[\\w-@ .\\/?%&=!\\*:]*)?";
    NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    NSString *regex1 =@"http(s)?:\\/\\/([a-z0-9A-Z]+\\.)+[a-z0-9A-Z]+(\\/[\\w-@ .\\/?%&=!\\*:]*)?";
    NSPredicate *   pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
    NSString *regex2 =@"\\s*itms-apps:\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w- .\\/?%&=]*)?";
    NSPredicate *   pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
    NSString *      regex3 = @"[\\s-]+itms-apps:\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w- .\\/?%&=]*)?";
    NSPredicate *   pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex3];
    if ([pred evaluateWithObject:code]||[pred1 evaluateWithObject:code]) {
        return CTWebSite;
    }
    else if ([pred2 evaluateWithObject:code]||[pred3 evaluateWithObject:code]) {
        return CTApplication;
    }
    return  CTText;//[pred evaluateWithObject:code];
}

//

- (void)layoutTableView
{
 [self setHistoryTableView:[[UITableView alloc] initWithFrame:CGRectMake(0, self.topViewCantainer.frame.origin.y+self.topViewCantainer.frame.size.height, WIDTH, HEIGHT - self.topViewCantainer.frame.size.height-self.topViewCantainer.frame.origin.y)] ];

    [self setHistoryTablViewSet:[[HistoryTableViewSet alloc] init]];
    [self.historyTablViewSet setHisData:[self hisData]];
    [self.historyTablViewSet initHistoryArray];
    [self.historyTablViewSet setDelegate:self];
    [self setShoudResaveHistoryData:NO];
    [self setIsEditionMode:YES];
    if ([self.historyTablViewSet.historyArry count] == 0) {
        [self.historyBtn setUserInteractionEnabled:NO];
        [self.historyBtn setAlpha:0.4];
    }
    [self.historyTableView setDataSource:self.historyTablViewSet];
    [self.historyTableView setDelegate:self.historyTablViewSet];
    [self.historyTableView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.historyTableView];
    [self.historyTableView setHidden:YES];
    //[self.historyTableView setCenter:self.view.center];
   // [self.historyTableView setHidden:NO];
}
- (void) moveCamera
{
//    [self.scannerCantainer setCenter:CGPointMake(self.scannerCantainer.center.x + self.menuListCantainer.frame.size.width,self.scannerCantainer.center.y)];
//    CGRect frame = [self.preview frame];
//    frame.origin.x += self.menuListCantainer.frame.size.width;
//    [self.preview setFrame:frame];
}
- (void) resetCamera
{
//    [self.scannerCantainer setCenter:CGPointMake(self.scannerCantainer.center.x - self.menuListCantainer.frame.size.width,self.scannerCantainer.center.y)];
//    CGRect frame = [self.preview frame];
//    frame.origin.x -= self.menuListCantainer.frame.size.width;
//    [self.preview setFrame:frame];
}
- (void) movePDF
{
//    [self moveCamera];
//    CGRect frame = [self.PDFCamtainer frame];
//    frame.origin.x += self.menuListCantainer.frame.size.width;
//    [self.PDFCamtainer setFrame:frame];
}
- (void) resetPDF
{
//    [self resetCamera];
//    CGRect frame = [self.PDFCamtainer frame];
//    frame.origin.x -= self.menuListCantainer.frame.size.width;
//    [self.PDFCamtainer setFrame:frame];
}
- (void) moveAlbum
{
    CGRect frame = [self.albumImageView frame];
    frame.origin.x += self.menuListCantainer.frame.size.width;
   // [self.albumImageView setFrame:frame];

}
- (void)resetAlbum
{
    CGRect frame = [self.albumImageView frame];
    frame.origin.x -= self.menuListCantainer.frame.size.width;
   // [self.albumImageView setFrame:frame];
}
- (void) changeView{
    if (![self shoudHideMuneLst]) {
        switch (self.scannerMode) {
            case SMHisTory:
//                [self moveHistoryTableView];
                [self.menuListCantainer setHidden:NO];
                [self.view bringSubviewToFront:self.menuListCantainer];
                break;
            case SMCamera:
                [self moveCamera];
                break;
            case SMPDFMaker:
                [self movePDF];
                break;
            case SMAlBum:
                [self moveAlbum];
                break;
            case SMCreator:
                [self moveCreator];
                break;
            default:
                break;
        }
    }
    else{
        
        switch (self.scannerMode) {
            case SMHisTory:
//                [self resetHistoryTableView];
                [self.menuListCantainer setHidden:YES];
                break;
            case SMCamera:
                [self resetCamera];
                break;
            case SMPDFMaker:
                [self resetPDF];
                break;
            case SMAlBum:
                [self resetAlbum];
                break;
            case SMCreator:
                [self resetCreator];
                break;
            default:
                break;
        }
    }
}
- (void) moveCreator
{
    CGRect frame = self.whitBG.frame;
    frame.origin.x += self.menuListCantainer.frame.size.width;
    [self.whitBG setFrame:frame];
    frame = self.qrImageView.frame;
    frame.origin.x += self.menuListCantainer.frame.size.width;
    [self.qrImageView setFrame:frame];
}
- (void) resetCreator
{
    CGRect frame = self.whitBG.frame;
    frame.origin.x -= self.menuListCantainer.frame.size.width;
    [self.whitBG setFrame:frame];
    frame = self.qrImageView.frame;
    frame.origin.x -= self.menuListCantainer.frame.size.width;
    [self.qrImageView setFrame:frame];
}
- (void)hideView
{
    switch (self.scannerMode) {
        case SMHisTory:
            [self.historyTableView setHidden:YES];
            [self.deleteHistoryBtn setHidden:YES];
            [self.cameraSwtitchBtn setHidden:NO];
            if (!self.isEditionMode) {
            }
            [self setIsEditionMode:YES];
            break;
        case SMCamera:
            //[self resetCamera];
            break;
        case SMPDFMaker:
            [self.PDFImageArray removeAllObjects];
            [self.PDFCamtainer setHidden:YES];
            break;
        case SMCreator:
            [self.whitBG setHidden:YES];
            [self.qrImageView setHidden:YES];
            [self.shareBtn setHidden:YES];
            [self.cameraSwtitchBtn setHidden:NO];
            [self.closeQRBtn setHidden:YES];
            break;
        default:
            break;
    }
}
- (void) codeView
{
    
}
- (void) codeProcess: (NSString *)code
{
    switch ([self codeType]) {
        case CTWebSite:
            
            break;
            
        default:
            break;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:code]];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isEqual:self.toPDFViewController]) {
        UIViewController *vc = segue.destinationViewController;
        if ([vc respondsToSelector:@selector(setImageArray:)]) {
            [vc setValue:self.PDFImageArray forKey:@"imageArray"];
        }
    }
}
- (void) layoutResultCatainer
{
    UITableView *resultTable;
    UIButton *closeWebCantainer;
    UIView *upLine;
    UIView *downLine;
    //zzx result 20240124 update ui height -40
    if (IS_IPAD) {
        int pianyiy=40;
        self.resultpic= [[UIImageView alloc] initWithFrame:CGRectMake(3.7*CELL_WIDTH, CELL_WIDTH*3.7-pianyiy-10, CELL_WIDTH*2.5*0.6, CELL_WIDTH*2.5*0.6)];
        self.resultCantianer =[[UIView alloc] initWithFrame:CGRectMake(0, self.topViewCantainer.frame.size.height+self.topViewCantainer.frame.origin.y, WIDTH, HEIGHT -( self.topViewCantainer.frame.size.height+self.topViewCantainer.frame.origin.y))];
        self.resultNameLable = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH/2-CELL_WIDTH*20/2,0-20, CELL_WIDTH*20, CELL_WIDTH*2.3)];
        // 20240126  update history result  "text fontsize" -40
        [self.resultNameLable setFont:[UIFont fontWithName:@"Arial" size:CELL_WIDTH*1.7-40]];
        self.resultNumLable = [[TextUpperLeftLabel alloc] initWithFrame:CGRectMake(3.7*CELL_WIDTH+CELL_WIDTH*4*0.6+7, CELL_WIDTH*3.3 -pianyiy, CELL_WIDTH*15.5*0.6, CELL_WIDTH*4.5*0.6)];
        // import // 30 cellheight -30
        resultTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CELL_WIDTH*9*0.8-10-pianyiy-30, WIDTH,self.resultCantianer.frame.size.height - 8*CELL_WIDTH+80)];
        [self.resultNumLable setFont:[UIFont systemFontOfSize:CELL_WIDTH*1.1*0.6]];
    }
    else {
        self.resultpic= [[UIImageView alloc] initWithFrame:CGRectMake(CELL_WIDTH*0.7-4, CELL_WIDTH*3.7, CELL_WIDTH*2.6*1.2, CELL_WIDTH*2.6*1.2)];
        self.resultCantianer =[[UIView alloc] initWithFrame:CGRectMake(0, self.topViewCantainer.frame.size.height+self.topViewCantainer.frame.origin.y, WIDTH, HEIGHT -( self.topViewCantainer.frame.size.height+self.topViewCantainer.frame.origin.y))];
        self.resultNameLable = [[UILabel alloc] initWithFrame:CGRectMake(CELL_WIDTH*5,0, CELL_WIDTH*20, CELL_WIDTH*2.3)];
        [self.resultNameLable setFont:[UIFont fontWithName:@"Arial" size:CELL_WIDTH*1.7]];
        //zzx result 20240124 update ui
       // TextUpperLeftLabel
       // self.resultNumLable = [[UILabel alloc] initWithFrame:CGRectMake(CELL_WIDTH*4, CELL_WIDTH*3.3, CELL_WIDTH*15.5, CELL_WIDTH*4.5)];
        self.resultNumLable = [[TextUpperLeftLabel alloc] initWithFrame:CGRectMake(CELL_WIDTH*4+13, CELL_WIDTH*3.7, CELL_WIDTH*15.5-13, CELL_WIDTH*4.5-5)];
        // import zzx
        resultTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CELL_WIDTH*9-14, WIDTH,self.resultCantianer.frame.size.height - 8*CELL_WIDTH)];
        [self.resultNumLable setFont:[UIFont systemFontOfSize:CELL_WIDTH*1.1]];
    }
    
// zzx closeWebCantainer zzx 2024.0124 16.08
    closeWebCantainer =[[UIButton alloc] initWithFrame:self.menuBtn.frame];
    if (liuhai) {
        closeWebCantainer.frame = CGRectMake(10, 64, stanardSizeWidth, stanardSizeHeight);
    }else{
        closeWebCantainer.frame = CGRectMake(10, self.menuBtn.frame.origin.y, stanardSizeWidth, stanardSizeHeight);
    }
    if (IS_IPAD) {
        closeWebCantainer.frame = CGRectMake(10, self.menuBtn.frame.origin.y, IpdStanardSizeWidth, IpdStanardSizeHeight);
    }
//    closeWebCantainer =[[UIButton alloc] initWithFrame:CGRectMake(10, 0, stanardSizeWidth/2, stanardSizeHeight/2)];
//    [self.closeWebCantainer setCenter:CGPointMake(self.menuBtn.center.x, self.topViewCantainer.center.y  +30 )];
//    menuBtn
    [resultTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ResultTable"];
    self.resultTable = resultTable;
    [self.resultCantianer addSubview:resultTable];
    [self.resultTable setDataSource:self.restTableDelegate];
    [self.resultTable setDelegate:self.restTableDelegate];
    
    upLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.resultNumLable.frame.size.height+self.resultNumLable.frame.origin.y+ 0.2*CELL_WIDTH, WIDTH, 0.4)];
    downLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.resultNumLable.frame.origin.y- 0.2*CELL_WIDTH, WIDTH, 0.3)];
    [upLine setBackgroundColor:[UIColor lightGrayColor]];
    [downLine setBackgroundColor:[UIColor lightGrayColor]];
    if (IS_IPAD) {
        // 20240126 向上偏移 40
        [upLine setFrame:CGRectMake(140, self.resultNumLable.frame.size.height+self.resultNumLable.frame.origin.y+ 0.2*CELL_WIDTH, WIDTH-280, 2)];
        [downLine setFrame:CGRectMake(140, self.resultNumLable.frame.origin.y- 0.2*CELL_WIDTH-5, WIDTH-280, 2)];
//        upLine.backgroundColor =[UIColor blackColor];
//        downLine.backgroundColor =[UIColor blackColor];
    }
    [self.resultCantianer addSubview:upLine];
    [self.resultCantianer addSubview:downLine];
    [self.resultCantianer bringSubviewToFront:upLine];
    [self.resultCantianer bringSubviewToFront:downLine];
 //   [timeLable setTextColor:[UIColor lightGrayColor]];
    
    [self.resultNumLable setTextColor:[UIColor darkGrayColor]];
    [self.resultNameLable setCenter:CGPointMake(self.resultCantianer.center.x, self.resultNameLable.center.y+0.4*CELL_WIDTH)];
    [self.resultNameLable setTextAlignment:NSTextAlignmentCenter];
    [self.resultNumLable setTextAlignment:NSTextAlignmentLeft];
    [self.resultNumLable setNumberOfLines:0];
//    [self.resultNumLable setLineBreakMode:NSLineBreakByCharWrapping];
    [self.resultNumLable setLineBreakMode:NSLineBreakByTruncatingTail];
//    self.resultNumLable = NSLineBreakByTruncatingTail;
    [self.resultCantianer addSubview:self.resultpic];
    [self.resultCantianer addSubview:self.resultNameLable];
    [self.resultCantianer addSubview:self.resultNumLable];
    [self.view addSubview:self.resultCantianer];
    [self.resultCantianer  setBackgroundColor:[UIColor whiteColor]];
    self.webCantainer =[[UIView alloc] initWithFrame :CGRectMake(0, CELL_WIDTH*10, WIDTH,CELL_WIDTH*12)];
//    UITableView *resultTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CELL_WIDTH*7, WIDTH,self.resultCantianer.frame.size.height - 6*CELL_WIDTH)];
//    self.resultTable = resultTable;
//    self.restTableDelegate = [[ResultTableView alloc] init];
//    [self.resultTable setDataSource:self.restTableDelegate];
//    [self.resultTable setDelegate:self.restTableDelegate];
//    [self.resultCantianer addSubview:self.webCantainer];
//    [self.resultCantianer addSubview:resultTable];
    //[self.webCantainer addSubview:self.webViewBtn];s
//    [self.webCantainer setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.4]];
//    [self.webViewBtn setBackgroundImage:[UIImage imageNamed:@"safiri"] forState:UIControlStateNormal];
//    [self.webCantainer addSubview:self.appBtn];
//    [self.appBtn setBackgroundImage:[UIImage imageNamed:@"app"] forState:UIControlStateNormal];
//    [self.webCantainer addSubview:google];
//    [google setBackgroundImage:[UIImage imageNamed:@"google"] forState:UIControlStateNormal];
//    [self.webCantainer addSubview:baidu];
//    [baidu setBackgroundImage:[UIImage imageNamed:@"baidu"] forState:UIControlStateNormal];
//    [self.webCantainer addSubview:amazon];
//    [amazon setBackgroundImage:[UIImage imageNamed:@"amazon"] forState:UIControlStateNormal];
//    [self.webCantainer addSubview:amazon_cn];
//    [amazon_cn setBackgroundImage:[UIImage imageNamed:@"amazon_cn"] forState:UIControlStateNormal];
//    [self.webCantainer addSubview:ebay];
//    [ebay setBackgroundImage:[UIImage imageNamed:@"ebay"] forState:UIControlStateNormal];
//    [self.webCantainer addSubview:taobao];
//    [taobao setBackgroundImage:[UIImage imageNamed:@"tmall"] forState:UIControlStateNormal];
//    [self.webCantainer addSubview:jingdong];
//    [jingdong setBackgroundImage:[UIImage imageNamed:@"jd"] forState:UIControlStateNormal];
//    [self.webCantainer addSubview:bing];
//    [bing setBackgroundImage:[UIImage imageNamed:@"bing"] forState:UIControlStateNormal];
//    [self.webCantainer addSubview:walmart];
//    [walmart setBackgroundImage:[UIImage imageNamed:@"walmart"] forState:UIControlStateNormal];
//    
//    [self.webViewBtn setTag:101];
//    [self.appBtn setTag:102];
//    [google setTag:103];
//    [baidu setTag:104];
//    [amazon setTag:105];
//    [amazon_cn setTag:106];
//    [taobao setTag:107];
//    [ebay setTag:108];
//    [jingdong setTag:109];
//    [bing setTag:110];
//    [walmart setTag:111];
//    [self.webViewBtn addTarget:self action:@selector(toSaferi:) forControlEvents:UIControlEventTouchUpInside];
//     [self.appBtn addTarget:self action:@selector(toSaferi:) forControlEvents:UIControlEventTouchUpInside];
//     [google addTarget:self action:@selector(toSaferi:) forControlEvents:UIControlEventTouchUpInside];
//     [baidu addTarget:self action:@selector(toSaferi:) forControlEvents:UIControlEventTouchUpInside];
//    [amazon_cn addTarget:self action:@selector(toSaferi:) forControlEvents:UIControlEventTouchUpInside];
//    [amazon addTarget:self action:@selector(toSaferi:) forControlEvents:UIControlEventTouchUpInside];
//    [taobao addTarget:self action:@selector(toSaferi:) forControlEvents:UIControlEventTouchUpInside];
//    [ebay addTarget:self action:@selector(toSaferi:) forControlEvents:UIControlEventTouchUpInside];
//    [jingdong addTarget:self action:@selector(toSaferi:) forControlEvents:UIControlEventTouchUpInside];
//    [bing    addTarget:self action:@selector(toSaferi:) forControlEvents:UIControlEventTouchUpInside];
//    [walmart addTarget:self action:@selector(toSaferi:) forControlEvents:UIControlEventTouchUpInside];
//    self.taobao = taobao;
//    self.jingdong = jingdong;
//    self.baidu = baidu;
//    self.google = google;
//    self.ebay = ebay;
//    self.taobao = taobao;
//    self.amazon_cn = amazon_cn;
//    self.amazon = amazon;
//    self.bing =bing;
//    self.walmart =walmart;
    [self.resultCantianer setHidden:YES];
    [self.topViewCantainer addSubview:closeWebCantainer];
    [closeWebCantainer addTarget:self action:@selector(closWebCantainer:) forControlEvents:UIControlEventTouchUpInside];
   // [closeWebCantainer setBackgroundImage:[UIImage imageNamed:@"return"] forState:UIControlStateNormal];
    //  update 20240124 18.25
    UIImageView *menuView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, stanardSizeWidth,stanardSizeHeight-5)];
    if (IS_IPAD) {
        menuView.frame = CGRectMake(0, 0, IpdStanardSizeWidth-5,IpdStanardSizeHeight-5);
    }
    
    [menuView setCenter:CGPointMake(self.menuBtn.frame.size.width/2, self.menuBtn.frame.size.height/2)];
    [menuView setImage:[UIImage imageNamed:@"return"]];
//    [self.baidu setHidden:YES];
    [closeWebCantainer  addSubview:menuView];
    self.closeWebCantainer =closeWebCantainer;
    [self.closeWebCantainer setHidden:YES];
 //   UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:self.baidu.frame];
//    [imageView1 setImage:[UIImage imageNamed:@"baidu"]];
//    [imageView1 setContentMode:UIViewContentModeScaleAspectFill];
//    [imageView1.layer setCornerRadius:0.3*CELL_WIDTH];
//    [imageView1.layer setBorderWidth:2];
//    [imageView1.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
//    [self.webCantainer addSubview:imageView1];
 //   UIImageView * ebView
}
- (void) showResult
{
    [self.view bringSubviewToFront:self.resultCantianer];
    [self.resultCantianer setHidden:NO];
    [self.resultNameLable setText:[self nameType]];
    [self.resultpic setImage:[self imageType]];
    [self.resultNumLable setText:[self code]];
    [self.closeWebCantainer setHidden:NO];
    //    if (self.codeType!= CTWebSite && self.codeType !=CTApplication) {
//        [self.webViewBtn setUserInteractionEnabled:NO];
//        [self.webViewBtn setAlpha:0.4];
//        [self.appBtn setAlpha:0.4];
//        [self.appBtn setUserInteractionEnabled:NO];
//        [self.amazon setUserInteractionEnabled:YES];
//        [self.amazon setAlpha:1];
//        [self.amazon_cn setUserInteractionEnabled:YES];
//        [self.amazon_cn setAlpha:1];
//        [self.baidu setUserInteractionEnabled:YES];
//        [self.baidu setAlpha:1];
//        [self.google setUserInteractionEnabled:YES];
//        [self.google setAlpha:1];
//        [self.jingdong setUserInteractionEnabled:YES];
//        [self.jingdong setAlpha:1];
//        [self.taobao setUserInteractionEnabled:YES];
//        [self.taobao setAlpha:1];
//        [self.ebay setUserInteractionEnabled:YES];
//        [self.ebay setAlpha:1];
//    }
//    else{
//        [self.webViewBtn setUserInteractionEnabled:YES];
//        [self.webViewBtn setAlpha:1];
//        [self.appBtn setAlpha:1];
//        [self.appBtn setUserInteractionEnabled:YES];
//        [self.amazon setUserInteractionEnabled:NO];
//        [self.amazon setAlpha:0.4];
//        [self.amazon_cn setUserInteractionEnabled:NO];
//        [self.amazon_cn setAlpha:0.4];
//        [self.baidu setUserInteractionEnabled:NO];
//        [self.baidu setAlpha:0.4];
//        [self.google setUserInteractionEnabled:NO];
//        [self.google setAlpha:0.4];
//        [self.jingdong setUserInteractionEnabled:NO];
//        [self.jingdong setAlpha:0.4];
//        [self.taobao setUserInteractionEnabled:NO];
//        [self.taobao setAlpha:0.4];
//        [self.ebay setUserInteractionEnabled:NO];
//        [self.ebay setAlpha:0.4];
//    }
   
    
    [self.restTableDelegate setCode:[self code]];
    if (self.codeType == CTWebSite || self.codeType == CTApplication) {
        [self.restTableDelegate setIsWeb:YES];
    }
    else {
        [self.restTableDelegate setIsWeb:NO];
    }
    [self.resultTable reloadData];

    
   // [self.resultCantianer addSubview:self.webCantainer];
   // [self.resultCantianer addSubview:resultTable];
    [self.topLable setText:@"Scan Result"];
    if (!self.shoudHideMuneLst) {
        [self setShoudHideMuneLst:YES];
        [self.menuListCantainer setHidden:YES];
        [self changeView];
        
        if (self.scannerMode != SMHisTory) {
            
            [self setScannerMode:SMCamera];
            if (self.availableDeviceType == ACTBoth) {
                [self.cameraSwtitchBtn setHidden:YES];
                [self.cameraSwtitchBtn setAlpha:1];
                [self.cameraSwtitchBtn setUserInteractionEnabled:YES];
            }
            
            [self.scannerCantainer setHidden:NO];
            
        }
        
    }
    if (self.scannerMode == SMHisTory) {
        [self.topLable setText:@"History Result"];
        [self.deleteHistoryBtn setHidden:YES];
    }
    [self.menuBtn setHidden:YES];
    [self.cameraSwtitchBtn setHidden:YES];
//    if (![self shoudHideMuneLst]) {
//        [self setShoudHideMuneLst:YES];
//        [self changeView];
//    }
}
- (void) closWebCantainer : (UIButton *) sender
{
    [sender setHidden:YES];
    [self.menuBtn setHidden:NO];
   // [self.resultTable removeFromSuperview];
    //[self setResultTable:nil];
    [self.resultCantianer setHidden:YES];
    [self.menuBtn setUserInteractionEnabled:YES];
    [self.menuBtn setAlpha:1];
    if (self.availableDeviceType ==ACTBoth)
    {
        [self.cameraSwtitchBtn setAlpha:1];
        [self.cameraSwtitchBtn setUserInteractionEnabled:YES];
    }
    
    if ([self scannerMode] == SMHisTory) {
        
        [self.topLable setText:@"History Data"];
        [self.deleteHistoryBtn setHidden:NO];
        [self.historyTableView setUserInteractionEnabled:YES];
//        [self.view insertSubview:self.adview atIndex:0];
        [self.view bringSubviewToFront:self.adview];
        [self.view bringSubviewToFront:self.liuHaiBtmBgview];
    }
    else{
        [self setScannerMode:SMCamera];
        [self.topLable setText:@"Camera Scanner"];
        if (self.availableDeviceType == ACTBoth) {
            [self.cameraSwtitchBtn setAlpha:1];
            [self.cameraSwtitchBtn setUserInteractionEnabled:YES];
            [self.cameraSwtitchBtn setHidden:NO];
        }
        
        if (self.availableDeviceType !=ACTNone) {
            [self.session startRunning];
        }
        
        [self.albumImageView setHidden:YES];
    }
}
//- (void) toSaferi:(UIButton *)sender
//{
//    //http://search.jd.com/Search?keyword=手&enc=utf-8&wq=机&pvid=tms9peci.0qiy76
//    //https://www.baidu.com/s?wd=
//    NSString *url;
//    switch (sender.tag) {
//        case 101:
//            
//        case 102:
//            url = self.code;
//            break;
//        case 103:
//            url = [NSString stringWithFormat:@"https://www.google.co.uk/search?q=%@",self.code];
//            break;
//        case 104:
//            url = [NSString stringWithFormat:@"https://www.baidu.com/s?wd=%@",self.code];
//            break;
//        case 105:
//            url = [NSString stringWithFormat:@"http://www.amazon.com/s/ref=nb_sb_noss_2?url=search-alias%%3Daps&field-keywords=%@",self.code];
//            break;
//        case 106:
//            url = [NSString stringWithFormat:@"http://www.amazon.cn/s/%@",self.code];
//            break;
//        case 107:
//            url = [NSString stringWithFormat:@"https://list.tmall.com/search_product.htm?q=%@",self.code];
//            break;
//        case 108:
//            url = [NSString stringWithFormat:@"http://www.ebay.com/sch/%@",self.code];
//            break;
//        case 109:
//            url = [NSString stringWithFormat:@"http://search.jd.com/Search?keyword=%@&enc=utf-8&wq=%@&pvid=tms9peci.0qiy76",self.code,self.code];
//            break;
//        case 110:
//            url = [NSString stringWithFormat:@"bing.com/search?q=%@",self.code];
//            break;
//        case 111:
//            url = [NSString stringWithFormat:@"http://www.walmart.com/search/?query=%@",self.code];
//            break;
//        default:
//            break;
//    }
//    NSLog(@"%@",self.code);
//    [[UIApplication  sharedApplication] openURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
//}
- (UIImage *)imageType
{
    CodeType type = [self codeType];
    switch (type) {
        case CTEAN13Code:
        case CTEAN8Code:
            return [UIImage imageNamed:@"shopping-icon@2x"];
            break;
        case CTWebSite:
            return [UIImage imageNamed:@"safari-icon@2x"];
            break;
        case CTApplication:
            return [UIImage imageNamed:@"apps-icon@2x"];
            break;
        case CTText:
            return [UIImage imageNamed:@"text-icon@2x"];
        default:
            return nil;
            break;
    }
}
- (NSString *) nameType
{
    CodeType type = [self codeType];
    switch (type) {
        case CTEAN8Code:
        case CTEAN13Code:
            return @"Bar Coder";
            break;
        case CTWebSite:
            return @"Web site";
            break;
        case CTApplication:
            return @"application";
            break;
        case CTText:
            return @"Text";
        default:
            return nil;
            break;
    }
}
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if  (alertView.tag == 1003)
    {
        return;
    }
    [self.albumImageView setHidden:YES];
    [self setScannerMode:SMCamera];
    [self.scannerCantainer setHidden:NO];
    [self.topLable setText:@"Camera Scanner"];
    if (self.availableDeviceType == ACTBoth) {
        [self.cameraSwtitchBtn setAlpha:1];
        [self.cameraSwtitchBtn setUserInteractionEnabled:YES];
    }
    if (self.availableDeviceType !=ACTNone) {
        [self.session startRunning];
    }
}
- (void) layoutCreator
{

}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    if ([self scannerMode] == SMAlBum) {
        [self setScannerMode:SMCamera];
        if (self.availableDeviceType ==ACTBoth) {
            [self.cameraSwtitchBtn setAlpha:1];
            [self.cameraSwtitchBtn setUserInteractionEnabled:YES];
        }
        [self.scannerCantainer setHidden:NO];
        [self.topLable setText:@"Camera Scanner"];
    }
    
    if (self.availableDeviceType != ACTNone) {
         [self.session startRunning];
    }
    
}
- (void) showResult:(NSString *)number andType :(NSString *)type atRow:(NSInteger)row
{
//    NSLog(@"%@",number);
    
    [self setCode:[NSMutableString stringWithString:number]];
    if ([type isEqualToString:@"Bar Code"]) {
        [self setCodeType:CTEAN13Code];
    }
    else{
        [self setCodeType:[self UrlType:number]];
    }
    [self.historyTableView setUserInteractionEnabled:NO];
    
    [self showResult];

}
- (void)selectedRow:(NSInteger)row
{
    NSMutableArray *hisData = [self.historyTablViewSet.historyArry objectAtIndex:row];
    if ([self isEditionMode]) {
        [self showResult:(NSString *)[hisData objectAtIndex:1] andType:[hisData objectAtIndex:0] atRow:row];
    }

}
- (void)deletData:(NSMutableArray *)historyArray atRow:(NSInteger)row
{
    
}
- (void) layoutDeleteHistoryDataButton
{
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:self.cameraSwtitchBtn.frame];
    [self.topViewCantainer addSubview:deleteButton];
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(changeDeleteMode:) forControlEvents:UIControlEventTouchUpInside];
    [self setDeleteHistoryBtn:deleteButton];
    [self.deleteHistoryBtn setHidden:YES];

}
- (void) changeDeleteMode : (UIButton *) sender
{
    if ([self isEditionMode]) {
        [self setIsEditionMode:NO];
        [self addDeleteAnimation];
    }
    else {
        [self setIsEditionMode:YES];
        [self removeDeleteAnimation];
    }
}
- (void) addDeleteAnimation
{
    for (UIImageView *imageView in [self.historyTablViewSet imageArray]) {
        [imageView setHidden:NO];
    }
    
}
- (void) reloadTableView
{

    [self.historyTableView reloadData];
    if ([self.historyTablViewSet.historyArry count] == 0 ) {
        [self.historyTableView setHidden:YES];
        [self setScannerMode:SMCamera];
        [self.scannerCantainer setHidden:NO];
        [self.historyBtn setUserInteractionEnabled:NO];
        [self.historyBtn setAlpha:0.4];
        [self.deleteHistoryBtn setHidden:YES];
        [self setIsEditionMode:YES];
        [self.menuBtn setHidden:NO];
        if (self.availableDeviceType != ACTNone) {
            [self.session startRunning];
        }
        if (self.availableDeviceType == ACTBoth) {
            [self.cameraSwtitchBtn setAlpha:1];
            [self.cameraSwtitchBtn setUserInteractionEnabled:YES];
        }
    }
    
}

//- (void) resetHistoryRecordWithType{
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory=[paths objectAtIndex:0];//Documents目录
//    NSString *historyPath = [documentsDirectory stringByAppendingPathComponent:@"path"];
//    BOOL isDir = NO;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL existed = [fileManager fileExistsAtPath:historyPath isDirectory:&isDir];
//    if ( !(isDir == YES && existed == YES) )
//    {
//        [fileManager createDirectoryAtPath:historyPath withIntermediateDirectories:YES attributes:nil error:nil];
//    }
//    NSString *fileName = [historyPath stringByAppendingPathComponent:@"history.txt"];
//    if ([fileManager fileExistsAtPath:fileName isDirectory:nil]) {
//        
//        
//    }
//    else{
//        [fileManager createFileAtPath:fileName contents:nil attributes:nil];
//    }
//   
//   
//    
//    //[history setDate:currentDate];
//   
//     NSMutableArray *array =[self.historyTablViewSet historyArry];
//    if ([array count]) {
//        NSArray *subArray =[array objectAtIndex:[array count]-1];
//        NSString *type = [subArray objectAtIndex:0];
//        NSString *content = [subArray objectAtIndex:1];
//        NSString *currentDate = [subArray objectAtIndex:2];
//        NSString *historyString = [NSString stringWithFormat:@"%@,%@,%@;",type,content,currentDate];
//        NSData *data =[historyString dataUsingEncoding:NSUTF8StringEncoding];
//        [data writeToFile:fileName atomically:YES];
//    }
//    else{
//        NSFileManager *manager = [NSFileManager defaultManager];
//        [manager removeItemAtPath:fileName error:nil];
//        [fileManager createFileAtPath:fileName contents:nil attributes:nil];
//    }
//    
//    //[data writeToFile:fileName atomically:YES];
//    
//    // NSLog(@"%@",imageDir);
//}
- (void) removeDeleteAnimation
{
    for (UIImageView *imageView in [self.historyTablViewSet imageArray]) {
        [imageView setHidden:YES];
    }
}
- (void) viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    [self.timer invalidate];
}
- (void) dealloc
{
    NSLog(@"sdd");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:nil];
}
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    return YES;
}

- (void) initAd
{
    /*
    if (IS_IPAD) {
        [self.adView addAds:self.view rootVc:self atPoint:CGPointMake(self.view.center.x, HEIGHT -45)];
    }
    else {
         [self.adView addAds:self.view rootVc:self atPoint:CGPointMake(self.view.center.x, HEIGHT - 25)];
    }
     */
    [self.timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCount) userInfo:nil repeats:YES];
//    [self setA:0];
}

- (void)adMobVCWillCloseInterstitialAd:(AdmobViewController *)adMobVC
{
    if (self.scannerMode == SMCamera||self.scannerMode == SMAlBum) {
        [self showResult];
    }
    else if (self.scannerMode  == SMCreator)
    {
        [self.qrImageView setHidden:NO];
        [self.createCantainer setHidden:YES];
        [self.menuBtn setAlpha:1];
        [self.scannerCantainer setHidden:YES];
        [self.menuBtn setUserInteractionEnabled:YES];
        [self.shareBtn setHidden:NO];
        [self.cameraSwtitchBtn setHidden:YES];
        [self.closeQRBtn setHidden:NO];
    }
    [self setA:0];
    //
    [AdmobViewController shareAdmobVC].delegate = nil;
}

- (void)timeCount
{
    NSLog(@"%d",self.a );
    self.a++;
    if (self.a == 30) {
        NSLog(@"ready");
    }
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self scannerMode] == SMCreator) {
        [self.creatText resignFirstResponder];
    }
}
- (void) moveView : (UIButton *)sender
{
    if (!self.shoudHideMuneLst)
    {
        [self changeMenuListCantainer:self.menuBtn];
    }

}
- (void) shareQRCode:(UIButton *)sender
{
    NSArray *ddad = [[NSArray alloc] initWithObjects:self.qrImageView.image, nil];
    if (self.qrImageView.image == nil) {
        NSLog(@"sddd");
    }
    UIActivityViewController *shareView = [[UIActivityViewController alloc] initWithActivityItems:ddad applicationActivities:nil];
    //shareVi
    if ( [shareView respondsToSelector:@selector(popoverPresentationController)]&& IS_IPAD ) {
        // iOS8
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:shareView];
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height*2/3, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self presentViewController:shareView animated:YES completion:nil];
    }
  
}
- (void) closeQRMode : (UIButton *)sender
{
    if (self.availableDeviceType != ACTNone) {
        [self.session startRunning];
    }
    [self.menuBtn setHidden:NO];
    [self.topLable setText:@"Camera Scanner"];
    [self.scannerCantainer setHidden:NO];
    [self setShoudHideMuneLst:YES];
    [self.menuListCantainer setHidden:YES];
    [self hideView];
    [self setScannerMode:SMCamera];
    if (self.availableDeviceType == ACTBoth) {
        [self.cameraSwtitchBtn setAlpha:1];
        [self.cameraSwtitchBtn setUserInteractionEnabled:YES];
        [self.cameraSwtitchBtn setHidden:NO];
        
    }
}

- (void)openAppWithId:(NSString *)_appId viewCtrl:(UIViewController*) viewCtrl
{
    Class storeVC = NSClassFromString(@"SKStoreProductViewController");
    if (storeVC != nil)
    {
        SKStoreProductViewController *_SKSVC = [[SKStoreProductViewController alloc] init];
        _SKSVC.delegate = self;
        [_SKSVC loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: _appId}
                          completionBlock:^(BOOL result, NSError *error) {
                          }];
        [viewCtrl presentViewController:_SKSVC animated:YES completion:nil];
    }
    else
    {
        //低于iOS6没有这个类
        NSString *_idStr = [NSString stringWithFormat:@"http://baidu.com"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_idStr]];
    }
}
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)isNotchScreen {
    
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets;
        if (safeAreaInsets.left>0) {
            NSLog(@"这是safeAreaInsets.left>0屏");
            return YES;
        }
        if (safeAreaInsets.right>0) {
            NSLog(@"这是safeAreaInsets.right>0屏");
            return YES;
        }
        if (safeAreaInsets.bottom>0) {
            NSLog(@"这是safeAreaInsets.bottom>0屏");
            return YES;
        }
        if (safeAreaInsets.top > 0) {
            // 是刘海屏
            NSLog(@"这是刘海屏");
            return YES;
        }
    }
    NSLog(@"zzx have not hair");
    return NO;
}


@end
