//
//  NewDrawingDialog.h
//  KKKidPaint
//
//  Created by 昭 陈 on 2017/5/17.
//  Copyright © 2017年 spring. All rights reserved.
//

#ifndef NewDrawingDialog_h
#define NewDrawingDialog_h

#include <UIKit/UIKit.h>
typedef void(^HANDLE_FUNC)();

@interface NewDrawingDialog : UIView

-(void) dialogWithTitle:(NSString*)title Message:(NSString*)msg Confirm:(NSString*)confirm Cancel:(NSString*)cancel;

-(void) setConfirmHandler:(HANDLE_FUNC)handler;
-(void) setCancelHandler:(HANDLE_FUNC)handler;

@end

#endif /* NewDrawingDialog_h */
