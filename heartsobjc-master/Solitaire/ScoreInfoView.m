//
//  ScoreInfoView.m
//  Hearts
//
//  Created by yysdsyl on 13-9-16.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ScoreInfoView.h"
#include "Config.h"
#include "zhconfig.h"
@implementation ScoreInfoView

@synthesize baseView;
@synthesize nameLabel;
@synthesize scoreLabel;

#define MARGIN_PX 2

- (id)initWithFrame:(CGRect)frame withIntValue:(int)value
{
    
    if (ZH_IS_IPAD) {
        // ipd ui展示存在的问题，上下两个用户（用户3和用户0）存在宽度不够分数不剧中
        /// 解决1.0 加长宽度 backgroundImageViewHeight
        /// 解决1.1 头像右移60 top1ToRight
        /// 解决1.2 头像向下微调5 top1ToDown
        /// 解决1.3 左右头像 下调20
        /// 左右背景长度加长 backgroundImageViewHeight1
        
    }
    int youInfoY=  value ==3 ? 50 : 0;//自己的牌 在竖屏且非刘海屏情况下要向上走一部分
    // 主要作用于3个部分， 一个部分为分数，一个部分为头像，一部分为外框
    
    int youInfox= [self isLandscape] && kScreenWidth >kScreenHeight && value == 3 ? 0 : 0;//自己的牌，在竖屏且非刘海屏情况下要向走一部分
    if ([self isLandscape] && kScreenWidth >kScreenHeight && value == 3 ) { NSLog(@"zzx test ans 0311");}
    // 主要作用于3个部分， 一个部分为分数，一个部分为头像，一部分为外框
    self = [super initWithFrame:frame];
    if (self) {
        //0313 by zzx 竖屏横屏用户的02 x都需要右移动3
        int scoollIpd02x=0;
        // 0314 ipd 0 2用户的背景需要上一点
        // 0314 18 iphone 的旋转后效果不一样
        int testx02=0;
        //        int testx02= value ==1 && ![self isLandscape] && !(ZH_IS_IPAD) && kScreenWidth +kScreenHeight <1500 ? 30:0;
        // 0315 发现ipd左右的高度比正常要高10多，修正高度 -3 再把竖屏情况下value ==3的top向下移动一点
        int pianyiyIpd0315=0;//对竖屏-3
        int Top1pianyiyIpd0315=0;//对横竖屏-3
        int pianyiy=8;
        int shupianyi=0;
        int shupianyix= 0 ;
        int Ipd_shupianyix= 0 ;
        int Ipd_shupianyix02=0;
        int Ipd_shupianyiY02=0;
        int Ipd_shupianyiScY02=0;
        CGFloat backgroundImageViewHeight1=0;
        if (![self isLandscape ] && kScreenHeight + kScreenWidth <1500) {
            if (value % 2 == 0) {
                shupianyi =40;
                //                Ipd_shupianyiY= 0 ;
            }
            if (value % 2 == 1) {
                shupianyix =20;
                Ipd_shupianyix= ZH_IS_IPAD ? 60:0 ;
            }
        }
        if (ZH_IS_IPAD && kScreenWidth + kScreenHeight >1500 ) {
            if (value %2 ==0) {
                ///目前只想要左右分数下移20
                
                Ipd_shupianyix02=10;
                Ipd_shupianyiY02=30;
                if ([self isLandscape ] && kScreenWidth > kScreenHeight) {
                    Ipd_shupianyiScY02=20;
                }
                scoollIpd02x=10;
            }
            if (value == 3) {
                Top1pianyiyIpd0315=5;
            }
            if (value == 1) {
                Top1pianyiyIpd0315=3;
            }
        }
        if (ZH_IS_IPAD) {
            if (![self isLandscape ] && kScreenHeight > kScreenWidth ) {
                if (value % 2 == 0) {
                    shupianyi =40;
                    //                Ipd_shupianyiY= 0 ;
                    pianyiyIpd0315 =3;//竖屏
                }
                if (value % 2 == 1) {
                    //                    shupianyix =20;
                    Ipd_shupianyix= ZH_IS_IPAD ? 60:0 ;
                    
                }
            }
        }
        
        if (ZH_IS_IPAD) {
            if (value %2 ==0) {
                ///目前只想要左右分数下移20
                
                Ipd_shupianyix02=10;
                Ipd_shupianyiY02=30;
                if ([self isLandscape ] && kScreenWidth > kScreenHeight) {
                    Ipd_shupianyiScY02=20;
                }
            }
        }
        

        
        self.baseView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN_PX, MARGIN_PX, frame.size.width - 2*MARGIN_PX, frame.size.height - 2*MARGIN_PX+20)];
        // 创建一个 UIImageView 并设置为和 ScoreInfoView 相同的大小
        CGFloat top1ToRight= ZH_IS_IPAD ? MARGIN_PX -frame.size.width + 2*MARGIN_PX +110 : MARGIN_PX -frame.size.width + 2*MARGIN_PX +50;
        CGFloat top1ToDown= ZH_IS_IPAD ? MARGIN_PX+5 + Top1pianyiyIpd0315: MARGIN_PX+5;
        CGFloat top1Width=(frame.size.width - 2*MARGIN_PX);
        CGFloat top1Height =frame.size.height - 2*MARGIN_PX+20-3-6;
        UIImageView *top1 = [[UIImageView alloc]initWithFrame:CGRectMake(top1ToRight , top1ToDown, top1Width, top1Height)];
        CGFloat backgroundImageViewHeight= ZH_IS_IPAD ? (frame.size.width - 2*MARGIN_PX)+3: frame.size.height - 2*MARGIN_PX+30 -3;
        // 创建一个 UIImageView 并设置为和 ScoreInfoView 相同的大小
        UIImageView *backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(MARGIN_PX -frame.size.width + 2*MARGIN_PX +shupianyix -youInfox + Ipd_shupianyix +testx02, MARGIN_PX -youInfoY, (frame.size.width - 2*MARGIN_PX)* 2+5,backgroundImageViewHeight)];
        NSLog(@"zzx 20240326   1 %lf",top1.frame.size.width);
        
        
        if (value  % 2== 0) {
//             top1Width=(frame.size.width - 2*MARGIN_PX) +4;
//             top1Height =frame.size.height - 2*MARGIN_PX+20-3-6 5;
            NSLog(@"zzx 20240326 0 %lf",top1.frame.size.width);
            CGFloat top1ToDown1= ZH_IS_IPAD ? 40: 0;
            backgroundImageViewHeight1= ZH_IS_IPAD && kScreenWidth + kScreenHeight > 1500 ?  50: 0;
            // 创建一个 UIImageView 并设置为和 ScoreInfoView 相同的大小
            //20.51 -10
            int pianyiy02=0;
            int ipdoianyiy02=0;
            if ( kScreenWidth + kScreenHeight <1500) {
                pianyiy02=10;
            }else{
                ipdoianyiy02=17;
            }
            top1 = [[UIImageView alloc]initWithFrame:CGRectMake(MARGIN_PX , top1ToDown1 + MARGIN_PX - frame.size.height + 2*MARGIN_PX +45 -pianyiy02, top1Width, top1Height)];//
            NSLog(@"zzx 20240326 0 0 %lf",top1.frame.size.width);
            // 创建一个 UIImageView 并设置为和 ScoreInfoView 相同的大小
            backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(MARGIN_PX-3, MARGIN_PX - frame.size.height + 2*MARGIN_PX-30+pianyiy02, (frame.size.width - 2*MARGIN_PX)+3, (frame.size.height - 2*MARGIN_PX+30)*2 +backgroundImageViewHeight1 -15 -ipdoianyiy02 )];
            
            if (![self isLandscape]) {
                int x =0,y=0;
                if ( kScreenWidth + kScreenHeight <1500) {
                     x =1,y=5;
                }
                top1 = [[UIImageView alloc]initWithFrame:CGRectMake(MARGIN_PX , top1ToDown1 +MARGIN_PX - frame.size.height + 2*MARGIN_PX +30 +10, top1Width, top1Height)];
                NSLog(@"zzx 20240326 0 shu %lf",top1.frame.size.width);
                // 创建一个 UIImageView 并设置为和 ScoreInfoView 相同的大小
                backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(MARGIN_PX-3, MARGIN_PX - frame.size.height + 2*MARGIN_PX-30 + shupianyi +10, (frame.size.width - 2*MARGIN_PX)+3+x, (frame.size.height - 2*MARGIN_PX+30)*2-pianyiy02 +backgroundImageViewHeight1 -ipdoianyiy02 -pianyiyIpd0315-y)];
            }
        }
        
        if (value ==1 && ![self isLandscape] && !(ZH_IS_IPAD) && kScreenWidth +kScreenHeight <1500 ) {
            NSLog(@"zzx MARGIN_PX-3 =%lf",MARGIN_PX -frame.size.width + 2*MARGIN_PX +shupianyix -youInfox + Ipd_shupianyix +testx02);
            NSLog(@"zzx MARGIN_PX-3 =%lf",MARGIN_PX -frame.size.width + 2*MARGIN_PX +shupianyix);
            NSLog(@"zzx MARGIN_PX-3 1 =%d",shupianyix );
        }
        // 设置图片，我假设你的图片名为 @"background"
        backgroundImageView.image = [UIImage imageNamed:@"topSkin"];
        
        // 添加 UIImageView 到 ScoreInfoView
        [self addSubview:backgroundImageView];
        
        
        NSString *TopimageNamed = [NSString stringWithFormat:@"top%d", value];
        // 设置图片，我假设你的图片名为 @"background"
        top1.image = [UIImage imageNamed:TopimageNamed];
        
        // 添加 UIImageView 到 ScoreInfoView
        [backgroundImageView addSubview:top1];
//        if (ZH_IS_IPAD && kScreenWidth + kScreenHeight >1500) {
//            top1.contentMode = UIViewContentModeScaleAspectFit;
//        }
                top1.contentMode = UIViewContentModeScaleAspectFit;
        
        // 将 backgroundImageView 发送到视图层的最底部
        [self sendSubviewToBack:top1];
        
        // 将 backgroundImageView 发送到视图层的最底部
        [self sendSubviewToBack:backgroundImageView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.baseView.frame.size.width, self.baseView.frame.size.height/2-MARGIN_PX/2)];
        self.nameLabel.textAlignment = UITextAlignmentCenter;
        self.nameLabel.text = @"";
        self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0 +shupianyix -youInfox +Ipd_shupianyix -Ipd_shupianyix02 +scoollIpd02x +testx02, self.baseView.frame.size.height/2+MARGIN_PX/2 - pianyiy +shupianyi - youInfoY +Ipd_shupianyiY02 -Ipd_shupianyiScY02, self.baseView.frame.size.width, self.baseView.frame.size.height/2-MARGIN_PX/2)];
        self.scoreLabel.textAlignment = UITextAlignmentCenter;
        self.scoreLabel.text = @"";
        self.scoreLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.scoreLabel.textColor = [UIColor whiteColor];
        self.nameLabel.textColor = [UIColor blueColor];
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        self.scoreLabel.adjustsFontSizeToFitWidth = YES;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            self.nameLabel.font = [UIFont systemFontOfSize:24];
            self.scoreLabel.font = [UIFont systemFontOfSize:34];
        }
        else
        {
            self.nameLabel.font = [UIFont systemFontOfSize:12];
            self.scoreLabel.font = [UIFont systemFontOfSize:12];
        }
        //        [self.baseView addSubview:self.nameLabel];
        [self.baseView addSubview:self.scoreLabel];
        [self addSubview:self.baseView];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIColor* sepColor = RGB(255, 0, 0, 1);
        // Initialization code
        /*
         UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MARGIN_PX, frame.size.height)];
         leftView.backgroundColor = sepColor;
         UIView* rightView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width-MARGIN_PX, 0, MARGIN_PX, frame.size.height)];
         rightView.backgroundColor = sepColor;
         UIView* topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, MARGIN_PX)];
         topView.backgroundColor = sepColor;
         UIView* bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - MARGIN_PX, frame.size.width, MARGIN_PX)];
         bottomView.backgroundColor = sepColor;
         */
        // 20240403 放大1.5倍
        CGFloat toMax=1.5;
        CGFloat toMax1=1.0;
        self.baseView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN_PX, MARGIN_PX, (frame.size.width - 2*MARGIN_PX) *toMax1, (frame.size.height - 2*MARGIN_PX) * toMax1)];
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(-13, 0, (self.baseView.frame.size.width) *toMax, (self.baseView.frame.size.height/2-MARGIN_PX/2) *toMax)];
        self.nameLabel.textAlignment = UITextAlignmentCenter;
        self.nameLabel.text = @"";
        self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(-13, self.baseView.frame.size.height/2+MARGIN_PX/2, (self.baseView.frame.size.width) * toMax, (self.baseView.frame.size.height/2-MARGIN_PX/2) *toMax)];
        self.scoreLabel.textAlignment = UITextAlignmentCenter;
        self.scoreLabel.text = @"";
        //UIView* sepView = [[UIView alloc] initWithFrame:CGRectMake(0, self.baseView.frame.size.height/2-MARGIN_PX, self.baseView.frame.size.width, MARGIN_PX)];
        //sepView.backgroundColor = sepColor;
        self.scoreLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.scoreLabel.textColor = [UIColor blueColor];
        self.nameLabel.textColor = [UIColor blueColor];
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        self.scoreLabel.adjustsFontSizeToFitWidth = YES;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            self.nameLabel.font = [UIFont systemFontOfSize:24];
            self.scoreLabel.font = [UIFont systemFontOfSize:24];
        }
        else
        {
            self.nameLabel.font = [UIFont systemFontOfSize:12];
            self.scoreLabel.font = [UIFont systemFontOfSize:12];
        }
        [self.baseView addSubview:self.nameLabel];
        [self.baseView addSubview:self.scoreLabel];
        //[self.baseView addSubview:sepView];
        /*
         [self addSubview:topView];
         [self addSubview:bottomView];
         [self addSubview:leftView];
         [self addSubview:rightView];
         */
        [self addSubview:self.baseView];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(id) adjustUI:(CGRect)frame withIntValue:(int)value {
    
}

- (void)setInfo:(NSString*)name curscore:(int)curscore totalscore:(int)totalscore
{
    self.nameLabel.text = name;
    self.scoreLabel.text = [NSString stringWithFormat:@"%d/%d",curscore,totalscore];
    [self.scoreLabel setNeedsDisplay];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
- (BOOL)isLandscape {
    // 横屏
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return UIDeviceOrientationIsLandscape(orientation);
}
@end
