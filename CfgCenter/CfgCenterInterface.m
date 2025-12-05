#ifdef UNITY_MODE
#import "sys/utsname.h"
#import "Admob.h"
#import "UnityAppController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "AdmobRewardVideoClient.h"
#import "AdmobVCDelegate.h"
#import <AVFoundation/AVAudioSession.h>
#import "BannerAdClient.h"
#import "SimpleNotification.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "ApplovinMaxWrapper.h"
#ifdef ATT_ENABLE
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
#endif

//declare
int getIDFAStatus();
void requestIDFA();

static NSString *URTStringFromUTF8String(const char *bytes) { return bytes ? @(bytes) : nil; }

#ifdef UNITY_MODE
UIViewController* getUnityControler() {
    return ((UnityAppController *)[UIApplication sharedApplication].delegate).rootViewController;
}
#endif

void InitialCfgCenter() {
    [[AdmobViewController shareAdmobVC] checkConfigUD];
}

void ShowRT() {
    [[[AdmobViewController shareAdmobVC] rtService] showRT:getUnityControler()];
}

void DoRT() {
    return [[[AdmobViewController shareAdmobVC] rtService] doRT];
}

BOOL DoFeedback() {
    return [[[AdmobViewController shareAdmobVC] rtService] doFeedback:getUnityControler()];
}

BOOL DecideShowRT() {
    return [[AdmobViewController shareAdmobVC] decideShowRT:getUnityControler()];
}

long GetUserDefaultLong(const char* key) {
    NSUserDefaults* setting = [NSUserDefaults standardUserDefaults];
    return [setting integerForKey:URTStringFromUTF8String(key)];
}

void onOrientationChange(int currOrientation) {
    [[AdmobViewController shareAdmobVC] onOrientationChanged];
}

#pragma mark - admob

void ShowAdmobBanner (const char* placeid, int align) {
    UIViewController* gameScreen = getUnityControler();
    [[AdmobViewController shareAdmobVC] show_admob_banner:gameScreen.view placeid:URTStringFromUTF8String(placeid)];
    switch(align) {
        case 0:
            [[AdmobViewController shareAdmobVC] setBannerAlign:AD_TOP];
            break;
        case 1:
            [[AdmobViewController shareAdmobVC] setBannerAlign:AD_CENTER];
            break;
        case 2:
            [[AdmobViewController shareAdmobVC] setBannerAlign:AD_BOTTOM];
            break;
    }
}

CGFloat admobX(){
    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];
    return  applovinWrapper.getAdmobX;
}
CGFloat admobY(){
    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];
    return  applovinWrapper.getAdmobY;
}
CGFloat admobWidth(){
    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];
    return  applovinWrapper.getAdmobWidth;
}
CGFloat admobHeight(){
    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];
    return  applovinWrapper.getAdmobHeight;
}

CGFloat getMaxBannerHeight(){
    return [[AdmobViewController shareAdmobVC] getMaxBannerHeightPx];
}

CGFloat getSafeAreaBottom(){
    return [[AdmobViewController shareAdmobVC] getSafeAreaBottom];
}

CGFloat getSafeAreaTop(){
    return [[AdmobViewController shareAdmobVC] getSafeAreaTop];
}

CGFloat getSafeAreaLeft(){
    return [[AdmobViewController shareAdmobVC] getSafeAreaLeft];
}

CGFloat getSafeAreaRight(){
    return [[AdmobViewController shareAdmobVC] getSafeAreaRight];
}



void RemoveBanner () {
    UIViewController* gameScreen = getUnityControler();
    [[AdmobViewController shareAdmobVC] remove_banner:gameScreen.view];
}

bool IsBannerAdLoaded () {
    return [[AdmobViewController shareAdmobVC] bannerAdLoaded:0];
}

void ShowAdmobNative (const char * placeid, int align) {
    UIViewController* gameScreen = getUnityControler();
    CGSize size = [UIScreen mainScreen].bounds.size;
    [[AdmobViewController shareAdmobVC] show_admob_native:size.width/2-150 posy:size.height/2-125 width:300 height:250 view:gameScreen.view];
}

void RemoveNative () {
    UIViewController* gameScreen = getUnityControler();
    [[AdmobViewController shareAdmobVC] remove_native:gameScreen.view];
}

bool IsInterstitialADLoaded (int placeid) {
    return [[AdmobViewController shareAdmobVC] admob_interstial_ready:placeid];
}

bool ShowAdmobInterstitial (int placeid) {
    return [[AdmobViewController shareAdmobVC] show_admob_interstitial:getUnityControler() placeid:placeid];
}

void setBannerAdCallBack(BannerAdLoadedCallback loaded,
                        BannerAdFailedLoadedCallback failed,
                         BannerAdClickCallback click) {
    [AdmobViewController shareAdmobVC].bannerClient = [[BannerAdClient alloc]
                                                       initWithCallbackLoaded:loaded
                                                       failedLoaded:failed
                                                       click:click];
}

void setAdmobVCCallBack(AdmobVCDidReceiveInterstitialAdCallback didRecieve,
                        AdmobVCDidCloseInterstitialAdCallback didClose,
                        AdmobVCDidFailedToLoadInterstitialAdCallback didFailed,
                        AdmobVCDidShowInterstitialAdCallback didShow,
                        AdmobVCDidClickInterstitialAdCallback didClick) {
    [AdmobViewController shareAdmobVC].interadClient = [[AdmobVCDelegate alloc]
                                                        initWithCallbackReceive:didRecieve
                                                        close:didClose
                                                        failed: didFailed
                                                        show: didShow
                                                        click: didClick];
    // auto check interadClient when interstitial ad callbacks from 3.5.1
//    [[AdmobViewController shareAdmobVC] setDelegate:[AdmobViewController shareAdmobVC].interadClient];
}

void setRewardVideoCallBack(AdmobRewardVideoAdDidReceiveAdCallback didRecieve,
                            AdmobRewardVideoAdDidFailToReceiveAdWithErrorCallback didFailed,
                            AdmobRewardBasedVideoAdDidOpenCallback didOpen,
                            AdmobRewardBasedVideoAdDidStartPlayingCallback didStartPlay,
                            AdmobRewardBasedVideoAdDidCloseCallback didClose,
                            AdmobRewardBasedVideoAdWillLeaveApplicationCallback willLeave,
                            AdmobRewardBasedVideoAdDidRewardUserWithRewardCallback didReward) {
    [AdmobViewController shareAdmobVC].rewardAdClient = [[AdmobRewardVideoClient alloc]
                                                         initWithCallbackReceive:didRecieve
                                                         failed:didFailed
                                                         open:didOpen
                                                         startPlay:didStartPlay
                                                         close:didClose
                                                         leave:willLeave
                                                         reward:didReward];
    [[AdmobViewController shareAdmobVC] init_reward_ad];
}

void setOpenAdCallBack(AdmobVCDidReceiveInterstitialAdCallback didRecieve,
                       AdmobVCDidCloseInterstitialAdCallback didClose,
                       AdmobVCDidFailedToLoadInterstitialAdCallback didFailed,
                       AdmobVCDidShowInterstitialAdCallback didShow,
                       AdmobVCDidClickInterstitialAdCallback didClick) {
   [AdmobViewController shareAdmobVC].openAdClient = [[AdmobVCDelegate alloc]
                                                       initWithCallbackReceive:didRecieve
                                                       close:didClose
                                                       failed: didFailed
                                                       show: didShow
                                                       click: didClick];
    [[AdmobViewController shareAdmobVC] init_open_ad];
}

void loadRewardVideo() {
//    [[[AdmobViewController shareAdmobVC] rewardAdClient] load];
}

bool isRewardLoaded() {
    return [[AdmobViewController shareAdmobVC] isRewardAdLoaded:0];
}

bool showRewardVideo() {
    return [[AdmobViewController shareAdmobVC] showRewardAd:getUnityControler() placeid:0];
}

void loadOpenAd() {
    //open ad auto loaded after initial
}

bool isOpenAdLoaded() {
    return [[AdmobViewController shareAdmobVC] isOpenAdLoaded:0];
}

bool showOpenAd() {
    return [[AdmobViewController shareAdmobVC] showOpenAd:getUnityControler() placeid:0];
}

int GetDeviceContryCode(intptr_t* code) {
    NSString* contry = [ConfigCenter getContryCode];
    int length = (int)strlen([contry cStringUsingEncoding:NSUTF8StringEncoding]);
    char* res = (char*)malloc(length + 1);
    if(res == NULL) {
        return -1;
    }
    strncpy(res, [contry cStringUsingEncoding:NSUTF8StringEncoding], length);
    res[length] = 0;
    *code = (intptr_t)(res);
    return length;
}

int GetDeviceLanguage(intptr_t* language) {
    NSString* lang = [ConfigCenter getLanguageCode];
    int length = (int)strlen([lang cStringUsingEncoding:NSUTF8StringEncoding]);
    char* res = (char*)malloc(length + 1);
    if(res == NULL) {
        return -1;
    }
    strncpy(res, [lang cStringUsingEncoding:NSUTF8StringEncoding], length);
    res[length] = 0;
    *language = (intptr_t)(res);
    return length;
}

bool canOpenUrl(const char * app) {
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%s://", app]];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        return true;
    } else {
        return false;
    }
}

void openUrl(const char * app) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@(app)]];
}

void iOSPopupOpenNotification() {
    [SimpleNoticication popupOpenNotification];
}

void iOSCancelNotification(int notiid) {
    [SimpleNoticication cancel:notiid];
}

void iOSCancelAllNotification() {
    [SimpleNoticication cancelAll];
}

void iOSSetNotification(int notiid, long span, const char * content) {
    [SimpleNoticication setLocalNotification:notiid time:span content:URTStringFromUTF8String(content)];
}

int getSystemVolume() {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    CGFloat volume = audioSession.outputVolume;
    return 100 * volume;
}

#pragma mark -
#pragma mark ios14 get idfa

int getIDFAStatus() {
#ifdef ATT_ENABLE
    if(@available(iOS 14, *)) {
        ATTrackingManagerAuthorizationStatus status = ATTrackingManager.trackingAuthorizationStatus;
        switch (status) {
            case ATTrackingManagerAuthorizationStatusDenied:
            case ATTrackingManagerAuthorizationStatusRestricted:
                return -1;
            case ATTrackingManagerAuthorizationStatusAuthorized:
                return 1;
            case ATTrackingManagerAuthorizationStatusNotDetermined:
                return 0;
            default:
                return 0;
        }
    } else {
        if ([ASIdentifierManager.sharedManager isAdvertisingTrackingEnabled]) {
            return 1;
        }else {
            return -1;
        }
    }
#else
    return 1;
#endif
}

void requestIDFA() {
#ifdef ATT_ENABLE
    int status = getIDFAStatus();
    if(status == 0) {
        if(@available(iOS 14, *)) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                // Tracking authorization completed. Start loading ads here.
                // [self loadAd];
            }];
        }
    } else if(status == -1){
        NSURL* url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if(url != nil) {
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
#endif
}

bool needShowIDFAWarmUpMsg() {
    return getIDFAStatus() < 1;  //-1 Denied or 0 Unknow
}

float getSystemScreenScale() {
    return [[UIScreen mainScreen] scale];
}

///获取具体的型号
int getDeviceModel(intptr_t* devicemodel) {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    int length = (int)strlen([deviceString cStringUsingEncoding:NSUTF8StringEncoding]);
    char* res = (char*)malloc(length + 1);
    if(res == NULL) {
        return -1;
    }
    strncpy(res, [deviceString cStringUsingEncoding:NSUTF8StringEncoding], length);
    res[length] = 0;
    *devicemodel = (intptr_t)(res);
    return length;
}

void setAudienceNetworkATE(bool enable) {
   [FBAdSettings setAdvertiserTrackingEnabled:YES];
}
#endif
