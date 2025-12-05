 //
//  PDFViewController.m
//  QRReader
//
//  Created by awt on 15/7/26.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import "PDFViewController.h"
#import "Config.h"
#import "CommonEmun.h"
#import "PDFGenerator.h"
#import "PDFData.h"
#import "PDFDataSet.h"
#import "Admob.h"
#include "ApplovinMaxWrapper.h"
@import WebKit;

@interface ShowPDFViewController () <UIAlertViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,PDFDataSetDelegate,AdmobViewControllerDelegate>
@property (nonatomic,strong) NSMutableArray *cellArray;
@property (nonatomic,strong) NSMutableArray *imagVewArray;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIView *topViewCaitner;
@property (nonatomic,strong) UIView *generateViewCantainer;
@property (nonatomic,strong) UILabel *nameLable;
@property (nonatomic,strong) UILabel *sizeLable;
@property (nonatomic,strong) UIButton *sizeBtn;
@property (nonatomic,strong) UITableView *sizeTableView;
@property (nonatomic,strong) UITextField *nameText;
@property (nonatomic,strong) UIButton *addNewImageBtn;
@property (nonatomic,strong) UIButton *returnBtn;
@property (nonatomic,strong) UIButton *editionBtn;
@property (nonatomic,strong) UIButton *deletImageBtn;
@property (nonatomic,strong) UIButton *generatePDFBtn;
@property (nonatomic,strong) UIImageView *tableviwImage;
@property (nonatomic,strong) UIButton *cancleBtn;
@property (nonatomic,strong) UIButton *confirmBtn;
@property PDFEditionMode editionMode;
@property (nonatomic,strong) NSTimer *aw;
@property (nonatomic,strong) NSMutableArray *editionGestureArray;
@property (nonatomic,strong) NSMutableArray *secletedArray;
@property (nonatomic,strong) NSMutableArray *sizeArray;
@property BOOL isExchange;
@property BOOL isSizeChoice;
@property NSInteger sizeType;
@property NSInteger lineNumber;
@property (nonatomic,strong) UIButton *historyBtn;
@property (nonatomic,strong) UICollectionView *hisToryView;
@property (nonatomic,strong) UIButton *deletHistoryBtn;
@property BOOL isHistoryDeleMode;
@property (nonatomic,strong) WKWebView *pdfView;
@property (nonatomic,strong) UIButton *closePDFViewBtn;
@property (nonatomic,strong) UIView *bgGray;
//@property (nonatomic,strong) PDFData *hisData;
@property (nonatomic,strong) PDFDataSet *hisDataSet;
@property NSInteger historyCount;
@property BOOL shoulDisabledEditbtn;
@property BOOL shouldDisabledHistoryBtn;

@property (strong,nonatomic) NSString *fileName;

@property (nonatomic, strong) UIView* adview;
@property (nonatomic, strong) UIView* liuHaiBtmBgview;
@end

BOOL liuhaiScreen;

@implementation ShowPDFViewController

- (void)viewDidLoad {
    liuhaiScreen = [self isNotchScreen] && kScreenHeight >811;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [super viewDidLoad];
   // [self setImageArray:setim]3
    self.cellArray = [[NSMutableArray alloc]init];
    self.secletedArray  = [[NSMutableArray alloc] init];
    self.imagVewArray = [[NSMutableArray alloc] init];
    [self setEditionMode:EMNone];
    self.editionGestureArray = [[NSMutableArray alloc] init];
    // test1 20240126 zzx
    for (int i =0; i<[self.imageArray count]; i++) {
        UIGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(changelocation:)];
        [self.editionGestureArray addObject:gesture];
    }
   
//    for (UIImage *image in [self imageArray]) {
//        UIImageView *imageView =[[UIImageView alloc] initWithFrame:self.view.frame];
//        [self.view addSubview:imageView];
//        [self.imageViewArray  addObject:imageView];
//        [imageView setImage:image];
//        
//    }
    [self layoutTopViewCantainer];
    [self layoutCollectionView];
    [self layoutGeneraetView];
    [self layoutHisToryView];
    [self enadledUserIntefaceExcpet];
    [self initAd];
   // self.aw = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showimage) userInfo:nil repeats:YES];
    // Do any additional setup after loading the view.
}

- (void) layoutHisToryView
{
    self.pdfView = [[WKWebView alloc] initWithFrame:CGRectMake(CELL_WIDTH*2, self.topViewCaitner.frame.size.height+self.topViewCaitner.frame.origin.y +2*CELL_WIDTH, CELL_WIDTH*16, CELL_WIDTH*16*1.22)];
    self.closePDFViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(CELL_WIDTH*17, self.topViewCaitner.frame.size.height+self.topViewCaitner.frame.origin.y +0.5*CELL_WIDTH, CELL_WIDTH*2*203/163, CELL_WIDTH*2)];
    [self.closePDFViewBtn setImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    [self.closePDFViewBtn addTarget:self action:@selector(hidePdfView:) forControlEvents:UIControlEventTouchUpInside];
    [self.closePDFViewBtn setHidden:YES];
        [self.pdfView setHidden:YES];
    self.hisDataSet = [[PDFDataSet alloc] init];
     [self loadHisData];
    [self.hisDataSet setupData];
    [self.hisDataSet setDelegate:self];  
    UICollectionViewFlowLayout *layout =[[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    //[layout setItemSize:CGSizeMake(CELL_WIDTH*5, CELL_WIDTH*5)];
    [layout setMinimumInteritemSpacing:0];
    [layout setMinimumLineSpacing:0];
    self.hisToryView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.topViewCaitner.frame.size.height+self.topViewCaitner.frame.origin.y, WIDTH, (HEIGHT - self.topViewCaitner.frame.size.height-self.topViewCaitner.frame.origin.y)) collectionViewLayout:layout];
    [self.hisToryView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"historyData"];
    [self.hisToryView setBackgroundColor:[UIColor lightGrayColor]];
    [self.hisToryView setDataSource:self.hisDataSet];
    [self.hisToryView setDelegate:self.hisDataSet];
    [self.view addSubview:self.hisToryView];
    [self.hisToryView setHidden:YES];
    [self.bgGray setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:self.bgGray];
    [self.view addSubview:self.closePDFViewBtn];
    [self.view addSubview:self.pdfView];

}

-(void) hidePdfView : (UIButton *)sender
{
    [self.pdfView setHidden:YES];
    [self.bgGray setHidden:YES];
    [self.closePDFViewBtn setHidden:YES];
    
    if([self editionMode] != EmHistory) {
        [self historyEdite:sender];
    }
}
- (void) loadHisData
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
        NSString *fileName = [historyPath stringByAppendingPathComponent:@"pdfHistory.txt"];
        
        if ([fileManager fileExistsAtPath:fileName isDirectory:nil]) {
            
        }
        else{
            [fileManager createFileAtPath:fileName contents:nil attributes:nil];
            [self.hisDataSet setHisData:[[PDFData alloc] init]];
            [self.hisDataSet.hisData setCount:[NSNumber numberWithInteger:0]];
            [self.hisDataSet.hisData setBookArray:[[NSMutableArray alloc] init]];
            return;
        }
    [self.hisDataSet setHisData:[NSKeyedUnarchiver unarchiveObjectWithFile:fileName] ];
    if ([self.hisDataSet hisData] == nil) {
        [self.hisDataSet setHisData:[[PDFData alloc] init]];
        [self.hisDataSet.hisData setCount:[NSNumber numberWithInteger:0]];
        [self.hisDataSet.hisData setBookArray:[[NSMutableArray alloc] init]];
    }
}

- (void) layoutTopViewCantainer
{//zzx 20240123 update ipd btnsize

    if (IS_IPAD) {
        CGFloat pianyix = 50;
        CGFloat pianyiy = 25;
        self.topViewCaitner = [[UIView alloc] initWithFrame:CGRectMake(0, pianyiy, WIDTH, CELL_WIDTH *3-pianyiy)];
        
        self.returnBtn  = [[UIButton alloc] initWithFrame:CGRectMake(0.5*CELL_WIDTH + pianyix, CELL_WIDTH*0.5, IpdStanardSizeWidth, IpdStanardSizeHeight)];
        self.editionBtn = [[UIButton alloc] initWithFrame:CGRectMake(CELL_WIDTH*4.5 + pianyix, CELL_WIDTH*0.5, IpdStanardSizeWidth, IpdStanardSizeHeight)];
        self.deletImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(CELL_WIDTH*8.5 + pianyix, CELL_WIDTH*0.5, IpdStanardSizeWidth, IpdStanardSizeHeight)];
        self.generatePDFBtn = [[UIButton alloc] initWithFrame:CGRectMake(CELL_WIDTH* 12 + pianyix, CELL_WIDTH *0.5, IpdStanardSizeWidth, IpdStanardSizeHeight)];
        self.historyBtn = [[UIButton alloc] initWithFrame:CGRectMake(CELL_WIDTH* 15.5 + pianyix, CELL_WIDTH *0.5+pianyiy, IpdStanardSizeWidth, IpdStanardSizeHeight)];
    }
    else {
        CGFloat liuhaiSizeWidth = stanardSizeWidth;
        CGFloat liuhaiSizeHeight = stanardSizeHeight;
        CGFloat liuhaiTop = liuhaiScreen ? 54 : 20;
        CGFloat pianyix=liuhaiScreen ? 11 : 9;
        CGFloat liuhaiHeight = liuhaiScreen ? CELL_WIDTH *4-20 : CELL_WIDTH *4-25;
        self.topViewCaitner = [[UIView alloc] initWithFrame:CGRectMake(0, liuhaiTop, WIDTH,  liuhaiHeight)];
        self.returnBtn  = [[UIButton alloc] initWithFrame:CGRectMake(0.5*CELL_WIDTH+pianyix, CELL_WIDTH*0.5, liuhaiSizeWidth, liuhaiSizeHeight)];
        self.editionBtn = [[UIButton alloc] initWithFrame:CGRectMake(CELL_WIDTH*4.5+pianyix, CELL_WIDTH*0.5,liuhaiSizeWidth, liuhaiSizeHeight)];
        self.deletImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(CELL_WIDTH*8.5+pianyix, CELL_WIDTH*0.5, liuhaiSizeWidth, liuhaiSizeHeight)];
        self.generatePDFBtn = [[UIButton alloc] initWithFrame:CGRectMake(CELL_WIDTH* 12.5 +pianyix, CELL_WIDTH *0.5, liuhaiSizeWidth, liuhaiSizeHeight)];
        self.historyBtn = [[UIButton alloc] initWithFrame:CGRectMake(CELL_WIDTH* 16.5+pianyix, CELL_WIDTH *0.5+liuhaiTop,liuhaiSizeWidth, liuhaiSizeHeight)];
    }
    self.bgGray = [[UIView alloc] initWithFrame:CGRectMake(0,self.topViewCaitner.frame.size.height+self.topViewCaitner.frame.origin.y, WIDTH, HEIGHT - (self.topViewCaitner.frame.size.height+self.topViewCaitner.frame.origin.y))];
    [self.view addSubview:self.topViewCaitner];
    
    [self.bgGray setHidden:YES];
    self.deletHistoryBtn = [[UIButton alloc] initWithFrame:self.deletImageBtn.frame];
    if (!IS_IPAD) {
        CGFloat liuhaiTop = liuhaiScreen ? 54 : 20;
        CGFloat pianyix=liuhaiScreen ? 11 : 9;
        self.deletHistoryBtn =  [[UIButton alloc] initWithFrame:CGRectMake(CELL_WIDTH*8.5+pianyix, CELL_WIDTH*0.5+liuhaiTop, stanardSizeWidth, stanardSizeHeight)];
    }
    [self.deletHistoryBtn setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [self.deletHistoryBtn addTarget:self action:@selector(deleteHisData:) forControlEvents:UIControlEventTouchUpInside];
    [self.deletHistoryBtn setHidden:YES];
    [self.view addSubview:self.deletHistoryBtn];
    [self.historyBtn setBackgroundImage:[UIImage imageNamed:@"history1.png"] forState:UIControlStateNormal];
    [self.historyBtn addTarget:self action:@selector(historyEdite:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.historyBtn];
    [self.generatePDFBtn setBackgroundImage:[UIImage imageNamed:@"creator"] forState:UIControlStateNormal];
    [self.generatePDFBtn addTarget:self action:@selector(generatePDFFile:) forControlEvents:UIControlEventTouchUpInside];
    [self.topViewCaitner addSubview:self.generatePDFBtn];
    [self.deletImageBtn setBackgroundImage:[UIImage imageNamed:@"delete1"] forState:UIControlStateNormal];
    [self.deletImageBtn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.topViewCaitner addSubview:self.deletImageBtn];
    [self.editionBtn setBackgroundImage:[UIImage imageNamed:@"edition"] forState:UIControlStateNormal];
    [self.editionBtn addTarget:self action:@selector(editePDF:) forControlEvents:UIControlEventTouchUpInside];
    [self.topViewCaitner addSubview:self.editionBtn];
    UIImageView *imagIView = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_WIDTH* 15.5, CELL_WIDTH *0.5, CELL_WIDTH*2.2*209/163, CELL_WIDTH*2.2)];
    [imagIView setCenter:CGPointMake(self.returnBtn.frame.size.width/2, self.returnBtn.frame.size.height/2)];
    
    [self.returnBtn setImage:[UIImage imageNamed:@"return"] forState:UIControlStateNormal];
    [self.returnBtn addTarget:self action:@selector(backView:) forControlEvents:UIControlEventTouchUpInside];
    [self.topViewCaitner addSubview:self.returnBtn];

    
}
- (void) layoutGeneraetView
{
    [self setIsSizeChoice:NO];
    [self setSizeType:0];
    UIView *nameView ;
    UIView *buttumCanTainer;
    if (IS_IPAD) {
        self.generateViewCantainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH*15*0.6, CELL_WIDTH*10.5*0.6)];
        
        nameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH*15*0.6, CELL_WIDTH*4*0.6)];
        buttumCanTainer = [[UIView alloc] initWithFrame:CGRectMake(0, 7.3*CELL_WIDTH*0.6, CELL_WIDTH*15*0.6, CELL_WIDTH*3.2*0.6)];
        self.nameLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH*6*0.6, CELL_WIDTH*3*0.6)];
        [nameView addSubview:self.nameLable];
        [nameView setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0.8 alpha:0.3]];
        [self.nameLable setFont:[UIFont systemFontOfSize:CELL_WIDTH*1.6*0.6]];
        self.nameText = [[UITextField alloc] initWithFrame:CGRectMake(CELL_WIDTH*4.8*0.6, 0, CELL_WIDTH*10*0.6, CELL_WIDTH*2.3*0.6)];
        [self.nameText.layer setCornerRadius:CELL_WIDTH*0.5];
        [self.nameText setFont:[UIFont fontWithName:@"arial" size:CELL_WIDTH*1.2*0.6]];
        [self.nameText setTextColor:[UIColor darkGrayColor]];
        [self.nameLable setCenter:CGPointMake(self.nameLable.center.x, nameView.center.y)];
        [self.nameText setCenter:CGPointMake(self.nameText.center.x, self.nameLable.center.y)];
        self.confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(buttumCanTainer.center.x- CELL_WIDTH*5*0.6, 0, buttumCanTainer.frame.size.height*209/163, buttumCanTainer.frame.size.height)];
        self.cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(buttumCanTainer.center.x+ CELL_WIDTH*1*0.6, 0, buttumCanTainer.frame.size.height*209/163, buttumCanTainer.frame.size.height)];
        [nameView addSubview:self.nameText];
        self.sizeTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.center.x-2.7*CELL_WIDTH*0.6, self.view.center.y-0.7*CELL_WIDTH*0.6, CELL_WIDTH*10*0.6, CELL_WIDTH*2.3*0.6)];
        self.tableviwImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.sizeTableView.frame.size.width -2*CELL_WIDTH*0.6, CELL_WIDTH*0.1*0.6, 2*CELL_WIDTH*203/163*0.6, 2*CELL_WIDTH*0.6)];
         self.sizeLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 4*CELL_WIDTH*0.6, CELL_WIDTH*6*0.6, CELL_WIDTH*3*0.6)];
        [self.sizeLable setFont:[UIFont systemFontOfSize:CELL_WIDTH*1.6*0.6]];
    }
    else{
        self.generateViewCantainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH*15, CELL_WIDTH*10.5)];
        
        nameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH*15, CELL_WIDTH*4)];
        buttumCanTainer = [[UIView alloc] initWithFrame:CGRectMake(0, 7.3*CELL_WIDTH, CELL_WIDTH*15, CELL_WIDTH*3.2)];
        self.nameLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH*6, CELL_WIDTH*3)];
        [nameView addSubview:self.nameLable];
        [nameView setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0.8 alpha:0.3]];
        [self.nameLable setFont:[UIFont systemFontOfSize:CELL_WIDTH*1.6]];
        self.nameText = [[UITextField alloc] initWithFrame:CGRectMake(CELL_WIDTH*4.8, 0, CELL_WIDTH*10, CELL_WIDTH*2.3)];
        [self.nameText.layer setCornerRadius:CELL_WIDTH*0.5];
        [self.nameText setFont:[UIFont fontWithName:@"arial" size:CELL_WIDTH*1.2]];
        [self.nameText setTextColor:[UIColor darkGrayColor]];
        [self.nameLable setCenter:CGPointMake(self.nameLable.center.x, nameView.center.y)];
        [self.nameText setCenter:CGPointMake(self.nameText.center.x, self.nameLable.center.y)];
        self.confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(buttumCanTainer.center.x- CELL_WIDTH*5, 0, buttumCanTainer.frame.size.height*209/163, buttumCanTainer.frame.size.height)];
        self.cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(buttumCanTainer.center.x+ CELL_WIDTH*1, 0, buttumCanTainer.frame.size.height*209/163, buttumCanTainer.frame.size.height)];
        [nameView addSubview:self.nameText];
        self.sizeTableView = [[UITableView alloc] initWithFrame:CGRectMake(CELL_WIDTH*7.4, self.view.center.y-0.7*CELL_WIDTH, CELL_WIDTH*10, CELL_WIDTH*2.3)];
        self.tableviwImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.sizeTableView.frame.size.width -2*CELL_WIDTH, CELL_WIDTH*0.1, 2*CELL_WIDTH*203/163, 2*CELL_WIDTH)];
         self.sizeLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 4*CELL_WIDTH, CELL_WIDTH*6, CELL_WIDTH*3)];
        [self.sizeLable setFont:[UIFont systemFontOfSize:CELL_WIDTH*1.6]];
    }
    [self.generateViewCantainer setCenter:self.view.center];
    [self.generateViewCantainer setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.generateViewCantainer];
    
    //[nameView.layer setBorderColor:[[UIColor blueColor] CGColor]];
    [nameView.layer setCornerRadius:0.4*CELL_WIDTH];
   // [nameView setAlpha:0.5];
    [self.generateViewCantainer.layer setCornerRadius:CELL_WIDTH*0.5];
    [self.nameText setKeyboardType:UIKeyboardTypeASCIICapable];
    [self.nameText setDelegate:self];
    [self.nameLable setText:@"Name:"];
    [self.nameText setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.nameLable.layer setCornerRadius:CELL_WIDTH*0.6];
    //[self.nameLable.layer setBorderWidth:CELL_WIDTH*0.01];
    [self.nameText setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    //[self.nameLable.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.nameLable setAdjustsFontSizeToFitWidth:YES];
    [self.nameLable setTintAdjustmentMode:UIViewTintAdjustmentModeAutomatic];
    [self.nameText setBackgroundColor:[UIColor whiteColor]];
    [self.generateViewCantainer addSubview:nameView];
    //self.sizeLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 4*CELL_WIDTH, CELL_WIDTH*6, CELL_WIDTH*3)];
    [self.generateViewCantainer addSubview:self.sizeLable];
    [self.sizeLable setText:@"Size:"];
    
    [self.sizeLable.layer setCornerRadius:CELL_WIDTH*0.6];
    [self.sizeLable.layer setBorderWidth:CELL_WIDTH*0.01];
    [self.sizeLable.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.sizeLable setAdjustsFontSizeToFitWidth:YES];
    [self.sizeLable setTintAdjustmentMode:UIViewTintAdjustmentModeAutomatic];
    [buttumCanTainer.layer setCornerRadius:CELL_WIDTH*0.5];
    [self createSizeArray];
    [self.view addSubview:self.sizeTableView];
    [self.sizeTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Albumnlist"];
    [self.sizeTableView setDataSource:self];
    [self.sizeTableView setDelegate:self];
    [self.sizeTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.sizeTableView setBackgroundColor:[UIColor whiteColor]];
   
    [self.tableviwImage setImage:[UIImage imageNamed:@"rightAngle"]];
    [self.sizeTableView addSubview:self.tableviwImage];
    [buttumCanTainer setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0.8 alpha:0.8]];
    [self.generateViewCantainer addSubview:buttumCanTainer];
    [buttumCanTainer addSubview:self.cancleBtn];
    [buttumCanTainer addSubview:self.confirmBtn];
    [self.cancleBtn setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    [self.confirmBtn setBackgroundImage:[UIImage imageNamed:@"ok"] forState:UIControlStateNormal];
    [self.confirmBtn addTarget:self action:@selector(confirmGenerate:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancleBtn addTarget:self action:@selector(cancleGenerate:) forControlEvents:UIControlEventTouchUpInside];
       // [self.generateViewCantainer addSubview:[]]
    [self.sizeTableView setHidden:YES];
    [self.generateViewCantainer setHidden:YES];
}
- (void) confirmGenerate : (id)sender
{
    [self.nameText resignFirstResponder];

    NSString *fileName = [NSString stringWithFormat:@"%@.pdf", self.nameText.text];
    if ([self.nameText.text length] == 0||[self.nameText clearsOnBeginEditing]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"file name is empty,cann't save" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    else if ([self checkFile:fileName])
    {
       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"file name has existed,cann't save" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    [self.collectionView setUserInteractionEnabled:YES];
    [self.hisDataSet.hisData.bookArray addObject:fileName];
    NSInteger count = [self.hisDataSet.hisData.count integerValue];
    count++;
    [self.hisDataSet.hisData setCount:[NSNumber numberWithInteger:count]];
    NSLog(@"his %d,%d",[self.hisDataSet.hisData.count integerValue],count);
    [self saveHisData];
    [self.hisDataSet cleanData];
    [self.hisToryView reloadData];
    [self ctreatPDF:fileName atSize:[self fileSize]];
}

- (void) saveHisData
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
    NSString *fileName = [historyPath stringByAppendingPathComponent:@"pdfHistory.txt"];
    
    if ([fileManager fileExistsAtPath:fileName isDirectory:nil]) {
        
    }
    else{
        [fileManager createFileAtPath:fileName contents:nil attributes:nil];
    }
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.hisDataSet.hisData];
    [data writeToFile:fileName atomically:YES];
}

- (CGSize)fileSize
{
    CGSize paperSize;
    switch (self.sizeType) {
        case 0:
            paperSize =CGSizeMake(1487, 2105);
            break;
        case 1:
            paperSize =CGSizeMake(2105, 2105.0*42.0/29.7);
            break;
        case 2:
            paperSize =CGSizeMake(2105.0*14.5/29.7, 2105.0*21.0/29.7);
            break;
        case 3:
            paperSize =CGSizeMake(2105.0*25.0/29.7, 2105.0*35.3/29.7);
            break;
        case 4:
            paperSize =CGSizeMake(2105.0*17.6/29.7, 2105.0*25.0/29.7);
            break;
        default:
            break;
    }
    return paperSize;
}

- (void)cancleGenerate : (id)sender
{
    [self.collectionView setUserInteractionEnabled:YES];
    [self.generateViewCantainer setHidden:YES];
    [self.sizeTableView setHidden:YES];
    [self enadledUserIntefaceExcpet];
     [self.nameText resignFirstResponder];
}
- (void) refreshTableView
{
    CGRect frame = self.sizeTableView.frame;
    if ([self isSizeChoice]) {
        frame.size.height += 9.2*CELL_WIDTH;
        self.tableviwImage.transform = CGAffineTransformMakeRotation(M_PI/2);
        [self.cancleBtn setUserInteractionEnabled:NO];
        [self.confirmBtn setUserInteractionEnabled:NO];
    }
    else{
        frame.size.height -=9.2*CELL_WIDTH;
        self.tableviwImage.transform = CGAffineTransformMakeRotation(0);
        [self.confirmBtn setUserInteractionEnabled:YES];
        [self.cancleBtn setUserInteractionEnabled:YES];
    }
    [self.sizeTableView setFrame:frame];
}

- (void) generatePDFFile : (id)sender
{
    [self disadledUserIntefaceExcpet:sender];
    [self showGenerateView];
    [self.collectionView setUserInteractionEnabled:NO];
    
}

- (void) historyEdite : (id)sender
{
    if ([self editionMode] == EmHistory) {
        [self setEditionMode:EMNone];
        [self enadledUserIntefaceExcpet];
        [self.deletHistoryBtn setHidden:YES];
        [self.hisToryView setHidden:YES];
    }
    else{
        [self disadledUserIntefaceExcpet:sender];
        [self.deletHistoryBtn setHidden:NO];
        [self.hisToryView setHidden:NO];
        [self setEditionMode:EmHistory];
        [self.returnBtn setAlpha:1];
        [self.returnBtn setUserInteractionEnabled:YES];
        
    }
}

- (void)deleteImage:(id)sender
{
    if(self.editionMode == EMDelete)
    {
        [self setEditionMode:EMNone];
        [self stopAnimation];
        [self removeCell];
        [self enadledUserIntefaceExcpet];
    }
    else {
        [self setEditionMode:EMDelete];
        [self addAnimation];
        [self.collectionView setUserInteractionEnabled:YES];
        [self disadledUserIntefaceExcpet:sender];
    }
   
}
- (void) disadledUserIntefaceExcpet : (UIButton*)button;
{
    [self.editionBtn setUserInteractionEnabled:NO];
    [self.returnBtn setUserInteractionEnabled:NO];
    [self.deletImageBtn setUserInteractionEnabled:NO];
    [self.generatePDFBtn setUserInteractionEnabled:NO];
    [self.historyBtn setUserInteractionEnabled:NO];
    [self.historyBtn setAlpha:0.4];
    [self.editionBtn setAlpha:0.4];
    [self.returnBtn setAlpha:0.4];
    [self.deletImageBtn setAlpha:0.4];
    [self.generatePDFBtn setAlpha:0.4];
    [button setUserInteractionEnabled:YES];
    [button setAlpha:1];
}
- (void) enadledUserIntefaceExcpet
{
    [self.editionBtn setUserInteractionEnabled:YES];
    [self.returnBtn setUserInteractionEnabled:YES];
    [self.deletImageBtn setUserInteractionEnabled:YES];
    [self.generatePDFBtn setUserInteractionEnabled:YES];
    [self.historyBtn setUserInteractionEnabled:YES];
    [self.historyBtn setAlpha:1];
    [self.editionBtn setAlpha:1];
    [self.returnBtn setAlpha:1];
    [self.deletImageBtn setAlpha:1];
    [self.generatePDFBtn setAlpha:1];
    if ([self.imageArray count] == 0) {
        [self.editionBtn setUserInteractionEnabled:NO];
        [self.deletImageBtn setUserInteractionEnabled:NO];
        [self.generatePDFBtn setUserInteractionEnabled:NO];
        [self.editionBtn setAlpha:0.4];
        [self.generatePDFBtn setAlpha:0.4];
        [self.deletImageBtn setAlpha:0.4];
    }
    if ([self.hisDataSet.hisData.count integerValue] == 0) {
        [self.historyBtn setAlpha:0.4];
        [self.historyBtn setUserInteractionEnabled:NO];
    }
}
- (void)editePDF : (UIButton *)sender
{
    if (self.editionMode ==EMINsert) {
        [self enadledUserIntefaceExcpet];
        [self.collectionView setUserInteractionEnabled:NO];
        for (UICollectionViewCell *cell in [self cellArray]) {
            [cell removeGestureRecognizer:[self.editionGestureArray objectAtIndex:[self.cellArray indexOfObject:cell]]];
        }
        [self stopAnimation];
        [self setEditionMode:EMNone];
    }
    else
    {
        [self setEditionMode:EMINsert];
        [self disadledUserIntefaceExcpet:sender];
        [self.collectionView setUserInteractionEnabled:YES];
        int i =0;
        [self addAnimation];
        for (UICollectionViewCell *cell in [self cellArray]) {
            [cell addGestureRecognizer:[self.editionGestureArray objectAtIndex:i]];
            i++;
        }
    }
    
    
}
- (void) layoutCollectionView
{
    UICollectionViewFlowLayout *layout =[[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    //[layout setItemSize:CGSizeMake(CELL_WIDTH*5, CELL_WIDTH*5)];
    [layout setMinimumInteritemSpacing:0];
    [layout setMinimumLineSpacing:0];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.topViewCaitner.frame.size.height+self.topViewCaitner.frame.origin.y, WIDTH, (HEIGHT - self.topViewCaitner.frame.size.height-self.topViewCaitner.frame.origin.y)) collectionViewLayout:layout];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"imageView"];
    [self.collectionView setBackgroundColor:[UIColor lightGrayColor]];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.view addSubview:self.collectionView];
}
- (void) showGenerateView
{
    [self.generateViewCantainer setHidden:NO];
    [self.sizeTableView setHidden:NO];
    [self.nameText setText:@"enter file name"];
    [self.nameText setTintColor:[UIColor lightGrayColor]];
    [self.nameText setClearsOnBeginEditing:YES];
}
- (BOOL) checkFile : (NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];//Documents目录
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:@"pdf"];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:pdfPath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:pdfPath withIntermediateDirectories:YES attributes:nil error:nil];
        return NO;
    }
    NSString *fileName1  = [pdfPath stringByAppendingPathComponent:fileName];
    if ([fileManager fileExistsAtPath:fileName1]) {
        return YES;
    }
    else return NO;
}
- (void) backView : (UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) layoutImageView{

}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.imageArray count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"imageView";
    UICollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:indentifier forIndexPath:indexPath];

    CGRect frame =cell.frame;
    frame.origin.x = frame.size.width*0.02;
    frame.origin.y = frame.size.height*0.02;
    frame.size.height = frame.size.height*0.96;
    frame.size.width =frame.size.width*0.96;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    [imageView setImage:[self.imageArray objectAtIndex:indexPath.row]];
    [self.cellArray addObject:cell];
    [cell addSubview:imageView];
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    return cell;
}
- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD) {
        return CGSizeMake(CELL_WIDTH*4, CELL_WIDTH*4);
    }
    return CGSizeMake(CELL_WIDTH*5, CELL_WIDTH*5);
    
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editionMode == EMDelete) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        if (![self.secletedArray containsObject:cell] ){
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width -2.1*CELL_WIDTH, 0.3*CELL_WIDTH, 1.5*CELL_WIDTH*203/163, 1.5*CELL_WIDTH)];
            if (IS_IPAD) {
                [imageView setFrame:CGRectMake(cell.frame.size.width -1.8*CELL_WIDTH, 0.1*CELL_WIDTH, 1.5*CELL_WIDTH*203/163, 1.5*CELL_WIDTH)];
            }
            [imageView setImage:[UIImage imageNamed:@"ok"]];
            [cell addSubview:imageView];
            [self.secletedArray addObject:cell];
            [self.imagVewArray addObject:imageView];
            
        }
        else {
            UIImageView *imageView = [self.imagVewArray objectAtIndex:[self.secletedArray indexOfObject:cell]];
            [imageView removeFromSuperview];
            [self.imagVewArray removeObject:imageView];
            [self.secletedArray removeObject:cell];
        }
    }
}
//zzx 20240126
- (void) changelocation : (UIPanGestureRecognizer *)event
{
    CGPoint center = [event locationInView:event.view.superview];
    
    static CGPoint orignalCenter;
    if (event.state == UIGestureRecognizerStateBegan) {
        orignalCenter = event.view.center;
        [event.view.superview bringSubviewToFront:event.view];
    }
    else if (event.state == UIGestureRecognizerStateChanged)
    {
        [event.view setCenter:center];
    }
    if (event.state == UIGestureRecognizerStateEnded) {
        [event.view setCenter:orignalCenter];
        int x =center.x/event.view.frame.size.width;
        int y =center.y/event.view.frame.size.height;
        if (IS_IPAD) {
            if (x==5) {
                x=4;
            }
            if (y>(([self.imageArray count]-1)/5)) {
                y= (([self.imageArray count]-1)/5);
            }
            y *=5;
        }
        else
        {
            if (x==4) {
                x=3;
            }
            if (y>(([self.imageArray count]-1)/4)) {
                y= (([self.imageArray count]-1)/4);
            }
            y *=4;
        }
    
        NSInteger index = [self.cellArray indexOfObject:event.view];
        NSInteger index1= x+y;
        if (index1 > [self.imageArray count]-1) {
            index1 = [self.imageArray count]-1;
        }
        if (self.editionMode == EMINsert) {
            if (index != index1) {
                [self.imageArray exchangeObjectAtIndex:index withObjectAtIndex:index1];
                UICollectionViewCell *cellView = [self.cellArray objectAtIndex:index1];
                UICollectionViewCell *cellView1 =[self.cellArray objectAtIndex:index];
                UIImageView *imageView = [cellView.subviews lastObject];
                UIImageView *imageView1 = [cellView1.subviews lastObject];
                [imageView removeFromSuperview];
                [imageView1 removeFromSuperview];
                [cellView addSubview:imageView1];
                [cellView1 addSubview:imageView];
                [self.collectionView reloadData];
                return;
            }
        }
        if (index > index1) {
            for (int i = index1;i<index; i++) {
                [self.imageArray exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                UICollectionViewCell *cellView = [self.cellArray objectAtIndex:i];
                UICollectionViewCell *cellView1 =[self.cellArray objectAtIndex:i+1];
                UIImageView *imageView = [cellView.subviews lastObject];
                UIImageView *imageView1 = [cellView1.subviews lastObject];
                [imageView removeFromSuperview];
                [imageView1 removeFromSuperview];
                [cellView addSubview:imageView1];
                [cellView1 addSubview:imageView];
            }
        }
        else if (index1 > index)
        {
            for (int i = index;i<index1; i++) {
                [self.imageArray exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                UICollectionViewCell *cellView = [self.cellArray objectAtIndex:i];
                UICollectionViewCell *cellView1 =[self.cellArray objectAtIndex:i+1];
                UIImageView *imageView = [cellView.subviews lastObject];
                UIImageView *imageView1 = [cellView1.subviews lastObject];
                [imageView removeFromSuperview];
                [imageView1 removeFromSuperview];
                [cellView addSubview:imageView1];
                [cellView1 addSubview:imageView];
            }
        }
    }
}
- (void) addAnimation{
   [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat|UIViewAnimationOptionAllowUserInteraction animations:^{
       for (UICollectionViewCell *cell in [self cellArray]) {
           cell.transform = CGAffineTransformMakeRotation(3*M_PI/180);
           cell.transform =CGAffineTransformMakeTranslation(1, 1);
       }
   } completion:nil];
}
- (void) stopAnimation
{
    for (UICollectionViewCell *cell in [self cellArray]) {
        [cell.layer removeAllAnimations];
    }
}
- (void)removeCell{
    for (UICollectionViewCell *cell in [self secletedArray]) {
        NSInteger index = [self.cellArray  indexOfObject:cell];
        for (NSInteger i =index; i<[self.cellArray count]-1; i++) {
            UICollectionViewCell *cell1 = [self.cellArray objectAtIndex:i+1];
            CGRect frame =cell1.frame;
            [cell1 setFrame:cell.frame];
            [cell setFrame:frame];
        }
        [self.cellArray removeObject:cell];
        [cell removeFromSuperview];
        [self.imageArray removeObjectAtIndex:index];
    }
    [self.secletedArray removeAllObjects];
    for (UIImageView *imageView in [self imagVewArray]) {
        [imageView removeFromSuperview];
        [self.editionGestureArray removeLastObject];
    }
    [self.imagVewArray removeAllObjects];
}
- (void) recordHisTory
{
    
}
- (void)ctreatPDF : (NSString *)fileName atSize : (CGSize) size
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];//Documents目录
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:@"pdf"];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:pdfPath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:pdfPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName1  = [pdfPath stringByAppendingPathComponent:fileName];

    [PDFGenerator drawPDF:fileName1 with:[self imageArray] atSize:size];
    if ([self checkFile:fileName]) {
        if ([[AdmobViewController shareAdmobVC] admob_interstial_ready]) {
            [[AdmobViewController shareAdmobVC] show_admob_interstitial:self];
            [AdmobViewController shareAdmobVC].delegate = self;
//            [self setA:0];
            [self setFileName:fileName1];
        }
        else {
            [self showPDFFile:fileName1];
        }
        [self cleanupCelleAndImage];
        [self.generateViewCantainer setHidden:YES];
        [self.sizeTableView setHidden:YES];
        [self enadledUserIntefaceExcpet];
    }
    else{
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Warning" message:[NSString stringWithFormat:@"The file %@ cann't be saved ,maybe you don't have enough space.",fileName] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alerView show];
    }

}
- (void) cleanupCelleAndImage
{
    for (UICollectionViewCell *cell in [self cellArray]) {
        [cell removeFromSuperview];
    }
    [self.imageArray removeAllObjects];
    [self.cellArray removeAllObjects];
}

-(void)showPDFFile: (NSString *)fileName
{
    NSURL *url = [NSURL fileURLWithPath:fileName];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[UIApplication sharedApplication] openURL:url];
//    [self.pdfView setScalesPageToFit:YES];
    [self.pdfView loadRequest:request];
//    [self.view bringSubviewToFront:self.bgGray];
//    [self.view bringSubviewToFront:self.pdfView];
//    [self.view bringSubviewToFront:self.closePDFViewBtn];
    [self.bgGray setHidden:NO];
    [self.pdfView setBackgroundColor:[UIColor whiteColor]];
    [self performSelector:@selector(dishiddenPDFView) withObject:nil afterDelay:0.5];
    [self.pdfView.layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
    //[self.pdfView set]
    //[self.view addSubview:webView];
    [self.pdfView.scrollView setBackgroundColor:[UIColor whiteColor]];
    [self.pdfView.window setBackgroundColor:[UIColor whiteColor]];
//    [self.pdfView setGapBetweenPages:1];
    
}
- (void) dishiddenPDFView
{
    [self.pdfView setHidden:NO];
    [self.closePDFViewBtn setHidden:NO];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self.nameText setTintColor:[UIColor darkGrayColor]];
    [self.nameText setClearsOnBeginEditing:NO];
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    if ((textField.text.length - range.length + string.length) > 14 || [string isEqualToString:@"\n"]||[string isEqualToString:@"."]||[string isEqualToString:@" "]) {
                    return NO;
    
        }
    return YES;
}
- (void) createSizeArray
{
    NSArray *array = @[@"A4:21.0x29.7cm",@"A3:29.7x42.0cm",@"A5:14.5x21.0cm",@"B4:25.0x35.3cm",@"B5:17.6x25.0cm"];
    [self setSizeArray:[[NSMutableArray alloc] initWithArray:array]];
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *size;
    static NSString *CellIdentifier = @"Albumnlist";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!self.isSizeChoice) {
        size = [self.sizeArray objectAtIndex:self.sizeType];
        
        
    }
    else{
        size =[self.sizeArray objectAtIndex:indexPath.row];
    }
    
    [cell.layer setCornerRadius:CELL_WIDTH*0.5];
    [cell setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0.8 alpha:0.3]];
    [cell.textLabel setText:size];
    [cell.textLabel setFont:[UIFont systemFontOfSize:CELL_WIDTH]];
    if (IS_IPAD) {
         [cell.textLabel setFont:[UIFont systemFontOfSize:CELL_WIDTH*0.6]];
    }
    return cell;
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSizeChoice) {
        return [self.sizeArray count];
    }
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD) {
        return CELL_WIDTH*2.3*0.6;
    }
    return 2.3*CELL_WIDTH;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sizeType != 0) {
        [self.sizeArray exchangeObjectAtIndex:0 withObjectAtIndex:self.sizeType];
        NSLog(@"%@,%@",self.sizeArray[0],self.sizeArray[self.sizeType]);

    }
    if ([self isSizeChoice]) {
        [self.nameText setUserInteractionEnabled:NO];
        if (indexPath.row == self.sizeType) {
            [self setSizeType:0];
        }
        else if(indexPath.row != 0){
            [self setSizeType:indexPath.row];
        }
        [self.nameText setUserInteractionEnabled:YES];
    }
    else{
        [self.nameText setUserInteractionEnabled:NO];
    }
   
    [self setIsSizeChoice:![self isSizeChoice]];
    [self refreshTableView];
    [tableView reloadData];
}

- (void)getHistoryData
{


}

- (void) deleteHisData : (UIButton *)sender
{
    if (self.isHistoryDeleMode) {
        [self.hisDataSet removeCell];
        [self setIsHistoryDeleMode:NO];
        [self.historyBtn setUserInteractionEnabled:YES];
        [self.historyBtn setAlpha:1];
        [self.returnBtn setUserInteractionEnabled:YES];
        [self.returnBtn setAlpha:1];
        [self.hisDataSet removeAnimation];
        [self.hisDataSet setIsDeleteMode:NO];
        if (self.hisDataSet.shoudReLoadData) {
            [self saveHisData];
            [self.hisToryView reloadData];
            if ([self.hisDataSet.hisData.count integerValue] == 0) {
                [self.hisToryView setHidden:YES];
                [self enadledUserIntefaceExcpet];
                [self setEditionMode:EMNone];
            }
            
        }
    }
    else{
        [self.hisDataSet addAnimation];
        [self.hisDataSet setIsDeleteMode:YES];
        [self setIsHistoryDeleMode:YES];
        [self disadledUserIntefaceExcpet:nil];
       
    }
}

- (void) showChoicedFile:(NSString *)filename
{
    NSLog(@"dad");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];//Documents目录
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:@"pdf"];
    NSString *fileName1  = [pdfPath stringByAppendingPathComponent:filename];
     NSLog(@"dad %@",fileName1);
    [self showPDFFile:fileName1];
}
- (void) initAd
{  //zzx  test3  20240122 
    if (liuhaiScreen) {
        self.adview = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - buttomLiuhaiPianyiY - admobHeight, kScreenWidth, admobHeight)];
        self.liuHaiBtmBgview= [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - buttomLiuhaiPianyiY - admobHeight, kScreenWidth,44 +admobHeight)];
        self.liuHaiBtmBgview.backgroundColor=[UIColor colorWithWhite:0.10 alpha:1.0];
        [self.view addSubview:self.liuHaiBtmBgview];
    }else{
        self.adview = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - admobHeight, kScreenWidth,admobHeight)];
    }
    [self.view addSubview:self.adview];
    
    
//    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCount) userInfo:nil repeats:YES];
//    [self setA:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[AdmobViewController shareAdmobVC] show_admob_banner:self.adview placeid:@"pdfpage"];
}

- (void)adMobVCWillCloseInterstitialAd:(AdmobViewController *)adMobVC
{
//    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCount) userInfo:nil repeats:YES];
    [self showPDFFile:self.fileName];
    //
    [AdmobViewController shareAdmobVC].delegate = nil;
}

//- (void)timeCount
//{
//    self.a++;
//    if (self.a < 30) {
//        self.a++;
//        
//        //   NSLog(@"%d",self.a);
//        //        if ([_adViewController admob_interstial_ready]) {
//        //            NSLog(@"adshoud show %d",self.a);
//        //            [self.adViewController try_show_admob_interstitial:self.navigationController ignoreTimeInterval:YES];
//        //            [self performSegueWithIdentifier:@"toCodeScanner" sender:nil];
//        //
//        //            [self.timer invalidate];
//        //
//        //        }
//    }
//    else {
//        NSLog(@" im ready");
//        // [self performSegueWithIdentifier:@"toCodeScanner" sender:nil];
//        [self.timer invalidate];
//        //[self enterNewViewContoller];
//    }
//}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.nameText resignFirstResponder];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
