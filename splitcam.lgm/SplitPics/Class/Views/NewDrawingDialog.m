//
//  NewDrawingDialog.m
//  KKKidPaint
//
//  Created by 昭 陈 on 2017/5/17.
//  Copyright © 2017年 spring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewDrawingDialog.h"

@interface NewDrawingDialog()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *msgView;
@property (weak, nonatomic) IBOutlet UITextView *titleView;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@end

@implementation NewDrawingDialog
{
    HANDLE_FUNC confirmHandler;
    HANDLE_FUNC cancelHandler;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void) commonInit{
    [[NSBundle mainBundle] loadNibNamed:@"new_drawing_dialog" owner:self options:nil];
    [self addSubview:[self contentView]];
    self.contentView.frame = self.bounds;
}

-(void) dialogWithTitle:(NSString*)title Message:(NSString*)msg Confirm:(NSString*)confirm Cancel:(NSString*)cancel {
    [self msgView].text = msg;
    [self titleView].text = title;
    [[self confirmBtn] setTitle:confirm forState:UIControlStateNormal];
    [[self cancelBtn] setTitle:cancel forState:UIControlStateNormal];
}

-(void) setConfirmHandler:(HANDLE_FUNC)handler {
    confirmHandler = handler;
}


-(void) setCancelHandler:(HANDLE_FUNC)handler {
    cancelHandler = handler;
}


- (IBAction)onConfirmBtn:(id)sender {
    if(confirmHandler != nil)
        confirmHandler();
}

- (IBAction)onCancelBtn:(id)sender {
    if(cancelHandler != nil)
        cancelHandler();
}

@end
