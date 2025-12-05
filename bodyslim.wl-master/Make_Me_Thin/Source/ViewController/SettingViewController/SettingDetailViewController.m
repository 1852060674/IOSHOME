//
//  SettingAutoSaveViewController.m
//  MySketch
//
//  Created by ZB_Mac on 15/8/7.
//  Copyright (c) 2015年 ZB. All rights reserved.
//

#import "SettingDetailViewController.h"
#import "ZBCommonMethod.h"
#import "ZBCommonDefine.h"

@interface SettingDetailViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SettingDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
#ifdef BUTTON_LIKE
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
#endif
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
    
    self.titleLabel.text = NSLocalizedStringFromTable(@"SETTING_VC_TITLE", @"setting", @"");
}

#pragma mark - UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionHeaders.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *titles = self.sectionTitles[section];
    return titles.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];

//    BOOL selected = [self.selectedPaths containsObject:indexPath];
//    cell.accessoryType = (selected)?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
//    cell.selected = selected;

    cell.textLabel.text = self.sectionTitles[indexPath.section][indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
#ifdef BUTTON_LIKE
    cell.backgroundColor = [UIColor clearColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
    NSString *prefix = [ZBCommonMethod isIpad]?@"ipad":@"iphone";
    NSString *suffix = @"middle";
    
    if (indexPath.row == 0) {
        suffix = @"up";
    }
    else if (indexPath.row+1 == array.count)
    {
        suffix = @"down";
    }
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%@", prefix, suffix]];
    imageView.image = image;
    
    cell.backgroundView = imageView;
#endif
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sectionHeaders[section];
}
#pragma mark - UITableView Delegate
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableCell = [tableView cellForRowAtIndexPath:indexPath];
    tableCell.accessoryType = UITableViewCellAccessoryNone;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableCell = [tableView cellForRowAtIndexPath:indexPath];
    tableCell.accessoryType = UITableViewCellAccessoryCheckmark;
 
    if (self.actionBlock) {
        self.actionBlock(indexPath);
    }
//    [tableView reloadData];
}

#pragma mark -

- (IBAction)goBack:(id)sender
{
    //    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView selectRowAtIndexPath:self.selectedPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.selectedPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
