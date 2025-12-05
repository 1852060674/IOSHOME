//
//  ShareView.h
//  eyeColorPlus
//
//  Created by shen on 14-7-22.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareService.h"

@class ShareView;

@protocol ShareViewDelegate <NSObject>

@optional
-(void) closeShareView:(ShareView *)shareView;
-(void) saveImageShareView:(ShareView *)shareView;

-(void) shareView:(ShareView *)shareView shareImageToPlatform:(ZBShareType)shareType;

-(void) SMSShareView:(ShareView *)shareView;
-(void) FacebookShareView:(ShareView *)shareView;
-(void) TwitterShareView:(ShareView *)shareView;
-(void) GooglePlusShareView:(ShareView *)shareView;
-(void) TumblrShareView:(ShareView *)shareView;
-(void) MailShareView:(ShareView *)shareView;
-(void) InstagramShareView:(ShareView *)shareView;
-(void) WhatsAppShareView:(ShareView *)shareView;
-(void) WechatShareView:(ShareView *)shareView;
-(void) DropBoxShareView:(ShareView *)shareView;
-(void) FlickrShareView:(ShareView *)shareView;
-(void) VKontakteShareView:(ShareView *)shareView;
-(void) LinkdinShareView:(ShareView *)shareView;
-(void) SinaWeiboShareView:(ShareView *)shareView;
-(void) TencentWeiboShareView:(ShareView *)shareView;
-(void) PinterestShareView:(ShareView *)shareView;
-(void) LineShareView:(ShareView *)shareView;
-(void) AirPrintShareView:(ShareView *)shareView;
-(void) copyShareView:(ShareView *)shareView;
@end

@interface ShareView : UIView
@property (nonatomic, strong) NSArray *platforms;
@property (nonatomic, weak) id<ShareViewDelegate> delegate;

- (void)setupSubView;
@end
