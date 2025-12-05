//
//  ZBJoinCollageView.m
//  Collage
//
//  Created by shen on 13-6-26.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBJoinCollageView.h"
#import "ImageUtil.h"
#import "ZBCommonDefine.h"

#define kJoinGap   10

@interface ZBJoinCollageView()<UIGestureRecognizerDelegate,UIActionSheetDelegate>
{
    float _currentWidth;
    float _currentHeight;
}
@property (nonatomic, strong)NSArray *selectedImagesArray;
@property (nonatomic, assign) NSUInteger currentSelectedImageViewTag;
@property (nonatomic, strong) UIImage *currentEditImage;

@end

@implementation ZBJoinCollageView

@synthesize selectedImagesArray;
@synthesize photoFrameImageView = _photoFrameImageView;
@synthesize currentSelectedImageViewTag;
@synthesize currentEditImage = _currentEditImage;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChangeBackGroundImage object:nil];
}

- (id)initWithFrame:(CGRect)frame withSelectedImages:(NSArray *)imagesArray
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor whiteColor];
        
        _currentWidth = self.frame.size.width;
        _currentHeight = self.frame.size.height;
        self.backgroundColor = [UIColor whiteColor];
        
        self.selectedImagesArray = imagesArray;
        
        //监听背景变化信息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBackgroundImage:) name:kChangeBackGroundImage object:nil];
        
        //        [self decideImageViewRect];
        //        [self presentFreeCollage];
        [self joinImages];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.photoFrameImageView = imageView;
        [self addSubview:self.photoFrameImageView];
    }
    return self;

}

- (void)setBackgroundColorOrImage:(UIColor *)backgroundColor
{
    self.backgroundColor = backgroundColor;
}

- (void)setCurrentSelectedImage:(UIImage*)image
{
    UIImageView *_selectedImageView = (UIImageView*)[self viewWithTag:self.currentSelectedImageViewTag];
    _selectedImageView.image = image;
    float _originHeight = _selectedImageView.frame.size.height;
    
    float _scale = (_currentWidth-20)/image.size.width;
    float _imageHeight = image.size.height*_scale;
    
    _selectedImageView.frame = CGRectMake(_selectedImageView.frame.origin.x, _selectedImageView.frame.origin.y, _currentWidth-20, _imageHeight);
    
    for (UIView *aView in [self subviews])
    {
        if ([aView isKindOfClass:[UIImageView class]])
        {
            if (aView.tag>self.currentSelectedImageViewTag) {
                aView.frame = CGRectMake(aView.frame.origin.x, aView.frame.origin.y + (_imageHeight-_originHeight), aView.frame.size.width, aView.frame.size.height);
            }
        }
    }
    
    NSDictionary *_postInfoDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:self.frame.size.height+(_imageHeight-_originHeight)] forKey:@"JoinHeight"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeJoinHeight object:_postInfoDic];
}

- (void)joinImages
{
    float _lastHeight = kJoinGap;
    
    for (NSUInteger i=0; i<self.selectedImagesArray.count; i++)
    {
        UIImage *_image = [self.selectedImagesArray objectAtIndex:i];
        float _scale = (_currentWidth-20)/_image.size.width;
        float _imageHeight = _image.size.height*_scale;
                
        UIImageView *_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kJoinGap, _lastHeight, _currentWidth-20, _imageHeight)];
        _imageView.image = _image;
        [_imageView setUserInteractionEnabled:YES];
        _imageView.tag = kJoinCollageImageViewStartTag+i;
        [self addSubview:_imageView];
        _lastHeight += _imageHeight+kJoinGap;
        
        UITapGestureRecognizer *_doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleThisPic:)];
        [_imageView addGestureRecognizer:_doubleTapRecognizer];
        // 双击的 Recognizer
        _doubleTapRecognizer.numberOfTapsRequired = 2; //
    }
    
    NSDictionary *_postInfoDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:_lastHeight]
                                                             forKey:@"JoinHeight"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeJoinHeight object:_postInfoDic];
}

- (void)changeBackgroundImage:(NSNotification*)notification
{
    NSDictionary *_infoDic = [notification object];//获取到传递的对象
    
    CollageType _type = [[_infoDic valueForKey:@"CollageType"] integerValue];
    if (_type != CollageTypeJoin) {
        return;
    }
    
    NSString *_imageName = [_infoDic valueForKey:@"imageIndex"];
    _imageName = [NSString stringWithFormat:@"bg%@.png",_imageName];
    
    UIImage *_backgroundImage = [ImageUtil loadResourceImage:_imageName];
    self.backgroundColor = [UIColor colorWithPatternImage:_backgroundImage];
}

#pragma mark -- UIGestureRecognizer 手势
- (void)handleThisPic:(UIGestureRecognizer*)recognizer
{
    UIImageView *_imageView = (UIImageView*)[recognizer view];
    
    self.currentEditImage = _imageView.image;
    self.currentSelectedImageViewTag = _imageView.tag;
    
    UIActionSheet *aActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reselect photo" otherButtonTitles:@"Edit current photo", nil];
    [aActionSheet showInView:self];
}

#pragma mark -- UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImageView *_selectedImageView = (UIImageView*)[self viewWithTag:self.currentSelectedImageViewTag];
    
    if (buttonIndex == 0)
    {
        //打开相册
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(openAlbum: withRect:)]) {
            [self.delegate openAlbum:UIImagePickerControllerSourceTypeSavedPhotosAlbum  withRect:_selectedImageView.frame];
        }
        
    }else if (buttonIndex == 1) {
        //编辑当前选择的图片
        if (self.delegate && [self.delegate respondsToSelector:@selector(editCurrentSelectedImage:)]) {
            [self.delegate editCurrentSelectedImage:self.currentEditImage];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
