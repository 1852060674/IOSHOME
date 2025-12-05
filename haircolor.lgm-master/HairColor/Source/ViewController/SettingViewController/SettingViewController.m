//
//  SettingViewController.m
//  EyeColor4.0
//
//  Created by ZB_Mac on 14-12-23.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#import "SettingViewController.h"
#import "UserSettingManger.h"
#import <MessageUI/MessageUI.h>
#import "ZBCommonMethod.h"
#import "ZBCommonDefine.h"
#import "ShareService.h"
#import "Admob.h"
#import "AdUtility.h"
//#import "PurchaseViewController.h"
#import "SettingDetailViewController.h"
#import "PhotoStore.h"
#import "SettingPopAnimator.h"
//#import "VideoPlayViewController.h"

typedef enum : NSUInteger {
    CellActionNone,
    CellActionResolution,
    CellActionAutoSave,
    CellActionSplitScreen,
    CellActionFeather,
    CellActionSmoothEdge,
    CellActionAutoSaveCutResultSystem,
    CellActionAutoSaveCutResultApp,
    CellActionAccurateCut,
    
    CellActionGuide,
    CellActionGuide_2,
    CellActionUpgrade,
    CellActionFeedback,
    CellActionShare,
    CellActionRT,
    CellActionClearCache,
    
} CellAction;

@interface SettingViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, ShareServiceDelegate, UIAlertViewDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (strong, nonatomic) NSArray *actions;

@end

@implementation SettingViewController

@synthesize actions=_actions;
-(NSArray *)actions
{
    if (_actions == nil) {
        
        if (![AdUtility allPurchased]) {
            _actions = @[
                         @[
                             @(CellActionResolution),
//                             @(CellActionAccurateCut),
//                             @(CellActionFeather),
//                             @(CellActionSmoothEdge),
                             @(CellActionAutoSave),
//                             @(CellActionAutoSaveCutResultSystem),
                             @(CellActionAutoSaveCutResultApp),
                             ],
                         @[
                             @(CellActionShare),
                             @(CellActionFeedback),
                             @(CellActionUpgrade),
//                             @(CellActionGuide),
                             @(CellActionGuide_2),
                             @(CellActionClearCache),
                             ],
                         ];
        }
        else
        {
            _actions = @[
                         @[
                             @(CellActionResolution),
//                             @(CellActionAccurateCut),
//                             @(CellActionFeather),
//                             @(CellActionSmoothEdge),
                             @(CellActionAutoSave),
//                             @(CellActionAutoSaveCutResultSystem),
                             @(CellActionAutoSaveCutResultApp),
                             ],
                         @[
                             @(CellActionShare),
                             @(CellActionFeedback),
//                             @(CellActionGuide),
                             @(CellActionGuide_2),
                             @(CellActionClearCache),
                             ],
                         ];
        }
    }
    return _actions;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [_backBtn setTitle:NSLocalizedStringFromTable(@"SETTING_BACK", @"setting", @"") forState:UIControlStateNormal];

    // Do any additional setup after loading the view.
#ifdef BUTTON_LIKE
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

#endif
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.width*0.15)];
    label.textAlignment = NSTextAlignmentCenter;
    
    label.text = [NSLocalizedStringFromTable(@"SETTING_VERSION", @"setting", @"") stringByAppendingString:[NSString stringWithFormat:@"v%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey]]];
    label.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:label];
    
    self.titleLabel.text = NSLocalizedStringFromTable(@"SETTING_VC_TITLE", @"setting", @"");
}

-(NSString *)getAppName
{
    NSString *prodName = NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @"");
    
    if (!prodName || [prodName isEqualToString:@"CFBundleDisplayName"]) {
        NSBundle*bundle =[NSBundle mainBundle];
        NSDictionary*info =[bundle infoDictionary];
        prodName =[info objectForKey:@"CFBundleDisplayName"];
    }
    else if (!prodName)
    {
        prodName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    }
    
    return prodName;
}

-(NSString *)getSettingShareMessage
{
    NSString *message = [NSString stringWithFormat:@"%@%@%@\n%@", NSLocalizedStringFromTable(@"SETTING_SHARE_MESSAGE_1", @"setting", @""), [self getAppName], NSLocalizedStringFromTable(@"SETTING_SHARE_MESSAGE_2", @"setting", @""), APP_URL];
    return message;
}

-(NSString *)getSettingShareTitle
{
    NSString *title = NSLocalizedStringFromTable(@"SETTING_SHARE_TITLE", @"setting", @"");
    return title;
}
- (IBAction)onScreenEdgeLeftPan:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGFloat progress = [recognizer translationInView:self.view].x / (self.view.bounds.size.width * 1.0);
    progress = MIN(1.0, MAX(0.0, progress));
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // Create a interactive transition and pop the view controller
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // Update the interactive transition's progress
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        // Finish or cancel the interactive transition
        if (progress > 0.5) {
            [self.interactivePopTransition finishInteractiveTransition];
        }
        else {
            [self.interactivePopTransition cancelInteractiveTransition];
        }
        
        self.interactivePopTransition = nil;
    }
}

#pragma mark - table date source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.actions.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.actions[section];
    return array.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = self.actions[indexPath.section];

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14];

    CellAction action = [array[indexPath.row] integerValue];
    cell.accessoryType = [self accessoryTypeForCellAction:action];
    cell.textLabel.text = [self titleForCellAction:action];
    cell.detailTextLabel.text = [self detailForCellAction:action];

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

#pragma mark - UITableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self doActionForCellAction:[self.actions[indexPath.section][indexPath.row] integerValue]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *s;
    switch (section) {
        case 0:
            s = NSLocalizedStringFromTable(@"SETTING_SECTION_GENERAL", @"setting", @"");
            break;
        case 1:
            s = NSLocalizedStringFromTable(@"SETTING_SECTION_OTHER", @"setting", @"");
            break;
        default:
            break;
    }
    return s;
}

#pragma mark -
-(void)doActionForCellAction:(CellAction)action
{
    switch (action) {
        case CellActionAutoSave:
        {
            SettingDetailViewController *settingVC = [[SettingDetailViewController alloc] initWithNibName:@"SettingDetailViewController" bundle:[NSBundle mainBundle]];
            settingVC.sectionHeaders = @[NSLocalizedStringFromTable(@"SETTING_AUTO_SAVE_IMAGE", @"setting", @"")];
            settingVC.sectionTitles = @[
                                        @[NSLocalizedStringFromTable(@"SETTING_YES", @"setting", @""),
                                          NSLocalizedStringFromTable(@"SETTING_NO", @"setting", @"")],
                                        ];
            BOOL autoSave = [[UserSettingManger defaultManger] autoSave];
            settingVC.selectedPath = [NSIndexPath indexPathForRow:autoSave?0:1 inSection:0];
                                        ;
            [settingVC setActionBlock:^(NSIndexPath *indexPath) {
                [UserSettingManger defaultManger].autoSave = (indexPath.row==0);
            }];
            
            [self.navigationController pushViewController:settingVC animated:YES];
            break;
        }
        case CellActionResolution:
        {
            SettingDetailViewController *settingVC = [[SettingDetailViewController alloc] initWithNibName:@"SettingDetailViewController" bundle:[NSBundle mainBundle]];
            settingVC.sectionHeaders = @[NSLocalizedStringFromTable(@"SETTING_IMAGE_RESOLUTION", @"setting", @"")];
            settingVC.sectionTitles = @[
                                        @[NSLocalizedStringFromTable(@"HIGE_WORD", @"setting", @""),
                                          NSLocalizedStringFromTable(@"MEDIAN_WORD", @"setting", @""),
                                          NSLocalizedStringFromTable(@"LOW_WORD", @"setting", @""),
                                          ],
                                        ];

            NSInteger resolution = [[UserSettingManger defaultManger] resolution];
            settingVC.selectedPath = [NSIndexPath indexPathForRow:resolution inSection:0];

            [settingVC setActionBlock:^(NSIndexPath *indexPath) {
                [UserSettingManger defaultManger].resolution = indexPath.row;
            }];
            
            [self.navigationController pushViewController:settingVC animated:YES];
            break;
        }
        case CellActionAutoSaveCutResultSystem:
        {
            SettingDetailViewController *settingVC = [[SettingDetailViewController alloc] initWithNibName:@"SettingDetailViewController" bundle:[NSBundle mainBundle]];
            settingVC.sectionHeaders = @[NSLocalizedStringFromTable(@"SETTING_AUTO_SAVE_IMAGE_CUT_SYSTEM", @"setting", @"")];
            settingVC.sectionTitles = @[
                                        @[NSLocalizedStringFromTable(@"SETTING_YES", @"setting", @""),
                                          NSLocalizedStringFromTable(@"SETTING_NO", @"setting", @"")],
                                        ];
            BOOL autoSave = [[UserSettingManger defaultManger] autoSaveCutSystem];
            settingVC.selectedPath = [NSIndexPath indexPathForRow:autoSave?0:1 inSection:0];

            [settingVC setActionBlock:^(NSIndexPath *indexPath) {
                [UserSettingManger defaultManger].autoSaveCutSystem = (indexPath.row==0);
            }];
            
            [self.navigationController pushViewController:settingVC animated:YES];
            break;
        }
        case CellActionAutoSaveCutResultApp:
        {
            SettingDetailViewController *settingVC = [[SettingDetailViewController alloc] initWithNibName:@"SettingDetailViewController" bundle:[NSBundle mainBundle]];
            settingVC.sectionHeaders = @[NSLocalizedStringFromTable(@"SETTING_AUTO_SAVE_IMAGE_CUT_APP", @"setting", @"")];
            settingVC.sectionTitles = @[
                                        @[NSLocalizedStringFromTable(@"SETTING_YES", @"setting", @""),
                                          NSLocalizedStringFromTable(@"SETTING_NO", @"setting", @"")],
                                        ];
            BOOL autoSave = [[UserSettingManger defaultManger] autoSaveCutApp];
            settingVC.selectedPath = [NSIndexPath indexPathForRow:autoSave?0:1 inSection:0];

            [settingVC setActionBlock:^(NSIndexPath *indexPath) {
                [UserSettingManger defaultManger].autoSaveCutApp = (indexPath.row==0);
            }];
            
            [self.navigationController pushViewController:settingVC animated:YES];
            break;
        }
        case CellActionFeather:
        {
            SettingDetailViewController *settingVC = [[SettingDetailViewController alloc] initWithNibName:@"SettingDetailViewController" bundle:[NSBundle mainBundle]];
            settingVC.sectionHeaders = @[NSLocalizedStringFromTable(@"SETTING_AUTO_SAVE_IMAGE_CUT_APP", @"setting", @"")];
            settingVC.sectionTitles = @[
                                        @[NSLocalizedStringFromTable(@"SETTING_YES", @"setting", @""),
                                          NSLocalizedStringFromTable(@"SETTING_NO", @"setting", @"")],
                                        ];
            BOOL feather = [[UserSettingManger defaultManger] feather];
            settingVC.selectedPath = [NSIndexPath indexPathForRow:feather?0:1 inSection:0];

            [settingVC setActionBlock:^(NSIndexPath *indexPath) {
                [UserSettingManger defaultManger].feather = (indexPath.row==0);
            }];
            
            [self.navigationController pushViewController:settingVC animated:YES];
            break;
        }
        case CellActionSmoothEdge:
        {
            SettingDetailViewController *settingVC = [[SettingDetailViewController alloc] initWithNibName:@"SettingDetailViewController" bundle:[NSBundle mainBundle]];
            settingVC.sectionHeaders = @[NSLocalizedStringFromTable(@"SETTING_AUTO_SAVE_IMAGE_CUT_APP", @"setting", @"")];
            settingVC.sectionTitles = @[
                                        @[NSLocalizedStringFromTable(@"SETTING_YES", @"setting", @""),
                                          NSLocalizedStringFromTable(@"SETTING_NO", @"setting", @"")],
                                        ];
            BOOL smoothEdge = [[UserSettingManger defaultManger] smoothEdge];
            settingVC.selectedPath = [NSIndexPath indexPathForRow:smoothEdge?0:1 inSection:0];

            [settingVC setActionBlock:^(NSIndexPath *indexPath) {
                [UserSettingManger defaultManger].smoothEdge = (indexPath.row==0);
            }];
            
            [self.navigationController pushViewController:settingVC animated:YES];
            break;
        }
        case CellActionAccurateCut:
        {
            SettingDetailViewController *settingVC = [[SettingDetailViewController alloc] initWithNibName:@"SettingDetailViewController" bundle:[NSBundle mainBundle]];
            settingVC.sectionHeaders = @[NSLocalizedStringFromTable(@"SETTING_ACCURATECUT", @"setting", @"")];
            settingVC.sectionTitles = @[
                                        @[NSLocalizedStringFromTable(@"SETTING_YES", @"setting", @""),
                                          NSLocalizedStringFromTable(@"SETTING_NO", @"setting", @"")],
                                        ];
            BOOL accurateCut = [[UserSettingManger defaultManger] accurateCut];
            settingVC.selectedPath = [NSIndexPath indexPathForRow:accurateCut?0:1 inSection:0];
            
            [settingVC setActionBlock:^(NSIndexPath *indexPath) {
                [UserSettingManger defaultManger].accurateCut = (indexPath.row==0);
            }];
            
            [self.navigationController pushViewController:settingVC animated:YES];
            break;
        }
        case CellActionUpgrade:
            [self buy];
            break;
        case CellActionRT:
            [[[AdmobViewController shareAdmobVC] rtService] doRT];
            break;
        case CellActionShare:
            [self share];
            break;
        case CellActionFeedback:
            [self feedback];
            break;
        case CellActionSplitScreen:
        {
            break;
        }
        case CellActionClearCache:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"SETTING_CLEAR_CACHE_ALERT_TITLE_1", @"setting", @"") message:NSLocalizedStringFromTable(@"SETTING_CLEAR_CACHE_ALERT_MESSAGE_1", @"setting", @"") delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"SETTING_CANCEL_WORD", @"setting", @"") otherButtonTitles:NSLocalizedStringFromTable(@"SETTING_CLEAR_CACHE", @"setting", @""), nil];
            alertView.tag = 10000;
            [alertView show];
            
            break;
        }
        case CellActionGuide:
        {
            [self.navigationController.viewControllers.firstObject performSegueWithIdentifier:@"gotoCutout" sender:self.navigationController.viewControllers.firstObject];
            break;
        }
        case CellActionGuide_2:
        {
//            VideoPlayViewController *purchaseVC = [[VideoPlayViewController alloc] initWithNibName:@"VideoPlayViewController" bundle:[NSBundle mainBundle]];
//            VideoPlayViewController *purchaseVC = [[VideoPlayViewController alloc] init];
//            purchaseVC.defaultPageIndex = 0;
//            [self presentViewController:purchaseVC animated:YES completion:nil];
//            [self.navigationController pushViewController:purchaseVC animated:YES];
//            PurchaseViewController *purchaseVC = [[PurchaseViewController alloc] initWithNibName:@"PurchaseViewController" bundle:[NSBundle mainBundle]];
//            [self presentViewController:purchaseVC animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

-(NSString *)titleForCellAction:(CellAction)action
{
    NSString *title = nil;
    switch (action) {
        case CellActionAutoSave:
            title = NSLocalizedStringFromTable(@"SETTING_AUTO_SAVE_IMAGE", @"setting", @"");
            break;
        case CellActionAutoSaveCutResultSystem:
            title = NSLocalizedStringFromTable(@"SETTING_AUTO_SAVE_IMAGE_CUT_SYSTEM", @"setting", @"");
            break;
        case CellActionAutoSaveCutResultApp:
            title = NSLocalizedStringFromTable(@"SETTING_AUTO_SAVE_IMAGE_CUT_APP", @"setting", @"");
            break;
        case CellActionResolution:
            title = NSLocalizedStringFromTable(@"SETTING_IMAGE_RESOLUTION", @"setting", @"");
            break;
        case CellActionSmoothEdge:
            title = NSLocalizedStringFromTable(@"SETTING_SMOOTH_EDGE", @"setting", @"");
            break;
        case CellActionFeather:
            title = NSLocalizedStringFromTable(@"SETTING_FEATHER", @"setting", @"");
            break;
        case CellActionAccurateCut:
            title = NSLocalizedStringFromTable(@"SETTING_ACCURATECUT", @"setting", @"");

            break;
        case CellActionSplitScreen:
            title = NSLocalizedStringFromTable(@"SETTING_SPLIT_SCREEN_WORD", @"setting", @"");
            break;
            
        case CellActionUpgrade:
            title = NSLocalizedStringFromTable(@"SETTING_UPGRADE_WORD", @"setting", @"");
            break;
        case CellActionRT:
            title = NSLocalizedStringFromTable(@"SETTING_RATE_WORD", @"setting", @"");
            break;
        case CellActionShare:
            title = NSLocalizedStringFromTable(@"SETTING_SHARE_WORD", @"setting", @"");
            break;
        case CellActionFeedback:
            title = NSLocalizedStringFromTable(@"SETTING_FEEDBACK_WORD", @"setting", @"");
            break;
            
        case CellActionClearCache:
            title = NSLocalizedStringFromTable(@"SETTING_CLEAR_CACHE", @"setting", @"");
            break;
        case CellActionGuide:
            title = NSLocalizedStringFromTable(@"SETTING_GUIDE", @"setting", @"");
            break;
        case CellActionGuide_2:
            title = NSLocalizedStringFromTable(@"SETTING_GUIDE_2", @"setting", @"");
            break;
        default:
            break;
    }
    return title;
}

-(NSString *)detailForCellAction:(CellAction)action
{
    NSString *detail = nil;
    switch (action) {
        case CellActionResolution:
        {
            NSArray *array = @[NSLocalizedStringFromTable(@"HIGE_WORD", @"setting", @""),
                               NSLocalizedStringFromTable(@"MEDIAN_WORD", @"setting", @""),
                               NSLocalizedStringFromTable(@"LOW_WORD", @"setting", @""),
                               ];
            
            detail = array[[[UserSettingManger defaultManger] resolution]];
            break;
        }
        case CellActionAutoSave:
        {
            
            NSArray *array = @[NSLocalizedStringFromTable(@"SETTING_NO", @"setting", @""),
                               NSLocalizedStringFromTable(@"SETTING_YES", @"setting", @""),
                               ];
            
            detail = array[[[UserSettingManger defaultManger] autoSave]];
            break;
        }
        case CellActionAutoSaveCutResultSystem:
        {
            
            NSArray *array = @[NSLocalizedStringFromTable(@"SETTING_NO", @"setting", @""),
                               NSLocalizedStringFromTable(@"SETTING_YES", @"setting", @""),
                               ];
            
            detail = array[[[UserSettingManger defaultManger] autoSaveCutSystem]];
            break;
        }
        case CellActionAutoSaveCutResultApp:
        {
            
            NSArray *array = @[NSLocalizedStringFromTable(@"SETTING_NO", @"setting", @""),
                               NSLocalizedStringFromTable(@"SETTING_YES", @"setting", @""),
                               ];
            
            detail = array[[[UserSettingManger defaultManger] autoSaveCutApp]];
            break;
        }
        case CellActionFeather:
        {
            NSArray *array = @[NSLocalizedStringFromTable(@"SETTING_NO", @"setting", @""),
                               NSLocalizedStringFromTable(@"SETTING_YES", @"setting", @""),
                               ];
            
            detail = array[[[UserSettingManger defaultManger] feather]];
            break;
        }
        case CellActionSmoothEdge:
        {
            NSArray *array = @[NSLocalizedStringFromTable(@"SETTING_NO", @"setting", @""),
                               NSLocalizedStringFromTable(@"SETTING_YES", @"setting", @""),
                               ];
            
            detail = array[[[UserSettingManger defaultManger] smoothEdge]];
            break;
        }
        case CellActionAccurateCut:
        {
            NSArray *array = @[NSLocalizedStringFromTable(@"SETTING_NO", @"setting", @""),
                               NSLocalizedStringFromTable(@"SETTING_YES", @"setting", @""),
                               ];
            
            detail = array[[[UserSettingManger defaultManger] accurateCut]];
            break;
        }
        case CellActionUpgrade:
            break;
        case CellActionRT:
            break;
        case CellActionShare:
            break;
        case CellActionFeedback:
            break;
        case CellActionSplitScreen:
        {
            break;
        }
        case CellActionClearCache:
        {
            CGFloat cacheSize = [[PhotoStore defaultStore] photoStoreDiskUsage];
            NSLog(@"%f", cacheSize);
            
            detail = [NSString stringWithFormat:@"%0.2fM", cacheSize/1024/1024];
            break;
        }
        default:
            break;
    }
    return detail;
}

-(UITableViewCellAccessoryType)accessoryTypeForCellAction:(CellAction)action
{
    UITableViewCellAccessoryType type = UITableViewCellAccessoryNone;
    switch (action) {
        case CellActionAutoSave:
            type = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case CellActionResolution:
            type = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case CellActionAutoSaveCutResultApp:
            type = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case CellActionAutoSaveCutResultSystem:
            type = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case CellActionSmoothEdge:
            type = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case CellActionFeather:
            type = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case CellActionAccurateCut:
            type = UITableViewCellAccessoryDisclosureIndicator;
            break;
        default:
            break;
    }
    return type;
}

#pragma mark -
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10000) {
        switch (buttonIndex) {
            case 0:
                
                break;
            case 1:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"SETTING_CLEAR_CACHE_ALERT_TITLE_2", @"setting", @"") message:NSLocalizedStringFromTable(@"SETTING_CLEAR_CACHE_ALERT_MESSAGE_2", @"setting", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"SETTING_YES", @"setting", @""), NSLocalizedStringFromTable(@"SETTING_NO", @"setting", @""), nil];
                alertView.tag = 10001;
                [alertView show];
                
                break;
            }
            default:
                break;
        }
    }
    else if (alertView.tag == 10001)
    {
        switch (buttonIndex) {
            case 0:
                [[PhotoStore defaultStore] removeAllItems];
                
                [self.tableView reloadData];
                break;
            
            default:
                break;
        }
    }
}

#pragma mark UINavigationControllerDelegate methods
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    // Check if we're transitioning from this view controller to a DSLFirstViewController
    if (operation == UINavigationControllerOperationPop && ([fromVC isKindOfClass:[SettingViewController class]] || [fromVC isKindOfClass:[SettingDetailViewController class]]))
    {
        return [[SettingPopAnimator alloc] init];
    }
    else {
        return nil;
    }
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    // Check if this is for our custom transition
    if ([animationController isKindOfClass:[SettingPopAnimator class]]) {
        return self.interactivePopTransition;
    }
    else {
        return nil;
    }
}

#pragma mark -
-(void)resolutionChanged:(UISegmentedControl *)segment
{
//    NSLog(@"selected: %ld", (long)segment.selectedSegmentIndex);
    [[UserSettingManger defaultManger] setResolution:segment.selectedSegmentIndex];
}

-(void)autoSaveChanged:(UISwitch *)s
{
    [[UserSettingManger defaultManger] setAutoSave:s.on];
}

- (IBAction)goBack:(id)sender
{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)feedback
{
    [[[AdmobViewController shareAdmobVC] rtService] showRT:self];
}

- (void)share
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"SETTING_SHARE_SHEET_TITLE", @"setting", @"")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedStringFromTable(@"SETTING_CANCEL_WORD", @"setting", @"")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                  NSLocalizedStringFromTable(@"SETTING_MAIL_WORD", @"setting", @""),
                                  NSLocalizedStringFromTable(@"SETTING_SMS_WORD", @"setting", @""),
                                  NSLocalizedStringFromTable(@"SETTING_FB_WORD", @"setting", @""),
                                  NSLocalizedStringFromTable(@"SETTING_TL_WORD", @"setting", @""),
                                  nil];
    [actionSheet showInView:self.view];
}

#pragma mark - action delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"effect_home_id_s" ofType:@"jpg"];
    UIImage *demoImage = [UIImage imageWithContentsOfFile:path];
    if (buttonIndex==0) {
        //[[ShareService defaultService] setDelegate:self];
        [[ShareService defaultService] sendMailInVC:self title:[self getSettingShareTitle] content:[self getSettingShareMessage] image:demoImage recipients:nil];
    }
    else if(buttonIndex==1)
    {
        //[[ShareService defaultService] setDelegate:self];
        [[ShareService defaultService] sendSMSInVC:self title:[self getSettingShareTitle] content:[self getSettingShareMessage] image:demoImage];
    }
    else if (buttonIndex==2)
    {
        //[[ShareService defaultService] setDelegate:self];
        [[ShareService defaultService] showShareToPlatForm:ZBShareTypeFacebook inVC:self fromView:self.view title:[self getSettingShareTitle] content:[self getSettingShareMessage] image:demoImage];
    }
    else if (buttonIndex==3)
    {
        //[[ShareService defaultService] setDelegate:self];
        [[ShareService defaultService] showShareToPlatForm:ZBShareTypeWeixiTimeline inVC:self fromView:self.view title:[self getSettingShareTitle] content:[self getSettingShareMessage] image:demoImage];
    }
}

#pragma mark - share or feedback callback
-(void)shareServiceDidEndShare:(ShareService *)shareService shareType:(ZBShareType)shareType result:(ShareServiceResult)resultCode
{
    NSLog(@"%s", __FUNCTION__);
    switch (resultCode) {
        case kShareServiceSuccess:
            break;
        case kShareServiceDeviceNotSupport:
        {
            NSString *message = nil;
            if (shareType == ZBShareTypeMail) {
                message = NSLocalizedStringFromTable(@"SETTING_MAIL_NOT_SUPPORT", @"setting", @"");
            }
            else if (shareType == ZBShareTypeSMS)
            {
                message = NSLocalizedStringFromTable(@"SETTING_SMS_NOT_SUPPORT", @"setting", @"");
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"SETTING_OK_WORD", @"setting", @"") otherButtonTitles:nil];
            [alertView show];
            break;
        }
        case kShareServiceFail:
        {
            NSString *message = nil;
            if (shareType == ZBShareTypeMail) {
                message = NSLocalizedStringFromTable(@"SETTING_SEND_MAIL_FAIL", @"setting", @"");
            }
            else if (shareType == ZBShareTypeSMS)
            {
                message = NSLocalizedStringFromTable(@"SETTING_SEND_SMS_FAIL", @"setting", @"");
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"SETTING_OK_WORD", @"setting", @"") otherButtonTitles:nil];
            [alertView show];
            break;
        }
        case kShareServiceSaveCraft:
            break;
        case kShareServiceUserCancel:
            break;
        default:
            break;
    }
}

#pragma mark -
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.actions = nil;
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.delegate = self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - for ad

-(void)buy
{
//    PurchaseViewController *purchaseVC = [[PurchaseViewController alloc] initWithNibName:@"PurchaseViewController" bundle:[NSBundle mainBundle]];
//    [self presentViewController:purchaseVC animated:YES completion:nil];
}
@end
