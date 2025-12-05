//
//  ZBPosterCell.h
//  Collage
//
//  Created by shen on 13-7-22.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol ZBPosterCellDelegate <NSObject>
//
//@optional
//
//- (void)selectAPoster:(NSUInteger)lastPosterType;
//
//@end

@interface ZBPosterCell : UITableViewCell

@property (nonatomic, strong)UIImageView *imageView;
//@property (nonatomic, assign)id<ZBPosterCellDelegate> delegate;

- (void)refreshCell:(NSDictionary *)imagesNameDic;

@end
