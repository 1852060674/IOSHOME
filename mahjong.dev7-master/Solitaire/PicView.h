//
//  PicView.h
//  Solitaire
//
//  Created by apple on 13-7-21.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {PIC_BACKGROUND=1,PIC_CARDBACK=2};

@interface PicView : UIView

@property (strong, nonatomic) UIImageView* imageView;
@property (strong, nonatomic) UIImageView* gouView;
@property (assign, nonatomic) BOOL checkFlag;
@property (assign, nonatomic) NSInteger theid;
@property (assign, nonatomic) NSInteger type;
@property (strong, nonatomic) NSString* name;

- (id)initWithFrame:(CGRect)frame border:(CGFloat)border;

- (void)setImage:(NSString*)imgname custom:(BOOL)flag idx:(NSInteger)idx type:(NSInteger)type;
- (void)setCheck:(BOOL)flag;

@end
