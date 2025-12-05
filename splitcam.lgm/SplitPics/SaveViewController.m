//
//  SaveViewController.m
//  SplitPics
//
//  Created by spring on 2016/10/20.
//  Copyright © 2016年 ZBNetWork. All rights reserved.
//

#import "SaveViewController.h"
#import "LemonUtil.h"
@interface SaveViewController ()
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) NSMutableArray * array;
@end

@implementation SaveViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor redColor];
  self.view.userInteractionEnabled = YES;
  self.array = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Filters" ofType:@"plist"]];
  self.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"filter0" ofType:@"jpg"]];
  [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOn:)]];
    // Do any additional setup after loading the view.
}

- (void)tapOn:(id)sender {
  NSInteger index = 0;
  for (NSString * name in self.array) {
    UIImage * image = [LemonUtil lemonFilter:self.image Withname:name];
    NSData * data = UIImageJPEGRepresentation(image, 0.7);
    NSString * path = [NSString stringWithFormat:@"/Users/spring/Desktop/filterNew%ld.jpg",(long)index];
    [data writeToFile:path atomically:NO];
    index++;
  }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
