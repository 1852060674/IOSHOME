//
//  resultTableView.m
//  QRReader
//
//  Created by awt on 15/8/5.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import "resultTableView.h"
#import "CustomTableViewCell.h"
#import "Config.h"
@implementation ResultTableView

- (void) toSaferi:(NSInteger) row
{
    //http://search.jd.com/Search?keyword=手&enc=utf-8&wq=机&pvid=tms9peci.0qiy76
    //https://www.baidu.com/s?wd=
    NSString *url;
    switch (row) {
        case 101:
            
        case 102:
            url = self.code;
            break;
        case 103:
            url = [NSString stringWithFormat:@"https://www.google.co.uk/search?q=%@",self.code];
            break;
        case 108:
            url = [NSString stringWithFormat:@"https://www.baidu.com/s?wd=%@",self.code];
            break;
        case 105:
            url = [NSString stringWithFormat:@"http://www.amazon.com/s/ref=nb_sb_noss_2?url=search-alias%%3Daps&field-keywords=%@",self.code];
            break;
        case 111:
            url = [NSString stringWithFormat:@"http://www.amazon.cn/s/%@",self.code];
            break;
        case 110:
            url = [NSString stringWithFormat:@"https://list.tmall.com/search_product.htm?q=%@",self.code];
            break;
        case 107:
            url = [NSString stringWithFormat:@"http://www.ebay.com/sch/%@",self.code];
            break;
        case 109:
            url = [NSString stringWithFormat:@"http://search.jd.com/Search?keyword=%@&enc=utf-8&wq=%@&pvid=tms9peci.0qiy76",self.code,self.code];
            break;
        case 104:
            url = [NSString stringWithFormat:@"http://bing.com/search?q=%@",self.code];
            break;
        case 106:
            url = [NSString stringWithFormat:@"http://www.walmart.com/search/?query=%@",self.code];
            break;
        default:
            break;
    }
    NSLog(@"%@",self.code);
    [[UIApplication  sharedApplication] openURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.code == nil)
    {
        return 0;
    }
    if (self.isWeb) {
        return 2;
    }
    else
    {
        if (IS_IPAD) {
            return 12;
        }
        return 12;
    }
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD) {
        return CELL_WIDTH*2.4;
    }
        return CELL_WIDTH*3;
 
    
      //  return CELL_WIDTH*3;
  
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ResultTable";
   
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
//        
//   }
    CustomTableViewCell *cell = [[CustomTableViewCell alloc] init];
    
//    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell" forIndexPath:indexPath];
    
    UIImageView *imageView;

    UILabel *lable;
  
    UIImageView *array;
    if (IS_IPAD) {
        int pianyiy=15;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(3.7*CELL_WIDTH, 0.2*CELL_WIDTH*0.6+pianyiy, CELL_WIDTH*2.6*0.6,  CELL_WIDTH*2.6*0.6)];
        [imageView setTag:101];
        lable = [[UILabel alloc] initWithFrame:CGRectMake(7.7*CELL_WIDTH-30-25, 0+pianyiy, CELL_WIDTH*12*0.6,  CELL_WIDTH*2.6*0.6)];
        [lable setTag:102];
        [lable setTextAlignment:NSTextAlignmentLeft];
        [lable setFont:[UIFont systemFontOfSize:1*CELL_WIDTH*0.6]];
        array = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-CELL_WIDTH*2.6*0.6-0.7*CELL_WIDTH-200, 0.2*CELL_WIDTH*0.6+pianyiy, CELL_WIDTH*2.6*0.6,  CELL_WIDTH*2.6*0.6)];
        //  20240126 zzzx
        tableView.separatorInset = UIEdgeInsetsMake(0, 140, 0, 140);
        cell.customSeparatorHeight = 2.0;
    }
    else{
       imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.7*CELL_WIDTH, 0.2*CELL_WIDTH, CELL_WIDTH*2.6,  CELL_WIDTH*2.6)];
        [imageView setTag:101];
        lable = [[UILabel alloc] initWithFrame:CGRectMake(4.7*CELL_WIDTH, 0, CELL_WIDTH*12,  CELL_WIDTH*2.6)];
        [lable setTag:102];
        [lable setTextAlignment:NSTextAlignmentLeft];
        [lable setFont:[UIFont systemFontOfSize:1*CELL_WIDTH]];
        array = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH -3*CELL_WIDTH -0.7*CELL_WIDTH-74, 0.2*CELL_WIDTH, CELL_WIDTH*2.6,  CELL_WIDTH*2.6)];
    }
   // [imageView setCenter:CGPointMake(imageView.center.x, cell.center.y)];
    [array setTag:103];
    [array setImage:[UIImage imageNamed:@"rightAngle"]];
    [lable setTintColor:[UIColor lightGrayColor]];
    for (UIView *subView in [cell subviews]) {
        if (subView.tag > 100 && subView.tag <= 105) {
            [subView removeFromSuperview];
            if ([subView tag] == 102) {
                [(UILabel *)subView setText:nil];
            }
        }
    }
    if (self.isWeb) {
        switch (indexPath.row) {
            case 0:
                [imageView setImage:[UIImage imageNamed:@"safiri"]];
                [lable setText:@"Open by Safiri"];
                [imageView.layer setCornerRadius:0.4*CELL_WIDTH];
                [imageView.layer setBorderWidth:1];
                [imageView.layer setBorderColor:[[UIColor colorWithRed:32.0/255.0 green:(9*16+9)/255.0 blue:1 alpha:1] CGColor]];
                break;
                
            default:
                [imageView setImage:[UIImage imageNamed:@"app"]];
                [lable setText:@"Open by Appstore"];
                [tableView setHidden:NO];
                break;
        }
    }
    else {
        switch (indexPath.row) {
            case 0:
                [imageView setImage:[UIImage imageNamed:@"google"]];
                [lable setText:@"Search in Google "];
                [imageView.layer setCornerRadius:0.4*CELL_WIDTH];
                [imageView.layer setBorderWidth:1];
                [imageView.layer setBorderColor:[[UIColor colorWithRed:32.0/255.0 green:(9*16+9)/255.0 blue:1 alpha:1] CGColor]];
                break;
            case 1:
                [imageView setImage:[UIImage imageNamed:@"bing"]];
                [lable setText:@"Search in Bing"];
                break;
            case 2:
                [imageView setImage:[UIImage imageNamed:@"amazon"]];
                [lable setText:@"Find goods in Amazon"];
                break;
            case 3:
                [imageView setImage:[UIImage imageNamed:@"walmart"]];
                [lable setText:@"Find goods in Walmark"];
                [imageView.layer setCornerRadius:0.4*CELL_WIDTH];
                [imageView.layer setBorderWidth:1];
                [imageView.layer setBorderColor:[[UIColor colorWithRed:32.0/255.0 green:(9*16+9)/255.0 blue:1 alpha:1] CGColor]];
                break;
            case 4:
                [imageView setImage:[UIImage imageNamed:@"ebay"]];
                [lable setText:@"Find goods in Ebay"];
                [imageView.layer setCornerRadius:0.4*CELL_WIDTH];
                [imageView.layer setBorderWidth:1];
                [imageView.layer setBorderColor:[[UIColor colorWithRed:32.0/255.0 green:(9*16+9)/255.0 blue:1 alpha:1] CGColor]];
                break;
            case 5:
                [imageView setImage:[UIImage imageNamed:@"baidu"]];
                [lable setText:@"Search in Baidu"];
               // [imageView.layer setCornerRadius:0.4*CELL_WIDTH];
              //  [imageView.layer setBorderWidth:1];
               // [imageView.layer setBorderColor:[[UIColor colorWithRed:32.0/255.0 green:(9*16+9)/255.0 blue:1 alpha:1] CGColor]];
                break;
//            case 8:
//                [imageView setImage:[UIImage imageNamed:@"amazon_cn"]];
//                [lable setText:@"Find goods in Amazon China"];
//                break;
            case 6:
                [imageView setImage:[UIImage imageNamed:@"tmall"]];
                [lable setText:@"Find goods in Tmall"];
                break;
            case 7:
                [imageView setImage:[UIImage imageNamed:@"jd"]];
                [lable setText:@"Find goods in Jingdong"];
                [imageView.layer setCornerRadius:0.4*CELL_WIDTH];
                [imageView.layer setBorderWidth:1];
                [imageView.layer setBorderColor:[[UIColor colorWithRed:32.0/255.0 green:(9*16+9)/255.0 blue:1 alpha:1] CGColor]];
                //[tableView setHidden:NO];
                break;
            default:
                break;
        }
    }
  
   // [cell snapshotViewAfterScreenUpdates:YES]
// UIView *view = [[UIView alloc] initWithFrame:cell.frame];
//    [view setTag:105];
//    [view addSubview:imageView];
//    [view addSubview:array];
//    [view addSubview:lable];
//    [cell addSubview:view];
 
   // [imageView setCenter:CGPointMake(imageView.center.x, cell.frame.size.height/2)];
   // [lable setCenter:CGPointMake(lable.center.x, cell.frame.size.height/2)];
//    [array setCenter:CGPointMake(array.center.x+40, array.center.y)];
    if (indexPath.row < 8) {
        [cell addSubview:imageView];
         [cell addSubview:array];
        [cell addSubview:lable];
        
//        cell.accessoryView= array;
    }
    [array setCenter:CGPointMake(array.center.x+100, array.center.y)];
    return cell;

}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger tag ;
    if (self.isWeb) {
        tag = 101 + indexPath.row;
    }
    else{
        tag =103 +indexPath.row;
    }
    [self toSaferi:tag];
}

@end
