//
//  HistoryTableViewSet.m
//  QRReader
//
//  Created by awt on 15/7/23.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import "HistoryTableViewSet.h"
//#import "Config.h"
#import "TextUpperLeftLabel.h"

@implementation HistoryTableViewSet
- (NSInteger)historyCountOfFile
{
    
    [self setHistoryArry:[[NSMutableArray alloc] init]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];//Documents目录
    NSString *historyPath = [documentsDirectory stringByAppendingPathComponent:@"path"];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:historyPath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:historyPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"no fil");
        return 0;
    }
    
    NSString *fileName = [historyPath stringByAppendingPathComponent:@"history.txt"];
    if ([fileManager fileExistsAtPath:fileName isDirectory:nil]) {
        
        NSString *ppStr = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
        NSMutableArray *lines = [ppStr componentsSeparatedByString:@";"];
        return [lines count];
        
    }
    else{
        [fileManager createFileAtPath:fileName contents:nil attributes:nil];
        return 0;
    }
    return 0;
}

- (void) initHistoryArray
{
    [self setHistoryArry:[[NSMutableArray alloc] init]];
    [self setImageArray:[[NSMutableArray alloc] init]];
    if (IS_IPAD) {
        cell_width = CELL_WIDTH *0.6;
    }
    else{
        cell_width =CELL_WIDTH;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];//Documents目录
    NSString *historyPath = [documentsDirectory stringByAppendingPathComponent:@"path"];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:historyPath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:historyPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"no fil");
        return;
    }
    
    NSString *fileName = [historyPath stringByAppendingPathComponent:@"history.txt"];
    if ([fileManager fileExistsAtPath:fileName isDirectory:nil]) {
        
//        NSString *ppStr = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
//        NSMutableArray *lines = [NSMutableArray arrayWithArray:[ppStr componentsSeparatedByString:@";"]];
//        [lines removeLastObject];
//        for (int i =[lines count]-1; i>=0; i--) {
//            NSArray *cellArray = [[lines objectAtIndex:i] componentsSeparatedByString:@","];
//            [self.historyArry addObject:cellArray];
//        }
        HistoryData *data = [self hisData];
        while (data) {
            NSString *type = [data codeType];
            NSString *number = [data codeNumber];
            NSString *date = [data date];
            NSArray *array = @[type,number,date];
            [self.historyArry addObject:array];
            UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(cell_width*17, cell_width*2.2, cell_width*2, cell_width*2)];
            
            [deleteBtn setBackgroundImage:[UIImage imageNamed:@"myClose"] forState:UIControlStateNormal];
            [deleteBtn addTarget:self action:@selector(deleteHisData:) forControlEvents:UIControlEventTouchUpInside];
            [self.imageArray addObject:deleteBtn];
            data = [data next];
        }
  
        
    }
    else{
        [fileManager createFileAtPath:fileName contents:nil attributes:nil];
  
    }
    

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (void) addImageView
{
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(cell_width*17, cell_width*2.2, cell_width*2, cell_width*2)];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"myClose"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteHisData:) forControlEvents:UIControlEventTouchUpInside];
    [self.imageArray addObject:deleteBtn];
}
- (UIImage *)imageOfType : (NSString *)type
{
    if ([type isEqualToString:@"Web Site"]) {
       return  [UIImage imageNamed:@"safari-icon@2x"];
    }
    else if([type isEqualToString:@"Application"])
    {
        return [UIImage imageNamed:@"apps-icon@2x"];
    }
    else if([type isEqualToString:@"Text"])
    {
        return [UIImage imageNamed:@"text-icon@2x"];
    }
    return [UIImage imageNamed:@"shopping-icon@2x"];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.historyArry count];
    NSLog(@"histort %d",[self.historyArry count]);//[self historyCountOfFile];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Albumnlist";
    UIButton *deleteBtn =[self.imageArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    // Configure the cell...
//    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
//        
//    }
    NSMutableArray *cellHistory = [self.historyArry objectAtIndex:indexPath.row];
    if ([cellHistory count] <3) {
        NSLog(@"row %d",indexPath.row);
    }
    NSString *type= [cellHistory objectAtIndex:0];
    NSString *number = [cellHistory objectAtIndex:1];
    NSString *date = [cellHistory objectAtIndex:2];
    for (UIView *myView in [cell subviews]) {
        if (myView.tag >=101&&myView.tag<=105) {
            [myView removeFromSuperview];
        }
    }
    // update zzx 20240123 update cellview UI start
    // 让坐内容靠内，标题和内容居左，时间局右，然后标题内容左对齐
    CGFloat pianyix=10;
    int imageviewY=5;
   // UIImage *image= [UIImage imageNamed:@"web-icon@2x"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(cell_width*0.7, cell_width*0.7+imageviewY, cell_width*3.4, cell_width*3.4)];
    [imageView setImage:[self imageOfType:type]];
    [cell addSubview:imageView];
//    UILabel *typeLable = [[UILabel alloc] initWithFrame:CGRectMake(cell_width*6,0, cell_width*10, cell_width*2)];
    // update 2024 0124 by zzx insert ui center for history data contain
    int centerForY=7;
    
    UILabel *typeLable = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH/2-cell_width*10/2,0+centerForY, cell_width*10, cell_width*2)];
    [typeLable setFont:[UIFont fontWithName:@"Arial" size:cell_width*1.5]];
    typeLable.textAlignment = NSTextAlignmentLeft;
    [cell addSubview:typeLable];
    [typeLable setText:type];
    UILabel *timeLable = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH-cell_width*0.7-cell_width*5.5, -cell_width/2+centerForY, cell_width*5.5, cell_width*3)];
    timeLable.textAlignment=NSTextAlignmentLeft;
  [cell addSubview:timeLable];
    [timeLable setText:date];
    [timeLable setFont:[UIFont systemFontOfSize:cell_width*1]];
    [timeLable setTextColor:[UIColor lightGrayColor]];
//    UILabel *numberLable = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH/2-cell_width*10/2+5, cell_width*1.3+centerForY, cell_width*14, cell_width*3)];
    // zzx 20240124 create leaftlabel
    TextUpperLeftLabel *numberLable = [[TextUpperLeftLabel alloc] initWithFrame:CGRectMake(WIDTH/2-cell_width*10/2+5, cell_width*1.3+centerForY+7, cell_width*14, cell_width*3-10)];
    numberLable.contentMode=UIViewContentModeTop;
    numberLable.textAlignment=NSTextAlignmentLeft;
    [numberLable setFont:[UIFont systemFontOfSize:cell_width*1]];
    [numberLable setTextColor:[UIColor darkGrayColor]];
    

    
    
    [numberLable setText:number];
//    label.numberOfLines = 2;
    [numberLable setNumberOfLines:2];
//    [numberLable setLineBreakMode:NSLineBreakByCharWrapping];
   [cell addSubview:numberLable];
    [imageView setTag:101];
    [typeLable setTag:102];
    [numberLable setTag:103];
    [timeLable setTag:104];
    [deleteBtn setTag:105];
//    [numberLable setTextAlignment:NSTextAlignmentCenter];
    numberLable.numberOfLines = 0;
    numberLable.lineBreakMode = NSLineBreakByTruncatingTail;
    NSLog(@"%@",timeLable.text);
    if ([type isEqualToString:@"EAN-13"] ||[type isEqualToString:@"EAN-8"]) {
     //
    }
//    UIView *subView = [[UIView alloc] initWithFrame:cell.frame];
//    [subView addSubview:imageView];
//    [subView addSubview:typeLable];
//    [subView addSubview:timeLable];
//    [subView addSubview:numberLable];
//    [subView addSubview:deleteBtn];
//    [cell addSubview:subView];
//    [self.subViewArray addObject:subView];
    [cell addSubview:deleteBtn];
    [deleteBtn setUserInteractionEnabled:YES];
    if ([self.delegate respondsToSelector:@selector(isEditionMode)]) {
        [deleteBtn setHidden:[self.delegate isEditionMode]];
    }
    else {
        [deleteBtn setHidden:YES];
    }

    // [imageView setCenter:CGPointMake(imageView.center.x, cell.center.y)];
    // [array setCenter:CGPointMake(array.center.x, cell.center.y)];

    return cell;
}
- (void) deleteHisData:(UIButton *)sender
{
    NSInteger indexOfSender = [self.imageArray indexOfObject:sender];
    [self.historyArry removeObjectAtIndex:indexOfSender];
    [self.imageArray removeObjectAtIndex:indexOfSender];
    NSLog(@"%d",[self.historyArry count]);
    for (UIImageView *imageView in [self imageArray]) {
        [imageView removeFromSuperview];
    }
    [self resetHistoryRecordWithType:indexOfSender];
    [self.delegate reloadTableView];
    [sender setHidden:YES];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if ([settings integerForKey:@"historyCount"] == nil) {
       NSInteger number= [settings integerForKey:@"historyCount"];
        if(number>0) {
            number--;
        }
        [settings setInteger:number forKey:@"historyCount"];
        [settings synchronize];
    }
    NSLog(@"deld %d",indexOfSender);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cell_width*5;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(selectedRow:)]) {
        [self.delegate selectedRow:indexPath.row];
    }
}
- (void) resetHistoryRecordWithType :(NSInteger) row
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];//Documents目录
    NSString *historyPath = [documentsDirectory stringByAppendingPathComponent:@"path"];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:historyPath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:historyPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName = [historyPath stringByAppendingPathComponent:@"history.txt"];
    if ([fileManager fileExistsAtPath:fileName isDirectory:nil]) {
        
        
    }
    else{
        [fileManager createFileAtPath:fileName contents:nil attributes:nil];
    }
    HistoryData *hisData =[self hisData];
    for (int i =0; i<row-1; i++) {
        hisData = [hisData next];
    }
    HistoryData *deleteData = [hisData next];
    if (row == 0) {
        self.hisData = [hisData next];
        [hisData setNext:nil];
    }
    else{
        [hisData setNext:[deleteData next]];
        [deleteData setNext:nil];
    }
    if ([self hisData]) {
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.hisData];
        [data writeToFile:fileName atomically:YES];
    }
    else
    {
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:fileName error:nil];
        [fileManager createFileAtPath:fileName contents:nil attributes:nil];
    }
    //[history setDate:currentDate];
    
  
    
    //[data writeToFile:fileName atomically:YES];
    
    // NSLog(@"%@",imageDir);
}
- (void) initImgDictionary
{
   
    
}
@end
