//
//  LeftViewController.m
//  VoiceChanger
//
//  Created by tangtaoyu on 15/5/25.
//  Copyright (c) 2015年 tangtaoyu. All rights reserved.
//

#import "LeftViewController.h"
#import "MGVoiceCell.h"
#import "MGFile.h"
#import "MGDefine.h"
#import "MGData.h"
#import "VoiceViewController.h"
#import "MGVoiceDefine.h"
#import "MBProgressHUD.h"
#import "MGFunction.h"

#define kCellIdentifier @"MGSwipeTableCellType"

@interface LeftViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *mgTableView;
    
    NSMutableArray *listArray;
    NSArray *changerArray;
    
    NSMutableArray *removeArray;
    
    NSArray *imageNames;
    
    NSMutableArray *statusArr;
    
    AVAudioPlayer *audioPalyer;
    
    NSInteger lastIndex;
}

@property (nonatomic, assign)  BOOL isEdit;
@property (nonatomic, assign)  BOOL canEdit;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation LeftViewController

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
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage) name:kRefreshNotice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage) name:kRefreshNotice2 object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeVoice) name:kCloseVoiceNotice object:nil];

    imageNames = @[@"tb_original",@"tb_children",@"tb_man",
                   @"tb_woman",@"tb_old",@"tb_fast",
                   @"tb_slow",@"tb_setting"];
    
    removeArray = [[NSMutableArray alloc] init];
    
    changerArray = [MGData getVoiceChanger];
    
    self.canEdit = YES;
    
    [self dataInit];
    [self widgetsInit];
    if ([[UIScreen mainScreen] bounds].size.height >= 812 && [[UIScreen mainScreen] bounds].size.height+ [[UIScreen mainScreen] bounds].size.width <1500) {
        [self prefersStatusBarHidden];
    }
}

- (void)refreshPage
{
    [self dataInit];
    [mgTableView reloadData];
}

- (void)closeVoice
{
    if(audioPalyer){
        [audioPalyer stop];
        audioPalyer = nil;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self editStatus];
}

- (void)dataInit
{
    [listArray removeAllObjects];
    listArray = nil;
    [statusArr removeAllObjects];
    statusArr = nil;
    
    NSArray *array = [MGFile getVoiceFileNameArray];
    NSArray *array1 = array[1];
    listArray = array1.mutableCopy;
    
    statusArr = [[NSMutableArray alloc] init];
    for(int i=0; i<listArray.count; i++){
        [statusArr addObject:@0];
    }
    
    [self editStatus];
}

- (void)widgetsInit
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self naviInit];
    
    CGRect tableRect = CGRectMake(0, 0, kW(self.view)*0.85, kH(self.view));
    mgTableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStyleGrouped];
    mgTableView.dataSource = self;
    mgTableView.delegate = self;
    [self.view addSubview:mgTableView];
    
    [mgTableView setEditing:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MGVoiceCell *cell = (MGVoiceCell*)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if(!cell){
        cell = [[MGVoiceCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
    }
    
    NSDictionary *dict = [listArray objectAtIndex:indexPath.row];
    NSArray *dataArray = [self getDataFromDict:dict];
    
    NSInteger voiceType = [[dict objectForKey:kVoiceCate] integerValue];
    
    if([statusArr[indexPath.row] integerValue] == 0){
        cell.imageView.image = [UIImage imageNamed:imageNames[voiceType]];
    }else{
        cell.imageView.image = [UIImage imageNamed:@"tb_pause"];
    }
    
    cell.textLabel.text = dataArray[0];
    cell.detailTextLabel.text = dataArray[1];
    cell.durationLabel.text = dataArray[3];
    
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *dict = [listArray objectAtIndex:indexPath.row];
    NSArray *dataArray = [self getDataFromDict:dict];
    
    NSInteger voiceCate = [dataArray[2] integerValue];
    NSDictionary *voiceDict;
    
    if(voiceCate <7){
        voiceDict = changerArray[voiceCate];
    }else{
        NSString *customs = [dict objectForKey:kVoiceCustom];
        NSArray *customDatas = [customs componentsSeparatedByString:@","];
        NSDictionary *dict = @{kTempo:[NSNumber numberWithInteger:[customDatas[0] integerValue]],
                               kPitch:[NSNumber numberWithInteger:[customDatas[1] integerValue]],
                               kRate:@0};
        voiceDict = dict;
    }
    
    if(_isEdit){
        [removeArray addObject:indexPath];
        return;
    }
    
    if([statusArr[indexPath.row] integerValue] == 0){
        [self lastReset];

        statusArr[indexPath.row] = @1;
        cell.imageView.image = [UIImage imageNamed:@"tb_pause"];
        [self changeVoice:voiceDict WithFileName:[dict objectForKey:kVoiceName]];
    }else{
        statusArr[indexPath.row] = @0;
        [self stopAudio];

        NSDictionary *dict = [listArray objectAtIndex:indexPath.row];
        NSInteger voiceType = [[dict objectForKey:kVoiceCate] integerValue];
        cell.imageView.image = [UIImage imageNamed:imageNames[voiceType]];
    }
    
    if(!_isEdit)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

    lastIndex = indexPath.row;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_isEdit){
        [removeArray removeObject:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        
        [MGFile popVoicePathWith:[listArray objectAtIndex:indexPath.row]];
        
        [listArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        
        [self editStatus];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [listArray objectAtIndex:indexPath.row];
    NSInteger timeLength = [[dict objectForKey:kVoiceTime] integerValue];
    NSString *fileName = [dict objectForKey:kVoiceName];
    
    [self stopAudio];
    VoiceViewController *voiceVC = [[VoiceViewController alloc] init];
    voiceVC.outputFormat = kVoiceOutputFormat;
    voiceVC.voiceTimeLength = timeLength;
    voiceVC.fileName = fileName;
    voiceVC.filePath = [[MGFile getFilePathOfFile:fileName] stringByAppendingString:@".wav"];
    voiceVC.isPresent = YES;
    
    voiceVC.modalPresentationStyle = UIModalPresentationFullScreen;
    voiceVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self.navigationController pushViewController:voiceVC animated:YES];
    voiceVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:voiceVC animated:YES completion:nil];
    NSLog(@"zzx  %@",self.navigationController.viewControllers);
}

- (void)lastReset
{
    statusArr[lastIndex] = @0;
    UITableViewCell *cell = [mgTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastIndex inSection:0]];
    NSDictionary *dict = [listArray objectAtIndex:lastIndex];
    NSInteger voiceType = [[dict objectForKey:kVoiceCate] integerValue];
    cell.imageView.image = [UIImage imageNamed:imageNames[voiceType]];
}

- (void)naviInit
{
    self.navigationItem.title = NSLocalizedString(@"MG_MYRECORD", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(clickEdit)];
}

- (void)setIsEdit:(BOOL)isEdit
{
    _isEdit = isEdit;
    
    if(!isEdit){
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(clickEdit)];
    }else{
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clickRemove)];
    }
}

- (void)setCanEdit:(BOOL)canEdit
{
    _canEdit = canEdit;
    
    if(canEdit){
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
}

- (void)editStatus
{
    if(listArray.count > 0){
        self.canEdit = YES;
    }else{
        self.canEdit = NO;
    }
}

- (void)clickEdit
{
    [self stopAudio];
    
    if(listArray.count <= 0){
        return;
    }

    self.isEdit = YES;
    [mgTableView setEditing:YES animated:YES];
}

- (void)clickRemove
{
    self.isEdit = NO;
    
    NSInteger count = removeArray.count;
    
    if(count > 0){
        
        NSArray *indexArr = [MGData SortOfIndexPath:removeArray];
        
        for(int i=0; i<removeArray.count; i++){
            [MGFile popVoicePathWith:[listArray objectAtIndex:[indexArr[i] integerValue]]];
            [listArray removeObjectAtIndex:[indexArr[i] integerValue]];
        }
        
        [mgTableView deleteRowsAtIndexPaths:removeArray withRowAnimation:UITableViewRowAnimationFade];
        [removeArray removeAllObjects];
    }else{
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MG_REMOVE_TIPS", nil) message:NSLocalizedString(@"MG_REMOVE_MESSAGE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MG_REMOVE_OK", nil) otherButtonTitles:NSLocalizedString(@"MG_REMOVE_REDO", nil), nil];
//        [alert show];
    }
    
    [self editStatus];
    
    [mgTableView setEditing:NO animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (NSArray*)getDataFromDict:(NSDictionary*)dict
{
    NSString *fileName = [dict objectForKey:kVoiceDate];
    NSArray *nameArray = [fileName componentsSeparatedByString:@"_"];
    
    NSString *str0 = nameArray[0];
    NSString *str1 = nameArray[1];
    
    NSArray *timeArray = [str1 componentsSeparatedByString:@"."];
    str1 = [NSString stringWithFormat:@"%@:%@:%@", timeArray[0], timeArray[1], timeArray[2]];
    
    NSString *str2 = [dict objectForKey:kVoiceCate];
    NSString *str3 = [dict objectForKey:kVoiceTime];
    str3 = [NSString stringWithFormat:@"%@s", str3];
    
    NSArray *array = [[NSArray alloc] initWithObjects:str0, str1, str2, str3, nil];
    return array;
}

#pragma mark Voice Change
- (void)changeVoice:(NSDictionary*)dict WithFileName:(NSString*)fileName
{
    self.HUD.label.text = kLocalizable(@"MG_PROCESS");
    
    if (audioPalyer) {
        [audioPalyer stop];
        audioPalyer = nil;
    }
    
    NSString *path = [MGFile getFilePathOfFile:[NSString stringWithFormat:@"%@.wav", fileName]];
    AudioConvertConfig dconfig;
    dconfig.sourceAuioPath = [path UTF8String];
    dconfig.outputFormat = kVoiceOutputFormat;
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
    
    NSURL *url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSError *err = nil;
    if (audioPalyer) {
        [audioPalyer stop];
        audioPalyer = nil;
    }
    audioPalyer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    audioPalyer.delegate = self;
    [audioPalyer play];
}

//停止播放
- (void)stopAudio {
    if (audioPalyer) {
        [audioPalyer stop];
        audioPalyer = nil;
    }
    
    statusArr[lastIndex] = @0;
    UITableViewCell *cell = [mgTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastIndex inSection:0]];
    NSDictionary *dict = [listArray objectAtIndex:lastIndex];
    NSInteger voiceType = [[dict objectForKey:kVoiceCate] integerValue];
    cell.imageView.image = [UIImage imageNamed:imageNames[voiceType]];
}

#pragma mak - 播放回调代理
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    statusArr[lastIndex] = @0;
    UITableViewCell *cell = [mgTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastIndex inSection:0]];
    NSDictionary *dict = [listArray objectAtIndex:lastIndex];
    NSInteger voiceType = [[dict objectForKey:kVoiceCate] integerValue];
    cell.imageView.image = [UIImage imageNamed:imageNames[voiceType]];
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

- (void)button:(UIButton*)btn Status:(NSInteger)type
{
    if(type == 0){
        [btn setImage:[UIImage imageNamed:imageNames[btn.tag]] forState:UIControlStateNormal];
    }else{
        [btn setImage:[UIImage imageNamed:@"tb_pause"] forState:UIControlStateNormal];
    }
}

- (BOOL)prefersStatusBarHidden
{
    if ([[UIScreen mainScreen] bounds].size.height >= 812 && [[UIScreen mainScreen] bounds].size.height+ [[UIScreen mainScreen] bounds].size.width <1500) {
        return NO;
    }
    return YES;
}
@end
