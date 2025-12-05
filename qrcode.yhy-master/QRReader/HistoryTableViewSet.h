//
//  HistoryTableViewSet.h
//  QRReader
//
//  Created by awt on 15/7/23.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryData.h"
#import "Config.h"
@protocol HistoryTableviewdelegate <NSObject>
@required
@property (nonatomic,readwrite) BOOL shoudResaveHistoryData;
@property (nonatomic,readwrite) BOOL isEditionMode;
- (void) showResult:(NSString *)number andType :(NSString *)type atRow:(NSInteger)row;
- (void) deletData : (NSMutableArray *) historyArray atRow : (NSInteger) row;
- (void) selectedRow : (NSInteger) row;
- (void) reloadTableView;
@end
@interface HistoryTableViewSet: NSObject<UITableViewDataSource,UITableViewDelegate>
{
    float cell_width;
}
@property NSInteger historyCount;
@property BOOL isDeleteMode;
@property (nonatomic,strong) id<HistoryTableviewdelegate> delegate;
@property (nonatomic,strong) NSMutableArray *historyArry;
@property (nonatomic,strong) NSMutableDictionary *imageDictionary;
@property (nonatomic,strong) NSMutableArray *imageArray;
@property (nonatomic,strong) HistoryData *hisData;
- (void) initHistoryArray;
- (void) addImageView;

@end
