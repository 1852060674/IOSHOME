//
//  ZBPosterThumbnailView.h
//  Collage
//
//  Created by shen on 13-7-23.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol ZBPosterThumbnailViewDelegate <NSObject>
//
//@optional
//
//- (void)selectAPoster:(NSUInteger)lastPosterType;
//
//@end

@interface ZBPosterThumbnailView : UIView

@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, assign)NSUInteger thumbnailIndex;
@property (nonatomic, assign) BOOL isSelected;
//@property (nonatomic, assign)id<ZBPosterThumbnailViewDelegate> delegate;

- (void)clearSelectedStatus;
- (void)setSelectedStatus;

@end
