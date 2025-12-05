//
//  ZBShowSpecificTemplatesView.h
//  Collage
//
//  Created by shen on 13-6-25.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZBShowSpecificTemplatesViewDelegate <NSObject>

@optional

//选中某个相框
- (void)selectedATemplate:(NSUInteger)templateIndex;

@end

@interface ZBShowSpecificTemplatesView : UIView

@property (nonatomic, assign)id<ZBShowSpecificTemplatesViewDelegate> delegate;
@property (nonatomic, assign)NSUInteger currentTemplateCount;

- (id)initWithFrame:(CGRect)frame withSelectedImagesCount:(NSUInteger)imagesCount;
@end
