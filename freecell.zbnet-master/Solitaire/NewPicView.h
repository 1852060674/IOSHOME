//
//  NewPicView.h
//  Canfield
//
//  Created by macbook on 14/12/8.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef Canfield_NewPicView_h
#define Canfield_NewPicView_h

enum PicType {
    kPicTypeCardForground = 0,
    kPicTypeCardBack = 1,
    kPicTypeGameBack = 2
};

@interface NewPicView : UIView
@property (strong, nonatomic) UIImageView* imageView;
@property (strong, nonatomic) UIImageView* shadowView;
@property (assign, nonatomic) BOOL selected;
@property (assign, nonatomic) NSInteger theid;
@property (assign, nonatomic) NSInteger type;

- (id)initWithFrame:(CGRect)frame imgName:(NSString*)imgname custom:(BOOL)flag idx:(NSInteger)idx type:(NSInteger)type;
- (void)hideShadow:(BOOL) willHide;
@end

#endif
