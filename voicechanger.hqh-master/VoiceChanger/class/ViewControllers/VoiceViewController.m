//
//  VoiceViewController.m
//  VoiceChanger
//
//  Created by tangtaoyu on 15/5/27.
//  Copyright (c) 2015年 tangtaoyu. All rights reserved.
//

#import "VoiceViewController.h"
#import "MBProgressHUD.h"
#import "MGDefine.h"
#import "MGData.h"
#import "MGFile.h"
#import "MGVoiceDefine.h"
#import "MGSlider.h"
#import "MGFunction.h"
#import "Admob.h"
#import "JASidePanelController.h"
#define kVoiceCount   8
#define kCOLNUMs      4

@interface VoiceViewController ()
{
    UIView *voiceView;
    UIImageView *showIV;
    UIView *settingView;
    
    AVAudioPlayer *audioPalyer;
    
    NSArray *changerArray;
    
    UIButton *lastBtn;
    NSInteger btnType;
    
    NSArray *btnNames;
    NSArray *showNames;
    
    BOOL isAppear;
    float voiceH;
    float bottomH;
    
    float sSpeed;
    float sPitch;
    UIButton *yesBtn;
    UIButton *closeBtn;
    
    float currentSelectIndex;
    float pianyiy;
    float showsoundviewY;
    NSArray *nameArray;
    
    JASidePanelController *jaPC;
}

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, assign) NSInteger yesStatus;
@property (nonatomic, assign) BOOL isCustom;

@property (nonatomic, strong) UIView* adview;

@end

@implementation VoiceViewController

- (MBProgressHUD*)HUD
{
    if(_HUD){
        [_HUD removeFromSuperview];
        _HUD = nil;
    }
    _HUD = [MGFunction createHUD];

    return _HUD;
}

- (void)viewDidLoad {
    if ([[UIScreen mainScreen] bounds].size.height >= 812 && [[UIScreen mainScreen] bounds].size.height+ [[UIScreen mainScreen] bounds].size.width <1500) {
        pianyiy=50;
        showsoundviewY=70;
        [self prefersStatusBarHidden];
    }
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self dataInit];
    [self widgetsInit];
    
    self.adview = [[UIView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight+pianyiy, kScreenWidth, kAdHeight)];
    [self.view addSubview:self.adview];
    NSLog(@"zzx3 %lf",kNavigationBarHeight);
    NSLog(@"zzx3 %lf",self.adview.center.y);
    [[AdmobViewController shareAdmobVC] checkConfigUD];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    if ([[UIScreen mainScreen] bounds].size.height >= 812 && [[UIScreen mainScreen] bounds].size.height+ [[UIScreen mainScreen] bounds].size.width <1500) {
        return NO;
    }
    return YES;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    [[AdmobViewController shareAdmobVC] show_admob_banner:self.adview placeid:@"voicepage"];
}

- (void)viewDidAppear:(BOOL)animated
{
    if(!isAppear){
        isAppear = !isAppear;
        [self clickVoiceBtn:lastBtn];
    }
}

- (void)dataInit
{
    voiceH = kDevice3(140., 140., 300.);
    NSLog(@" zzx voiceH =%lf",voiceH);
    bottomH = kDevice3(40., 40., 60.);
    isAppear = NO;
    btnType = 0;
    changerArray = [MGData getVoiceChanger];
    
    sSpeed = 0;
    sPitch = 2;
    self.isCustom = NO;
    currentSelectIndex = 0;
    
    btnNames = @[@"btn_voice_original",@"btn_voice_children",@"btn_voice_man",
                 @"btn_voice_woman",@"btn_voice_old",@"btn_voice_fast",
                 @"btn_voice_slow",@"btn_voice_setting"];
    
    showNames = @[@"show_original",@"show_children",@"show_man",
                 @"show_woman",@"show_old",@"show_fast",
                 @"show_slow",@"show_setting"];
    
    nameArray = @[kLocalizable(@"MG_ORIGINAL"),kLocalizable(@"MG_KID"),kLocalizable(@"MG_MAN"),
                  kLocalizable(@"MG_WOMAN"),kLocalizable(@"MG_OLD"),kLocalizable(@"MG_FAST"),
                  kLocalizable(@"MG_SLOW"),kLocalizable(@"MG_CUSTOM")];
}

- (void)widgetsInit
{
    float changeshowIVH0Y=0;
    UIImageView *bgIV = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgIV.image = [UIImage imageNamed:@"background.jpg"];
    [self.view addSubview:bgIV];
    int x;
    if (kScreenHeight + kScreenWidth <1500) {
        x=140;
    }else{
        x=300;
    }
    float showIVH = (kScreenHeight - x - bottomH - kNavigationBarHeight - kSmartAdHeight);
    float showIVH0 = showIVH/1.5;
    if ([[UIScreen mainScreen] bounds].size.height >= 812 && [[UIScreen mainScreen] bounds].size.height+ [[UIScreen mainScreen] bounds].size.width <1500) {
        // iPhone 11 375x812
        showIVH0 = showIVH/1.5/1.5;
//        changeSpeakBtnY=100.0-30;
        changeshowIVH0Y=0;
        if (kScreenHeight ==844) {
            changeshowIVH0Y=-14;
        }
        if ( kScreenHeight >850  )
        {
            changeshowIVH0Y=-14; 
        }
    }
    showIV = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-showIVH0)/2, kNavigationBarHeight+kSmartAdHeight+(showIVH-showIVH0)/2+changeshowIVH0Y, showIVH0, showIVH0)];
    NSLog(@" zzx showIheight2 =%lf",kNavigationBarHeight+kSmartAdHeight+(showIVH-showIVH0)/2+changeshowIVH0Y);
    showIV.image = [UIImage imageNamed:showNames[0]];
    [self.view addSubview:showIV];
    
    [self voiceViewInit];
    [self setttingViewInit];
    [self naviInit];
}

- (void)voiceViewInit
{
    voiceView = [[UIView alloc] init];
    voiceView.frame = CGRectMake(0, kScreenHeight-voiceH-bottomH-showsoundviewY, kScreenWidth, voiceH);
    [self.view addSubview:voiceView];
    
    int row, col;
    float btnH = kDevice2(60., 120.);
    float Ox = (kScreenWidth-btnH*4)/9*3;
    float gapX = (kScreenWidth-btnH*4)/9;
    float Oy = 0;
    float gapY = voiceH-btnH*2;

    
    CGRect btnFrame;
    for(int i=0; i<kVoiceCount; i++){
        row = i / kCOLNUMs;
        col = i % kCOLNUMs;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnFrame = CGRectMake(Ox+(btnH+gapX)*col, Oy+(btnH+gapY)*row, btnH, btnH);
        
        btn.frame = btnFrame;
        [btn setImage:[UIImage imageNamed:btnNames[i]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickVoiceBtn:) forControlEvents:UIControlEventTouchUpInside];
        [voiceView addSubview:btn];
        
        btn.tag = i;
        
        if(i == 0){
            lastBtn = btn;
            [self button:btn Status:1];
        }
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(Ox+(btnH+gapX)*col, Oy+btnH+(btnH+gapY)*row, btnH, gapY);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12.];
        label.textColor = [UIColor blackColor];
        label.text = nameArray[i];
        [voiceView addSubview:label];
    }
}

- (void)setttingViewInit
{
    float setW = kScreenWidth*kDevice2(0.85, 0.5);
    float setH = 140.;
    float setOy = kScreenHeight-bottomH-voiceH + (voiceH-setH)/2;
    settingView = [[UIView alloc] init];
    settingView.frame = CGRectMake((kScreenWidth-setW)/2, setOy, setW, setH);
    settingView.backgroundColor = COLOR(0, 0, 0, 200);
    [self.view addSubview:settingView];
    settingView.layer.cornerRadius = 8.0;
    
    float closeW = 45.;
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(kX(settingView)+kW(settingView)-closeW/2, kY(settingView)-closeW/2, closeW, closeW);
    [closeBtn setImage:[UIImage imageNamed:@"setting_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    closeBtn.contentMode = UIViewContentModeCenter;
    closeBtn.contentEdgeInsets = UIEdgeInsetsMake(4., 4., 4., 4.);

    
    float labelW = 70.;
    float labelH = 45.;
    float sliderGap = kDevice2(20., 30.);
    UILabel *speedLabel = [[UILabel alloc] init];
    speedLabel.frame = CGRectMake(0, 0, labelW, labelH);
    speedLabel.textAlignment = NSTextAlignmentCenter;
    speedLabel.font = [UIFont systemFontOfSize:18.];
    speedLabel.textColor = HEXCOLOR(0xd8d8d8ff);
    speedLabel.text = kLocalizable(@"MG_SPEED");
    [settingView addSubview:speedLabel];
    
    UILabel *patchLabel = [[UILabel alloc] init];
    patchLabel.frame = CGRectMake(0, labelH, labelW, labelH);
    patchLabel.textAlignment = NSTextAlignmentCenter;
    patchLabel.font = [UIFont systemFontOfSize:18.];
    patchLabel.textColor = HEXCOLOR(0xd8d8d8ff);
    patchLabel.text = kLocalizable(@"MG_PITCH");
    [settingView addSubview:patchLabel];
    
    UISlider *speedSlider = [[MGSlider alloc] init];
    speedSlider.frame = CGRectMake(labelW+sliderGap, 0., kW(settingView)-labelW-sliderGap*2, labelH);
    speedSlider.maximumValue = 50;
    speedSlider.minimumValue = -50;
    speedSlider.value = 0;
    [speedSlider addTarget:self action:@selector(changeSpeedValue:) forControlEvents:UIControlEventValueChanged];
    [speedSlider setMinimumTrackTintColor:HEXCOLOR(0xd8d8d8ff)];
    [speedSlider setMaximumTrackTintColor:HEXCOLOR(0x4f4f4fff)];
    [settingView addSubview:speedSlider];
    
    UISlider *pitchSlider = [[MGSlider alloc] init];
    pitchSlider.frame = CGRectMake(labelW+sliderGap, labelH, kW(settingView)-labelW-sliderGap*2, labelH);
    pitchSlider.maximumValue = 12;
    pitchSlider.minimumValue = -12;
    pitchSlider.value = 2;
    [pitchSlider addTarget:self action:@selector(changePitchValue:) forControlEvents:UIControlEventValueChanged];
    [pitchSlider setMinimumTrackTintColor:HEXCOLOR(0xd8d8d8ff)];
    [pitchSlider setMaximumTrackTintColor:HEXCOLOR(0x4f4f4fff)];
    [settingView addSubview:pitchSlider];
    
    float btnW = 120., btnH = 40.;
    yesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    yesBtn.frame = CGRectMake((setW-btnW)/2, labelH*2+(setH-labelH*2-btnH)/2, btnW, btnH);
    [yesBtn setImage:[UIImage imageNamed:@"setting_play"] forState:UIControlStateNormal];
    [yesBtn addTarget:self action:@selector(clickYesBtn) forControlEvents:UIControlEventTouchUpInside];
    [settingView addSubview:yesBtn];
    
    settingView.hidden = YES;
    closeBtn.hidden = YES;
}

- (void)changeSpeedValue:(UISlider*)slider
{
    sSpeed = slider.value;
}

- (void)changePitchValue:(UISlider*)slider
{
    sPitch = slider.value;
}

- (void)clickCloseBtn
{
    [self hideSetting];
}

- (void)clickYesBtn
{
    if(self.yesStatus == 0){
        NSDictionary *dict = @{kTempo:[NSNumber numberWithFloat:sSpeed],
                           kPitch:[NSNumber numberWithFloat:sPitch],
                           kRate:@0};
    
        [self changeVoice:dict];
    }else{
        self.yesStatus = 0;
        [self stopAudio];
    }
}

- (void)showSetting
{
    [self stopVideo];
    
    self.isCustom = YES;
    settingView.hidden = NO;
    closeBtn.hidden = NO;
    self.yesStatus = 0;
    
    [self button:lastBtn Status:0];
    btnType = 0;
    
    [self clickYesBtn];
}

- (void)hideSetting
{
    [self stopVideo];

    self.isCustom = NO;
    settingView.hidden = YES;
    closeBtn.hidden = YES;
    self.yesStatus = 0;
}

- (void)setYesStatus:(NSInteger)yesStatus
{
    _yesStatus = yesStatus;
    
    if(yesStatus == 0){
        [yesBtn setImage:[UIImage imageNamed:@"setting_play"] forState:UIControlStateNormal];
    }else{
        [yesBtn setImage:[UIImage imageNamed:@"setting_pause"] forState:UIControlStateNormal];
    }
}

- (void)button:(UIButton*)btn Status:(NSInteger)type
{
    if(type == 0){
        [btn setImage:[UIImage imageNamed:btnNames[btn.tag]] forState:UIControlStateNormal];
    }else if(type == 1){
        [btn setImage:[UIImage imageNamed:@"btn_voice_start"] forState:UIControlStateNormal];
    }else{
        [btn setImage:[UIImage imageNamed:@"btn_voice_pause"] forState:UIControlStateNormal];
    }
}

- (void)clickVoiceBtn:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    NSInteger index = btn.tag;
    
    NSInteger voiceIdx = (index < 7)?index:7;
    NSDictionary *dict = changerArray[voiceIdx];
    
    if(index == 7){
        currentSelectIndex = index;
        [self showSetting];
        showIV.image = [UIImage imageNamed:showNames[voiceIdx]];
        return;
    }
    
    if(btn.tag == lastBtn.tag){
        if(btnType == 0){
            btnType = 1;
            [self button:btn Status:1];
            [self changeVoice:dict];
        }else if(btnType == 1){
            btnType = 2;
            [self button:btn Status:2];
            [self changeVoice:dict];
        }else{
            btnType = 1;
            [self button:btn Status:1];
            [self stopAudio];
        }
    }else{
        [self button:lastBtn Status:0];
        [self button:btn Status:1];
        lastBtn = btn;
        btnType = 1;
        
        [self changeVoice:dict];
    }
    
    currentSelectIndex = index;
    
    showIV.image = [UIImage imageNamed:showNames[voiceIdx]];
}

- (void)changeVoice:(NSDictionary*)dict
{
    self.HUD.label.text = kLocalizable(@"MG_PROCESS");
    
    if (audioPalyer) {
        [audioPalyer stop];
        audioPalyer = nil;
    }

    NSString *path =  _filePath;//[Recorder shareRecorder].filePath;
    AudioConvertConfig dconfig;
    dconfig.sourceAuioPath = [path UTF8String];
    dconfig.outputFormat = _outputFormat;
    dconfig.outputChannelsPerFrame = 1;
    dconfig.outputSampleRate = kOutputSampleRate;
    
    dconfig.soundTouchTempoChange = (int)[[dict objectForKey:kTempo] integerValue];
    dconfig.soundTouchPitch = (int)[[dict objectForKey:kPitch] integerValue];
    dconfig.soundTouchRate = (int)[[dict objectForKey:kRate] integerValue];
    
    [[AudioConvert shareAudioConvert] audioConvertBegin:dconfig withCallBackDelegate:self];
}

//开始播放
- (void)playAudio:(NSString*)path
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [_HUD hideAnimated:YES];
    });
    
    if(_isCustom){
        self.yesStatus = 1;
    }else{
        [self button:lastBtn Status:2];
        btnType = 2;
    }
    
    NSURL *url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSError *err = nil;
    if (audioPalyer) {
        [audioPalyer stop];
        audioPalyer = nil;
    }
    audioPalyer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    audioPalyer.delegate = self;
    [audioPalyer play];
    self.voiceTimeLength = audioPalyer.duration;
}

//停止播放
- (void)stopAudio {
    if (audioPalyer) {
        [audioPalyer stop];
        audioPalyer = nil;
    }
    
    if(_isCustom){
        self.yesStatus = 0;
    }else{
        btnType = 1;
        [self button:lastBtn Status:1];
    }
}

- (void)stopVideo
{
    if (audioPalyer) {
        [audioPalyer stop];
        audioPalyer = nil;
    }
}

#pragma mak - 播放回调代理
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if(_isCustom){
        self.yesStatus = 0;
    }else{
        btnType = 1;
        [self button:lastBtn Status:1];
    }
}


/**
 * 对音频解码动作的回调
 **/
- (void)audioConvertDecodeSuccess:(NSString *)audioPath {
    //解码成功
    [self playAudio:audioPath];
}
- (void)audioConvertDecodeFaild
{
    //解码失败
    _HUD.mode = MBProgressHUDModeCustomView;
    _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
    _HUD.label.text = NSLocalizedString(@"MG_PROCESS_FAILED", nil);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [_HUD hideAnimated:YES];
    });
    [self stopAudio];
}

/**
 * 对音频变声动作的回调
 **/
- (void)audioConvertSoundTouchSuccess:(NSString *)audioPath
{
    //变声成功
    [self playAudio:audioPath];
}

- (void)audioConvertSoundTouchFail
{
    //变声失败
    _HUD.mode = MBProgressHUDModeCustomView;
    _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
    _HUD.label.text = NSLocalizedString(@"MG_PROCESS_FAILED", nil);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [_HUD hideAnimated:YES];
    });
    [self stopAudio];
}

/**
 * 对音频编码动作的回调
 **/

- (void)audioConvertEncodeSuccess:(NSString *)audioPath
{
    //编码完成
    [self playAudio:audioPath];
}

- (void)audioConvertEncodeFaild
{
    //编码失败
    _HUD.mode = MBProgressHUDModeCustomView;
    _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
    _HUD.label.text = NSLocalizedString(@"MG_PROCESS_FAILED", nil);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [_HUD hideAnimated:YES];
    });
    [self stopAudio];
}

#pragma mark - AudioConvertDelegate
- (BOOL)audioConvertOnlyDecode
{
    return  NO;
}
- (BOOL)audioConvertHasEnecode
{
    return YES;
}

- (void)naviInit
{
    // 2024.1.3 zzx update ui iph15
    UIView *naviBarView = [[UIView alloc] init];
    naviBarView.frame = CGRectMake(0, 0+pianyiy, kScreenWidth, kNavigationBarHeight);
    [self.view addSubview:naviBarView];
    
//    UIImageView *bgIV = [[UIImageView alloc] initWithFrame:naviBarView.bounds];
//    bgIV.image = [UIImage imageNamed:@"navibar"];
//    [naviBarView addSubview:bgIV];
    UIColor *color = [UIColor colorWithRed:162/255.0 green:177/255.0 blue:180/255.0 alpha:1.0];
    naviBarView.layer.shadowColor = [UIColor clearColor].CGColor;
    naviBarView.layer.shadowOffset = CGSizeMake(0, 0.5);
    naviBarView.layer.shadowOpacity = 0.6;
    naviBarView.layer.shadowRadius = 0.3;
    naviBarView.backgroundColor = [UIColor clearColor];
    naviBarView.opaque = NO;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = NO;
    float cellW = kNavigationBarHeight;
    float cellH = kNavigationBarHeight;
    float gap = kNavigationBarHeight/8;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, cellW, cellH);
    [leftBtn setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [leftBtn setContentMode:UIViewContentModeCenter];
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(gap, gap, gap, gap)];
    [leftBtn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(kScreenWidth-cellW*2, 0, cellW, cellH);
    [saveBtn setImage:[UIImage imageNamed:@"btn_save"] forState:UIControlStateNormal];
    [saveBtn setContentMode:UIViewContentModeCenter];
    [saveBtn setImageEdgeInsets:UIEdgeInsetsMake(gap, gap, gap, gap)];
    [saveBtn addTarget:self action:@selector(clickSaveBtn) forControlEvents:UIControlEventTouchUpInside];
    //zzx
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(kScreenWidth-cellW, 0, cellW, cellH);
    [rightBtn setImage:[UIImage imageNamed:@"btn_share"] forState:UIControlStateNormal];
    [rightBtn setContentMode:UIViewContentModeCenter];
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(gap, gap, gap, gap)];
    [rightBtn addTarget:self action:@selector(clickShareBtn) forControlEvents:UIControlEventTouchUpInside];
//    UIColor *color1  = [UIColor colorWithRed:150/255.0 green:165/255.0 blue:170/255.0 alpha:1.0];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:naviBarView.bounds];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.layer.backgroundColor=color.CGColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"MG_RECORD", nil);
    
    [naviBarView addSubview:titleLabel];
    [naviBarView addSubview:leftBtn];
    [naviBarView addSubview:rightBtn];
    [naviBarView addSubview:saveBtn];
}
//zzx BackBtn
- (void)clickBackBtn
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshNotice2 object:self userInfo:nil];
    
    [self stopAudio];
    
    if(self.backBlock){
        self.backBlock();
    }
    
    if(_isPresent){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)clickSaveBtn
{
    NSInteger voiceIdx = currentSelectIndex;
    
    [MGFile pushVoicePathWith:@{kVoiceNum:[NSString stringWithFormat:@"%i",(int)[MGFile Instance].voiceIndex],
                                kVoiceName:_fileName,
                                kVoiceCate:[NSString stringWithFormat:@"%d", (int)voiceIdx],
                                kVoiceTime:[NSString stringWithFormat:@"%d", (int)_voiceTimeLength],
                                kVoiceCustom:[NSString stringWithFormat:@"%d,%d", (int)sSpeed, (int)sPitch],
                                kVoiceDate:[self createFilename]
                                }];

    self.HUD.label.text = kLocalizable(@"MG_PROCESS");
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:0.5];
}

- (NSString *)createFilename
{
    NSDate *date_ = [NSDate date];
    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
    [dateformater setDateFormat:@"yyyy.MM.dd_HH.mm.ss"];
    NSString *timeFileName = [dateformater stringFromDate:date_];
    return timeFileName;
}

- (void)hideHUD
{
    _HUD.mode = MBProgressHUDModeCustomView;
    _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
    _HUD.label.text = NSLocalizedString(@"MG_SAVED", nil);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [_HUD hideAnimated:YES];
    });
}

- (void)clickShareBtn
{
    [self shareVoice];
    
    [[AdmobViewController shareAdmobVC] recordValidUseCount];
}

- (void)shareVoice
{
    NSString *voicePath = [NSString stringWithFormat:@"%@/%@.%@",kOutputPath, kEncode, kVoiceLast];
    NSString *textToShare = @"share Voice";
    NSURL *outputURL = [NSURL fileURLWithPath:voicePath];
    NSArray *activityItems = @[textToShare, outputURL];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems
                                                                            applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeAssignToContact];
    
    if([activityVC respondsToSelector:@selector(completionWithItemsHandler)]){
        activityVC.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            // When completed flag is YES, user performed specific activity
        };
    }else{
        activityVC.completionHandler = ^(NSString *activityType, BOOL completed) {
            NSLog(@" activityType: %@", activityType);
            NSLog(@" completed: %i", completed);
            if([activityType isEqualToString:UIActivityTypeSaveToCameraRoll]){
                //[_adViewController show_admob_interstitial:self];
            }
        };
    }
    
    if (IS_IPAD)
    {
        _popover = nil;
        if(_popover == nil){
            
            _popover = [[UIPopoverController alloc] initWithContentViewController:activityVC];
            _popover.delegate = self;
            _popover.popoverContentSize = CGSizeMake(400, 450);
            
            [_popover presentPopoverFromRect:((UIButton*)self.navigationItem.rightBarButtonItem).frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else
    {
        [self presentViewController:activityVC animated:YES completion:^{
        }];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [_popover dismissPopoverAnimated:YES];
    _popover = nil;
}

@end
