//
//  ResultViewController.m
//  QRReader
//
//  Created by awt on 15/8/5.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import "ResultViewController.h"
#import "Config.h"

@implementation ResultViewController

- (void) layoutTopView
{
    if (IS_IPAD) {
        self.topViewCantainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, CELL_WIDTH *4)];
        self.returnBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, CELL_WIDTH*2*209/163, CELL_WIDTH*2)];
        //        self.scanTypeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CELL_WIDTH*2, CELL_WIDTH*2*209/163, CELL_WIDTH*2)];
     //   [self.scanTypeBtn setCenter:CGPointMake(self.topViewCantainer.center.x, self.scanTypeBtn.center.y)];
       // self.cameraSwtitchBtn = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 4*CELL_WIDTH, 0, CELL_WIDTH*3*249/231, CELL_WIDTH*3)];//
        self.topLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH*10, CELL_WIDTH*3)];
        [self.topLable setFont:[UIFont systemFontOfSize:CELL_WIDTH*1.2]];
        [self.topLable setTextColor:[UIColor darkGrayColor ]];
        [self.topLable setCenter:CGPointMake(self.topViewCantainer.center.x,self.topViewCantainer.center.y )];
        [self.returnBtn setBackgroundImage:[UIImage imageNamed:@"return"] forState:UIControlStateNormal];
    }
    else{
        self.topViewCantainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, CELL_WIDTH *4)];
        self.returnBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, CELL_WIDTH*3*209/163, CELL_WIDTH*3)];
        //        self.scanTypeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CELL_WIDTH*2, CELL_WIDTH*2*209/163, CELL_WIDTH*2)];
        self.topLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH*10, CELL_WIDTH*3)];
        [self.topLable setFont:[UIFont systemFontOfSize:CELL_WIDTH*1.2]];
        [self.topLable setTextColor:[UIColor darkGrayColor ]];
        [self.topLable setCenter:CGPointMake(self.topViewCantainer.center.x,self.topViewCantainer.center.y )];
       
    }
    
    [self.topLable setText:@"Scan Result"];
    [self.topLable setAdjustsFontSizeToFitWidth:YES];
    [self.topLable setTextAlignment:NSTextAlignmentCenter];
    //[self.topLable setTintAdjustmentMode:UIViewTintAdjustmentModeAutomatic];
    [self.topViewCantainer addSubview:self.topLable];
    

    [self.returnBtn setCenter:CGPointMake(self.returnBtn.center.x, self.topViewCantainer.center.y)];


    [self.topViewCantainer setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.9]];
    [self.topViewCantainer addSubview:self.returnBtn];
    [self.view addSubview:self.topViewCantainer];
    [self.returnBtn addTarget:self action:@selector(quitViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    //
    //    [self.scanTypeBtn addTarget:self action:@selector(showScantypeList:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.scanTypeBtn setBackgroundImage:[UIImage imageNamed:@"trangle"]
 
    
}
- (void)layoutResultLable
{
    
}
- (void) quitViewController : (UIButton *)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
