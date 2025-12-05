//
//  CodeScanner.h
//  QRReader
//
//  Created by awt on 15/7/20.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CommonEmun.h"
#import "HistoryTableViewSet.h"
@interface CodeScanner : UIViewController

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput *frontInput;
@property (strong,nonatomic)AVCaptureDevice *frontDevice;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (strong,nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, retain) UIImageView * line;
@property (nonatomic,strong) CIDetector *detector;
@property (nonatomic,strong) NSMutableString *result;
@property CodeType codeType;
@property ScannerMode scannerMode;
@property AvailableCameraType availableDeviceType;
@property (strong,nonatomic) UIImageView *scanWindow;
@property (strong,nonatomic) UIButton *flash;
@property BOOL hasTorch;
@property BOOL isBack;
@property BOOL isPDFAlbum;
@property (strong,nonatomic) UIView *topViewCantainer;
@property (strong,nonatomic) UIButton *menuBtn;
@property (strong,nonatomic) UIButton *scanTypeBtn;
@property (strong,nonatomic) UIButton *cameraSwtitchBtn;
@property (strong,nonatomic) UIButton *albumBtn;
@property BOOL hidenemuListCantainer;
@property (strong,nonatomic) UIView *scannerCantainer;
@property (strong,nonatomic) UIView *PDFCamtainer;
@property (strong,nonatomic) NSMutableArray *PDFImageArray;
@property (strong,nonatomic) UIButton *takePhotoBtn;
@property (strong,nonatomic) UIButton *PDFAlbum;
@property (strong,nonatomic) UIButton *toPDFViewController;
@property (strong,nonatomic) UIImageView *cornerRT;
@property (strong,nonatomic) UIImageView *cornerLT;
@property (strong,nonatomic) UIImageView *cornerRB;
@property (strong,nonatomic) UIImageView *cornerLB;
@property (strong,nonatomic) UIImageView *scanBar;
@property (strong,nonatomic) UIImageView *menuListCantainer;
@property (strong,nonatomic) UIButton *cameraBtn;
@property (strong,nonatomic) UIButton *historyBtn;
@property (strong,nonatomic) UIButton *creatorBtn;
@property (strong,nonatomic) UIButton *settings;
@property (strong,nonatomic) UIButton *PDFBtn;
@property (strong, nonatomic) UILabel *topLable;
@property (strong, nonatomic) UITableView *historyTableView;
@property (strong,nonatomic) HistoryTableViewSet *historyTablViewSet;

@property (strong,nonatomic) NSTimer *timer;
@property int a;

@end
