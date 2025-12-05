//
//  ZBPosterCollageView.m
//  Collage
//
//  Created by shen on 13-7-18.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBPosterCollageView.h"
#import "ZBPosterImageView.h"
#import "ZBPosterCollageScrollView.h"
#import "ImageUtil.h"
#import "ZBCommonMethod.h"
#import "UIColor-Expanded.h"
#import "ZBColorDefine.h"

@interface ZBPosterCollageView()<UIScrollViewDelegate>
{
    UIImage *_image1;
    UIImage *_image2;
    UIImage *_image3;
    UIImage *_image4;
    UIImage *_image5;
    UIImage *_image6;
    UIImage *_image7;
    UIImage *_image8;
    
    float _currentWidth;
    float _currentHeight;
    
    float _gap;
    BOOL _isRegularTemplate;
    BOOL _isGetOriginImage;
    
    NSUInteger _selectedImagesCount;
}

@property (nonatomic, strong) NSMutableArray *selectedImagesArray;
@property (nonatomic, strong) NSMutableDictionary *imageDictionary;
@property (nonatomic, strong) NSMutableDictionary *pointDictionary;
@property (nonatomic, assign) PosterCollageType currentPosterCollageType;
@property (nonatomic, strong) UIImageView *posterImageView;
@property (nonatomic, strong) UIImageView *ss;

@property (nonatomic,strong)NSMutableArray *pointArray1;
@property (nonatomic,strong)NSMutableArray *pointArray2;
@property (nonatomic,strong)NSMutableArray *pointArray3;
@property (nonatomic,strong)NSMutableArray *pointArray4;
@property (nonatomic,strong)NSMutableArray *pointArray5;
@property (nonatomic,strong)NSMutableArray *pointArray6;
@property (nonatomic,strong)NSMutableArray *pointArray7;

@end

@implementation ZBPosterCollageView

@synthesize selectedImagesArray;
@synthesize imageDictionary;
@synthesize pointDictionary;
@synthesize currentPosterCollageType;
@synthesize posterImageView;
@synthesize pointArray1,pointArray2,pointArray3,pointArray4,pointArray5,pointArray6,pointArray7;

- (id)initWithFrame:(CGRect)frame andSelectedImages:(NSArray*)imagesArray
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isGetOriginImage = YES;
        _selectedImagesCount = MIN(imagesArray.count, 7);
        self.selectedImagesArray = [[NSMutableArray alloc] initWithArray:imagesArray];
        self.currentPosterCollageType = PosterCollageType1;
        
        NSUInteger _lastThumbnailIndex = [ZBCommonMethod getCurrentPosterType];
        [ZBCommonMethod setCurrentPosterType:self.currentPosterCollageType];
        
        NSDictionary *_postInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInteger:self.currentPosterCollageType] ,@"PosterChangeType",
                                      [NSNumber numberWithInteger:_lastThumbnailIndex] ,@"LastPosterChangeType",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPosterChangeType object:_postInfoDic];
        
        [self setIsRegularTemplate];
        
        _currentWidth = self.frame.size.width;
        _currentHeight = self.frame.size.height;
        _gap = kIrregularTemplateGap;
        
        self.pointArray1 = [[NSMutableArray alloc] initWithCapacity:2];
        self.pointArray2 = [[NSMutableArray alloc] initWithCapacity:2];
        self.pointArray3 = [[NSMutableArray alloc] initWithCapacity:2];
        self.pointArray4 = [[NSMutableArray alloc] initWithCapacity:2];
        self.pointArray5 = [[NSMutableArray alloc] initWithCapacity:2];
        self.pointArray6 = [[NSMutableArray alloc] initWithCapacity:2];
        self.pointArray7 = [[NSMutableArray alloc] initWithCapacity:2];
        
        self.imageDictionary = [[NSMutableDictionary alloc] initWithCapacity:2];
        self.pointDictionary = [[NSMutableDictionary alloc] initWithCapacity:2];
        
        [self initDictionary];
        [self selectAnTemplateWithImagesCount:_selectedImagesCount];
        
        self.posterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        if (IS_IPAD) {
            self.posterImageView.image = [ImageUtil loadResourceImage:@"poster_ipad_1"];
        }
        else
            self.posterImageView.image = [ImageUtil loadResourceImage:@"poster1"];
        
        [self addSubview:self.posterImageView];
        [self bringSubviewToFront:self.posterImageView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePosterType:) name:kPosterChangeType object:nil];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    _currentWidth = self.frame.size.width;
    _currentHeight = self.frame.size.height;
    self.posterImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self selectAnTemplateWithImagesCount:_selectedImagesCount];
}
- (void)initDictionary
{
    [self.imageDictionary setObject:self.pointArray1 forKey:[NSNumber numberWithInteger:0]];
    [self.imageDictionary setObject:self.pointArray2 forKey:[NSNumber numberWithInteger:1]];
    [self.imageDictionary setObject:self.pointArray3 forKey:[NSNumber numberWithInteger:2]];
    [self.imageDictionary setObject:self.pointArray4 forKey:[NSNumber numberWithInteger:3]];
    [self.imageDictionary setObject:self.pointArray5 forKey:[NSNumber numberWithInteger:4]];
    [self.imageDictionary setObject:self.pointArray6 forKey:[NSNumber numberWithInteger:5]];
    [self.imageDictionary setObject:self.pointArray7 forKey:[NSNumber numberWithInteger:6]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPosterChangeType object:nil];
}

- (void)changePosterType:(NSNotification*)notification
{
    NSDictionary *_infoDic = [notification object];//获取到传递的对象
    self.currentPosterCollageType = [[_infoDic objectForKey:@"PosterChangeType"] integerValue];
    //change imageView
    if (IS_IPAD) {
        self.posterImageView.image = [ImageUtil loadResourceImage:[NSString stringWithFormat:@"poster_ipad_%d",self.currentPosterCollageType+1]];
    }
    else
        self.posterImageView.image = [ImageUtil loadResourceImage:[NSString stringWithFormat:@"poster%d",self.currentPosterCollageType+1]];

    [self setIsRegularTemplate];
    [self selectAnTemplateWithImagesCount:_selectedImagesCount];
    [self bringSubviewToFront:self.posterImageView];
}

- (BOOL)canChangeBackgroundImageWithPosterCollageChangeType:(PosterCollageChangeType)type
{
    BOOL canChange = YES;
    
    if (type == PosterCollageChangeTypeLast && self.currentPosterCollageType == 0) {
        canChange = NO;
    }
    if (type == PosterCollageChangeTypeNext && self.currentPosterCollageType == 14) {
        canChange = NO;
    }
    
    return canChange;
}

- (void)changeBackgroundImageWithPosterCollageChangeType:(PosterCollageChangeType)type
{
    if (type == PosterCollageChangeTypeLast && self.currentPosterCollageType == 0) {
        return;
    }
    if (type == PosterCollageChangeTypeNext && self.currentPosterCollageType == 14) {
        return;
    }
    if (type == FreeCollageChangeTypeLast) {
        self.currentPosterCollageType--;
        
    }
    else if(type == FreeCollageChangeTypeNext)
        self.currentPosterCollageType++;
    
    NSUInteger _lastThumbnailIndex = [ZBCommonMethod getCurrentPosterType];
    [ZBCommonMethod setCurrentPosterType:self.currentPosterCollageType];
    
    NSDictionary *_postInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInteger:self.currentPosterCollageType] ,@"PosterChangeType",
                                  [NSNumber numberWithInteger:_lastThumbnailIndex] ,@"LastPosterChangeType",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPosterChangeType object:_postInfoDic];
    
    [self setIsRegularTemplate];
    [self selectAnTemplateWithImagesCount:_selectedImagesCount];
    [self bringSubviewToFront:self.posterImageView];
}

- (void)setIsRegularTemplate
{
    self.posterImageView.image = [ImageUtil loadResourceImage:[NSString stringWithFormat:@"poster%d",self.currentPosterCollageType+1]];
    switch (self.currentPosterCollageType) {
        case PosterCollageType1:
        {
            _isRegularTemplate = NO;
            self.backgroundColor = kPosterCollageType1Color;
        }
            break;
        case PosterCollageType2:
        {
            _isRegularTemplate = NO;
            self.backgroundColor = kPosterCollageType2Color;
        }
            break;
        case PosterCollageType3:
        {
            _isRegularTemplate = YES;
            self.backgroundColor = kPosterCollageType3Color;
        }
            break;
        case PosterCollageType4:
        {
            _isRegularTemplate = NO;
            
            self.backgroundColor = kPosterCollageType4Color;
        }
            break;
        case PosterCollageType5:
        {
            _isRegularTemplate = NO;
            
            self.backgroundColor = kPosterCollageType5Color;
        }
            break;
        case PosterCollageType6:
        {
            _isRegularTemplate = NO;
            self.backgroundColor = kPosterCollageType6Color;
        }
            break;
        case PosterCollageType7:
        {
            _isRegularTemplate = NO;
            
            self.backgroundColor = kPosterCollageType7Color;
        }
            break;
        case PosterCollageType8:
        {
            _isRegularTemplate = YES;
            self.backgroundColor = kPosterCollageType8Color;
        }
            break;
        case PosterCollageType9:
        {
            _isRegularTemplate = NO;
            self.backgroundColor = kPosterCollageType9Color;
        }
            break;
        case PosterCollageType10:
        {
            _isRegularTemplate = NO;
            self.backgroundColor = kPosterCollageType10Color;
        }
            break;
        case PosterCollageType11:
        {
            _isRegularTemplate = NO;
            self.backgroundColor = kPosterCollageType11Color;
        }
            break;
        case PosterCollageType12:
        {
            _isRegularTemplate = NO;
            self.backgroundColor = kPosterCollageType12Color;
        }
            break;
        case PosterCollageType13:
        {
            _isRegularTemplate = NO;
            self.backgroundColor = kPosterCollageType13Color;
        }
            break;
        case PosterCollageType14:
        {
            _isRegularTemplate = NO;
            self.backgroundColor = kPosterCollageType14Color;
        }
            break;
        case PosterCollageType15:
        {
            _isRegularTemplate = NO;
            self.backgroundColor = kPosterCollageType15Color;
        }
            break;
        default:
            break;
    }
}
//根据图片数量和海报类型，选择一个模板拼图
- (void)selectAnTemplateWithImagesCount:(NSUInteger)imagesCount
{
    switch (imagesCount) {
        case 1:
        {
            switch (self.currentPosterCollageType)
            {
                case PosterCollageType1:
                {
                    [self template1_1_withoutGap];
                }
                    break;
                case PosterCollageType2:
                {
                    [self template1_1_withGap];
                }
                    break;
                case PosterCollageType3:
                {
                    [self template1_1_withGap];
                }
                    break;
                case PosterCollageType4:
                {
                    [self template4_1];
                }
                    break;
                case PosterCollageType5:
                {
                    [self template1_1_withGap];
                }
                    break;
                case PosterCollageType6:
                {
                    [self template1_1_withGap];
                }
                    break;
                case PosterCollageType7:
                {
                    [self template1_1_withGap];
                }
                    break;
                case PosterCollageType8:
                {
                    [self template1_1_withGap];
                }
                    break;
                case PosterCollageType9:
                {
                    [self template1_1_withGap];
                }
                    break;
                case PosterCollageType10:
                {
                    [self template1_1_withGap];
                }
                    break;
                case PosterCollageType11:
                {
                    [self template1_1_withGap];
                }
                    break;
                case PosterCollageType12:
                {
                    [self template1_1_withGap];
                }
                    break;
                case PosterCollageType13:
                {
                    [self template1_1_withGap];
                }
                    break;
                case PosterCollageType14:
                {
                    [self template1_1_withGap];
                }
                    break;
                case PosterCollageType15:
                {
                    [self template1_1_withGap];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            switch (self.currentPosterCollageType)
            {
                case PosterCollageType1:
                {
                    [self template1_2];
                }
                    break;
                case PosterCollageType2:
                {
                    [self template2_2];
                }
                    break;
                case PosterCollageType3:
                {
                    [self template3_2];
                }
                    break;
                case PosterCollageType4:
                {
                    [self template4_2];
                }
                    break;
                case PosterCollageType5:
                {
                    [self template5_2];
                }
                    break;
                case PosterCollageType6:
                {
                    [self template6_2];
                }
                    break;
                case PosterCollageType7:
                {
                    [self template7_2];
                }
                    break;
                case PosterCollageType8:
                {
                    [self template8_2];
                }
                    break;
                case PosterCollageType9:
                {
                    [self template9_2];
                }
                    break;
                case PosterCollageType10:
                {
                    [self template8_2];
                }
                    break;
                case PosterCollageType11:
                {
                    [self template8_2];
                }
                    break;
                case PosterCollageType12:
                {
                    [self template12_2];
                }
                    break;
                case PosterCollageType13:
                {
                    [self template8_2];
                }
                    break;
                case PosterCollageType14:
                {
                    [self template8_2];
                }
                    break;
                case PosterCollageType15:
                {
                    [self template15_2];
                }
                    break;
                default:
                    break;
            }

        }
            break;
        case 3:
        {
            switch (self.currentPosterCollageType) {
                case PosterCollageType1:
                {
                    [self template1_3];
                }
                    break;
                case PosterCollageType2:
                {
                    [self template2_3];
                }
                    break;
                case PosterCollageType3:
                {
                    [self template3_3];
                }
                    break;
                case PosterCollageType4:
                {
                    [self template4_3];
                }
                    break;
                case PosterCollageType5:
                {
                    [self template5_3];
                }
                    break;
                case PosterCollageType6:
                {
                    [self template6_3];
                }
                    break;
                case PosterCollageType7:
                {
                    [self template7_3];
                }
                    break;
                case PosterCollageType8:
                {
                    [self template8_3];
                }
                    break;
                case PosterCollageType9:
                {
                    [self template9_3];
                }
                    break;
                case PosterCollageType10:
                {
                    [self template8_3];
                }
                    break;
                case PosterCollageType11:
                {
                    [self template11_3];
                }
                    break;
                case PosterCollageType12:
                {
                    [self template12_3];
                }
                    break;
                case PosterCollageType13:
                {
                    [self template13_3];
                }
                    break;
                case PosterCollageType14:
                {
                    [self template14_3];
                }
                    break;
                case PosterCollageType15:
                {
                    [self template15_3];
                }
                    break;
                default:
                    break;
            }

        }
            break;
        case 4:
        {
            switch (self.currentPosterCollageType) {
                case PosterCollageType1:
                {
                    [self template1_4];
                }
                    break;
                case PosterCollageType2:
                {
                    [self template2_4];
                }
                    break;
                case PosterCollageType3:
                {
                    [self template3_4];
                }
                    break;
                case PosterCollageType4:
                {
                    [self template4_4];
                }
                    break;
                case PosterCollageType5:
                {
                    [self template5_4];
                }
                    break;
                case PosterCollageType6:
                {
                    [self template6_4];
                }
                    break;
                case PosterCollageType7:
                {
                    [self template7_4];
                }
                    break;
                case PosterCollageType8:
                {
                    [self template8_4];
                }
                    break;
                case PosterCollageType9:
                {
                    [self template9_4];
                }
                    break;
                case PosterCollageType10:
                {
                    [self template10_4];
                }
                    break;
                case PosterCollageType11:
                {
                    [self template11_4];
                }
                    break;
                case PosterCollageType12:
                {
                    [self template12_4];
                }
                    break;
                case PosterCollageType13:
                {
                    [self template13_4];
                }
                    break;
                case PosterCollageType14:
                {
                    [self template14_4];
                }
                    break;
                case PosterCollageType15:
                {
                    [self template15_4];
                }
                    break;
                default:
                    break;
            }

        }
            break;
        case 5:
        {
            switch (self.currentPosterCollageType) {
                case PosterCollageType1:
                {
                    [self template1_5];
                }
                    break;
                case PosterCollageType2:
                {
                    [self template2_5];
                }
                    break;
                case PosterCollageType3:
                {
                    [self template3_5];
                }
                    break;
                case PosterCollageType4:
                {
                    [self template4_5];
                }
                    break;
                case PosterCollageType5:
                {
                    [self template5_5];
                }
                    break;
                case PosterCollageType6:
                {
                    [self template6_5];
                }
                    break;
                case PosterCollageType7:
                {
                    [self template7_5];
                }
                    break;
                case PosterCollageType8:
                {
                    [self template8_5];
                }
                    break;
                case PosterCollageType9:
                {
                    [self template9_5];
                }
                    break;
                case PosterCollageType10:
                {
                    [self template10_5];
                }
                    break;
                case PosterCollageType11:
                {
                    [self template11_5];
                }
                    break;
                case PosterCollageType12:
                {
                    [self template12_5];
                }
                    break;
                case PosterCollageType13:
                {
                    [self template13_5];
                }
                    break;
                case PosterCollageType14:
                {
                    [self template14_5];
                }
                    break;
                case PosterCollageType15:
                {
                    [self template15_5];
                }
                    break;
                default:
                    break;
            }

        }
            break;
        case 6:
        {
            switch (self.currentPosterCollageType) {
                case PosterCollageType1:
                {
                    [self template1_6];
                }
                    break;
                case PosterCollageType2:
                {
                    [self template2_6];
                }
                    break;
                case PosterCollageType3:
                {
                    [self template3_6];
                }
                    break;
                case PosterCollageType4:
                {
                    [self template4_6];
                }
                    break;
                case PosterCollageType5:
                {
                    [self template5_6];
                }
                    break;
                case PosterCollageType6:
                {
                    [self template2_6];
                }
                    break;
                case PosterCollageType7:
                {
                    [self template7_6];
                }
                    break;
                case PosterCollageType8:
                {
                    [self template8_6];
                }
                    break;
                case PosterCollageType9:
                {
                    [self template9_6];
                }
                    break;
                case PosterCollageType10:
                {
                    [self template10_6];
                }
                    break;
                case PosterCollageType11:
                {
                    [self template11_6];
                }
                    break;
                case PosterCollageType12:
                {
                    [self template12_6];
                }
                    break;
                case PosterCollageType13:
                {
                    [self template13_6];
                }
                    break;
                case PosterCollageType14:
                {
                    [self template14_6];
                }
                    break;
                case PosterCollageType15:
                {
                    [self template15_6];
                }
                    break;
                default:
                    break;
            }

        }
            break;
        case 7:
        {
            switch (self.currentPosterCollageType) {
                case PosterCollageType1:
                {
                    [self template1_7];
                }
                    break;
                case PosterCollageType2:
                {
                    [self template2_7];
                }
                    break;
                case PosterCollageType3:
                {
                    [self template3_7];
                }
                    break;
                case PosterCollageType4:
                {
                    [self template4_7];
                }
                    break;
                case PosterCollageType5:
                {
                    [self template5_7];
                }
                    break;
                case PosterCollageType6:
                {
                    [self template6_7];
                }
                    break;
                case PosterCollageType7:
                {
                    [self template7_7];
                }
                    break;
                case PosterCollageType8:
                {
                    [self template8_7];
                }
                    break;
                case PosterCollageType9:
                {
                    [self template9_7];
                }
                    break;
                case PosterCollageType10:
                {
                    [self template10_7];
                }
                    break;
                case PosterCollageType11:
                {
                    [self template11_7];
                }
                    break;
                case PosterCollageType12:
                {
                    [self template12_7];
                }
                    break;
                case PosterCollageType13:
                {
                    [self template13_7];
                }
                    break;
                case PosterCollageType14:
                {
                    [self template14_7];
                }
                    break;
                case PosterCollageType15:
                {
                    [self template15_7];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark -- Poster collage type 1
- (void)template1_1_withoutGap
{
    int _random = arc4random()%10;
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(0, 0, _currentWidth, _currentHeight)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, 0, _currentWidth, _currentHeight);
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_currentWidth andHeight:_currentHeight];
    _scrollView.originImage = _image1;
    _scrollView.imageView.image = _image1;
        
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template1_2
{
//    if (self.selectedImagesArray.count == 2) {
//        /********* the firt image ***************/
//        ZBPosterImageView *_posterImageView = [[ZBPosterImageView alloc] initWithFrame:CGRectMake(0, 0, _currentWidth, (_currentHeight-_gap)*0.8)];
////        _imageView.imageView.image = [self.selectedImagesArray objectAtIndex:0];
//        _posterImageView.tag = kPosterImageViewStartTag;
//        _posterImageView.originImage = [self.selectedImagesArray objectAtIndex:0];
//        
//        _image1 = [self.selectedImagesArray objectAtIndex:0];
//        
//        CGPoint p = CGPointMake(0, _image1.size.height);
//        [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
//        p = CGPointMake(0, _image1.size.height - _posterImageView.frame.size.height);
//        [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
//        p = CGPointMake(_posterImageView.frame.size.width, _image1.size.height-(_posterImageView.frame.size.height-(_currentHeight-_gap)*0.2));
//        [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
//        p = CGPointMake(_posterImageView.frame.size.width, _image1.size.height);
//        [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
//                
//        [self addSubview:_posterImageView];
//        _posterImageView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
//        
//        [_posterImageView showImageWidthPoints:self.pointArray1];
//        
//        /********* the second image ***************/
//        _posterImageView = [[ZBPosterImageView alloc] initWithFrame:CGRectMake(0, (_currentHeight-_gap)*0.6+_gap, _currentWidth, (_currentHeight-_gap)*0.4)];
////        _imageView.image = [self.selectedImagesArray objectAtIndex:1];
//        _posterImageView.tag = kPosterImageViewStartTag+1;
//        _posterImageView.originImage = [self.selectedImagesArray objectAtIndex:1];
//        
//        _image2 = [self.selectedImagesArray objectAtIndex:1];
//        
//        p = CGPointMake(0, _image2.size.height-(_currentHeight-_gap)*0.2);
//        [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
//        p = CGPointMake(0, _image2.size.height-_posterImageView.frame.size.height);
//        [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
//        p = CGPointMake(_currentWidth, _image2.size.height-_posterImageView.frame.size.height);
//        [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
//        p = CGPointMake(_currentWidth, _image2.size.height);
//        [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
//        
//        [self addSubview:_posterImageView];
//        _posterImageView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
//        [_posterImageView showImageWidthPoints:self.pointArray2];
//    }
    
    int _random = arc4random()%10;
    /********* the firt image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(0, 0, _currentWidth, (_currentHeight-_gap)*0.8)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, 0, _currentWidth, (_currentHeight-_gap)*0.8);


    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_currentWidth andHeight:(_currentHeight-_gap)*0.8];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect1_2_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    
    /********* the second image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(0, (_currentHeight-_gap)*0.6+_gap, _currentWidth, (_currentHeight-_gap)*0.4)];
        _scrollView.delegate = self;
        _scrollView.tag = kPosterImageViewStartTag+1;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, (_currentHeight-_gap)*0.6+_gap, _currentWidth, (_currentHeight-_gap)*0.4);
    
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_currentWidth andHeight:(_currentHeight-_gap)*0.4];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect1_2_2:_scrollView.frame];
    
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];

}

- (void)template1_3
{
    int _random = arc4random()%10;
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(0, 0, _currentWidth, (_currentHeight-_gap)*0.8)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, 0, _currentWidth, (_currentHeight-_gap)*0.8);
    
    if (_isGetOriginImage) {
        _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_currentWidth andHeight:(_currentHeight-_gap)*0.8];
        _scrollView.originImage = _image1;
    }
    _isGetOriginImage = YES;
    ///NSLog(@"image size %f,%f,%f",_image1.size.width,_image1.size.height,_image1.scale);
    
    [self creatPointsArrayWithRect1_3_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    
    /********* the second image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(0, (_currentHeight-_gap)*0.7+_gap, (_currentWidth-_gap)*0.6, (_currentHeight-_gap)*0.3)];
        _scrollView.delegate = self;
        _scrollView.tag = kPosterImageViewStartTag+1;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, (_currentHeight-_gap)*0.7+_gap, (_currentWidth-_gap)*0.6, (_currentHeight-_gap)*0.3);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:(_currentWidth-_gap)*0.6 andHeight:(_currentHeight-_gap)*0.3];
    _scrollView.originImage = _image2;
    
    
    [self creatPointsArrayWithRect1_3_2:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the third image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake((_currentWidth-_gap)*0.5+_gap, (_currentHeight-_gap)*0.6+_gap, (_currentWidth-_gap)*0.5, (_currentHeight-_gap)*0.4)];
        _scrollView.delegate = self;
        _scrollView.tag = kPosterImageViewStartTag+2;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake((_currentWidth-_gap)*0.5+_gap, (_currentHeight-_gap)*0.6+_gap, (_currentWidth-_gap)*0.5, (_currentHeight-_gap)*0.4);
        
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:(_currentWidth-_gap)*0.5 andHeight:(_currentHeight-_gap)*0.4];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect1_3_3:_scrollView.frame];
    
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template1_4
{
    int _random = arc4random()%10;
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(0, 0, _currentWidth, (_currentHeight-2*_gap)*0.35)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, 0, _currentWidth, (_currentHeight-2*_gap)*0.35);    
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_currentWidth andHeight:(_currentHeight-2*_gap)*0.35];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect1_4_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    /********* the second image ***************/
    
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(0, (_currentHeight-2*_gap)*0.15+_gap, _currentWidth, (_currentHeight-2*_gap)*0.65)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, (_currentHeight-2*_gap)*0.15+_gap, _currentWidth, (_currentHeight-2*_gap)*0.65);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_currentWidth andHeight:(_currentHeight-2*_gap)*0.65];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect1_4_2:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the third image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(0, (_currentHeight-2*_gap)*0.7+2*_gap, (_currentWidth-_gap)*0.6, (_currentHeight-2*_gap)*0.3)];
        _scrollView.delegate = self;
        _scrollView.tag = kPosterImageViewStartTag+2;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, (_currentHeight-2*_gap)*0.7+2*_gap, (_currentWidth-_gap)*0.6, (_currentHeight-2*_gap)*0.3);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:(_currentWidth-_gap)*0.6 andHeight:(_currentHeight-2*_gap)*0.3];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect1_4_3:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fourth image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake((_currentWidth-_gap)*0.5+_gap, (_currentHeight-2*_gap)*0.6+2*_gap, (_currentWidth-_gap)*0.5, (_currentHeight-2*_gap)*0.4)];
        _scrollView.delegate = self;
        _scrollView.tag = kPosterImageViewStartTag+3;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake((_currentWidth-_gap)*0.5+_gap, (_currentHeight-2*_gap)*0.6+2*_gap, (_currentWidth-_gap)*0.5, (_currentHeight-2*_gap)*0.4);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:(_currentWidth-_gap)*0.5 andHeight:(_currentHeight-2*_gap)*0.4];
    _scrollView.originImage = _image4;
    
    
    [self creatPointsArrayWithRect1_4_4:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template1_5
{
    int _random = arc4random()%10;
    //计算参数
    float _tanA = 0.2*_currentHeight/_currentWidth;
    float _tanB = (_currentHeight-2*_gap)*3.5/(_currentWidth-_gap);
    float _image1Width = 2.1*(_currentHeight-2*_gap)/(_tanA+_tanB);
    float _image1SecondHeight  = 2.1*(_currentHeight-2*_gap)*_tanA/(_tanA+_tanB);
        
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(0, 0, _image1Width, (_currentHeight-2*_gap)*0.35)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, 0, _image1Width, (_currentHeight-2*_gap)*0.35);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_image1Width andHeight:(_currentHeight-2*_gap)*0.35];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect1_5_1:_scrollView.frame withSecondHeight:_image1SecondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    //计算参数
    
    float _cosB = 1/sqrt(1+1/(_tanB*_tanB));
    float _sinB = sqrt(1-_cosB*_cosB);
    float _incr = _gap/_sinB;
    
    float _image2SecondWidth = (2.1*(_currentHeight-2*_gap)+_incr)/(_tanA+_tanB);
    float _image2Height  = (2.1*(_currentHeight-2*_gap)+_incr)*_tanA/(_tanA+_tanB);
    _image2Height = (_currentHeight-2*_gap)*0.35-_image2Height;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake((_currentWidth-_gap)*0.5+_gap, 0, (_currentWidth-_gap)*0.5, _image2Height)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake((_currentWidth-_gap)*0.5+_gap, 0, (_currentWidth-_gap)*0.5, _image2Height);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:(_currentWidth-_gap)*0.5 andHeight:_image2Height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect1_5_2:_scrollView.frame withSecondWidth:_image2SecondWidth];
    
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the third image ***************/
   
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(0, (_currentHeight-2*_gap)*0.15+_gap, _currentWidth, (_currentHeight-2*_gap)*0.65)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, (_currentHeight-2*_gap)*0.15+_gap, _currentWidth, (_currentHeight-2*_gap)*0.65);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_currentWidth andHeight:(_currentHeight-2*_gap)*0.65];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect1_5_3:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fourth image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(0, (_currentHeight-2*_gap)*0.7+2*_gap, (_currentWidth-_gap)*0.6, (_currentHeight-2*_gap)*0.3)];
        _scrollView.delegate = self;
        _scrollView.tag = kPosterImageViewStartTag+3;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, (_currentHeight-2*_gap)*0.7+2*_gap, (_currentWidth-_gap)*0.6, (_currentHeight-2*_gap)*0.3);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:(_currentWidth-_gap)*0.6 andHeight:(_currentHeight-2*_gap)*0.3];
    _scrollView.originImage = _image4;
    
    
    [self creatPointsArrayWithRect1_5_4:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fifth image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake((_currentWidth-_gap)*0.5+_gap, (_currentHeight-2*_gap)*0.6+2*_gap, (_currentWidth-_gap)*0.5, (_currentHeight-2*_gap)*0.4)];
        _scrollView.delegate = self;
        _scrollView.tag = kPosterImageViewStartTag+4;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake((_currentWidth-_gap)*0.5+_gap, (_currentHeight-2*_gap)*0.6+2*_gap, (_currentWidth-_gap)*0.5, (_currentHeight-2*_gap)*0.4);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:(_currentWidth-_gap)*0.5 andHeight:(_currentHeight-2*_gap)*0.4];
    _scrollView.originImage = _image5;
    
    
    [self creatPointsArrayWithRect1_5_5:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template1_6
{
    int _random = arc4random()%10;
    //计算参数
    float _tanA = 0.2*_currentHeight/_currentWidth;
    float _tanB = (_currentHeight-2*_gap)*3.5/(_currentWidth-_gap);
    float _image1Width = 2.1*(_currentHeight-2*_gap)/(_tanA+_tanB);
    float _image1SecondHeight  = 2.1*(_currentHeight-2*_gap)*_tanA/(_tanA+_tanB);
    
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(0, 0, _image1Width, (_currentHeight-2*_gap)*0.35)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, 0, _image1Width, (_currentHeight-2*_gap)*0.35);
    
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_image1Width andHeight:(_currentHeight-2*_gap)*0.35];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect1_6_1:_scrollView.frame withSecondHeight:_image1SecondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    //计算参数
    
    float _cosB = 1/sqrt(1+1/(_tanB*_tanB));
    float _sinB = sqrt(1-_cosB*_cosB);
    float _incr = _gap/_sinB;
    
    float _image2SecondWidth = (2.1*(_currentHeight-2*_gap)+_incr)/(_tanA+_tanB);
    float _image2Height  = (2.1*(_currentHeight-2*_gap)+_incr)*_tanA/(_tanA+_tanB);
    _image2Height = (_currentHeight-2*_gap)*0.35-_image2Height;
    
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake((_currentWidth-_gap)*0.5+_gap, 0, (_currentWidth-_gap)*0.5, _image2Height)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake((_currentWidth-_gap)*0.5+_gap, 0, (_currentWidth-_gap)*0.5, _image2Height);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:(_currentWidth-_gap)*0.5 andHeight:_image2Height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect1_6_2:_scrollView.frame withSecondWidth:_image2SecondWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the third image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(0, (_currentHeight-2*_gap)*0.15+_gap, _currentWidth, (_currentHeight-2*_gap)*0.65)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, (_currentHeight-2*_gap)*0.15+_gap, _currentWidth, (_currentHeight-2*_gap)*0.65);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_currentWidth andHeight:(_currentHeight-2*_gap)*0.65];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect1_6_3:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fourth image ***************/
    float _b = 0.8*(_currentHeight-2*_gap)/3+_tanB*((_currentWidth-2*_gap)/3);
    float _image4Height = -_tanB*(_currentWidth-2*_gap)/3+_b;
    float _image4Width = _b/_tanB;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(0, _currentHeight-_image4Height, _image4Width, _image4Height)];
        _scrollView.delegate = self;
        _scrollView.tag = kPosterImageViewStartTag+3;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, _currentHeight-_image4Height, _image4Width, _image4Height);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_image4Width andHeight:_image4Height];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect1_6_4:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fifth image ***************/
    float _tanC = 0.2*(_currentHeight-2*_gap)/(_currentWidth-2*_gap);
    float _incH = _gap*_tanC;
    float _cosC = 1/sqrt(1+_tanC*_tanC);
    float _incW = _gap/_cosC;
    _b = (_currentHeight-2*_gap)/3+_tanB*((_currentWidth-2*_gap)/3*2);
    float _image5Height = -_tanB*2*(_currentWidth-2*_gap)/3+_b;
    float _image5RightWidth = _b/_tanB;
    
    _b = 0.8*(_currentHeight-2*_gap)/3+_incH+_tanB*((_currentWidth-2*_gap)/3+_incW);
    float _image5LeftHeight = -_tanB*((_currentWidth-2*_gap)/3+_incW)+_b;
    float _image5LeftWidth = _b/_tanB;
    float _image5Width = _image5RightWidth-(_currentWidth-2*_gap)/3-_incW;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake((_currentWidth-2*_gap)/3+_gap, _currentHeight-_image5Height, _image5Width, _image5Height)];
        _scrollView.delegate = self;
        _scrollView.tag = kPosterImageViewStartTag+4;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake((_currentWidth-2*_gap)/3+_gap, _currentHeight-_image5Height, _image5Width, _image5Height);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_image5Width andHeight:_image5Height];
    _scrollView.originImage = _image5;
    
    [self creatPointsArray1_6_5:_scrollView.frame withLeftHeight:_image5LeftHeight andLeftWidth:_image5LeftWidth-(_currentWidth-2*_gap)/3-_gap];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the sixth image ***************/
    _b = (_currentHeight-2*_gap)/3+_incH+_tanB*((_currentWidth-2*_gap)/3*2+_incW);
    float _image6LeftW = _b/_tanB;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+5];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake((_currentWidth-2*_gap)/3*2+2*_gap, (_currentHeight-2*_gap)*0.6+2*_gap, (_currentWidth-2*_gap)/3, (_currentHeight-2*_gap)*0.4)];
        _scrollView.delegate = self;
        _scrollView.tag = kPosterImageViewStartTag+5;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake((_currentWidth-2*_gap)/3*2+2*_gap, (_currentHeight-2*_gap)*0.6+2*_gap, (_currentWidth-2*_gap)/3, (_currentHeight-2*_gap)*0.4);
    
    _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:(_currentWidth-2*_gap)/3 andHeight:(_currentHeight-2*_gap)*0.4];
    _scrollView.originImage = _image6;
    
    [self creatPointsArray1_6_6:_scrollView.frame andLeftWidth:_image6LeftW-(_currentWidth-2*_gap)/3*2-2*_gap];
    
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
    _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template1_7
{
    int _random = arc4random()%10;
    //计算参数
    float _tanA = 0.2*(_currentHeight-2*_gap)/(_currentWidth-2*_gap);
    float _tanB = (_currentHeight-2*_gap)*3.5/(_currentWidth-2*_gap);
    float _b = 0.35*(_currentHeight-2*_gap)+_tanB*(_currentWidth-2*_gap)/3;
    
    
    float _image1Width = _b/(_tanA+_tanB);
    float _image1SecondHeight  = _b*_tanA/(_tanA+_tanB);
    
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(0, 0, _image1Width, (_currentHeight-2*_gap)*0.35)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, 0, _image1Width, (_currentHeight-2*_gap)*0.35);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_image1Width andHeight:(_currentHeight-2*_gap)*0.35];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect1_7_1:_scrollView.frame withSecondHeight:_image1SecondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    //计算参数
    float _cosA = 1/sqrt(1+_tanA*_tanA);
    float _sinA = sqrt(1-_cosA*_cosA);
    float _incrW = _gap*_cosA;
    float _incrH = _gap*_sinA;

    _b = 0.35*(_currentHeight-2*_gap)+_incrH+_tanB*((_currentWidth-2*_gap)/3+_incrW);
    float _image2LeftHeight = _b*_tanA/(_tanA+_tanB);
    float _image2LeftWidth = _b/(_tanA+_tanB);
    
    _b = 0.35*(_currentHeight-2*_gap)+_incrH+_tanB*((_currentWidth-2*_gap)/3*2+_incrW);
    float _image2RightHeight = _b*_tanA/(_tanA+_tanB);
    float _image2RightWidth = _b/(_tanA+_tanB);
    
    float _image2Width = _image2RightWidth-(_currentWidth-2*_gap)/3-_gap;
    float _image2Height  = 0.35*(_currentHeight-2*_gap)-_image2LeftHeight;
    
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake((_currentWidth-2*_gap)/3+_gap, 0, _image2Width, _image2Height)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake((_currentWidth-2*_gap)/3+_gap, 0, _image2Width, _image2Height);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_image2Width andHeight:_image2Height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect1_7_2:_scrollView.frame withLeftWidth:_image2LeftWidth-(_currentWidth-2*_gap)/3-_gap andRightHeight:_image2RightHeight-_image2LeftHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 7 image ***************/
    //计算参数
    _b = 0.35*(_currentHeight-2*_gap)+_incrH*2+_tanB*((_currentWidth-2*_gap)/3*2+2*_incrW);
    float _image3LeftHeight = _b*_tanA/(_tanA+_tanB);
    float _image3LeftWidth = _b/(_tanA+_tanB);
    float _image3Height = (_currentHeight-2*_gap)*0.35-_image3LeftHeight;
    
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+6];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake((_currentWidth-2*_gap)/3*2+2*_gap, 0, (_currentWidth-2*_gap)/3, _image3Height)];
        _scrollView.tag = kPosterImageViewStartTag+6;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake((_currentWidth-2*_gap)/3*2+2*_gap, 0, (_currentWidth-2*_gap)/3, _image3Height);
    
    _image7 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:6] withWidth:(_currentWidth-2*_gap)/3 andHeight:_image3Height];
    _scrollView.originImage = _image7;
    
    [self creatPointsArrayWithRect1_7_7:_scrollView.frame andLeftWidth:_image3LeftWidth-(_currentWidth-2*_gap)/3*2-2*_gap];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image7.size.width, _image7.size.height);
    _scrollView.contentSize = CGSizeMake(_image7.size.width, _image7.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(0, (_currentHeight-2*_gap)*0.15+_gap, _currentWidth, (_currentHeight-2*_gap)*0.65)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, (_currentHeight-2*_gap)*0.15+_gap, _currentWidth, (_currentHeight-2*_gap)*0.65);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_currentWidth andHeight:(_currentHeight-2*_gap)*0.65];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect1_7_3:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fourth image ***************/
    _b = 0.8*(_currentHeight-2*_gap)/3+_tanB*((_currentWidth-2*_gap)/3);
    float _image4Height = -_tanB*(_currentWidth-2*_gap)/3+_b;
    float _image4Width = _b/_tanB;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(0, _currentHeight-_image4Height, _image4Width, _image4Height)];
        _scrollView.delegate = self;
        _scrollView.tag = kPosterImageViewStartTag+3;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, _currentHeight-_image4Height, _image4Width, _image4Height);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_image4Width andHeight:_image4Height];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect1_7_4:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fifth image ***************/
    float _tanC = 0.2*(_currentHeight-2*_gap)/(_currentWidth-2*_gap);
    float _incH = _gap*_tanC;
    float _cosC = 1/sqrt(1+_tanC*_tanC);
    float _incW = _gap/_cosC;
    _b = (_currentHeight-2*_gap)/3+_tanB*((_currentWidth-2*_gap)/3*2);
    float _image5Height = -_tanB*2*(_currentWidth-2*_gap)/3+_b;
    float _image5RightWidth = _b/_tanB;
    
    _b = 0.8*(_currentHeight-2*_gap)/3+_incH+_tanB*((_currentWidth-2*_gap)/3+_incW);
    float _image5LeftHeight = -_tanB*((_currentWidth-2*_gap)/3+_incW)+_b;
    float _image5LeftWidth = _b/_tanB;
    float _image5Width = _image5RightWidth-(_currentWidth-2*_gap)/3-_incW;
    
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake((_currentWidth-2*_gap)/3+_gap, _currentHeight-_image5Height, _image5Width, _image5Height)];
        _scrollView.delegate = self;
        _scrollView.tag = kPosterImageViewStartTag+4;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake((_currentWidth-2*_gap)/3+_gap, _currentHeight-_image5Height, _image5Width, _image5Height);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_image5Width andHeight:_image5Height];
    _scrollView.originImage = _image5;
    
    [self creatPointsArray1_7_5:_scrollView.frame withLeftHeight:_image5LeftHeight andLeftWidth:_image5LeftWidth-(_currentWidth-2*_gap)/3-_gap];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the sixth image ***************/
    _b = (_currentHeight-2*_gap)/3+_incH+_tanB*((_currentWidth-2*_gap)/3*2+_incW);
    float _image6LeftW = _b/_tanB;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+5];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake((_currentWidth-2*_gap)/3*2+2*_gap, (_currentHeight-2*_gap)*0.6+2*_gap, (_currentWidth-2*_gap)/3, (_currentHeight-2*_gap)*0.4)];
        _scrollView.delegate = self;
        _scrollView.tag = kPosterImageViewStartTag+5;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake((_currentWidth-2*_gap)/3*2+2*_gap, (_currentHeight-2*_gap)*0.6+2*_gap, (_currentWidth-2*_gap)/3, (_currentHeight-2*_gap)*0.4);
    
    _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:(_currentWidth-2*_gap)/3 andHeight:(_currentHeight-2*_gap)*0.4];
    _scrollView.originImage = _image6;
    
    [self creatPointsArray1_7_6:_scrollView.frame andLeftWidth:_image6LeftW-(_currentWidth-2*_gap)/3*2-2*_gap];
    
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
    _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}



#pragma mark -- Poster collage type 2

- (void)template1_1_withGap
{
    float _x = _gap;
    float _y = _gap;
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight-2*_gap;
    
    int _random = arc4random()%10;
    
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_x, _y, _w, _h)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_x, _y, _w, _h);
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_w andHeight:_h];
    _scrollView.originImage = _image1;
    _scrollView.imageView.image = _image1;
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template2_2
{
    int _random = arc4random()%10;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _currentWidth-2*_gap, (_currentHeight-3*_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_currentWidth-2*_gap andHeight:(_currentHeight-3*_gap)*0.5];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect2_2_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-3*_gap)*0.4+_gap, _currentWidth-2*_gap, (_currentHeight-3*_gap)*0.6);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_currentWidth-2*_gap andHeight:(_currentHeight-3*_gap)*0.5];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect2_2_2:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];

}

- (void)template2_3
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    int _random = arc4random()%10;
    //计算参数
    float _tanA = 0.1*(_h-_gap)/_w;
    float _tanB = (_h-_gap)*5/(_w-_gap);
    float _image1Width = 3*(_h-_gap)/(_tanA+_tanB);
    float _image1SecondHeight  = 3*(_h-_gap)*_tanA/(_tanA+_tanB);
    
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _image1Width, (_currentHeight-3*_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_image1Width andHeight:(_currentHeight-3*_gap)*0.5];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect2_3_1:_scrollView.frame  withSecondHeight:_image1SecondHeight];
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    //计算参数
    
    float _cosB = 1/sqrt(1+1/(_tanB*_tanB));
    float _sinB = sqrt(1-_cosB*_cosB);
    float _incr = _gap/_sinB;
    
    float _image2SecondWidth = (3*(_h-_gap)+_incr)/(_tanA+_tanB);
    float _image2Height  = (3*(_h-_gap)+_incr)*_tanA/(_tanA+_tanB);
    _image2Height = (_h-_gap)*0.5-_image2Height;
    
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, _image2Height);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:(_currentWidth-3*_gap)*0.5 andHeight:_image2Height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect2_3_2:_scrollView.frame withSecondWidth:_image2SecondWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];

    
    /********* the third image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_currentHeight-3*_gap)*0.4+_gap, _currentWidth-2*_gap, (_currentHeight-3*_gap)*0.6)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-3*_gap)*0.4+_gap, _currentWidth-2*_gap, (_currentHeight-3*_gap)*0.6);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_currentWidth-2*_gap andHeight:(_currentHeight-3*_gap)*0.6];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect2_3_3:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
}

- (void)template2_4
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    int _random = arc4random()%10;
    //计算参数
    float _tanA = 0.1*(_h-2*_gap)/_w;
    float _tanB = (_h-2*_gap)*5/(_w-_gap);
    float _image1Width = 3*(_h-2*_gap)/(_tanA+_tanB);
    float _image1SecondHeight  = 3*(_h-2*_gap)*_tanA/(_tanA+_tanB);
    
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap, _image1Width, (_currentHeight-4*_gap)*0.5)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _image1Width, (_currentHeight-4*_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_image1Width andHeight:(_currentHeight-4*_gap)*0.5];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect2_4_1:_scrollView.frame  withSecondHeight:_image1SecondHeight];
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    //计算参数
    
    float _cosB = 1/sqrt(1+1/(_tanB*_tanB));
    float _sinB = sqrt(1-_cosB*_cosB);
    float _incr = _gap/_sinB;
    
    float _image2SecondWidth = (3*(_h-2*_gap)+_incr)/(_tanA+_tanB);
    float _image2Height  = (3*(_h-2*_gap)+_incr)*_tanA/(_tanA+_tanB);
    _image2Height = (_h-2*_gap)*0.5-_image2Height;
    
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, _image2Height)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, _image2Height);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:(_currentWidth-3*_gap)*0.5 andHeight:_image2Height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect2_4_2:_scrollView.frame withSecondWidth:_image2SecondWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    
    /********* the third image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_currentHeight-4*_gap)*0.4+_gap, _currentWidth-2*_gap, (_currentHeight-4*_gap)*0.4)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)*0.4+_gap, _currentWidth-2*_gap, (_currentHeight-4*_gap)*0.4);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_currentWidth-2*_gap andHeight:(_currentHeight-4*_gap)*0.4];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect2_4_3:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fourth image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_currentHeight-4*_gap)*0.7+2*_gap, _currentWidth-2*_gap, (_currentHeight-4*_gap)*0.3)];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)*0.7+2*_gap, _currentWidth-2*_gap, (_currentHeight-4*_gap)*0.3);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_currentWidth-2*_gap andHeight:(_currentHeight-4*_gap)*0.3];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect2_4_4:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
}

- (void)template2_5
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    int _random = arc4random()%10;
    //计算参数
    float _tanA = 0.1*(_h-2*_gap)/_w;
    float _tanB = (_h-2*_gap)*5/(_w-_gap);
    float _image1Width = 3*(_h-2*_gap)/(_tanA+_tanB);
    float _image1SecondHeight  = 3*(_h-2*_gap)*_tanA/(_tanA+_tanB);
    
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap, _image1Width, (_currentHeight-4*_gap)*0.5)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _image1Width, (_currentHeight-4*_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_image1Width andHeight:(_currentHeight-4*_gap)*0.5];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect2_5_1:_scrollView.frame  withSecondHeight:_image1SecondHeight];
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    //计算参数
    
    float _cosB = 1/sqrt(1+1/(_tanB*_tanB));
    float _sinB = sqrt(1-_cosB*_cosB);
    float _incrW = _gap/_sinB;
    
    float _image2SecondWidth = (3*(_h-2*_gap)+_incrW)/(_tanA+_tanB);
    float _image2Height  = (3*(_h-2*_gap)+_incrW)*_tanA/(_tanA+_tanB);
    _image2Height = (_h-2*_gap)*0.5-_image2Height;
    
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, _image2Height)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, _image2Height);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:(_currentWidth-3*_gap)*0.5 andHeight:_image2Height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect2_5_2:_scrollView.frame withSecondWidth:_image2SecondWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    
    /********* the third image ***************/
    //计算参数
    _tanB = ((_h-2*_gap)*0.5+_gap)*10/(_w-_gap);
    float _cosA = 1/sqrt((1+_tanA*_tanA));
    float _incrY = _gap/_cosA;
    float _image3SecondWidth = (2.5*(_h - 2*_gap)+5*_gap-0.5*(_h-2*_gap)+_incrY-2*_gap)/(_tanA+_tanB);
    float _image3Height = ((2.5*(_h-2*_gap)+5*_gap)*_tanA+_tanB*(0.5*(_h-2*_gap)-_incrY+2*_gap))/(_tanA+_tanB);
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_h-_image3Height, (_w-_gap)*0.5, _image3Height)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_h-_image3Height, (_w-_gap)*0.5, _image3Height);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:(_w-_gap)*0.5 andHeight:_image3Height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect2_5_3:_scrollView.frame withSecondWidth:_image3SecondWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fourth image ***************/
    float _a = (_h-2*_gap)*0.5-_incrY+2*_gap;
    float _b = 2.5*(_h-2*_gap)+5*_gap+5*_gap*(_h-2*_gap)/(_w-_gap)+10*_gap*_gap/(_w-_gap);
    float _upW4 = (_b-_a)/(_tanA+_tanB);
    float _upH4 = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = (_h-2*_gap)*0.2+_incrY;
    float _w4 = (_b-_a)/(_tanA+_tanB);
    float _h4 = (_b*_tanA + _a*_tanB)/(_tanA+_tanB);
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_upW4, _gap+(_currentHeight-4*_gap)*0.4+_gap, _currentWidth-2*_gap-_upW4, (_currentHeight-4*_gap)*0.6+_gap-_h4)];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_upW4, _gap+(_currentHeight-4*_gap)*0.4+_gap, _currentWidth-2*_gap-_upW4, (_currentHeight-4*_gap)*0.6+_gap-_h4);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_currentWidth-2*_gap-_upW4 andHeight:(_currentHeight-4*_gap)*0.6+_gap-_h4];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect2_5_4:_scrollView.frame withSecondWidth:_w4-_upW4 andUpH4:_upH4];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fifth image ***************/
    _a = (_h-2*_gap)*0.2;
    float _w5 = (_b - _a)/(_tanA+_tanB);
    float _h5 = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_w5, _gap+(_currentHeight-4*_gap)*0.7+2*_gap, _currentWidth-2*_gap-_w5, (_currentHeight-4*_gap)*0.3)];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_w5, _gap+(_currentHeight-4*_gap)*0.7+2*_gap, _currentWidth-2*_gap-_w5, (_currentHeight-4*_gap)*0.3);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_currentWidth-2*_gap-_w5 andHeight:(_currentHeight-4*_gap)*0.3];
    _scrollView.originImage = _image5;
    
    [self creatPointsArrayWithRect2_5_5:_scrollView.frame withSecondHeight:_h5];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
}

- (void)template2_6
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    
    int _random = arc4random()%10;
    //计算参数
    float _tanA = 0.1*(_h-2*_gap)/_w;
    float _tanB = (_h-2*_gap)*5/(_w-_gap);
    float _image1Width = 3*(_h-2*_gap)/(_tanA+_tanB);
    float _image1SecondHeight  = 3*(_h-2*_gap)*_tanA/(_tanA+_tanB);
    
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap, _image1Width, (_currentHeight-4*_gap)*0.5)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _image1Width, (_currentHeight-4*_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_image1Width andHeight:(_currentHeight-4*_gap)*0.5];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect2_6_1:_scrollView.frame  withSecondHeight:_image1SecondHeight];
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    //计算参数
    
    float _cosB = 1/sqrt(1+1/(_tanB*_tanB));
    float _sinB = sqrt(1-_cosB*_cosB);
    float _incrW = _gap/_sinB;
    
    float _image2SecondWidth = (3*(_h-2*_gap)+_incrW)/(_tanA+_tanB);
    float _image2Height  = (3*(_h-2*_gap)+_incrW)*_tanA/(_tanA+_tanB);
    _image2Height = (_h-2*_gap)*0.5-_image2Height;
    
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, _image2Height)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, _image2Height);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:(_currentWidth-3*_gap)*0.5 andHeight:_image2Height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect2_6_2:_scrollView.frame withSecondWidth:_image2SecondWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    
    /********* the 3 image ***************/
    //计算参数
    _tanB = ((_h-2*_gap)*0.5+_gap)*10/(_w-_gap);
    float _cosA = 1/sqrt((1+_tanA*_tanA));
    float _incrY = _gap/_cosA;
    float _a = 0.5*(_h-2*_gap)-_incrY+2*_gap;
    float _b = 2.5*(_h - 2*_gap)+5*_gap;
    float _image3SecondWidth = (_b-_a)/(_tanA+_tanB);
    float _image3Height = (_b*_tanA+_tanB*_a)/(_tanA+_tanB);
    float _y = _image3Height;
    _image3Height = _image3Height - (_h - 2*_gap)*0.2-_gap;
    
    _a = 0.2*(_h-2*_gap)+_incrY;
    float _image3Width = (_b-_a)/(_tanA+_tanB);
    float _image3SecondHeight = (_b*_tanA+_tanB*_a)/(_tanA+_tanB);
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_h-_y, _image3Width, _image3Height)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_h-_y, _image3Width, _image3Height);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_image3Width andHeight:_image3Height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect2_6_3:_scrollView.frame withSecondWidth:_image3SecondWidth withSecondHeight:_image3SecondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    //计算参数
    _a = 0.2*(_h-2*_gap);
    float _image4SecondWidth = (_b-_a)/(_tanA+_tanB);
    float _image4Height = (_b*_tanA+_tanB*_a)/(_tanA+_tanB);
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_h-_image4Height, (_w-_gap)*0.5, _image4Height)];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_h-_image4Height, (_w-_gap)*0.5, _image4Height);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:(_w-_gap)*0.5 andHeight:_image4Height];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect2_6_4:_scrollView.frame withSecondWidth:_image4SecondWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    _a = (_h-2*_gap)*0.5-_incrY+2*_gap;
    _b = 2.5*(_h-2*_gap)+5*_gap+5*_gap*(_h-2*_gap)/(_w-_gap)+10*_gap*_gap/(_w-_gap);
    float _upW5 = (_b-_a)/(_tanA+_tanB);
    float _upH5 = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = (_h-2*_gap)*0.2+_incrY;
    float _w5 = (_b-_a)/(_tanA+_tanB);
    float _h5 = (_b*_tanA + _a*_tanB)/(_tanA+_tanB);
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_upW5, _gap+(_currentHeight-4*_gap)*0.4+_gap, _currentWidth-2*_gap-_upW5, (_currentHeight-4*_gap)*0.6+_gap-_h5)];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_upW5, _gap+(_currentHeight-4*_gap)*0.4+_gap, _currentWidth-2*_gap-_upW5, (_currentHeight-4*_gap)*0.6+_gap-_h5);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_currentWidth-2*_gap-_upW5 andHeight:(_currentHeight-4*_gap)*0.6+_gap-_h5];
    _scrollView.originImage = _image5;
    
    [self creatPointsArrayWithRect2_6_5:_scrollView.frame withSecondWidth:_w5-_upW5 andUpH5:_upH5];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the sixth image ***************/
    _a = (_h-2*_gap)*0.2;
    float _w6 = (_b - _a)/(_tanA+_tanB);
    float _h6 = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+5];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_w6, _gap+(_currentHeight-4*_gap)*0.7+2*_gap, _currentWidth-2*_gap-_w6, (_currentHeight-4*_gap)*0.3)];
        _scrollView.tag = kPosterImageViewStartTag+5;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_w6, _gap+(_currentHeight-4*_gap)*0.7+2*_gap, _currentWidth-2*_gap-_w6, (_currentHeight-4*_gap)*0.3);
    
    _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_currentWidth-2*_gap-_w6 andHeight:(_currentHeight-4*_gap)*0.3];
    _scrollView.originImage = _image6;
    
    [self creatPointsArrayWithRect2_6_6:_scrollView.frame withSecondHeight:_h6];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
    _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
}

- (void)template2_7
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    int _random = arc4random()%10;
    //计算参数
    float _tanA = 0.1*(_h-2*_gap)/_w;
    float _tanB = (_h-2*_gap)*5/(_w-_gap);
    float _image1Width = 3*(_h-2*_gap)/(_tanA+_tanB);
    float _image1SecondHeight  = 3*(_h-2*_gap)*_tanA/(_tanA+_tanB);
    
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap, _image1Width, (_currentHeight-4*_gap)*0.5)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _image1Width, (_currentHeight-4*_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_image1Width andHeight:(_currentHeight-4*_gap)*0.5];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect2_7_1:_scrollView.frame  withSecondHeight:_image1SecondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    //计算参数
    
    float _cosB = 1/sqrt(1+1/(_tanB*_tanB));
    float _sinB = sqrt(1-_cosB*_cosB);
    float _incrW = _gap/_sinB;
    float _a = (_h-2*_gap)*0.2+_gap;
    float _b = 3*(_h-2*_gap)+_incrW;
    float _image2SecondWidth = (_b-_a)/(_tanA+_tanB);
    float _image2Height  = (_b*_tanA+_tanB*_a)/(_tanA+_tanB);
    _image2Height = (_h-2*_gap)*0.5-_image2Height;
    
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, _image2Height)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, _image2Height);
    NSLog(@"self.selectedImagesArray %d",self.selectedImagesArray.count);
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:(_currentWidth-3*_gap)*0.5 andHeight:_image2Height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect2_7_2:_scrollView.frame withSecondWidth:_image2SecondWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    
    /********* the 3 image ***************/
    //计算参数
    _tanB = ((_h-2*_gap)*0.5+_gap)*10/(_w-_gap);
    float _cosA = 1/sqrt((1+_tanA*_tanA));
    float _incrY = _gap/_cosA;
    _a = 0.5*(_h-2*_gap)-_incrY+2*_gap;
    _b = 2.5*(_h - 2*_gap)+5*_gap;
    float _image3SecondWidth = (_b-_a)/(_tanA+_tanB);
    float _image3Height = (_b*_tanA+_tanB*_a)/(_tanA+_tanB);
    float _y = _image3Height;
    _image3Height = _image3Height - (_h - 2*_gap)*0.2-_gap;
    
    _a = 0.2*(_h-2*_gap)+_incrY;
    float _image3Width = (_b-_a)/(_tanA+_tanB);
    float _image3SecondHeight = (_b*_tanA+_tanB*_a)/(_tanA+_tanB);
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_h-_y, _image3Width, _image3Height)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_h-_y, _image3Width, _image3Height);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_image3Width andHeight:_image3Height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect2_7_3:_scrollView.frame withSecondWidth:_image3SecondWidth withSecondHeight:_image3SecondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    //计算参数
    _a = 0.2*(_h-2*_gap);
    float _image4SecondWidth = (_b-_a)/(_tanA+_tanB);
    float _image4Height = (_b*_tanA+_tanB*_a)/(_tanA+_tanB);
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_h-_image4Height, (_w-_gap)*0.5, _image4Height)];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_h-_image4Height, (_w-_gap)*0.5, _image4Height);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:(_w-_gap)*0.5 andHeight:_image4Height];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect2_7_4:_scrollView.frame withSecondWidth:_image4SecondWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    _a = (_h-2*_gap)*0.5-_incrY+2*_gap;
    _b = 2.5*(_h-2*_gap)+5*_gap+5*_gap*(_h-2*_gap)/(_w-_gap)+10*_gap*_gap/(_w-_gap);
    float _upW5 = (_b-_a)/(_tanA+_tanB);
    float _upH5 = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = (_h-2*_gap)*0.2+_incrY;
    float _w5 = (_b-_a)/(_tanA+_tanB);
    float _h5 = (_b*_tanA + _a*_tanB)/(_tanA+_tanB);
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_upW5, _gap+(_currentHeight-4*_gap)*0.4+_gap, _currentWidth-2*_gap-_upW5, (_currentHeight-4*_gap)*0.6+_gap-_h5)];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_upW5, _gap+(_currentHeight-4*_gap)*0.4+_gap, _currentWidth-2*_gap-_upW5, (_currentHeight-4*_gap)*0.6+_gap-_h5);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_currentWidth-2*_gap-_upW5 andHeight:(_currentHeight-4*_gap)*0.6+_gap-_h5];
    _scrollView.originImage = _image5;
    
    [self creatPointsArrayWithRect2_7_5:_scrollView.frame withSecondWidth:_w5-_upW5 andUpH5:_upH5];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the sixth image ***************/
    _a = (_h-2*_gap)*0.2;
    float _w6 = (_b - _a)/(_tanA+_tanB);
    float _h6 = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+5];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_w6, _gap+(_currentHeight-4*_gap)*0.7+2*_gap, _currentWidth-2*_gap-_w6, (_currentHeight-4*_gap)*0.3)];
        _scrollView.tag = kPosterImageViewStartTag+5;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_w6, _gap+(_currentHeight-4*_gap)*0.7+2*_gap, _currentWidth-2*_gap-_w6, (_currentHeight-4*_gap)*0.3);
    
    _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_currentWidth-2*_gap-_w6 andHeight:(_currentHeight-4*_gap)*0.3];
    _scrollView.originImage = _image6;
    
    [self creatPointsArrayWithRect2_7_6:_scrollView.frame withSecondHeight:_h6];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
    _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 7 image ***************/

//    float _a = (_h-2*_gap)*0.2+_gap;
//    float _b = 3*(_h-2*_gap)+_incrW;

    //计算参数
    _tanB = (_h-2*_gap)*5/(_w-_gap);
    _a = (_h-2*_gap)*0.2;
    _b = 3*(_h-2*_gap)+_incrW;
    float _image7UpWidth = (_b - _a)/(_tanA+_tanB);
    float _image7UpHeight = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    _a = 0;
    float _image7SecondWidth = (_b - _a)/(_tanA+_tanB);
    float _image7Height  = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    _image7Height = (_h-2*_gap)*0.3-_image7Height-_gap;
    
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+6];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_image7UpWidth, _gap+(_currentHeight-5*_gap)*0.2+_gap, _w-_image7UpWidth, _image7Height)];
        _scrollView.tag = kPosterImageViewStartTag+6;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_image7UpWidth, _gap+(_currentHeight-5*_gap)*0.2+_gap, _w-_image7UpWidth, _image7Height);
    
    _image7 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:6] withWidth:_w-_image7UpWidth andHeight:_image7Height];
    _scrollView.originImage = _image7;
    
    [self creatPointsArrayWithRect2_7_7:_scrollView.frame withSecondWidth:_image7SecondWidth-_image7UpWidth withSecondHeight:_image7UpHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image7.size.width, _image7.size.height);
    _scrollView.contentSize = CGSizeMake(_image7.size.width, _image7.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

#pragma mark -- Poster collage type 3

- (void)template3_2
{
    int _random = arc4random()%10;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap, _currentWidth-2*_gap, (_currentHeight-3*_gap)*0.55)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _currentWidth-2*_gap, (_currentHeight-3*_gap)*0.55);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_currentWidth-2*_gap andHeight:(_currentHeight-3*_gap)*0.55];
    _scrollView.originImage = _image1;
    
    _scrollView.imageView.image = _image1;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 2 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_currentHeight-3*_gap)*0.55+_gap, _currentWidth-2*_gap, (_currentHeight-3*_gap)*0.45)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-3*_gap)*0.55+_gap, _currentWidth-2*_gap, (_currentHeight-3*_gap)*0.45);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_currentWidth-2*_gap andHeight:(_currentHeight-3*_gap)*0.45];
    _scrollView.originImage = _image2;
    
    _scrollView.imageView.image = _image2;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template3_3
{
    int _random = arc4random()%10;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-3*_gap)*0.55)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-3*_gap)*0.55);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:(_currentWidth-3*_gap)*0.5 andHeight:(_currentHeight-3*_gap)*0.55];
    _scrollView.originImage = _image1;
    
    _scrollView.imageView.image = _image1;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 2 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-3*_gap)*0.55)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-3*_gap)*0.55);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:(_currentWidth-3*_gap)*0.5 andHeight:(_currentHeight-3*_gap)*0.55];
    _scrollView.originImage = _image2;
    
    _scrollView.imageView.image = _image2;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_currentHeight-3*_gap)*0.55+_gap, _currentWidth-2*_gap, (_currentHeight-3*_gap)*0.45)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-3*_gap)*0.55+_gap, _currentWidth-2*_gap, (_currentHeight-3*_gap)*0.45);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_currentWidth-2*_gap andHeight:(_currentHeight-3*_gap)*0.45];
    _scrollView.originImage = _image3;
    
    _scrollView.imageView.image = _image3;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template3_4
{
    int _random = arc4random()%10;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-3*_gap)*0.55)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-3*_gap)*0.55);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:(_currentWidth-3*_gap)*0.5 andHeight:(_currentHeight-3*_gap)*0.55];
    _scrollView.originImage = _image1;
    
    _scrollView.imageView.image = _image1;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 2 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-3*_gap)*0.45)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-3*_gap)*0.45);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:(_currentWidth-3*_gap)*0.5 andHeight:(_currentHeight-3*_gap)*0.55];
    _scrollView.originImage = _image2;
    
    _scrollView.imageView.image = _image2;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_currentHeight-3*_gap)*0.55+_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-3*_gap)*0.45)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-3*_gap)*0.55+_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-3*_gap)*0.45);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:(_currentWidth-3*_gap)*0.5 andHeight:(_currentHeight-3*_gap)*0.45];
    _scrollView.originImage = _image3;
    
    _scrollView.imageView.image = _image3;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap+(_currentHeight-3*_gap)*0.45+_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-3*_gap)*0.55)];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap+(_currentHeight-3*_gap)*0.45+_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-3*_gap)*0.55);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:(_currentWidth-3*_gap)*0.5 andHeight:(_currentHeight-3*_gap)*0.55];
    _scrollView.originImage = _image4;
    
    _scrollView.imageView.image = _image4;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template3_5
{
    int _random = arc4random()%10;
    /********* the first image ***************/

    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap, (_currentWidth-3*_gap)*0.4, (_currentHeight-4*_gap)*0.3)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, (_currentWidth-3*_gap)*0.4, (_currentHeight-4*_gap)*0.3);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:(_currentWidth-3*_gap)*0.4 andHeight:(_currentHeight-4*_gap)*0.3];
    _scrollView.originImage = _image1;
    
    _scrollView.imageView.image = _image1;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 2 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_currentWidth-3*_gap)*0.4+_gap, _gap, (_currentWidth-3*_gap)*0.6, (_currentHeight-4*_gap)*0.3)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.4+_gap, _gap, (_currentWidth-3*_gap)*0.6, (_currentHeight-4*_gap)*0.3);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:(_currentWidth-3*_gap)*0.6 andHeight:(_currentHeight-4*_gap)*0.3];
    _scrollView.originImage = _image2;
    
    _scrollView.imageView.image = _image2;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_currentHeight-4*_gap)*0.3+_gap, (_currentWidth-3*_gap)*0.6, (_currentHeight-4*_gap)*0.3)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)*0.3+_gap, (_currentWidth-3*_gap)*0.6, (_currentHeight-4*_gap)*0.3);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:(_currentWidth-3*_gap)*0.6 andHeight:(_currentHeight-4*_gap)*0.3];
    _scrollView.originImage = _image3;
    
    _scrollView.imageView.image = _image3;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_currentWidth-3*_gap)*0.6+_gap, _gap+(_currentHeight-4*_gap)*0.3+_gap, (_currentWidth-3*_gap)*0.4, (_currentHeight-4*_gap)*0.3)];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.6+_gap, _gap+(_currentHeight-4*_gap)*0.3+_gap, (_currentWidth-3*_gap)*0.4, (_currentHeight-4*_gap)*0.3);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:(_currentWidth-3*_gap)*0.4 andHeight:(_currentHeight-4*_gap)*0.3];
    _scrollView.originImage = _image4;
    
    _scrollView.imageView.image = _image4;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_currentHeight-4*_gap)*0.6+2*_gap, (_currentWidth-2*_gap), (_currentHeight-4*_gap)*0.4)];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)*0.6+2*_gap, (_currentWidth-2*_gap), (_currentHeight-4*_gap)*0.4);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:(_currentWidth-2*_gap) andHeight:(_currentHeight-4*_gap)*0.4];
    _scrollView.originImage = _image5;
    
    _scrollView.imageView.image = _image5;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template3_6
{
    int _random = arc4random()%10;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap, (_currentWidth-3*_gap)*0.4, (_currentHeight-4*_gap)*0.3)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, (_currentWidth-3*_gap)*0.4, (_currentHeight-4*_gap)*0.3);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:(_currentWidth-3*_gap)*0.4 andHeight:(_currentHeight-4*_gap)*0.3];
    _scrollView.originImage = _image1;
    
    _scrollView.imageView.image = _image1;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 2 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_currentWidth-3*_gap)*0.4+_gap, _gap, (_currentWidth-3*_gap)*0.6, (_currentHeight-4*_gap)*0.3)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.4+_gap, _gap, (_currentWidth-3*_gap)*0.6, (_currentHeight-4*_gap)*0.3);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:(_currentWidth-3*_gap)*0.6 andHeight:(_currentHeight-4*_gap)*0.3];
    _scrollView.originImage = _image2;
    
    _scrollView.imageView.image = _image2;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_currentHeight-4*_gap)*0.3+_gap, (_currentWidth-3*_gap)*0.6, (_currentHeight-4*_gap)*0.3)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)*0.3+_gap, (_currentWidth-3*_gap)*0.6, (_currentHeight-4*_gap)*0.3);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:(_currentWidth-3*_gap)*0.6 andHeight:(_currentHeight-4*_gap)*0.3];
    _scrollView.originImage = _image3;
    
    _scrollView.imageView.image = _image3;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_currentWidth-3*_gap)*0.6+_gap, _gap+(_currentHeight-4*_gap)*0.3+_gap, (_currentWidth-3*_gap)*0.4, (_currentHeight-4*_gap)*0.3)];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.6+_gap, _gap+(_currentHeight-4*_gap)*0.3+_gap, (_currentWidth-3*_gap)*0.4, (_currentHeight-4*_gap)*0.3);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:(_currentWidth-3*_gap)*0.4 andHeight:(_currentHeight-4*_gap)*0.3];
    _scrollView.originImage = _image4;
    
    _scrollView.imageView.image = _image4;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_currentHeight-4*_gap)*0.6+2*_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)*0.4)];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)*0.6+2*_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)*0.4);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:(_currentWidth-3*_gap)*0.5 andHeight:(_currentHeight-4*_gap)*0.4];
    _scrollView.originImage = _image5;
    
    _scrollView.imageView.image = _image5;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 6 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+5];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap+(_currentHeight-4*_gap)*0.6+2*_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)*0.4)];
        _scrollView.tag = kPosterImageViewStartTag+5;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap+(_currentHeight-4*_gap)*0.6+2*_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)*0.4);
    
    _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:(_currentWidth-3*_gap)*0.5 andHeight:(_currentHeight-4*_gap)*0.4];
    _scrollView.originImage = _image6;
    
    _scrollView.imageView.image = _image6;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
    _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template3_7
{
    int _random = arc4random()%10;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)*0.35)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)*0.35);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:(_currentWidth-3*_gap)*0.5 andHeight:(_currentHeight-4*_gap)*0.35];
    _scrollView.originImage = _image1;
    
    _scrollView.imageView.image = _image1;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 2 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)*0.35)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)*0.35);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:(_currentWidth-3*_gap)*0.6 andHeight:(_currentHeight-4*_gap)*0.3];
    _scrollView.originImage = _image2;
    
    _scrollView.imageView.image = _image2;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
   
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)*0.35+_gap, (_currentWidth-4*_gap)/3, (_currentHeight-4*_gap)*0.3);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:(_currentWidth-5*_gap)/3 andHeight:(_currentHeight-4*_gap)*0.3];
    _scrollView.originImage = _image3;
    
    _scrollView.imageView.image = _image3;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-4*_gap)/3+_gap, _gap+(_currentHeight-4*_gap)*0.35+_gap, (_currentWidth-4*_gap)/3, (_currentHeight-4*_gap)*0.3);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:(_currentWidth-5*_gap)/3 andHeight:(_currentHeight-4*_gap)*0.3];
    _scrollView.originImage = _image4;
    
    _scrollView.imageView.image = _image4;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-4*_gap)/3*2+2*_gap, _gap+(_currentHeight-4*_gap)*0.35+_gap, (_currentWidth-4*_gap)/3, (_currentHeight-4*_gap)*0.3);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:(_currentWidth-5*_gap)/3 andHeight:(_currentHeight-4*_gap)*0.3];
    _scrollView.originImage = _image5;
    
    _scrollView.imageView.image = _image5;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 6 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+5];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_currentHeight-4*_gap)*0.65+2*_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)*0.35)];
        _scrollView.tag = kPosterImageViewStartTag+5;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)*0.65+2*_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)*0.35);
    
    _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:(_currentWidth-3*_gap)*0.5 andHeight:(_currentHeight-4*_gap)*0.35];
    _scrollView.originImage = _image6;
    
    _scrollView.imageView.image = _image6;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
    _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 7 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+6];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap+(_currentHeight-4*_gap)*0.65+2*_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)*0.35)];
        _scrollView.tag = kPosterImageViewStartTag+6;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap+(_currentHeight-4*_gap)*0.65+2*_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)*0.35);
    
    _image7 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:6] withWidth:(_currentWidth-3*_gap)*0.5 andHeight:(_currentHeight-4*_gap)*0.35];
    _scrollView.originImage = _image7;
    
    _scrollView.imageView.image = _image7;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image7.size.width, _image7.size.height);
    _scrollView.contentSize = CGSizeMake(_image7.size.width, _image7.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

#pragma mark -- Poster collage type 4

- (void)template4_1
{
    float _y = (_currentHeight-2*_gap)*0.15;
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap)*0.85;
    int _random = arc4random()%10;
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    
    _scrollView.frame = CGRectMake(_gap, _y, _w, _h);

    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_w andHeight:_h];
    _scrollView.originImage = _image1;
    _scrollView.imageView.image = _image1;
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template4_2
{
    float _y = (_currentHeight-2*_gap)*0.15;
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap)*0.85;
    int _random = arc4random()%10;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_y, _w, (_h-_gap)*0.5)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_y, _w, (_h-_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_w andHeight:(_h-_gap)*0.5];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect4_2_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    float _tanA = 0.2*(_h-2*_gap)/_w;
    float _conA = 1/sqrt(1+_tanA*_tanA);
    float _secondHeight = _gap/_conA;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_h-_gap)*0.4+_gap+_y, _w, (_h-_gap)*0.6)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.4+_gap+_y, _w, (_h-_gap)*0.6);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_w andHeight:(_h-_gap)*0.6];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect4_2_2:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
}

- (void)template4_3
{
    float _y = (_currentHeight-2*_gap)*0.15;
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap)*0.85;
    
    int _random = arc4random()%10;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_y, _w, (_h-_gap)*0.5)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_y, _w, (_h-_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_w andHeight:(_h-_gap)*0.5];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect4_3_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    float _tanA = 0.2*(_h-2*_gap)/_w;
    float _conA = 1/sqrt(1+_tanA*_tanA);
    float _secondHeight = _gap/_conA;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_h-_gap)*0.4+_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.6)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.4+_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.6);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:(_w-_gap)*0.5 andHeight:(_h-_gap)*0.6];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect4_3_2:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.4+_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.6)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.4+_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.6);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:(_w-_gap)*0.5 andHeight:(_h-_gap)*0.6];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect4_3_3:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
}

- (void)template4_4
{
    float _y = (_currentHeight-2*_gap)*0.15;
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap)*0.85;
    
    int _random = arc4random()%10;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_y, _w, (_h-_gap)*0.5)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_y, _w, (_h-_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_w andHeight:(_h-_gap)*0.5];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect4_4_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    float _tanA = 0.2*(_h-2*_gap)/_w;
    float _conA = 1/sqrt(1+_tanA*_tanA);
    float _secondHeight = _gap/_conA;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_h-_gap)*0.4+_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.35)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.4+_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.35);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:(_w-_gap)*0.5 andHeight:(_h-_gap)*0.35];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect4_4_2:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.4+_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.35)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.4+_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.35);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:(_w-_gap)*0.5 andHeight:(_h-_gap)*0.35];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect4_4_3:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_h-_gap)*0.65+2*_gap+_y, _w, (_h-_gap)*0.35-_gap)];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.65+2*_gap+_y, _w, (_h-_gap)*0.35-_gap);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_w andHeight:(_h-_gap)*0.35-_gap];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect4_4_4:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template4_5
{
    float _y = (_currentHeight-2*_gap)*0.15;
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap)*0.85;
    
    int _random = arc4random()%10;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.5)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:(_w-_gap)*0.5 andHeight:(_h-_gap)*0.5];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect4_5_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    float _tanA = 0.2*(_h-2*_gap)/_w;
    float _conA = 1/sqrt(1+_tanA*_tanA);
    float _secondHeight = _gap/_conA;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_h-_gap)*0.4+_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.35)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.4+_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.35);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:(_w-_gap)*0.5 andHeight:(_h-_gap)*0.35];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect4_5_2:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.4+_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.35)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.4+_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.35);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:(_w-_gap)*0.5 andHeight:(_h-_gap)*0.35];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect4_5_3:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_h-_gap)*0.65+2*_gap+_y, _w, (_h-_gap)*0.35-_gap)];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.65+2*_gap+_y, _w, (_h-_gap)*0.35-_gap);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_w andHeight:(_h-_gap)*0.35-_gap];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect4_5_4:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.5)];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.5);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:(_w-_gap)*0.5 andHeight:(_h-_gap)*0.5];
    _scrollView.originImage = _image5;
    
    [self creatPointsArrayWithRect4_5_5:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    

}

- (void)template4_6
{
    float _y = (_currentHeight-2*_gap)*0.15;
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap)*0.85;
    
    int _random = arc4random()%10;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.5)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:(_w-_gap)*0.5 andHeight:(_h-_gap)*0.5];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect4_6_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    float _tanA = 0.2*(_h-2*_gap)/_w;
    float _conA = 1/sqrt(1+_tanA*_tanA);
    float _secondHeight = _gap/_conA;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_h-_gap)*0.4+_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.35)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.4+_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.35);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:(_w-_gap)*0.5 andHeight:(_h-_gap)*0.35];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect4_6_2:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.4+_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.35)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.4+_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.35);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:(_w-_gap)*0.5 andHeight:(_h-_gap)*0.35];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect4_6_3:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_h-_gap)*0.65+2*_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.35-_gap)];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.65+2*_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.35-_gap);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:(_w-_gap)*0.5 andHeight:(_h-_gap)*0.35-_gap];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect4_6_4:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.5)];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.5);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:(_w-_gap)*0.5 andHeight:(_h-_gap)*0.5];
    _scrollView.originImage = _image5;
    
    [self creatPointsArrayWithRect4_6_5:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 6 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+5];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.65+2*_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.35-_gap)];
        _scrollView.tag = kPosterImageViewStartTag+5;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.65+2*_gap+_y, (_w-_gap)*0.5, (_h-_gap)*0.35-_gap);
    
    _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:(_w-_gap)*0.5 andHeight:(_h-_gap)*0.35-_gap];
    _scrollView.originImage = _image6;
    
    [self creatPointsArrayWithRect4_6_6:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
    _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template4_7
{
    int _random = arc4random()%10;
    float _y = (_currentHeight-2*_gap)*0.15;
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap)*0.85;
    float _tanB = (_h-2*_gap)*0.2/(_w-2*_gap);
    float _image1Width = 0.33*(_w-2*_gap);
    float _image1Height = -_tanB*_image1Width+0.1*(_h-2*_gap)+_gap;
    _image1Height = (_h-2*_gap)*0.4+_gap-_image1Height;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_y, _image1Width, _image1Height)];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_y, _image1Width, _image1Height);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_image1Width andHeight:_image1Height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect4_7_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    float _image2Width = (_w-2*_gap)*0.34;
    float _image2Height = -_tanB*(_image1Width+_gap)+0.1*(_h-2*_gap)+_gap;
    _image2Height = (_h-2*_gap)*0.4+_gap-_image2Height;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_w-2*_gap)*0.33+_gap, _gap+_y, _image2Width, _image2Height)];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)*0.33+_gap, _gap+_y, _image2Width, _image2Height);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_image2Width andHeight:_image2Height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect4_7_2:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_w-2*_gap)*0.67+2*_gap, _gap+_y, _image1Width, _image1Height)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)*0.67+2*_gap, _gap+_y, _image1Width, _image1Height);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_image1Width andHeight:_image1Height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect4_7_3:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];

    
    /********* the 4 image ***************/
    float _tanA = 0.2*(_h-2*_gap)/(_w-2*_gap);
    float _image4SecondHeight = -_tanB*(_w-2*_gap)*0.33+0.45*(_h-2*_gap)+_gap;
    float _image4ThirdHeight = _tanA*(_w-2*_gap)*0.33+_gap;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_h-2*_gap)*0.3+_gap+_y, (_w-2*_gap)*0.33, (_h-2*_gap)*0.45)];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.3+_gap+_y, (_w-2*_gap)*0.33, (_h-2*_gap)*0.45);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:(_w-2*_gap)*0.33 andHeight:(_h-2*_gap)*0.45];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect4_7_4:_scrollView.frame withSecondHeight:_scrollView.frame.size.height+_gap-_image4SecondHeight andThirdHeight:_image4ThirdHeight-_gap];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    float _image5SecondHeight = -_tanB*((_w-2*_gap)*0.33+_gap)+0.45*(_h-2*_gap)+_gap;
    float _image5ThirdHeight = _tanA*((_w-2*_gap)*0.33+_gap)+_gap;
    float _image5MiddleHeight = _tanA*((_w-2*_gap)*0.5+_gap)+_gap;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_w-2*_gap)*0.33+_gap, _gap+(_h-2*_gap)*0.75+2*_gap+_y-_image5SecondHeight, (_w-2*_gap)*0.34, _image5SecondHeight-_image5ThirdHeight)];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)*0.33+_gap, _gap+(_h-2*_gap)*0.75+2*_gap+_y-_image5SecondHeight, (_w-2*_gap)*0.34, _image5SecondHeight-_image5ThirdHeight);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:(_w-2*_gap)*0.34 andHeight:_image5SecondHeight-_image5ThirdHeight];
    _scrollView.originImage = _image5;
    
    [self creatPointsArrayWithRect4_7_5:_scrollView.frame withMiddleHeight:_image5MiddleHeight-_image5ThirdHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 6 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+5];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_w-2*_gap)*0.67+2*_gap, _gap+(_h-2*_gap)*0.3+_gap+_y, (_w-2*_gap)*0.33, (_h-2*_gap)*0.45)];
        _scrollView.tag = kPosterImageViewStartTag+5;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)*0.67+2*_gap, _gap+(_h-2*_gap)*0.3+_gap+_y, (_w-2*_gap)*0.33, (_h-2*_gap)*0.45);
    
    _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:(_w-2*_gap)*0.33 andHeight:(_h-2*_gap)*0.45];
    _scrollView.originImage = _image6;
    
    [self creatPointsArrayWithRect4_7_6:_scrollView.frame withSecondHeight:_scrollView.frame.size.height+_gap-_image4SecondHeight andThirdHeight:_image4ThirdHeight-_gap];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
    _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 7 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+6];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_h-2*_gap)*0.65+2*_gap+_y, _w, (_h-2*_gap)*0.35)];
        _scrollView.tag = kPosterImageViewStartTag+6;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.65+2*_gap+_y, _w, (_h-2*_gap)*0.35);
    
    _image7 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:6] withWidth:_w andHeight:(_h-2*_gap)*0.35];
    _scrollView.originImage = _image7;
    
    [self creatPointsArrayWithRect4_7_7:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image7.size.width, _image7.size.height);
    _scrollView.contentSize = CGSizeMake(_image7.size.width, _image7.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

#pragma mark -- Poster collage type 5
- (void)template5_2
{
    int _random = arc4random()%10;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _currentWidth-2*_gap, (_currentHeight-2*_gap)*0.6-0.5*_gap);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect5_2_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-2*_gap)*0.4+0.5*_gap, _currentWidth-2*_gap, (_currentHeight-2*_gap)*0.6-0.5*_gap);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect5_2_2:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template5_3
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight -2*_gap;
    
    int _random = arc4random()%10;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.6, _h);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect5_3_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 2 image ***************/
    
    float _tanA = (_h-_gap)*0.1/_w;
    float _tanB = 5*_h/(_w-_gap);
    float _a = 0.45*(_h-_gap)+_gap;
    float _b = _tanB*((_w-_gap)*0.6+_gap);
    float _image2SecondWidth = (_b-_a)/(_tanA+_tanB);
    float _image2Height = (_a*_tanB+_b*_tanA)/(_tanA+_tanB);
    _image2Height = _h - _image2Height;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.4+_gap, _gap, (_w-_gap)*0.6, _image2Height);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect5_3_2:_scrollView.frame withSecondWidth:_image2SecondWidth-(_w-_gap)*0.4-_gap];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    _a = _a - _gap;
    
    float _image3Width = (_b-_a)/(_tanA+_tanB);
    _image3Width = _w - _image3Width;
    float _image3SecondHeight = (_a*_tanB+_b*_tanA)/(_tanA+_tanB);
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_w - _image3Width, _gap+(_h-_gap)*0.45+_gap, _image3Width, (_h-_gap)*0.55);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect5_3_3:_scrollView.frame withSecondHeight:_image3SecondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template5_4
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    
    int _random = arc4random()%10;
    
    /**** 角度计算 *****/
    float _tanA = (0.2*_h-_gap)/_w;
    float _tanB = (0.2*_w-_gap)/_h;
    
    float _leftUpWidth = ((0.6*_w-_gap)/_tanB-(0.4*_h+_gap))/(_tanA+1/_tanB);
    float _leftUpMiddleHeight = _h - ((0.4*_h+_gap)/_tanB+_tanA*(0.6*_w-_gap)/_tanB)/(_tanA+1/_tanB);
    
    float _leftDownMiddleWidth = ((0.6*_w-_gap)/_tanB-0.4*_h)/(_tanA+1/_tanB);
    float _leftDownHeight = (0.4*_h/_tanB+_tanA*(0.6*_w-_gap)/_tanB)/(1/_tanB+_tanA);
    
    float _rightUpMiddleWidth = (0.6*_w/_tanB-(0.4*_h+_gap))/(_tanA+1/_tanB)-0.4*_w-_gap;
    float _rightUpHeight = _h - ((0.4*_h+_gap)/_tanB+_tanA*(0.6*_w)/_tanB)/(_tanA+1/_tanB);
    
    float _rightDownWidth = _w - ((0.6*_w)/_tanB-(0.4*_h))/(_tanA+1/_tanB);
    float _rightDownMiddleHeight = ((0.4*_h)/_tanB+_tanA*(0.6*_w)/_tanB)/(_tanA+1/_tanB);
    
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _leftUpWidth, _h*0.6-_gap);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect5_4_1:_scrollView.frame  withSecondHeight:_leftUpMiddleHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/

    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-_leftDownHeight), _w*0.6-_gap, _leftDownHeight);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect5_4_2:_scrollView.frame withSecondWidth:_leftDownMiddleWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    
    /********* the third image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_w*0.4+_gap, _gap, _w*0.6-_gap, _rightUpHeight);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect5_4_3:_scrollView.frame withSecondWidth:_rightUpMiddleWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fourth image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_currentHeight-4*_gap)*0.7+2*_gap, _currentWidth-2*_gap, (_currentHeight-4*_gap)*0.3)];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_w-_rightDownWidth, _gap+_h*0.4+_gap, _rightDownWidth, _h*0.6-_gap);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect5_4_4:_scrollView.frame withSecondHeight:_rightDownMiddleHeight andSecondWidth:_rightDownWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template5_5
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    
    int _random = arc4random()%10;
    
    /**** 角度计算 *****/
    float _middleMinusWidth = _w*0.2;;
    float _middleMinusHeight = _h*0.2;
    
    float _middleImageWidth = _w-2*_middleMinusWidth-_gap*2.4;
    float _middleImageHeight = _h - 2*_middleMinusHeight - _gap*2.4;
    
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _w*0.5-0.5*_gap, _h*0.5-0.5*_gap);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect5_5_1:_scrollView.frame  withSecondHeight:_middleMinusHeight andSecondWidth:_middleMinusWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/

    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_h*0.5+0.5*_gap, _w*0.5-0.5*_gap, _h*0.5-0.5*_gap);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect5_5_2:_scrollView.frame withSecondHeight:_middleMinusHeight andSecondWidth:_middleMinusWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    
    /********* the third image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_w*0.5+0.5*_gap, _gap, _w*0.5-0.5*_gap, _h*0.5-0.5*_gap);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect5_5_3:_scrollView.frame withSecondHeight:_middleMinusHeight andSecondWidth:_middleMinusWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fourth image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_w*0.5+0.5*_gap, _gap+_h*0.5+0.5*_gap, _w*0.5-0.5*_gap, _h*0.5-0.5*_gap);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect5_5_4:_scrollView.frame withSecondHeight:_middleMinusHeight andSecondWidth:_middleMinusWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fifth image ***************/

    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_middleMinusWidth+_gap*1.2, _gap+_middleMinusHeight+_gap*1.2, _middleImageWidth, _middleImageHeight);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image5;
    
    [self creatPointsArrayWithRect5_5_5:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template5_6
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    
    int _random = arc4random()%10;
    /**** 角度计算 *****/
    float _tanA = 0.1*(_h-_gap)/_w;
    float _tanB = 5*_h/(_w-_gap);
    
    float _aUpTop = 0.6*(_h-2*_gap)+2*_gap;
    float _aUpBelow = 0.6*(_h-2*_gap)+_gap;
    float _aDownTop = 0.4*(_h-2*_gap)+_gap;
    float _aDownBelow = 0.4*(_h-2*_gap);
    float _bLeft = _tanB*0.6*(_w-_gap);
    float _bRight = _tanB*(0.6*(_w-_gap)+_gap);
    
    float _leftUpWidth = (_bLeft-_aUpTop)/(_tanA+_tanB);
    float _leftUpMiddleHeight = (_bLeft*_tanA+_tanB*_aUpTop)/(_tanA+_tanB);
    
    float _leftMiddleRightUpWidth = (_bLeft-_aUpBelow)/(_tanA+_tanB);
    float _leftMiddleRightUpHeight = (_bLeft*_tanA+_tanB*_aUpBelow)/(_tanA+_tanB);
    
    float _leftMiddleRightDownWidth = (_aDownTop-_bLeft)/(_tanA-_tanB);
    float _leftMiddleRightDownHeight = (_tanB*_aDownTop-_bLeft*_tanA)/(-_tanA+_tanB);
    
    float _leftDownWidth = (_aDownBelow-_bLeft)/(_tanA-_tanB);
    float _leftDownHeight = (_tanB*_aDownBelow-_bLeft*_tanA)/(-_tanA+_tanB);
    
    float _rightUpWidth = (_bRight-_aUpTop)/(_tanA+_tanB);
    float _rightUpHeight = (_bRight*_tanA+_tanB*_aUpTop)/(_tanA+_tanB);
    
    float _rightMiddleLeftUpWidth = (_bRight-_aUpBelow)/(_tanA+_tanB);
    float _rightMiddleLeftUpHeight = (_bRight*_tanA+_tanB*_aUpBelow)/(_tanA+_tanB);
    
    float _rightMiddleLeftDownWidth = (_aDownTop-_bRight)/(_tanA-_tanB);
    float _rightMiddleLeftDownHeight = (_tanB*_aDownTop-_bRight*_tanA)/(-_tanA+_tanB);
    
    float _rightDownWidth = (_aDownBelow-_bRight)/(_tanA-_tanB);
    float _rightDownMiddleHeight = (_tanB*_aDownBelow-_bRight*_tanA)/(-_tanA+_tanB);
    
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _leftUpWidth, (_h-2*_gap)*0.4);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect5_6_1:_scrollView.frame  withSecondHeight:_leftUpMiddleHeight-(_h-2*_gap)*0.6-2*_gap];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_h-_leftMiddleRightUpHeight, _leftMiddleRightDownWidth, _leftMiddleRightUpHeight-_leftMiddleRightDownHeight);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect5_6_2:_scrollView.frame withSecondHeight:_leftMiddleRightUpHeight-(_h-2*_gap)*0.6-_gap andSecondWidth:_leftMiddleRightUpWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    
    /********* the third image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.6+2*_gap, (_w-_gap)*0.6, (_h-2*_gap)*0.4);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect5_6_3:_scrollView.frame withSecondHeight:_leftDownHeight andSecondWidth:_leftDownWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fourth image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.4+_gap, _gap, (_w-_gap)*0.6, _h-_rightUpHeight);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect5_6_4:_scrollView.frame withSecondWidth:_rightUpWidth-(_w-_gap)*0.4-_gap];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_rightMiddleLeftUpWidth, _gap+(_h-2*_gap)*0.3+_gap, _w-_rightMiddleLeftUpWidth, (_h-2*_gap)*0.4);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image5;
    
    [self creatPointsArrayWithRect5_6_5:_scrollView.frame withSecondHeight:(_h-2*_gap)*0.7+_gap-_rightMiddleLeftUpHeight andSecondWidth:_rightMiddleLeftDownWidth-_rightMiddleLeftUpWidth andThirdHeight:(_h-2*_gap)*0.7+_gap-_rightMiddleLeftDownHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 6 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+5];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+5;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_rightDownWidth, _gap+_h-_rightDownMiddleHeight, _w-_rightDownWidth, _rightDownMiddleHeight);
    
    _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image6;
    
    [self creatPointsArrayWithRect5_6_6:_scrollView.frame withSecondHeight:_rightDownMiddleHeight-(_h-2*_gap)*0.3 andSecondWidth:(_w-_gap)*0.6+_gap-_rightDownWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
    _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template5_7
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    
    int _random = arc4random()%10;
    /**** 角度计算 *****/
    float _tanA = 0.1*(_h-_gap)/_w;
    float _tanB = 5*_h/(_w-_gap);
    
    float _aUpTop = 0.6*(_h-2*_gap)+2*_gap;
    float _aUpBelow = 0.6*(_h-2*_gap)+_gap;
    float _aDownTop = 0.4*(_h-2*_gap)+_gap;
    float _aDownBelow = 0.4*(_h-2*_gap);
    float _bLeft = _tanB*0.6*(_w-_gap);
    float _bRight = _tanB*(0.6*(_w-_gap)+_gap);
    
    float _a7Up = (0.4*(_h-2*_gap)-_gap)*0.5+_gap;
    float _a7Down = (0.4*(_h-2*_gap)-_gap)*0.5;
    
    float _leftUpWidth = (_bLeft-_aUpTop)/(_tanA+_tanB);
    float _leftUpMiddleHeight = (_bLeft*_tanA+_tanB*_aUpTop)/(_tanA+_tanB);
    
    float _leftMiddleRightUpWidth = (_bLeft-_aUpBelow)/(_tanA+_tanB);
    float _leftMiddleRightUpHeight = (_bLeft*_tanA+_tanB*_aUpBelow)/(_tanA+_tanB);
    
    float _leftMiddleRightDownWidth = (_aDownTop-_bLeft)/(_tanA-_tanB);
    float _leftMiddleRightDownHeight = (_tanB*_aDownTop-_bLeft*_tanA)/(-_tanA+_tanB);
    
    float _leftDownWidth = (_aDownBelow-_bLeft)/(_tanA-_tanB);
    float _leftDownHeight = (_tanB*_aDownBelow-_bLeft*_tanA)/(-_tanA+_tanB);
    
    float _left7UpWidth = (_a7Up-_bLeft)/(_tanA-_tanB);
    float _left7UpHeight = (_tanB*_a7Up-_bLeft*_tanA)/(-_tanA+_tanB);
    
    float _left7DownWidth = (_a7Down-_bLeft)/(_tanA-_tanB);
    float _left7DownHeight = (_tanB*_a7Down-_bLeft*_tanA)/(-_tanA+_tanB);
    
    float _rightUpWidth = (_bRight-_aUpTop)/(_tanA+_tanB);
    float _rightUpHeight = (_bRight*_tanA+_tanB*_aUpTop)/(_tanA+_tanB);
    
    float _rightMiddleLeftUpWidth = (_bRight-_aUpBelow)/(_tanA+_tanB);
    float _rightMiddleLeftUpHeight = (_bRight*_tanA+_tanB*_aUpBelow)/(_tanA+_tanB);
    
    float _rightMiddleLeftDownWidth = (_aDownTop-_bRight)/(_tanA-_tanB);
    float _rightMiddleLeftDownHeight = (_tanB*_aDownTop-_bRight*_tanA)/(-_tanA+_tanB);
    
    float _rightDownWidth = (_aDownBelow-_bRight)/(_tanA-_tanB);
    float _rightDownMiddleHeight = (_tanB*_aDownBelow-_bRight*_tanA)/(-_tanA+_tanB);
    
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _leftUpWidth, (_h-2*_gap)*0.4);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect5_7_1:_scrollView.frame  withSecondHeight:_leftUpMiddleHeight-(_h-2*_gap)*0.6-2*_gap];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_h-_leftMiddleRightUpHeight, _leftMiddleRightDownWidth, _leftMiddleRightUpHeight-_leftMiddleRightDownHeight);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect5_7_2:_scrollView.frame withSecondHeight:_leftMiddleRightUpHeight-(_h-2*_gap)*0.6-_gap andSecondWidth:_leftMiddleRightUpWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    
    /********* the third image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.6+2*_gap, _left7UpWidth, (_h-2*_gap)*0.4-_left7UpHeight);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect5_7_3:_scrollView.frame withSecondHeight:_leftDownHeight andSecondWidth:_leftDownWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fourth image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.4+_gap, _gap, (_w-_gap)*0.6, _h-_rightUpHeight);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect5_7_4:_scrollView.frame withSecondWidth:_rightUpWidth-(_w-_gap)*0.4-_gap];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_rightMiddleLeftUpWidth, _gap+(_h-2*_gap)*0.3+_gap, _w-_rightMiddleLeftUpWidth, (_h-2*_gap)*0.4);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image5;
    
    [self creatPointsArrayWithRect5_7_5:_scrollView.frame withSecondHeight:(_h-2*_gap)*0.7+_gap-_rightMiddleLeftUpHeight andSecondWidth:_rightMiddleLeftDownWidth-_rightMiddleLeftUpWidth andThirdHeight:(_h-2*_gap)*0.7+_gap-_rightMiddleLeftDownHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 6 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+5];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+5;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_rightDownWidth, _gap+_h-_rightDownMiddleHeight, _w-_rightDownWidth, _rightDownMiddleHeight);
    
    _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image6;
    
    [self creatPointsArrayWithRect5_7_6:_scrollView.frame withSecondHeight:_rightDownMiddleHeight-(_h-2*_gap)*0.3 andSecondWidth:(_w-_gap)*0.6+_gap-_rightDownWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
    _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 7 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+6];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+6;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.6+2*_gap+((_h-2*_gap)*0.4-_gap)*0.5+_gap, (_w-_gap)*0.6, ((_h-2*_gap)*0.4-_gap)*0.5);
    
    _image7 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:6] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image7;
    
    [self creatPointsArrayWithRect5_7_7:_scrollView.frame withSecondHeight:_left7DownHeight andSecondWidth:_left7DownWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image7.size.width, _image7.size.height);
    _scrollView.contentSize = CGSizeMake(_image7.size.width, _image7.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}


#pragma mark -- Poster collage type 6

- (void)template6_2
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    int _random = arc4random()%10;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _w*0.6-_gap*0.5, _h);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect6_2_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_w*0.4+0.5*_gap, _gap, _w*0.6-_gap*0.5, _h);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_currentWidth-2*_gap andHeight:(_currentHeight-3*_gap)*0.5];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect6_2_2:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template6_3
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    
    int _random = arc4random()%10;
    
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, (_w-2*_gap)*0.35, _h);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect6_3_1:_scrollView.frame];
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/

    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)*0.3+_gap, _gap, (_w-2*_gap)*0.4, _h);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect6_3_2:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    
    /********* the third image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+(_currentHeight-3*_gap)*0.4+_gap, _currentWidth-2*_gap, (_currentHeight-3*_gap)*0.6)];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_w-(_w-2*_gap)*0.35, _gap, (_w-2*_gap)*0.35, _h);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect6_3_3:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template6_4
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    
    int _random = arc4random()%10;
    
    /**** 角度计算 *****/
    float _tanA = (0.2*_h-_gap)/_w;
    float _tanB = _h/(0.2*_w-_gap);
    
    float _leftUpMiddleWidth = -(0.4*_w*_tanB+(0.4*_h+_gap))/(_tanA-_tanB);
    float _leftUpMiddleHeight = _h - (-0.4*_w*_tanB*_tanA-(0.4*_h+_gap)*_tanB)/(_tanA-_tanB);
    
    float _leftDownWidth = -(0.4*_w*_tanB+0.4*_h)/(_tanA-_tanB);
    float _leftDownHeight = -(0.4*_h*_tanB+_tanA*0.4*_w*_tanB)/(_tanA-_tanB);
    
    float _rightUpWidth =_w -(-((0.4*_w+_gap)*_tanB+(0.4*_h+_gap))/(_tanA-_tanB));
    float _rightUpHeight = _h - (-(0.4*_h+_gap)*_tanB-_tanA*(0.4*_w+_gap)*_tanB)/(_tanA-_tanB);
    
    float _rightDownMiddleWidth = _w*0.6 -_gap - (_w - (-(0.4*_w+_gap)*_tanB-(0.4*_h))/(_tanA-_tanB));
    float _rightDownMiddleHeight = -((0.4*_h)*_tanB+_tanA*(0.4*_w+_gap)*_tanB)/(_tanA-_tanB);
    
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _w*0.6-_gap, _h*0.6-_gap);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect6_4_1:_scrollView.frame  withSecondHeight:_leftUpMiddleHeight andSecondWidth:_leftUpMiddleWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_h-_leftDownHeight, _leftDownWidth, _leftDownHeight);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect6_4_2:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    
    /********* the third image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_w-_rightUpWidth, _gap, _rightUpWidth, _rightUpHeight);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect6_4_3:_scrollView.frame withSecondWidth:_rightUpWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fourth image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_w*0.4+_gap, _gap+_h*0.4+_gap, _w*0.6-_gap, _h*0.6-_gap);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect6_4_4:_scrollView.frame withSecondHeight:_rightDownMiddleHeight andSecondWidth:_rightDownMiddleWidth];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template6_5
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;

    float _middleImageWidth = _w*0.5;
    float _middleImageHeight = _w*0.5;

    int _random = arc4random()%10;
    
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.5, (_h-_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect6_5_1:_scrollView.frame withSecondHeight:_middleImageHeight];
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.5+_gap, (_w-_gap)*0.5, (_h-_gap)*0.5);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect6_5_2:_scrollView.frame withSecondHeight:_middleImageHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
    /********* the third image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap, (_w-_gap)*0.5, (_h-_gap)*0.5);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect6_5_3:_scrollView.frame withSecondHeight:_middleImageHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fourth image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.5+_gap, (_w-_gap)*0.5, (_h-_gap)*0.5);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect6_5_4:_scrollView.frame withSecondHeight:_middleImageHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fifth image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_w*0.25, _gap+(_h-_middleImageHeight)*0.5, _middleImageWidth, _middleImageHeight);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image5;
    
    [self creatPointsArrayWithRect6_5_5:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template6_7
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    
    int _random = arc4random()%10;
    /**** 角度计算 *****/
    float _middleImageWidth = _w*0.5;

    float _middleImageHeight = sqrtf(3)*_middleImageWidth*0.5;

    
    float _firtImageHeight = (_h*0.5-_middleImageHeight/3);
//    float _firtImageSecondHeight = (_h-_middleImageHeight)*0.5-_gap;
//    float _secondImageWidth = (_w*0.5-_gap)*0.5;
    
    float _h1 = _h*0.5-(_w*0.5+2*_gap)*0.5;
    _firtImageHeight = _h*0.5 - sqrt(3)*0.125*(_w*0.5+2*_gap);
    float _h2 = _h*0.5 - sqrt(3)*0.5*(_w*0.5+2*_gap)*0.5;
    
    float _w1 = _w*0.5 - 0.375*(_w*0.5+2*_gap);
    float _w2 = _w*0.5 - 0.25*(_w*0.5+2*_gap);
    float _middleWidth = _w*0.5 - 0.5*(_w*0.5+2*_gap);
    
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.5, _firtImageHeight);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect6_7_1:_scrollView.frame withSecondHeight:_h1 andSecondWidth:_w1 andThirdHeight:_h2 andThirdWidth:_w2];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_h1+_gap, _w1-0.5*_gap, _h-_h1*2-2*_gap);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect6_7_2:_scrollView.frame withSecondHeight:_h1 andSecondWidth:_middleWidth andThirdHeight:_firtImageHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    
    /********* the third image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_h-_firtImageHeight, (_w-_gap)*0.5, _firtImageHeight);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect6_7_3:_scrollView.frame withSecondHeight:_h1 andSecondWidth:_w1 andThirdHeight:_h2 andThirdWidth:_w2];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the fourth image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap, (_w-_gap)*0.5, _firtImageHeight);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect6_7_4:_scrollView.frame withSecondHeight:_h1 andSecondWidth:_w1 andThirdHeight:_h2 andThirdWidth:_w2];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_w-(_w1-0.5*_gap), _gap+_h1+_gap, _w1-0.5*_gap, _h-_h1*2-2*_gap);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image5;
    
    [self creatPointsArrayWithRect6_7_5:_scrollView.frame withSecondHeight:_h1 andSecondWidth:_middleWidth andThirdHeight:_firtImageHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 6 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+5];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+5;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+_h-_firtImageHeight, (_w-_gap)*0.5, _firtImageHeight);
    
    _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image6;
    
    [self creatPointsArrayWithRect6_7_6:_scrollView.frame withSecondHeight:_h1 andSecondWidth:_w1 andThirdHeight:_h2 andThirdWidth:_w2];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
    _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 7 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+6];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+6;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_w*0.5-_middleImageWidth*0.5, _gap+(_h-_middleImageHeight)*0.5, _middleImageWidth, _middleImageHeight);
    
    _image7 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:6] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image7;
    
    [self creatPointsArrayWithRect6_7_7:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image7.size.width, _image7.size.height);
    _scrollView.contentSize = CGSizeMake(_image7.size.width, _image7.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}


#pragma mark -- Poster collage type 7

- (void)template7_2
{
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap);
    int _random = arc4random()%10;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _w, (_h-_gap)*0.45);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect7_2_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    float _tanA = 0.1*(_h-2*_gap)/_w;
    float _conA = 1/sqrt(1+_tanA*_tanA);
    float _secondHeight = _gap/_conA;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.4+_gap, _w, (_h-_gap)*0.6);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect7_2_2:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
}

- (void)template7_3
{
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap);
    
    int _random = arc4random()%10+arc4random()%10*0.1;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _w, (_h-_gap)*0.45);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect7_3_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    float _tanA = 0.1*(_h-2*_gap)/_w;
    float _conA = 1/sqrt(1+_tanA*_tanA);
    float _secondHeight = _gap/_conA;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.4+_gap, (_w-_gap)*0.5, (_h-_gap)*0.6);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect7_3_2:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.4+_gap, (_w-_gap)*0.5, (_h-_gap)*0.6);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect7_3_3:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template7_4
{
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap);
    
    int _random = arc4random()%10+arc4random()%10*0.1;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _w, (_h-_gap)*0.45);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect7_3_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    float _tanA = 0.1*(_h-2*_gap)/_w;
    float _conA = 1/sqrt(1+_tanA*_tanA);
    float _secondHeight = _gap/_conA;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.4+_gap, (_w-_gap)*0.5, (_h-_gap)*0.6);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect7_3_2:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.4+_gap, (_w-_gap)*0.5, (_h-_gap)*0.35);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect7_4_3:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.7+2*_gap, (_w-_gap)*0.5, (_h-_gap)*0.3-_gap);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect7_4_4:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
}

- (void)template7_5
{
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap);
    
    int _random = arc4random()%10+arc4random()%10*0.1;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _w, (_h-_gap)*0.45);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect7_3_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    float _tanA = 0.1*(_h-2*_gap)/_w;
    float _conA = 1/sqrt(1+_tanA*_tanA);
    float _secondHeight = _gap/_conA;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.4+_gap, (_w-_gap)*0.5, (_h-_gap)*0.35);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect7_5_2:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.7+2*_gap, (_w-_gap)*0.5, (_h-_gap)*0.3-_gap);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect7_5_3:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.4+_gap, (_w-_gap)*0.5, (_h-_gap)*0.35);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect7_5_4:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.7+2*_gap, (_w-_gap)*0.5, (_h-_gap)*0.3-_gap);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image5;
    
    [self creatPointsArrayWithRect7_5_5:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
}

- (void)template7_6
{
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap);
    
    int _random = arc4random()%10+arc4random()%10*0.1;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.5, (_h-2*_gap)*0.45);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect7_6_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 2 image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap, (_w-_gap)*0.5, (_h-2*_gap)*0.45);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect7_6_2:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    float _tanA = 0.1*(_h-2*_gap)/_w;
    float _conA = 1/sqrt(1+_tanA*_tanA);
    float _secondHeight = _gap/_conA;
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.4+_gap, (_w-_gap)*0.5, (_h-2*_gap)*0.35);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect7_6_3:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.7+2*_gap, (_w-_gap)*0.5, (_h-2*_gap)*0.3-_gap);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect7_6_4:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-2*_gap)*0.4+_gap, (_w-_gap)*0.5, (_h-2*_gap)*0.35);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image5;
    
    [self creatPointsArrayWithRect7_6_5:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 6 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+5];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+5;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-2*_gap)*0.7+2*_gap, (_w-_gap)*0.5, (_h-2*_gap)*0.3-_gap);
    
    _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image6;
    
    [self creatPointsArrayWithRect7_6_6:_scrollView.frame withSecondHeight:_secondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
    _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
}

- (void)template7_7
{
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap);
    
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    float _tanA = 0.1*(_h-2*_gap)/_w;
//    float _conA = 1/sqrt(1+_tanA*_tanA);
//    float _secondHeight = _gap/_conA;
    float _b = 0.6*(_h-2*_gap)+_gap;
    float _middleLeftImageUpHeight = -_tanA*(_w-2*_gap)/3+_b;
    float _middleMiddleImageLeftUpHeight = -_tanA*((_w-2*_gap)/3+_gap)+_b;
    float _middleLeftImageHeight = 0.6*(_h-2*_gap)+_gap-_middleLeftImageUpHeight+0.3*(_h-2*_gap);
    
    _b = 0.3*(_h-2*_gap)+_gap;
    float _middleMiddleImageDownHeight = -_tanA*_w*0.5+_b;
    float _middleMiddleImageHeight = _middleMiddleImageLeftUpHeight - _middleMiddleImageDownHeight;
    
    _b = 0.3*(_h-2*_gap);
    float _downLeftImageUpHeight = -_tanA*(_w-2*_gap)/3+_b;
    float _downMiddleImageHeight = -_tanA*((_w-2*_gap)/3+_gap)+_b;
    
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _w, (_h-2*_gap)*0.45);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect7_7_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 2 image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.4+_gap, (_w-2*_gap)/3, _middleLeftImageHeight);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect7_7_2:_scrollView.frame withSecondHeight:(_h-2*_gap)*0.6+_gap-_middleLeftImageUpHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)/3+_gap, _gap+_h-_middleMiddleImageLeftUpHeight, (_w-2*_gap)/3, _middleMiddleImageHeight);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect7_7_3:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)/3*2+2*_gap, _gap+(_h-2*_gap)*0.4+_gap, (_w-2*_gap)/3, _middleLeftImageHeight);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect7_7_4:_scrollView.frame withSecondHeight:(_h-2*_gap)*0.6+_gap-_middleLeftImageUpHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.7+2*_gap, (_w-2*_gap)/3, (_h-2*_gap)*0.3);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image5;
    
    [self creatPointsArrayWithRect7_7_5:_scrollView.frame withSecondHeight:_scrollView.frame.size.height-_downLeftImageUpHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 6 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+5];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+5;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)/3+_gap, _gap+_h-_downMiddleImageHeight, (_w-2*_gap)/3, _downMiddleImageHeight);
    
    _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image6;
    
    [self creatPointsArrayWithRect7_7_6:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
    _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 7 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+6];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+6;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)/3*2+2*_gap, _gap+(_h-2*_gap)*0.7+2*_gap, (_w-2*_gap)/3, (_h-2*_gap)*0.3);
    
    _image7 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:6] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image7;
    
    [self creatPointsArrayWithRect7_7_7:_scrollView.frame withSecondHeight:_scrollView.frame.size.height-_downLeftImageUpHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image7.size.width, _image7.size.height);
    _scrollView.contentSize = CGSizeMake(_image7.size.width, _image7.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
}



#pragma mark -- Poster collage type 8

- (void)template8_2
{
    int _random = arc4random()%10+arc4random()%10*0.1;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _currentWidth-2*_gap, (_currentHeight-3*_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    _scrollView.imageView.image = _image1;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    [self.pointArray1 removeAllObjects];
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 2 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-3*_gap)*0.5+_gap, _currentWidth-2*_gap, (_currentHeight-3*_gap)*0.5);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    _scrollView.imageView.image = _image2;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    [self.pointArray2 removeAllObjects];
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template8_3
{
    int _random = arc4random()%10+arc4random()%10*0.1;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, (_currentWidth-2*_gap), (_currentHeight-4*_gap)/3);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    _scrollView.imageView.image = _image1;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    [self.pointArray1 removeAllObjects];
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 2 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_currentWidth-2*_gap), (_currentHeight-4*_gap)/3);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    _scrollView.imageView.image = _image2;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    [self.pointArray2 removeAllObjects];
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, _currentWidth-2*_gap, (_currentHeight-4*_gap)/3);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    _scrollView.imageView.image = _image3;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    [self.pointArray3 removeAllObjects];
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template8_4
{
    int _random = arc4random()%10+arc4random()%10*0.1;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-3*_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    _scrollView.imageView.image = _image1;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 2 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-3*_gap)*0.5);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    _scrollView.imageView.image = _image2;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-3*_gap)*0.5+_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-3*_gap)*0.5);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    _scrollView.imageView.image = _image3;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap+(_currentHeight-3*_gap)*0.5+_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-3*_gap)*0.5);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image4;
    
    _scrollView.imageView.image = _image4;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template8_5
{
    int _random = arc4random()%10+arc4random()%10*0.1;
    /********* the first image ***************/
    
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)/3);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    _scrollView.imageView.image = _image1;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 2 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)/3);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    _scrollView.imageView.image = _image2;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_currentWidth-2*_gap), (_currentHeight-4*_gap)/3);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    _scrollView.imageView.image = _image3;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)/3);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image4;
    
    _scrollView.imageView.image = _image4;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)/3);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image5;
    
    _scrollView.imageView.image = _image5;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template8_6
{
    int _random = arc4random()%10+arc4random()%10*0.1;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)/3);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    _scrollView.imageView.image = _image1;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 2 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)/3);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    _scrollView.imageView.image = _image2;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)/3);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    _scrollView.imageView.image = _image3;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)/3);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image4;
    
    _scrollView.imageView.image = _image4;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)/3);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image5;
    
    _scrollView.imageView.image = _image5;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 6 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+5];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+5;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)/3);
    
    _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image6;
    
    _scrollView.imageView.image = _image6;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
    _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template8_7
{
    int _random = arc4random()%10+arc4random()%10*0.1;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)/3);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    _scrollView.imageView.image = _image1;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 2 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)/3);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    _scrollView.imageView.image = _image2;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_currentWidth-4*_gap)/3, (_currentHeight-4*_gap)/3);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    _scrollView.imageView.image = _image3;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-4*_gap)/3+_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_currentWidth-4*_gap)/3, (_currentHeight-4*_gap)/3);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image4;
    
    _scrollView.imageView.image = _image4;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-4*_gap)/3*2+2*_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_currentWidth-4*_gap)/3, (_currentHeight-4*_gap)/3);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image5;
    
    _scrollView.imageView.image = _image5;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 6 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+5];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+5;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)/3);
    
    _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image6;
    
    _scrollView.imageView.image = _image6;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
    _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 7 image ***************/
    
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+6];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+6;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_currentWidth-3*_gap)*0.5+_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, (_currentWidth-3*_gap)*0.5, (_currentHeight-4*_gap)/3);
    
    _image7 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:6] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image7;
    
    _scrollView.imageView.image = _image7;
    _scrollView.imageView.frame = CGRectMake(0, 0, _image7.size.width, _image7.size.height);
    _scrollView.contentSize = CGSizeMake(_image7.size.width, _image7.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}


#pragma mark -- Poster collage type 9

- (void)template9_2
{
    int _random = arc4random()%10+arc4random()%10*0.1;
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _currentWidth-2*_gap, (_currentHeight-3*_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_currentWidth-2*_gap andHeight:(_currentHeight-3*_gap)*0.5];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect2_2_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-3*_gap)*0.4+_gap, _currentWidth-2*_gap, (_currentHeight-3*_gap)*0.6);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_currentWidth-2*_gap andHeight:(_currentHeight-3*_gap)*0.5];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect2_2_2:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template9_3
{
    int _random = arc4random()%10+arc4random()%10*0.1;
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    float _tanA = 0.1*(_h-_gap)/_w;
    float _tanB = 10*(_h-_gap)/(_w-_gap);
    float _a = (_h-_gap)*0.5;
    float _b = -_tanB*(_w-_gap)*0.5;
    float _image2Width = (_b-_a)/(_tanA-_tanB);
    float _image2Height = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    _b = -_tanB*((_w-_gap)*0.5+_gap);
    float _image3SecondWidth = (_b-_a)/(_tanA-_tanB);
    float _image3SecondHeight = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, _currentWidth-2*_gap, (_currentHeight-3*_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect2_2_1:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_h-_image2Height, _image2Width, _image2Height);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect9_3_2:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.4+_gap, (_w-_gap)*0.5, (_h-_gap)*0.6);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect9_3_3:_scrollView.frame withSecondWidth:_image3SecondWidth-(_w-_gap)*0.5-_gap andSecondHeight:_scrollView.frame.size.height-_image3SecondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template9_4
{
    int _random = arc4random()%10+arc4random()%10*0.1;
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    float _tanA = 0.1*(_h-_gap)/_w;
    float _tanB = 10*(_h-_gap)/(_w-_gap);
    
    float _a = (_h-_gap)*0.5;
    float _b = -_tanB*(_w-_gap)*0.5;
    
    float _image1SecondWidth = _b/(_tanA-_tanB);
    float _image1SecondHeight = _b*_tanA/(_tanA-_tanB);
    
    _b = -_tanB*((_w-_gap)*0.5+_gap);
    float _image2LeftWidth = _b/(_tanA-_tanB);
    float _image2LeftHeight = _b*_tanA/(_tanA-_tanB);
    
    _b = -_tanB*(_w-_gap)*0.5;
    float _image3Width = (_b-_a)/(_tanA-_tanB);
    float _image3Height = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    _b = -_tanB*((_w-_gap)*0.5+_gap);
    float _image4SecondWidth = (_b-_a)/(_tanA-_tanB);
    float _image4SecondHeight = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.55, (_h-_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect9_4_1:_scrollView.frame withSecondWidth:_image1SecondWidth andSecondHeight:_image1SecondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 2 image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_image2LeftWidth, _gap, _w-_image2LeftWidth, (_h-_gap)*0.5-_image2LeftHeight);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect9_4_2:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_h-_image3Height, _image3Width, _image3Height);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect9_4_3:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.4+_gap, (_w-_gap)*0.5, (_h-_gap)*0.6);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect9_4_4:_scrollView.frame withSecondWidth:_image4SecondWidth-(_w-_gap)*0.5-_gap andSecondHeight:_scrollView.frame.size.height-_image4SecondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template9_5
{
    int _random = arc4random()%10+arc4random()%10*0.1;
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    float _tanA = 0.1*(_h-_gap)/_w;
    float _tanB = 10*(_h-_gap)/(_w-_gap);
    
    float _a = (_h-_gap)*0.5;
    float _b = -_tanB*(_w-_gap)*0.5;
    
    float _image1SecondWidth = _b/(_tanA-_tanB);
    float _image1SecondHeight = _b*_tanA/(_tanA-_tanB);
    
    _b = -_tanB*((_w-_gap)*0.5+_gap);
    float _image2LeftWidth = _b/(_tanA-_tanB);
    float _image2LeftHeight = _b*_tanA/(_tanA-_tanB);
    
    _b = -_tanB*(_w-_gap)*0.5;
    float _image3Width = (_b-_a)/(_tanA-_tanB);
    float _image3Height = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    _b = -_tanB*((_w-_gap)*0.5+_gap);
    float _image5SecondWidth = (_b-_a)/(_tanA-_tanB);
    float _image5SecondHeight = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    _a = (_h-_gap)*0.25+_gap;
    _b = -_tanB*(_w-_gap)*0.5;
    float _image3RightDownWidth = (_b-_a)/(_tanA-_tanB);
    float _image3RightDownHeight = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    _a = _a-_gap;
    float _image4Width = (_b-_a)/(_tanA-_tanB);
    float _image4Height = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    /********* the first image ***************/
    ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.55, (_h-_gap)*0.5);
    
    _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image1;
    
    [self creatPointsArrayWithRect9_4_1:_scrollView.frame withSecondWidth:_image1SecondWidth andSecondHeight:_image1SecondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
    _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 2 image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+1];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+1;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+_image2LeftWidth, _gap, _w-_image2LeftWidth, (_h-_gap)*0.5-_image2LeftHeight);
    
    _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image2;
    
    [self creatPointsArrayWithRect9_4_2:_scrollView.frame];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
    _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 3 image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+2];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+2;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_h-_image3Height, _image3Width, _image3Height-(_h-_gap)*0.25-_gap);
    
    _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image3;
    
    [self creatPointsArrayWithRect9_5_3:_scrollView.frame withSecondWidth:_image3RightDownWidth andSecondHeight:_image3Height-_image3RightDownHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
    _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 4 image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+3];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+3;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap, _gap+_h-_image4Height, _image4Width, _image4Height);
    
    _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image4;
    
    [self creatPointsArrayWithRect9_5_4:_scrollView.frame withSecondHeight:_image4Height-(_h-_gap)*0.25];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
    _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the 5 image ***************/
    _scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+4];
    if (nil == _scrollView) {
        _scrollView = [[ZBPosterCollageScrollView alloc] init];
        _scrollView.tag = kPosterImageViewStartTag+4;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.4+_gap, (_w-_gap)*0.5, (_h-_gap)*0.6);
    
    _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
    _scrollView.originImage = _image5;
    
    [self creatPointsArrayWithRect9_5_5:_scrollView.frame withSecondWidth:_image5SecondWidth-(_w-_gap)*0.5-_gap andSecondHeight:_scrollView.frame.size.height-_image5SecondHeight];
    
    _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
    _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)template9_6
{
    int _random = arc4random()%10+arc4random()%10*0.1;
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    float _tanA = 0.1*(_h-_gap)/_w;
    float _tanB = 10*(_h-_gap)/(_w-_gap);
    
    float _a = (_h-_gap)*0.5;
    float _b = -_tanB*(_w-_gap)*0.5;
    
    float _image1SecondWidth = _b/(_tanA-_tanB);
    float _image1SecondHeight = _b*_tanA/(_tanA-_tanB);
    
    _b = -_tanB*((_w-_gap)*0.5+_gap);
    float _image2LeftWidth = _b/(_tanA-_tanB);
    float _image2LeftHeight = _b*_tanA/(_tanA-_tanB);
    
    _b = -_tanB*(_w-_gap)*0.5;
    float _image3Width = (_b-_a)/(_tanA-_tanB);
    float _image3Height = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    _b = -_tanB*((_w-_gap)*0.5+_gap);
    float _image5SecondWidth = (_b-_a)/(_tanA-_tanB);
    float _image5SecondHeight = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    _a = (_h-_gap)*0.25+_gap;
    _b = -_tanB*(_w-_gap)*0.5;
    float _image3RightDownWidth = (_b-_a)/(_tanA-_tanB);
    float _image3RightDownHeight = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    _a = _a-_gap;
    float _image4Width = (_b-_a)/(_tanA-_tanB);
    float _image4Height = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    _a = _a+_gap;
    _b = -_tanB*((_w-_gap)*0.5+_gap);
    float _image5LeftDownWidth = (_b-_a)/(_tanA-_tanB);
    float _image5LeftDownHeight = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    _a = _a-_gap;
    float _image6SecondWidth = (_b-_a)/(_tanA-_tanB);
    float _image6SecondHeight = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.55, (_h-_gap)*0.5);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect9_4_1:_scrollView.frame withSecondWidth:_image1SecondWidth andSecondHeight:_image1SecondHeight];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);

            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+_image2LeftWidth, _gap, _w-_image2LeftWidth, (_h-_gap)*0.5-_image2LeftHeight);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect9_4_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+_h-_image3Height, _image3Width, _image3Height-(_h-_gap)*0.25-_gap);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect9_5_3:_scrollView.frame withSecondWidth:_image3RightDownWidth andSecondHeight:_image3Height-_image3RightDownHeight];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+_h-_image4Height, _image4Width, _image4Height);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect9_5_4:_scrollView.frame withSecondHeight:_image4Height-(_h-_gap)*0.25];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap+_image5LeftDownWidth, _gap+(_h-_gap)*0.4+_gap, _w-_image5LeftDownWidth, (_h-_gap)*0.6-_image5LeftDownHeight);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                [self creatPointsArrayWithRect9_6_5:_scrollView.frame withSecondWidth:_image5SecondWidth-_image5LeftDownWidth andSecondHeight:(_h-_gap)*0.6-_image5SecondHeight];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            case 5:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.65+_gap, (_w-_gap)*0.5, (_h-_gap)*0.35);
                
                _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image6;
                
                [self creatPointsArrayWithRect9_6_6:_scrollView.frame withSecondWidth:_image6SecondWidth-(_w-_gap)*0.5-_gap andSecondHeight:_scrollView.frame.size.height-_image6SecondHeight];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
                _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
                
            }
                break;
                
            default:
                break;
        }
                
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template9_7
{
    int _random = arc4random()%10+arc4random()%10*0.1;
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight - 2*_gap;
    float _tanA = 0.1*(_h-_gap)/_w;
    float _tanB = 10*(_h-_gap)/(_w-_gap);
    
    float _a = (_h-_gap)*0.25+_gap;
    float _b = -_tanB*(_w-_gap)*0.5;
    
    float _image1RightDownWidht = (_b-_a)/(_tanA-_tanB);
    float _image1RightDownHeight = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    _a = _a-_gap;
    float _image2RightUpWidht = (_b-_a)/(_tanA-_tanB);
    float _image2RightUpHeight = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    float _image2RightDownWidth = _b/(_tanA-_tanB);
    float _image2RightDownHeight = _b*_tanA/(_tanA-_tanB);
    
    _b = -_tanB*((_w-_gap)*0.5+_gap);
    float _image3LeftWidth = _b/(_tanA-_tanB);
    float _image3LeftHeight = _b*_tanA/(_tanA-_tanB);
    
    _a = (_h-_gap)*0.5;
    _b = -_tanB*(_w-_gap)*0.5;
    float _image4Width = (_b-_a)/(_tanA-_tanB);
    float _image4Height = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    _b = -_tanB*((_w-_gap)*0.5+_gap);
    float _image6SecondWidth = (_b-_a)/(_tanA-_tanB);
    float _image6SecondHeight = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    _a = (_h-_gap)*0.25+_gap;
    _b = -_tanB*(_w-_gap)*0.5;
    float _image4RightDownWidth = (_b-_a)/(_tanA-_tanB);
    float _image4RightDownHeight = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    _a = _a-_gap;
    float _image5Width = (_b-_a)/(_tanA-_tanB);
    float _image5Height = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    _a = _a+_gap;
    _b = -_tanB*((_w-_gap)*0.5+_gap);
    float _image6LeftDownWidth = (_b-_a)/(_tanA-_tanB);
    float _image6LeftDownHeight = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    _a = _a-_gap;
    float _image7SecondWidth = (_b-_a)/(_tanA-_tanB);
    float _image7SecondHeight = (_b*_tanA-_a*_tanB)/(_tanA-_tanB);
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.55, (_h-_gap)*0.25-_gap);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect9_7_1:_scrollView.frame withSecondWidth:_image1RightDownWidht andSecondHeight:(_h-_gap)*0.5-_image1RightDownHeight];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.5-_image2RightUpHeight, _image2RightUpWidht, _image2RightUpHeight);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect9_7_2:_scrollView.frame withSecondWidth:_image2RightDownWidth andSecondHeight:_scrollView.frame.size.height-_image2RightDownHeight];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap+_image3LeftWidth, _gap, _w-_image3LeftWidth, (_h-_gap)*0.5-_image3LeftHeight);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect9_7_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+_h-_image4Height, _image4Width, _image4Height-(_h-_gap)*0.25-_gap);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect9_7_4:_scrollView.frame withSecondWidth:_image4RightDownWidth andSecondHeight:_image4Height-_image4RightDownHeight];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+_h-_image5Height, _image5Width, _image5Height);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                [self creatPointsArrayWithRect9_7_5:_scrollView.frame withSecondHeight:_image5Height-(_h-_gap)*0.25];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            case 5:
            {
                _scrollView.frame = CGRectMake(_gap+_image6LeftDownWidth, _gap+(_h-_gap)*0.4+_gap, _w-_image6LeftDownWidth, (_h-_gap)*0.6-_image6LeftDownHeight);
                
                _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image6;
                
                [self creatPointsArrayWithRect9_7_6:_scrollView.frame withSecondWidth:_image6SecondWidth-_image6LeftDownWidth andSecondHeight:(_h-_gap)*0.6-_image6SecondHeight];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
                _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
                
            }
                break;
            case 6:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.65+_gap, (_w-_gap)*0.5, (_h-_gap)*0.35);
                
                _image7 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:6] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image7;
                
                [self creatPointsArrayWithRect9_7_7:_scrollView.frame withSecondWidth:_image7SecondWidth-(_w-_gap)*0.5-_gap andSecondHeight:_scrollView.frame.size.height-_image7SecondHeight];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image7.size.width, _image7.size.height);
                _scrollView.contentSize = CGSizeMake(_image7.size.width, _image7.size.height);
                
            }
                break;
            default:
                break;
        }
        
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}


#pragma mark -- Poster collage type 10

- (void)template10_4
{
    float _w = _currentWidth-2*_gap;
//    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, (_currentWidth-2*_gap), (_currentHeight-4*_gap)/3);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;

                
                _scrollView.imageView.image = _image1;
                
                [self.pointArray1 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect10_4_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect10_4_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, _currentWidth-2*_gap, (_currentHeight-4*_gap)/3);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                _scrollView.imageView.image = _image4;
                
                [self.pointArray4 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template10_5
{
    float _w = _currentWidth-2*_gap;
//    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                
//                _scrollView.imageView.image = _image1;
                
                [self creatPointsArrayWithRect10_5_1:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect10_5_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect10_5_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                _scrollView.imageView.image = _image4;
                
                [self creatPointsArrayWithRect10_5_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, _currentWidth-2*_gap, (_currentHeight-4*_gap)/3);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                _scrollView.imageView.image = _image5;
                
                [self.pointArray5 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            default:
                break;
        }
        
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template10_6
{
    float _w = _currentWidth-2*_gap;
//    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                
                _scrollView.imageView.image = _image1;
                
                [self creatPointsArrayWithRect10_5_1:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect10_5_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect10_5_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                _scrollView.imageView.image = _image4;
                
                [self creatPointsArrayWithRect10_5_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                _scrollView.imageView.image = _image5;
                
                [self creatPointsArrayWithRect10_6_5:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            case 5:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image6;
                
                _scrollView.imageView.image = _image6;
                
                [self creatPointsArrayWithRect10_6_6:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
                _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
                
            }
                break;
            default:
                break;
        }
        
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template10_7
{
    float _w = _currentWidth-2*_gap;
    //    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                
                _scrollView.imageView.image = _image1;
                
                [self creatPointsArrayWithRect10_5_1:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect10_5_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_w-2*_gap)/3, (_currentHeight-4*_gap)/3);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect10_7_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)*0.233+_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_w-2*_gap)*0.534, (_currentHeight-4*_gap)/3);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                _scrollView.imageView.image = _image4;
                
                [self creatPointsArrayWithRect10_7_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                _scrollView.imageView.image = _image5;
                
                [self creatPointsArrayWithRect10_6_5:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            case 5:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image6;
                
                _scrollView.imageView.image = _image6;
                
                [self creatPointsArrayWithRect10_6_6:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
                _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
                
            }
                break;
            case 6:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)/3*2+2*_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_w-2*_gap)/3, (_currentHeight-4*_gap)/3);
                
                _image7 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:6] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image7;
                
                _scrollView.imageView.image = _image7;
                
                [self creatPointsArrayWithRect10_7_7:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image7.size.width, _image7.size.height);
                _scrollView.contentSize = CGSizeMake(_image7.size.width, _image7.size.height);
                
            }
                break;
            default:
                break;
        }
        
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}


#pragma mark -- Poster collage type 11

- (void)template11_3
{
    float _w = _currentWidth-2*_gap;
    //    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, (_currentWidth-2*_gap), (_currentHeight-3*_gap)/2);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                
                _scrollView.imageView.image = _image1;
                
                [self.pointArray1 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-3*_gap)/2+_gap, (_w-_gap)*0.55, (_currentHeight-3*_gap)/2);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect10_4_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap+(_currentHeight-3*_gap)/2+_gap, (_w-_gap)*0.55, (_currentHeight-3*_gap)/2);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect10_4_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template11_4
{
    float _w = _currentWidth-2*_gap;
    //    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.55, (_currentHeight-3*_gap)/2);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                
                [self creatPointsArrayWithRect11_4_1:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap, (_w-_gap)*0.55, (_currentHeight-3*_gap)/2);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect11_4_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-3*_gap)/2+_gap, (_w-_gap)*0.55, (_currentHeight-3*_gap)/2);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect10_5_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap+(_currentHeight-3*_gap)/2+_gap, (_w-_gap)*0.55, (_currentHeight-3*_gap)/2);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect10_5_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template11_5
{
    float _w = _currentWidth-2*_gap;
    //    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                
                [self creatPointsArrayWithRect11_4_1:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect11_4_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect10_5_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect10_5_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3+_gap, _w, (_currentHeight-4*_gap)/3);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                [self.pointArray5 removeAllObjects];
                _scrollView.imageView.image = _image5;
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template11_6
{
    float _w = _currentWidth-2*_gap;
    //    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                
                [self creatPointsArrayWithRect11_4_1:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect11_4_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect10_5_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect10_5_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                [self creatPointsArrayWithRect11_6_5:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            case 5:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image6;
                
                [self creatPointsArrayWithRect11_6_6:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
                _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template11_7
{
    float _w = _currentWidth-2*_gap;
    //    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                
                [self creatPointsArrayWithRect11_4_1:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect11_4_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect10_5_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.45+_gap, _gap+(_currentHeight-4*_gap)/3+_gap, (_w-_gap)*0.55, (_currentHeight-4*_gap)/3);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect10_5_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, (_w-2*_gap)*0.3, (_currentHeight-4*_gap)/3);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                [self creatPointsArrayWithRect11_7_5:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            case 5:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)*0.2+_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, (_w-2*_gap)*0.6, (_currentHeight-4*_gap)/3);
                
                _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image6;
                
                [self creatPointsArrayWithRect11_7_6:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
                _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
                
            }
                break;
            case 6:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)*0.7+2*_gap, _gap+(_currentHeight-4*_gap)/3*2+2*_gap, (_w-2*_gap)*0.3, (_currentHeight-4*_gap)/3);
                
                _image7 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:6] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image7;
                
                [self creatPointsArrayWithRect11_7_7:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image7.size.width, _image7.size.height);
                _scrollView.contentSize = CGSizeMake(_image7.size.width, _image7.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

#pragma mark -- Poster collage type 12

- (void)template12_2
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
        
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, _w, (_h-_gap)*0.55);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;

                [self creatPointsArrayWithRect12_2_1:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.45+_gap, _w, (_h-_gap)*0.55);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect12_2_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template12_3
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, _w, (_h-_gap)*0.55);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect12_2_1:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.5+_gap, (_w-_gap)*0.5, (_h-_gap)*0.5);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect12_3_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.45+_gap, (_w-_gap)*0.5, (_h-_gap)*0.5);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect12_3_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template12_4
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.1/3*2, (_w-_gap)/3, (_h-_gap)*(0.45+0.1/3));
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect12_4_1:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)/3+_gap, _gap, (_w-_gap)/3*2, (_h-_gap)*(0.45+0.1/3*2));
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect12_4_2:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*(0.45+0.1/3)+_gap, (_w-_gap)/3*2, (_h-_gap)*(0.45+0.1/3*2));
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect12_4_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)/3*2+_gap, _gap+(_h-_gap)*0.45+_gap, (_w-_gap)/3, (_h-_gap)*(0.45+0.1/3));
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect12_4_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template12_5
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.1/3*2, (_w-_gap)/3, (_h-_gap)*(0.45+0.1/3));
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect12_4_1:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)/3+_gap, _gap, (_w-_gap)/3*2, (_h-_gap)*(0.45+0.1/3*2));
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect12_4_2:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*(0.45+0.1/3*2)+_gap, (_w-2*_gap)/3, (_h-_gap)*(0.45+0.1/3));
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect12_5_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)/3*2+2*_gap, _gap+(_h-_gap)*0.45+_gap, (_w-2*_gap)/3, (_h-_gap)*(0.45+0.1/3));
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect12_4_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)/3+_gap, _gap+(_h-_gap)*(0.45+0.1/3)+_gap, (_w-2*_gap)/3, (_h-_gap)*(0.45+0.1/3));
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                [self creatPointsArrayWithRect12_5_5:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template12_6
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.1/3*2, (_w-2*_gap)/3, (_h-_gap)*(0.45+0.1/3));
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect12_4_1:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)/3+_gap, _gap+(_h-_gap)*0.1/3, (_w-2*_gap)/3, (_h-_gap)*(0.45+0.1/3));
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect12_6_2:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*(0.45+0.1/3*2)+_gap, (_w-2*_gap)/3, (_h-_gap)*(0.45+0.1/3));
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect12_5_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)/3*2+2*_gap, _gap+(_h-_gap)*0.45+_gap, (_w-2*_gap)/3, (_h-_gap)*(0.45+0.1/3));
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect12_4_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)/3+_gap, _gap+(_h-_gap)*(0.45+0.1/3)+_gap, (_w-2*_gap)/3, (_h-_gap)*(0.45+0.1/3));
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                [self creatPointsArrayWithRect12_5_5:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            case 5:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)/3*2+2*_gap, _gap, (_w-2*_gap)/3, (_h-_gap)*(0.45+0.1/3));
                
                _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image6;
                
                [self creatPointsArrayWithRect12_6_6:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
                _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template12_7
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.1/3*2, (_w-2*_gap)/3, (_h-_gap)*(0.45+0.1/3));
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect12_4_1:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)/3*2+2*_gap, _gap, (_w-2*_gap)/3, (_h-_gap)*(0.45+0.1/3));
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect12_7_2:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*(0.45+0.1/3*2)+_gap, (_w-2*_gap)/3, (_h-_gap)*(0.45+0.1/3));
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect12_7_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)/3*2+2*_gap, _gap+(_h-_gap)*0.45+_gap, (_w-2*_gap)/3, (_h-_gap)*(0.45+0.1/3));
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect12_7_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)/3+_gap, _gap+(_h-2*_gap)*(0.1/3), (_w-2*_gap)/3, (_h-2*_gap)*(0.3+0.1/3));
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                [self creatPointsArrayWithRect12_7_5:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            case 5:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)/3+_gap, _gap+(_h-2*_gap)*(0.3+0.1/3)+_gap, (_w-2*_gap)/3, (_h-2*_gap)*(0.3+0.1/3));
                
                _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image6;
                
                [self creatPointsArrayWithRect12_7_6:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
                _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
                
            }
                break;
            case 6:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)/3+_gap, _gap+(_h-2*_gap)*(0.6+0.1/3)+2*_gap, (_w-2*_gap)/3, (_h-2*_gap)*(0.3+0.1/3));
                
                _image7 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:6] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image7;
                
                [self creatPointsArrayWithRect12_7_7:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image7.size.width, _image7.size.height);
                _scrollView.contentSize = CGSizeMake(_image7.size.width, _image7.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

#pragma mark -- Poster collage type 13
- (void)template13_3
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, _w, (_h-2*_gap)*0.4);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect13_3_1:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.2+_gap, _w, (_h-2*_gap)*0.6);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect13_3_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.6+2*_gap, _w, (_h-2*_gap)*0.4);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect13_3_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template13_4
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, _w, (_h-2*_gap)*0.4);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect13_3_1:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.3+_gap, (_w-_gap)*0.5, (_h-2*_gap)*0.5);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect13_4_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.6+2*_gap, _w, (_h-2*_gap)*0.4);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect13_3_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-2*_gap)*0.2+_gap, (_w-_gap)*0.5, (_h-2*_gap)*0.5);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect13_4_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template13_5
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.5, (_h-2*_gap)*0.4);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect13_5_1:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap, (_w-_gap)*0.5, (_h-2*_gap)*0.3);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect13_5_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.2+_gap, _w, (_h-2*_gap)*0.6);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect13_5_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.7+2*_gap, (_w-_gap)*0.5, (_h-2*_gap)*0.3);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect13_5_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-2*_gap)*0.6+2*_gap, (_w-_gap)*0.5, (_h-2*_gap)*0.4);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                [self creatPointsArrayWithRect13_5_5:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template13_6
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.5, (_h-2*_gap)*0.4);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect13_5_1:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap, (_w-_gap)*0.5, (_h-2*_gap)*0.3);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect13_5_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.3+_gap, (_w-_gap)*0.5, (_h-2*_gap)*0.5);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect13_6_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.7+2*_gap, (_w-_gap)*0.5, (_h-2*_gap)*0.3);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect13_5_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-2*_gap)*0.6+2*_gap, (_w-_gap)*0.5, (_h-2*_gap)*0.4);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                [self creatPointsArrayWithRect13_5_5:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            case 5:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-2*_gap)*0.2+_gap, (_w-_gap)*0.5, (_h-2*_gap)*0.5);
                
                _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image6;
                
                [self creatPointsArrayWithRect13_6_6:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
                _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template13_7
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.5, (_h-2*_gap)*0.4);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect13_5_1:_scrollView.frame];
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap, (_w-_gap)*0.5, (_h-2*_gap)*0.3);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect13_5_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.3+_gap, (_w-_gap)*0.5, (_h-2*_gap)*0.5);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect13_6_3:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)*0.7+2*_gap, (_w-_gap)*0.5, (_h-2*_gap)*0.3);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect13_5_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-2*_gap)*0.6+2*_gap, (_w-_gap)*0.5, (_h-2*_gap)*0.4);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                [self creatPointsArrayWithRect13_5_5:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            case 5:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-2*_gap)*0.2+_gap, (_w-_gap)*0.5, (_h-2*_gap)*0.3);
                
                _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image6;
                
                [self creatPointsArrayWithRect13_7_6:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
                _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
                
            }
                break;
            case 6:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-2*_gap)*0.4+2*_gap, (_w-_gap)*0.5, (_h-2*_gap)*0.3-_gap);
                
                _image7 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:6] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image7;
                
                [self creatPointsArrayWithRect13_7_7:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image7.size.width, _image7.size.height);
                _scrollView.contentSize = CGSizeMake(_image7.size.width, _image7.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

#pragma mark -- Poster collage type 14
- (void)template14_3
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, _w, (_h-_gap)*0.5);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                _scrollView.imageView.image = _image1;
                [self.pointArray1 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.5+_gap, (_w-_gap)*0.5, (_h-_gap)*0.5);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                _scrollView.imageView.image = _image2;
                [self.pointArray2 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.5+_gap, (_w-_gap)*0.5, (_h-_gap)*0.5);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                _scrollView.imageView.image = _image3;
                [self.pointArray3 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template14_4
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.5, (_h-_gap)*0.5);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                _scrollView.imageView.image = _image1;
                [self.pointArray1 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap, (_w-_gap)*0.5, (_h-_gap)*0.5);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                _scrollView.imageView.image = _image2;
                [self.pointArray2 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.5+_gap, (_w-_gap)*0.5, (_h-_gap)*0.5);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                _scrollView.imageView.image = _image3;
                [self.pointArray3 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.5+_gap, (_w-_gap)*0.5, (_h-_gap)*0.5);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                _scrollView.imageView.image = _image4;
                [self.pointArray4 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template14_5
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, _w, (_h-_gap)*0.5);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                _scrollView.imageView.image = _image1;
                [self.pointArray1 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.5+_gap, (_w-_gap)*0.5, (_h-_gap)*0.25);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                _scrollView.imageView.image = _image2;
                [self.pointArray2 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.75+2*_gap, (_w-_gap)*0.5, (_h-_gap)*0.25-_gap);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                _scrollView.imageView.image = _image3;
                [self.pointArray3 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.5+_gap, (_w-_gap)*0.5, (_h-_gap)*0.3);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect14_5_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.7+2*_gap, (_w-_gap)*0.5, (_h-_gap)*0.3-_gap);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                [self creatPointsArrayWithRect14_5_5:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template14_6
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.5, (_h-_gap)*0.5);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                _scrollView.imageView.image = _image1;
                [self.pointArray1 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.5+_gap, (_w-_gap)*0.5, (_h-_gap)*0.25);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                _scrollView.imageView.image = _image2;
                [self.pointArray2 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.75+2*_gap, (_w-_gap)*0.5, (_h-_gap)*0.25-_gap);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                _scrollView.imageView.image = _image3;
                [self.pointArray3 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.5+_gap, (_w-_gap)*0.5, (_h-_gap)*0.3);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect14_5_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.7+2*_gap, (_w-_gap)*0.5, (_h-_gap)*0.3-_gap);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                [self creatPointsArrayWithRect14_5_5:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            case 5:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap, (_w-_gap)*0.5, (_h-_gap)*0.5);
                
                _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image6;
                
                _scrollView.imageView.image = _image6;
                [self.pointArray6 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
                _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template14_7
{
    float _w = _currentWidth-2*_gap;
    float _h = _currentHeight-2*_gap;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap, (_w-_gap)*0.5, (_h-2*_gap)/3);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                _scrollView.imageView.image = _image1;
                [self.pointArray1 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)/3+_gap, (_w-_gap)*0.5, (_h-2*_gap)/3);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                _scrollView.imageView.image = _image2;
                [self.pointArray2 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-2*_gap)/3*2+2*_gap, (_w-_gap)*0.5, (_h-2*_gap)/3);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                _scrollView.imageView.image = _image3;
                [self.pointArray3 removeAllObjects];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap, (_w-_gap)*0.5, (_h-_gap)*0.3);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect14_7_4:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.2+_gap, (_w-_gap)*0.5, (_h-_gap)*0.3-_gap);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                [self creatPointsArrayWithRect14_7_5:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            case 5:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.5+_gap, (_w-_gap)*0.5, (_h-_gap)*0.3);
                
                _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image6;
                
                [self creatPointsArrayWithRect14_7_6:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
                _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
                
            }
                break;
            case 6:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+(_h-_gap)*0.7+2*_gap, (_w-_gap)*0.5, (_h-_gap)*0.3-_gap);
                
                _image7 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:6] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image7;
                
                [self creatPointsArrayWithRect14_7_7:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image7.size.width, _image7.size.height);
                _scrollView.contentSize = CGSizeMake(_image7.size.width, _image7.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

#pragma mark -- Poster collage type 15
- (void)template15_2
{
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap)*0.9;
    float _y = _h*0.1;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+_y, _w, (_h-_gap)*0.55);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect15_2_1:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.5+_gap+_y, _w, (_h-_gap)*0.5);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect15_2_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template15_3
{
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap)*0.9;
    float _y = _h*0.1;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    float _tanA = 11*(_h-_gap)/(_w-_gap);
    float _tanB = 0.05*(_h-_gap)/_w;
    float _a = -0.5*(_w-_gap)*_tanA;
    float _b = 0.05*(_h-_gap);
    float _intersectionPointW = (_b-_a)/(_tanA+_tanB);
    float _intersectionPointH = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.5*(_w-_gap)+_gap)*_tanA;
    float _intersectionPoint2W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint2H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);

    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+_y, (_w-_gap)*0.55, (_h-_gap)*0.55-_intersectionPointH);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect15_3_1:_scrollView.frame withSecondWidth:_intersectionPointW];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.5+_gap+_y, _w, (_h-_gap)*0.5);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect15_2_2:_scrollView.frame];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap+_intersectionPoint2W, _gap+_y, _w-_intersectionPoint2W, (_h-_gap)*0.55);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect15_3_3:_scrollView.frame withSecondWidth:(_w-_gap)*0.55+_gap-_intersectionPoint2W andSecondHeight:(_h-_gap)*0.55-_intersectionPoint2H];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template15_4
{
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap)*0.9;
    float _y = _h*0.1;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    float _tanA = 11*(_h-_gap)/(_w-_gap);
    float _tanB = 0.05*(_h-_gap)/_w;
    float _a = -0.5*(_w-_gap)*_tanA;
    float _b = 0.05*(_h-_gap);
    float _intersectionPointW = (_b-_a)/(_tanA+_tanB);
    float _intersectionPointH = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.5*(_w-_gap)+_gap)*_tanA;
    float _intersectionPoint2W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint2H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -0.5*(_w-_gap)*_tanA;
    _b = 0.5*(_h-_gap);
    
    float _intersectionPoint3W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint3H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.5*(_w-_gap)+_gap)*_tanA;
    float _intersectionPoint4W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint4H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+_y, (_w-_gap)*0.55, (_h-_gap)*0.55-_intersectionPointH);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect15_3_1:_scrollView.frame withSecondWidth:_intersectionPointW];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+_intersectionPoint2W, _gap+_y, _w-_intersectionPoint2W, (_h-_gap)*0.55);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect15_4_2:_scrollView.frame withSecondWidth:(_w-_gap)*0.55+_gap-_intersectionPoint2W andSecondHeight:(_h-_gap)*0.55-_intersectionPoint2H];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.5+_gap+_y, _intersectionPoint3W, (_h-_gap)*0.5);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect15_4_3:_scrollView.frame withSecondHeight:_intersectionPoint3H];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+_h-_intersectionPoint4H+_y, (_w-_gap)*0.5, _intersectionPoint4H);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect15_4_4:_scrollView.frame withSecondWidth:_intersectionPoint4W-(_w-_gap)*0.5-_gap];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template15_5
{
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap)*0.9;
    float _y = _h*0.1;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    float _tanA = 11*(_h-_gap)/(_w-_gap);
    float _tanB = 0.05*(_h-_gap)/_w;
    float _a = -0.3*(_w-2*_gap)*_tanA;
    float _b = 0.05*(_h-_gap);
    float _intersectionPointW = (_b-_a)/(_tanA+_tanB);
    float _intersectionPointH = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.3*(_w-2*_gap)+_gap)*_tanA;
    float _intersectionPoint2W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint2H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.6*(_w-2*_gap)+_gap)*_tanA;
    float _intersectionPoint3W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint3H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.6*(_w-2*_gap)+2*_gap)*_tanA;
    float _intersectionPoint4W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint4H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -0.5*(_w-_gap)*_tanA;
    _b = 0.5*(_h-_gap);
    
    float _intersectionPoint5W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint5H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.5*(_w-_gap)+_gap)*_tanA;
    float _intersectionPoint6W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint6H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+_y, (_w-2*_gap)*0.35, (_h-_gap)*0.55-_intersectionPointH);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect15_5_1:_scrollView.frame withSecondWidth:_intersectionPointW];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+_intersectionPoint2W, _gap+_y, (_w-2*_gap)*0.65+_gap-_intersectionPoint2W, (_h-_gap)*0.55-_intersectionPoint3H);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect15_5_2:_scrollView.frame withSecondWidth:(_w-_gap)*0.35+_gap-_intersectionPoint2W andSecondHeight:(_h-_gap)*0.55-_intersectionPoint2H andThirdWidth:_intersectionPoint3W-_intersectionPoint2W];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap+_intersectionPoint4W, _gap+_y, _w-_intersectionPoint4W, (_h-_gap)*0.55);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect15_5_3:_scrollView.frame withSecondWidth:(_w-2*_gap)*0.65+2*_gap-_intersectionPoint4W andSecondHeight:(_h-_gap)*0.55-_intersectionPoint4H];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.5+_gap+_y, _intersectionPoint5W, (_h-_gap)*0.5);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect15_5_4:_scrollView.frame withSecondHeight:_intersectionPoint5H];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-_gap)*0.5+_gap, _gap+_h-_intersectionPoint6H+_y, (_w-_gap)*0.5, _intersectionPoint6H);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                [self creatPointsArrayWithRect15_5_5:_scrollView.frame withSecondWidth:_intersectionPoint6W-(_w-_gap)*0.5-_gap];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template15_6
{
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap)*0.9;
    float _y = _h*0.1;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    float _tanA = 11*(_h-_gap)/(_w-_gap);
    float _tanB = 0.05*(_h-_gap)/_w;
    float _a = -0.3*(_w-2*_gap)*_tanA;
    float _b = 0.05*(_h-_gap);
    float _intersectionPointW = (_b-_a)/(_tanA+_tanB);
    float _intersectionPointH = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.3*(_w-2*_gap)+_gap)*_tanA;
    float _intersectionPoint2W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint2H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.6*(_w-2*_gap)+_gap)*_tanA;
    float _intersectionPoint3W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint3H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.6*(_w-2*_gap)+2*_gap)*_tanA;
    float _intersectionPoint4W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint4H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -0.3*(_w-2*_gap)*_tanA;
    _b = 0.5*(_h-_gap);
    
    float _intersectionPoint5W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint5H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.3*(_w-2*_gap)+_gap)*_tanA;
    float _intersectionPoint6W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint6H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.6*(_w-2*_gap)+_gap)*_tanA;
    float _intersectionPoint7W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint7H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.6*(_w-2*_gap)+2*_gap)*_tanA;
    float _intersectionPoint8W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint8H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+_y, (_w-2*_gap)*0.35, (_h-_gap)*0.55-_intersectionPointH);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect15_5_1:_scrollView.frame withSecondWidth:_intersectionPointW];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+_intersectionPoint2W, _gap+_y, (_w-2*_gap)*0.65+_gap-_intersectionPoint2W, (_h-_gap)*0.55-_intersectionPoint3H);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect15_5_2:_scrollView.frame withSecondWidth:(_w-_gap)*0.35+_gap-_intersectionPoint2W andSecondHeight:(_h-_gap)*0.55-_intersectionPoint2H andThirdWidth:_intersectionPoint3W-_intersectionPoint2W];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap+_intersectionPoint4W, _gap+_y, _w-_intersectionPoint4W, (_h-_gap)*0.55);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect15_5_3:_scrollView.frame withSecondWidth:(_w-2*_gap)*0.65+2*_gap-_intersectionPoint4W andSecondHeight:(_h-_gap)*0.55-_intersectionPoint4H];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.5+_gap+_y, _intersectionPoint5W, (_h-_gap)*0.5);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect15_6_4:_scrollView.frame withSecondHeight:_intersectionPoint5H];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)*0.3+_gap, _gap+_h-_intersectionPoint6H+_y, _intersectionPoint7W-(_w-2*_gap)*0.3-_gap, _intersectionPoint6H);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                [self creatPointsArrayWithRect15_6_5:_scrollView.frame withSecondWidth:_intersectionPoint6W-(_w-2*_gap)*0.3-_gap andSecondHeight:_intersectionPoint6H-_intersectionPoint7H];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            case 5:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)*0.6+2*_gap, _gap+_h-_intersectionPoint8H+_y, (_w-2*_gap)*0.4, _intersectionPoint8H);
                
                _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image6;
                
                [self creatPointsArrayWithRect15_6_6:_scrollView.frame withSecondWidth:_intersectionPoint8W-(_w-2*_gap)*0.6-2*_gap];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
                _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

- (void)template15_7
{
    float _w = _currentWidth-2*_gap;
    float _h = (_currentHeight-2*_gap)*0.9;
    float _y = _h*0.1;
    int _random = arc4random()%10+arc4random()%10*0.1;
    
    float _tanA = 11*(_h-_gap)/(_w-_gap);
    float _tanB = 0.05*(_h-_gap)/_w;
    float _a = -0.3*(_w-2*_gap)*_tanA;
    float _b = 0.05*(_h-_gap);
    float _intersectionPointW = (_b-_a)/(_tanA+_tanB);
    float _intersectionPointH = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.3*(_w-2*_gap)+_gap)*_tanA;
    float _intersectionPoint2W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint2H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.6*(_w-2*_gap)+_gap)*_tanA;
    float _intersectionPoint3W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint3H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.6*(_w-2*_gap)+2*_gap)*_tanA;
    float _intersectionPoint4W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint4H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -0.3*(_w-2*_gap)*_tanA;
    _b = 0.5*(_h-_gap);
    
    float _intersectionPoint5W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint5H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.3*(_w-2*_gap)+_gap)*_tanA;
    float _intersectionPoint6W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint6H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.6*(_w-2*_gap)+_gap)*_tanA;
    float _intersectionPoint7W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint7H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.6*(_w-2*_gap)+2*_gap)*_tanA;
    float _intersectionPoint8W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint8H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.3*(_w-2*_gap)+_gap)*_tanA;
    _b = 0.35*(_h-_gap)+_gap;
    float _intersectionPoint9W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint9H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _b = 0.35*(_h-_gap);
    float _intersectionPoint10W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint10H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.6*(_w-2*_gap)+_gap)*_tanA;
    float _intersectionPoint11W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint11H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    _a = -(0.6*(_w-2*_gap)+2*_gap)*_tanA;
    float _intersectionPoint12W = (_b-_a)/(_tanA+_tanB);
    float _intersectionPoint12H = (_b*_tanA+_a*_tanB)/(_tanA+_tanB);
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (nil == _scrollView) {
            _scrollView = [[ZBPosterCollageScrollView alloc] init];
            _scrollView.tag = kPosterImageViewStartTag+i;
            _scrollView.delegate = self;
            [self addSubview:_scrollView];
        }
        
        switch (i) {
            case 0:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+_y, (_w-2*_gap)*0.35, (_h-_gap)*0.55-_intersectionPointH);
                
                _image1 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:0] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image1;
                
                [self creatPointsArrayWithRect15_5_1:_scrollView.frame withSecondWidth:_intersectionPointW];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image1.size.width, _image1.size.height);
                _scrollView.contentSize = CGSizeMake(_image1.size.width, _image1.size.height);
                
            }
                break;
            case 1:
            {
                _scrollView.frame = CGRectMake(_gap+_intersectionPoint9W, _gap+_y, _w-_intersectionPoint9W, (_h-_gap)*0.25-_gap);
                
                _image2 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:1] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image2;
                
                [self creatPointsArrayWithRect15_7_2:_scrollView.frame withSecondWidth:(_w-2*_gap)*0.35+_gap-_intersectionPoint9W andSecondHeight:(_h-_gap)*0.55-_intersectionPoint9H];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image2.size.width, _image2.size.height);
                _scrollView.contentSize = CGSizeMake(_image2.size.width, _image2.size.height);
                
            }
                break;
            case 2:
            {
                _scrollView.frame = CGRectMake(_gap+_intersectionPoint2W, _gap+_y+(_h-_gap)*0.55-_intersectionPoint10H, _intersectionPoint11W-_intersectionPoint2W, _intersectionPoint10H-_intersectionPoint3H);
                
                _image3 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:2] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image3;
                
                [self creatPointsArrayWithRect15_7_3:_scrollView.frame withSecondWidth:_intersectionPoint10W-_intersectionPoint2W andSecondHeight:_intersectionPoint10H-_intersectionPoint2H andThirdWidth:_intersectionPoint3W-_intersectionPoint2W andThirdHeight:_intersectionPoint10H-_intersectionPoint11H];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image3.size.width, _image3.size.height);
                _scrollView.contentSize = CGSizeMake(_image3.size.width, _image3.size.height);
                
            }
                break;
            case 3:
            {
                _scrollView.frame = CGRectMake(_gap, _gap+(_h-_gap)*0.5+_gap+_y, _intersectionPoint5W, (_h-_gap)*0.5);
                
                _image4 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:3] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image4;
                
                [self creatPointsArrayWithRect15_6_4:_scrollView.frame withSecondHeight:_intersectionPoint5H];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image4.size.width, _image4.size.height);
                _scrollView.contentSize = CGSizeMake(_image4.size.width, _image4.size.height);
                
            }
                break;
            case 4:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)*0.3+_gap, _gap+_h-_intersectionPoint6H+_y, _intersectionPoint7W-(_w-2*_gap)*0.3-_gap, _intersectionPoint6H);
                
                _image5 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:4] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image5;
                
                [self creatPointsArrayWithRect15_6_5:_scrollView.frame withSecondWidth:_intersectionPoint6W-(_w-2*_gap)*0.3-_gap andSecondHeight:_intersectionPoint6H-_intersectionPoint7H];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image5.size.width, _image5.size.height);
                _scrollView.contentSize = CGSizeMake(_image5.size.width, _image5.size.height);
                
            }
                break;
            case 5:
            {
                _scrollView.frame = CGRectMake(_gap+(_w-2*_gap)*0.6+2*_gap, _gap+_h-_intersectionPoint8H+_y, (_w-2*_gap)*0.4, _intersectionPoint8H);
                
                _image6 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:5] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image6;
                
                [self creatPointsArrayWithRect15_6_6:_scrollView.frame withSecondWidth:_intersectionPoint8W-(_w-2*_gap)*0.6-2*_gap];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image6.size.width, _image6.size.height);
                _scrollView.contentSize = CGSizeMake(_image6.size.width, _image6.size.height);
                
            }
                break;
            case 6:
            {
                _scrollView.frame = CGRectMake(_gap+_intersectionPoint4W, _gap+(_h-_gap)*0.55-_intersectionPoint12H+_y, _w-_intersectionPoint4W, _intersectionPoint12H);
                
                _image7 = [ImageUtil getScaleImage:[self.selectedImagesArray objectAtIndex:6] withWidth:_scrollView.frame.size.width andHeight:_scrollView.frame.size.height];
                _scrollView.originImage = _image7;
                
                [self creatPointsArrayWithRect15_7_7:_scrollView.frame withSecondWidth:_intersectionPoint12W-_intersectionPoint4W andSecondHeight:_intersectionPoint4H];
                
                _scrollView.imageView.frame = CGRectMake(0, 0, _image7.size.width, _image7.size.height);
                _scrollView.contentSize = CGSizeMake(_image7.size.width, _image7.size.height);
                
            }
                break;
            default:
                break;
        }
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2+_random, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}


#pragma mark -- get points array

- (void)creatPointsArrayWithRect1_2_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-(rect.size.height-(_currentHeight-_gap)*0.2));
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_2_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height-(_currentHeight-_gap)*0.2);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(_currentWidth, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(_currentWidth, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_3_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-(rect.size.height-(_currentHeight-_gap)*0.2));
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_3_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height-(_currentHeight-_gap)*0.1);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-_gap)*0.5, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_3_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height-(_currentHeight-_gap)*0.1);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-_gap)*0.1, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_4_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-(rect.size.height-(_currentHeight-2*_gap)*0.2));
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_4_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height-(_currentHeight-2*_gap)*0.2);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(rect.size.height-(_currentHeight-2*_gap)*0.2));
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_4_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height-(_currentHeight-2*_gap)*0.1);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-_gap)*0.5, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_4_4:(CGRect)rect
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image4.size.height-(_currentHeight-2*_gap)*0.1);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-_gap)*0.1, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_5_1:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-(rect.size.height-secondHeight));
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-_gap)*0.5, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_5_2:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((secondWidth-(_currentWidth-_gap)*0.5-_gap), _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-2*_gap)*0.15);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_5_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height-(_currentHeight-2*_gap)*0.2);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height - rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-(rect.size.height-(_currentHeight-2*_gap)*0.2));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_5_4:(CGRect)rect
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image4.size.height-(_currentHeight-2*_gap)*0.1);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-_gap)*0.5, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_5_5:(CGRect)rect
{
    [self.pointArray5 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image5.size.height-(_currentHeight-2*_gap)*0.1);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-_gap)*0.1, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_6_1:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-(rect.size.height-secondHeight));
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-_gap)*0.5, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_6_2:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((secondWidth-(_currentWidth-_gap)*0.5-_gap), _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-2*_gap)*0.15);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_6_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height-(_currentHeight-2*_gap)*0.2);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height - rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-(rect.size.height-(_currentHeight-2*_gap)*0.2));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}


- (void)creatPointsArrayWithRect1_6_4:(CGRect)rect
{
    [self.pointArray4 removeAllObjects];
//    float _tanA = (_currentHeight-2*_gap)*0.2/(_currentWidth-2*_gap);
    CGPoint p = CGPointMake(0, _image4.size.height- (rect.size.height - (_currentHeight-2*_gap)*0.2));
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-2*_gap)/3, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArray1_6_5:(CGRect)rect withLeftHeight:(float)leftHeight andLeftWidth:(float)leftWidth
{
    [self.pointArray5 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image5.size.height-(rect.size.height - leftHeight));
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(leftWidth, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-2*_gap)/3, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArray1_6_6:(CGRect)rect andLeftWidth:(float)leftWidth
{
    [self.pointArray6 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image6.size.height-(_currentHeight-2*_gap)*0.2/3);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(leftWidth, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}
- (void)creatPointsArrayWithRect1_7_1:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray1 removeAllObjects];

    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-(rect.size.height-secondHeight));
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-2*_gap)/3, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_7_2:(CGRect)rect withLeftWidth:(float)leftWidth andRightHeight:(float)rightHeiht
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(leftWidth, _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(rect.size.height-rightHeiht));
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-2*_gap)/3, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];

}

- (void)creatPointsArrayWithRect1_7_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height-(_currentHeight-2*_gap)*0.2);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height - rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-(rect.size.height-(_currentHeight-2*_gap)*0.2));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    
}

- (void)creatPointsArrayWithRect1_7_4:(CGRect)rect
{
    [self.pointArray4 removeAllObjects];
    //    float _tanA = (_currentHeight-2*_gap)*0.2/(_currentWidth-2*_gap);
    CGPoint p = CGPointMake(0, _image4.size.height- (rect.size.height - (_currentHeight-2*_gap)*0.2));
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-2*_gap)/3, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArray1_7_5:(CGRect)rect withLeftHeight:(float)leftHeight andLeftWidth:(float)leftWidth
{
    [self.pointArray5 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image5.size.height-(rect.size.height - leftHeight));
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(leftWidth, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-2*_gap)/3, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArray1_7_6:(CGRect)rect andLeftWidth:(float)leftWidth
{
    [self.pointArray6 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image6.size.height-(_currentHeight-2*_gap)*0.2/3);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(leftWidth, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect1_7_7:(CGRect)rect andLeftWidth:(float)leftWidth
{
    [self.pointArray7 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image7.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(leftWidth, _image7.size.height-rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height-(_currentHeight-2*_gap)*0.15);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
}


- (void)creatPointsArrayWithRect2_2_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-(rect.size.height-(_currentHeight-3*_gap)*0.1));
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_2_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake(0, _image2.size.height-(_currentHeight-3*_gap)*0.1);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_3_1:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-(rect.size.height-secondHeight));
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.5, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_3_2:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((secondWidth-(_currentWidth-3*_gap)*0.5-_gap), _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-3*_gap)*0.4);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_3_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(0, _image3.size.height-(_currentHeight-3*_gap)*0.1);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_4_1:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-(rect.size.height-secondHeight));
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.5, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_4_2:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((secondWidth-(_currentWidth-3*_gap)*0.5-_gap), _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-4*_gap)*0.4);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_4_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(0, _image3.size.height-(_currentHeight-4*_gap)*0.1);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-(rect.size.height-(_currentHeight-4*_gap)*0.1));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_4_4:(CGRect)rect
{
    [self.pointArray4 removeAllObjects];
    CGPoint p = CGPointMake(0, _image4.size.height-(_currentHeight-4*_gap)*0.1);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_5_1:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-(rect.size.height-secondHeight));
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.5, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_5_2:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((secondWidth-(_currentWidth-3*_gap)*0.5-_gap), _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-4*_gap)*0.4);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_5_3:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(0, _image3.size.height-(rect.size.height-((_currentHeight-4*_gap)*0.5+_gap)));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_5_4:(CGRect)rect withSecondWidth:(float)secondWidth andUpH4:(float)upH4
{
    [self.pointArray4 removeAllObjects];
    CGPoint p = CGPointMake(0, _image4.size.height-((_currentHeight-4*_gap)*0.6+_gap-upH4));
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-(_currentHeight-4*_gap)*0.3);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_5_5:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray5 removeAllObjects];
    CGPoint p = CGPointMake(0, _image5.size.height-(rect.size.height - secondHeight));
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width-(_currentWidth-3*_gap)*0.5, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_6_1:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-(rect.size.height-secondHeight));
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.5, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_6_2:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((secondWidth-(_currentWidth-3*_gap)*0.5-_gap), _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-4*_gap)*0.4);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_6_3:(CGRect)rect withSecondWidth:(float)secondWidth withSecondHeight:(float)secondHeight
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(0, _image3.size.height-(rect.size.height-(_currentHeight-4*_gap)*0.3));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-(rect.size.height-(secondHeight-(_currentHeight-4*_gap)*0.2-_gap)));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_6_4:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray4 removeAllObjects];
    CGPoint p = CGPointMake(0, _image4.size.height-(rect.size.height-(_currentHeight-4*_gap)*0.2));
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_6_5:(CGRect)rect withSecondWidth:(float)secondWidth andUpH5:(float)upH5
{
    [self.pointArray5 removeAllObjects];
    CGPoint p = CGPointMake(0, _image5.size.height-((_currentHeight-4*_gap)*0.6+_gap-upH5));
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-(_currentHeight-4*_gap)*0.3);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_6_6:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray6 removeAllObjects];
    CGPoint p = CGPointMake(0, _image6.size.height-(rect.size.height - secondHeight));
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width-(_currentWidth-3*_gap)*0.5, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_7_1:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-(rect.size.height-secondHeight));
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.5, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_7_2:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((secondWidth-(_currentWidth-3*_gap)*0.5-_gap), _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-5*_gap)*0.2);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_7_3:(CGRect)rect withSecondWidth:(float)secondWidth withSecondHeight:(float)secondHeight
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(0, _image3.size.height-(rect.size.height-(_currentHeight-4*_gap)*0.3));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-(rect.size.height-(secondHeight-(_currentHeight-4*_gap)*0.2-_gap)));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_7_4:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray4 removeAllObjects];
    CGPoint p = CGPointMake(0, _image4.size.height-(rect.size.height-(_currentHeight-4*_gap)*0.2));
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_7_5:(CGRect)rect withSecondWidth:(float)secondWidth andUpH5:(float)upH5
{
    [self.pointArray5 removeAllObjects];
    CGPoint p = CGPointMake(0, _image5.size.height-((_currentHeight-4*_gap)*0.6+_gap-upH5));
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-(_currentHeight-4*_gap)*0.3);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_7_6:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray6 removeAllObjects];
    CGPoint p = CGPointMake(0, _image6.size.height-(rect.size.height - secondHeight));
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width-(_currentWidth-3*_gap)*0.5, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect2_7_7:(CGRect)rect withSecondWidth:(float)secondWidth withSecondHeight:(float)secondHeigth
{
    [self.pointArray7 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image7.size.height - ((_currentHeight-4*_gap)*0.3-secondHeigth-0.9*_gap));
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image7.size.height - rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height-(_currentHeight-4*_gap)*0.2+_gap);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_2_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - ((_currentHeight-2*_gap)*0.85-_gap)*0.4);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.5, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height - ((_currentHeight-2*_gap)*0.85-_gap)*0.4);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_2_2:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.5, _image2.size.height-((_currentHeight-2*_gap)*0.85-_gap)*0.1+secondHeight-_gap);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_3_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - ((_currentHeight-2*_gap)*0.85-_gap)*0.4);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.5, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height - ((_currentHeight-2*_gap)*0.85-_gap)*0.4);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_3_2:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-((_currentHeight-2*_gap)*0.85-_gap)*0.1+secondHeight-_gap);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_3_3:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height-((_currentHeight-2*_gap)*0.85-_gap)*0.1+secondHeight-_gap);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height - rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_4_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - ((_currentHeight-2*_gap)*0.85-_gap)*0.4);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.5, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height - ((_currentHeight-2*_gap)*0.85-_gap)*0.4);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_4_2:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height+((_currentHeight-2*_gap)*0.85-_gap)*0.1);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-((_currentHeight-2*_gap)*0.85-_gap)*0.1+secondHeight-_gap);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_4_3:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height-((_currentHeight-2*_gap)*0.85-_gap)*0.1+secondHeight-_gap);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height+((_currentHeight-2*_gap)*0.85-_gap)*0.1);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_4_4:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image4.size.height-((_currentHeight-2*_gap)*0.85-_gap)*0.1);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-((_currentHeight-2*_gap)*0.85-_gap)*0.1);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.5, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_5_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - ((_currentHeight-2*_gap)*0.85-_gap)*0.4);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_5_2:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height+((_currentHeight-2*_gap)*0.85-_gap)*0.1);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-((_currentHeight-2*_gap)*0.85-_gap)*0.1+secondHeight-_gap);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_5_3:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height-((_currentHeight-2*_gap)*0.85-_gap)*0.1+secondHeight-_gap);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height+((_currentHeight-2*_gap)*0.85-_gap)*0.1);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_5_4:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image4.size.height-((_currentHeight-2*_gap)*0.85-_gap)*0.1);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-((_currentHeight-2*_gap)*0.85-_gap)*0.1);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.5, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_5_5:(CGRect)rect
{
    [self.pointArray5 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height - ((_currentHeight-2*_gap)*0.85-_gap)*0.4);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_6_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - ((_currentHeight-2*_gap)*0.85-_gap)*0.4);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_6_2:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width,  _image2.size.height-rect.size.height+((_currentHeight-2*_gap)*0.85-_gap)*0.1);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-((_currentHeight-2*_gap)*0.85-_gap)*0.1+secondHeight-_gap);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_6_3:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height-((_currentHeight-2*_gap)*0.85-_gap)*0.1+secondHeight-_gap);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height+((_currentHeight-2*_gap)*0.85-_gap)*0.1);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_6_4:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image4.size.height-((_currentHeight-2*_gap)*0.85-_gap)*0.1);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_6_5:(CGRect)rect
{
    [self.pointArray5 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height - ((_currentHeight-2*_gap)*0.85-_gap)*0.4);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_6_6:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray6 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image6.size.height - rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height - rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-((_currentHeight-2*_gap)*0.85-_gap)*0.1);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_7_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - ((_currentHeight-2*_gap)*0.85-2*_gap)*0.3);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_7_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_7_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height - ((_currentHeight-2*_gap)*0.85-2*_gap)*0.3);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_7_4:(CGRect)rect withSecondHeight:(float)secondHeight andThirdHeight:(float)thirdHeight
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-(rect.size.height-thirdHeight));
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-secondHeight);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_7_5:(CGRect)rect withMiddleHeight:(float)middleHeight
{
    [self.pointArray5 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.5, _image5.size.height - (rect.size.height-middleHeight));
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_7_6:(CGRect)rect withSecondHeight:(float)secondHeight andThirdHeight:(float)thirdHeight
{
    [self.pointArray6 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image6.size.height-secondHeight);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image6.size.height - (rect.size.height-thirdHeight));
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height - rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect4_7_7:(CGRect)rect
{
    [self.pointArray7 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image7.size.height-((_currentHeight-2*_gap)*0.85-_gap)*0.1);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image7.size.height - rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height-rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height-((_currentHeight-2*_gap)*0.85-_gap)*0.1);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.5, _image7.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_2_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);;
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-(_currentHeight-2*_gap)*0.4+0.5*_gap);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_2_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height-(_currentHeight-2*_gap)*0.2);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_3_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);;
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.4, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_3_2:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-3*_gap)*0.45);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_3_3:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height-(rect.size.height-secondHeight));;
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width-(_currentWidth-3*_gap)*0.4, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_4_1:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);;
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-rect.size.height);;
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-secondHeight);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-2*_gap)*0.4, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];

}

- (void)creatPointsArrayWithRect5_4_2:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height-(rect.size.height-0.4*(_currentHeight-2*_gap)));
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];

}

- (void)creatPointsArrayWithRect5_4_3:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-0.4*(_currentHeight-2*_gap));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];

}

- (void)creatPointsArrayWithRect5_4_4:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image4.size.height - (rect.size.height-secondHeight));
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth-0.4*(_currentWidth-2*_gap), _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];

}

- (void)creatPointsArrayWithRect5_5_1:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);;
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-secondHeight);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_5_2:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(rect.size.height-secondHeight));
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_5_3:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-secondHeight);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width-secondWidth, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_5_4:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image4.size.height - (rect.size.height-secondHeight));
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width-secondWidth, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_5_5:(CGRect)rect
{
    [self.pointArray5 removeAllObjects];

    CGPoint p = CGPointMake(0, _image5.size.height - rect.size.height*0.5);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.5, _image5.size.height - rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height - rect.size.height*0.5);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.5, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];

}

- (void)creatPointsArrayWithRect5_6_1:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);;
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-rect.size.height+secondHeight);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.4, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_6_2:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height-secondHeight);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-secondHeight-(_currentHeight-4*_gap)*0.2);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_6_3:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image3.size.height-rect.size.height+secondHeight);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_6_4:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height- (_currentHeight-4*_gap)*0.3);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_6_5:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth andThirdHeight:(float)thirdHeight
{
    [self.pointArray5 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image5.size.height - secondHeight);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image5.size.height - thirdHeight);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height - rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    
}

- (void)creatPointsArrayWithRect5_6_6:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth
{
    [self.pointArray6 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image6.size.height - rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height - rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-secondHeight);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    
}

- (void)creatPointsArrayWithRect5_7_1:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);;
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-rect.size.height+secondHeight);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.4, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_7_2:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height-secondHeight);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-secondHeight-(_currentHeight-4*_gap)*0.2);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_7_3:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-((_currentHeight-4*_gap)*0.4-_gap)*0.5);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image3.size.height-(_currentHeight-4*_gap)*0.4+secondHeight);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_7_4:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height- (_currentHeight-4*_gap)*0.3);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect5_7_5:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth andThirdHeight:(float)thirdHeight
{
    [self.pointArray5 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image5.size.height - secondHeight);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image5.size.height - thirdHeight);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height - rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    
}

- (void)creatPointsArrayWithRect5_7_6:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth
{
    [self.pointArray6 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image6.size.height - rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height - rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-secondHeight);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    
}

- (void)creatPointsArrayWithRect5_7_7:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth
{
    [self.pointArray7 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image7.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image7.size.height-rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height-rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image7.size.height-rect.size.height+secondHeight);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect6_2_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);;
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-2*_gap)*0.4-_gap*0.5, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect6_2_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(_currentWidth*0.2, _image2.size.height);;
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect6_3_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);;
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-4*_gap)*0.3, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect6_3_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);;
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-2*_gap)*0.05, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-2*_gap)-(_currentWidth-4*_gap)*0.65-2*_gap, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect6_3_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake((_currentWidth-4*_gap)*0.05, _image3.size.height);;
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect6_4_1:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);;
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-rect.size.height);;
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image1.size.height-secondHeight);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    
}

- (void)creatPointsArrayWithRect6_4_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height-(rect.size.height-0.4*(_currentHeight-2*_gap)));
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-2*_gap)*0.4, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    
}

- (void)creatPointsArrayWithRect6_4_3:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(secondWidth-(_currentWidth-2*_gap)*0.4, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-0.4*(_currentHeight-2*_gap));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    
}

- (void)creatPointsArrayWithRect6_4_4:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(secondWidth, _image4.size.height - (rect.size.height-secondHeight));
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect6_5_1:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);;
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-2*_gap)*0.25-_gap, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-2*_gap)*0.368, _image1.size.height-((_currentHeight-2*_gap)-secondHeight)*0.5+_gap);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-((_currentHeight-2*_gap)-secondHeight)*0.5+_gap);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];

}

- (void)creatPointsArrayWithRect6_5_2:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-secondHeight*0.5-0.5*_gap);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-2*_gap)*0.368, _image2.size.height-secondHeight*0.5-0.5*_gap);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-2*_gap)*0.25-_gap, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect6_5_3:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray3 removeAllObjects];

    
    CGPoint p = CGPointMake(0, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-((_currentHeight-2*_gap)-secondHeight)*0.5+_gap);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-2*_gap)*0.13, _image3.size.height-((_currentHeight-2*_gap)-secondHeight)*0.5+_gap);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width-(_currentWidth-2*_gap)*0.25+_gap, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];    
}

- (void)creatPointsArrayWithRect6_5_4:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image4.size.height -secondHeight*0.5-0.5*_gap);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width-(_currentWidth-2*_gap)*0.25+_gap, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-2*_gap)*0.13, _image4.size.height-secondHeight*0.5-0.5*_gap);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect6_5_5:(CGRect)rect
{
    [self.pointArray5 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image5.size.height - rect.size.height*0.5);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.25, _image5.size.height - rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.75, _image5.size.height - rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-rect.size.height*0.5);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.75, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.25, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];

}

- (void)creatPointsArrayWithRect6_7_1:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth andThirdHeight:(float)thirdHeight andThirdWidth:(float)thirdWidth
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);;
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-secondHeight);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(thirdWidth, _image1.size.height-thirdHeight);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-thirdHeight);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];

}

- (void)creatPointsArrayWithRect6_7_2:(CGRect)rect withSecondHeight:(float)secondHeight andSecondWidth:(float)secondWidth andThirdHeight:(float)thirdHeight
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(rect.size.height - (thirdHeight-secondHeight-0.5*_gap)));
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image2.size.height-rect.size.height*0.5);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(thirdHeight-secondHeight-0.5*_gap));
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect6_7_3:(CGRect)rect withSecondHeight:(float)_h1 andSecondWidth:(float)_w1 andThirdHeight:(float)_h2 andThirdWidth:(float)_w2
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height-(rect.size.height -_h1));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-(rect.size.height -_h2));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(_w2, _image3.size.height-(rect.size.height- _h2));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(_w1, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];

}

- (void)creatPointsArrayWithRect6_7_4:(CGRect)rect withSecondHeight:(float)_h1 andSecondWidth:(float)_w1 andThirdHeight:(float)_h2 andThirdWidth:(float)_w2
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-_h2);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width-_w2, _image4.size.height-_h2);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width-_w1, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-_h1);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];

}

- (void)creatPointsArrayWithRect6_7_5:(CGRect)rect withSecondHeight:(float)_h1 andSecondWidth:(float)_middleWidth andThirdHeight:(float)_firtImageHeight
{
    [self.pointArray5 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image5.size.height -(_firtImageHeight-_h1));
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((rect.size.width - _middleWidth), _image5.size.height - rect.size.height*0.5);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height - (rect.size.height - (_firtImageHeight-_h1-0.5*_gap)));
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];

    
}

- (void)creatPointsArrayWithRect6_7_6:(CGRect)rect withSecondHeight:(float)_h1 andSecondWidth:(float)_w1 andThirdHeight:(float)_h2 andThirdWidth:(float)_w2
{
    [self.pointArray6 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image6.size.height -(rect.size.height -_h2));
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image6.size.height - rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height - rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-(rect.size.height - _h1));
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width-_w1, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width-_w2, _image6.size.height-(rect.size.height-_h2));
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];

    
}

- (void)creatPointsArrayWithRect6_7_7:(CGRect)rect
{
    [self.pointArray7 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image7.size.height - rect.size.height*0.5);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.25, _image7.size.height - rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.75, _image7.size.height - rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height-rect.size.height*0.5);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.75, _image7.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.25, _image7.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];

}

- (void)creatPointsArrayWithRect7_2_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - (_currentHeight-3*_gap)*0.4);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.5, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height - (_currentHeight-3*_gap)*0.4);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_2_2:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.5, _image2.size.height-(_currentHeight-3*_gap)*0.05+secondHeight-_gap);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_3_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - (_currentHeight-3*_gap)*0.4);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.5, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height - (_currentHeight-3*_gap)*0.4);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_3_2:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-3*_gap)*0.05+secondHeight-_gap);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_3_3:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height-(_currentHeight-3*_gap)*0.05+secondHeight-_gap);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height - rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_4_3:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height-(_currentHeight-3*_gap)*0.05+secondHeight-_gap);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height - rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-(rect.size.height-(_currentHeight-3*_gap)*0.05+secondHeight-_gap));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_4_4:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image4.size.height-(_currentHeight-3*_gap)*0.05+secondHeight-_gap);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_5_2:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height - (rect.size.height-(_currentHeight-3*_gap)*0.05+secondHeight-_gap));
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-3*_gap)*0.05+secondHeight-_gap);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_5_3:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height - rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-(_currentHeight-3*_gap)*0.05+secondHeight-_gap);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_5_4:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image4.size.height-(_currentHeight-3*_gap)*0.05+secondHeight-_gap);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-(rect.size.height-(_currentHeight-3*_gap)*0.05+secondHeight-_gap));
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_5_5:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray5 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image5.size.height-(_currentHeight-3*_gap)*0.05+secondHeight-_gap);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height - rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_6_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - (_currentHeight-4*_gap)*0.4);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_6_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height - (_currentHeight-4*_gap)*0.4);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_6_3:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height - (rect.size.height-(_currentHeight-4*_gap)*0.05+secondHeight-_gap));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-(_currentHeight-4*_gap)*0.05+secondHeight-_gap);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_6_4:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-(_currentHeight-4*_gap)*0.05+secondHeight-_gap);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_6_5:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray5 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image5.size.height-(_currentHeight-4*_gap)*0.05+secondHeight-_gap);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height - rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-(rect.size.height-(_currentHeight-4*_gap)*0.05+secondHeight-_gap));
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_6_6:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray6 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image6.size.height-(_currentHeight-4*_gap)*0.05+secondHeight-_gap);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image6.size.height - rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_7_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - (_currentHeight-4*_gap)*0.4);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.5, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height - (_currentHeight-4*_gap)*0.4);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_7_2:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-(_currentHeight-4*_gap)*0.3);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-secondHeight);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_7_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height - (_currentHeight-4*_gap)*0.3);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.5, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height - (_currentHeight-4*_gap)*0.3);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.5, _image3.size.height-(rect.size.height-(_currentHeight-4*_gap)*0.3));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_7_4:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image4.size.height-secondHeight);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-(_currentHeight-4*_gap)*0.3);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_7_5:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray5 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height - rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height - rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-secondHeight);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_7_6:(CGRect)rect
{
    [self.pointArray6 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image6.size.height - rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width*0.5, _image6.size.height-(rect.size.height-(_currentHeight-4*_gap)*0.25));
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect7_7_7:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray7 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image7.size.height-secondHeight);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image7.size.height - rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height-rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_3_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image2.size.height-(rect.size.height-(_currentHeight-3*_gap)*0.5));
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height - rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.5, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_3_3:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image3.size.height-secondHeight);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_4_1:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray1 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height - rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image1.size.height-rect.size.height+secondHeight);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_4_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake(rect.size.width-(_currentWidth-3*_gap)*0.45, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-3*_gap)*0.4);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_4_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height-(rect.size.height-(_currentHeight-3*_gap)*0.5));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height - rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.5, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_4_4:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray4 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image4.size.height-secondHeight);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_5_3:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray3 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image3.size.height-(rect.size.height-(_currentHeight-3*_gap)*0.25+_gap));
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height - rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image3.size.height-secondHeight);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_5_4:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray4 removeAllObjects];
    CGPoint p = CGPointMake(0, _image4.size.height-secondHeight);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.5, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_5_5:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray5 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image5.size.height-secondHeight);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_6_5:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray5 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image5.size.height-secondHeight);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-(_currentHeight-3*_gap)*0.25+_gap);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_6_6:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray6 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image6.size.height-secondHeight);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_7_1:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray1 removeAllObjects];
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image1.size.height-secondHeight);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_7_2:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake(0, _image2.size.height-(rect.size.height-(_currentHeight-3*_gap)*0.25));
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image2.size.height-secondHeight);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_7_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(rect.size.width-(_currentWidth-3*_gap)*0.45, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-(_currentHeight-3*_gap)*0.4);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_7_4:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray4 removeAllObjects];
    
    CGPoint p = CGPointMake(0, _image4.size.height-(rect.size.height-(_currentHeight-3*_gap)*0.25+_gap));
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height - rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image4.size.height-secondHeight);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_7_5:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray5 removeAllObjects];
    CGPoint p = CGPointMake(0, _image5.size.height-secondHeight);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.5, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_7_6:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray6 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image6.size.height-secondHeight);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-(_currentHeight-3*_gap)*0.25+_gap);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect9_7_7:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray7 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image7.size.height-secondHeight);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image7.size.height-rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height-rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect10_4_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.45, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect10_4_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake((_currentWidth-3*_gap)*0.1, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect10_5_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.45, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect10_5_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.1, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect10_5_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(0, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.45, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect10_5_4:(CGRect)rect
{
    [self.pointArray4 removeAllObjects];
    CGPoint p = CGPointMake((_currentWidth-3*_gap)*0.1, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect10_6_5:(CGRect)rect
{
    [self.pointArray5 removeAllObjects];
    CGPoint p = CGPointMake(0, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.45, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect10_6_6:(CGRect)rect
{
    [self.pointArray6 removeAllObjects];
    CGPoint p = CGPointMake(0, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.1, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect10_7_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(0, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-4*_gap)*0.233, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect10_7_4:(CGRect)rect
{
    [self.pointArray4 removeAllObjects];
    CGPoint p = CGPointMake(0, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-4*_gap)*0.1, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width-(_currentWidth-4*_gap)*0.1, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect10_7_7:(CGRect)rect
{
    [self.pointArray7 removeAllObjects];
    CGPoint p = CGPointMake((_currentWidth-4*_gap)*0.1, _image7.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image7.size.height-rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height-rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect11_4_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.45, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect11_4_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake((_currentWidth-3*_gap)*0.1, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect11_6_5:(CGRect)rect
{
    [self.pointArray5 removeAllObjects];
    CGPoint p = CGPointMake(0, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.45, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect11_6_6:(CGRect)rect
{
    [self.pointArray6 removeAllObjects];
    CGPoint p = CGPointMake(0, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.1, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect11_7_5:(CGRect)rect
{
    [self.pointArray5 removeAllObjects];
    CGPoint p = CGPointMake(0, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-4*_gap)*0.2, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect11_7_6:(CGRect)rect
{
    [self.pointArray6 removeAllObjects];
    CGPoint p = CGPointMake(0, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-4*_gap)*0.1, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-4*_gap)*0.5, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect11_7_7:(CGRect)rect
{
    [self.pointArray7 removeAllObjects];
    CGPoint p = CGPointMake(0, _image7.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-4*_gap)*0.1, _image7.size.height-rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height-rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect12_2_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    CGPoint p = CGPointMake(0, _image1.size.height-(_currentHeight-3*_gap)*0.1);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-(_currentHeight-3*_gap)*0.45);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect12_2_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake(0, _image2.size.height-(_currentHeight-3*_gap)*0.1);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-3*_gap)*0.45);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect12_3_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake(0, _image2.size.height-(_currentHeight-3*_gap)*0.05);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-3*_gap)*0.45);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect12_3_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(0, _image3.size.height-(_currentHeight-3*_gap)*0.05);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-(_currentHeight-3*_gap)*0.45);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect12_4_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    CGPoint p = CGPointMake(0, _image1.size.height-(_currentHeight-3*_gap)*0.1/3);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-(_currentHeight-3*_gap)*0.45);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect12_4_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake(0, _image2.size.height-(_currentHeight-3*_gap)*0.1/3*2);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-3*_gap)*0.45);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect12_4_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(0, _image3.size.height-(_currentHeight-3*_gap)*0.1/3*2);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-(_currentHeight-3*_gap)*0.45);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect12_4_4:(CGRect)rect
{
    [self.pointArray4 removeAllObjects];
    CGPoint p = CGPointMake(0, _image4.size.height-(_currentHeight-3*_gap)*0.1/3);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-(_currentHeight-3*_gap)*0.45);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect12_5_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(0, _image3.size.height-(_currentHeight-3*_gap)*0.1/3);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-(_currentHeight-3*_gap)*0.45);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect12_5_5:(CGRect)rect
{
    [self.pointArray5 removeAllObjects];
    CGPoint p = CGPointMake(0, _image5.size.height-(_currentHeight-3*_gap)*0.1/3);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-(_currentHeight-3*_gap)*0.45);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}
- (void)creatPointsArrayWithRect12_6_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake(0, _image2.size.height-(_currentHeight-3*_gap)*0.1/3);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-3*_gap)*0.45);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect12_6_6:(CGRect)rect
{
    [self.pointArray6 removeAllObjects];
    CGPoint p = CGPointMake(0, _image6.size.height-(_currentHeight-3*_gap)*0.1/3);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-(_currentHeight-3*_gap)*0.45);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect12_7_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake(0, _image2.size.height-(_currentHeight-3*_gap)*0.1/3);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-3*_gap)*0.45);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect12_7_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(0, _image3.size.height-(_currentHeight-3*_gap)*0.1/3);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-(_currentHeight-3*_gap)*0.45);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect12_7_4:(CGRect)rect
{
    [self.pointArray4 removeAllObjects];
    CGPoint p = CGPointMake(0, _image4.size.height-(_currentHeight-3*_gap)*0.1/3);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-(_currentHeight-3*_gap)*0.45);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect12_7_5:(CGRect)rect
{
    [self.pointArray5 removeAllObjects];
    CGPoint p = CGPointMake(0, _image5.size.height-(_currentHeight-3*_gap)*0.1/3);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-(_currentHeight-4*_gap)*0.3);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect12_7_6:(CGRect)rect
{
    [self.pointArray6 removeAllObjects];
    CGPoint p = CGPointMake(0, _image6.size.height-(_currentHeight-3*_gap)*0.1/3);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-(_currentHeight-4*_gap)*0.3);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect12_7_7:(CGRect)rect
{
    [self.pointArray7 removeAllObjects];
    CGPoint p = CGPointMake(0, _image7.size.height-(_currentHeight-3*_gap)*0.1/3);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image7.size.height-rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height-(_currentHeight-4*_gap)*0.3);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect13_3_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-(_currentHeight-4*_gap)*0.2);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect13_3_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake(0, _image2.size.height-(_currentHeight-4*_gap)*0.2);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-4*_gap)*0.4);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect13_3_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(0, _image3.size.height-(_currentHeight-4*_gap)*0.2);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect13_4_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake(0, _image2.size.height-(_currentHeight-4*_gap)*0.1);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-4*_gap)*0.4);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect13_4_4:(CGRect)rect
{
    [self.pointArray4 removeAllObjects];
    CGPoint p = CGPointMake(0, _image4.size.height-(_currentHeight-4*_gap)*0.1);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-(_currentHeight-4*_gap)*0.4);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect13_5_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-(_currentHeight-4*_gap)*0.3);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect13_5_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-(_currentHeight-4*_gap)*0.2);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect13_5_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(0, _image3.size.height-(_currentHeight-4*_gap)*0.2);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-(_currentHeight-4*_gap)*0.4);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect13_5_4:(CGRect)rect
{
    [self.pointArray4 removeAllObjects];
    CGPoint p = CGPointMake(0, _image4.size.height-(_currentHeight-4*_gap)*0.1);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect13_5_5:(CGRect)rect
{
    [self.pointArray5 removeAllObjects];
    CGPoint p = CGPointMake(0, _image5.size.height-(_currentHeight-4*_gap)*0.1);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect13_6_3:(CGRect)rect
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(0, _image3.size.height-(_currentHeight-4*_gap)*0.1);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-(_currentHeight-4*_gap)*0.4);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect13_6_6:(CGRect)rect
{
    [self.pointArray6 removeAllObjects];
    CGPoint p = CGPointMake(0, _image6.size.height-(_currentHeight-4*_gap)*0.1);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-(_currentHeight-4*_gap)*0.4);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect13_7_6:(CGRect)rect
{
    [self.pointArray6 removeAllObjects];
    CGPoint p = CGPointMake(0, _image6.size.height-(_currentHeight-4*_gap)*0.1);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-(_currentHeight-4*_gap)*0.2);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect13_7_7:(CGRect)rect
{
    [self.pointArray7 removeAllObjects];
    CGPoint p = CGPointMake(0, _image7.size.height-(_currentHeight-4*_gap)*0.1);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image7.size.height-rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height-(_currentHeight-4*_gap)*0.2+_gap);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect14_5_4:(CGRect)rect
{
    [self.pointArray4 removeAllObjects];
    CGPoint p = CGPointMake(0, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-(_currentHeight-3*_gap)*0.2);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect14_5_5:(CGRect)rect
{
    [self.pointArray5 removeAllObjects];
    CGPoint p = CGPointMake(0, _image5.size.height-(_currentHeight-3*_gap)*0.1);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect14_7_4:(CGRect)rect
{
    [self.pointArray4 removeAllObjects];
    CGPoint p = CGPointMake(0, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-(_currentHeight-3*_gap)*0.2);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect14_7_5:(CGRect)rect
{
    [self.pointArray5 removeAllObjects];
    CGPoint p = CGPointMake(0, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-(_currentHeight-3*_gap)*0.1);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}


- (void)creatPointsArrayWithRect14_7_6:(CGRect)rect
{
    [self.pointArray6 removeAllObjects];
    CGPoint p = CGPointMake(0, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-(_currentHeight-3*_gap)*0.2);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect14_7_7:(CGRect)rect
{
    [self.pointArray7 removeAllObjects];
    CGPoint p = CGPointMake(0, _image7.size.height-(_currentHeight-3*_gap)*0.1);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image7.size.height-rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height-rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_2_1:(CGRect)rect
{
    [self.pointArray1 removeAllObjects];
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-((_currentHeight-2*_gap)*0.9-_gap)*0.5);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_2_2:(CGRect)rect
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake(0, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-((_currentHeight-2*_gap)*0.9-_gap)*0.05);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_3_1:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray1 removeAllObjects];
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-((_currentHeight-2*_gap)*0.9-_gap)*0.5);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_3_3:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-secondHeight);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_4_2:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-secondHeight);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_4_3:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-secondHeight);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_4_3:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(0, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.5, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height+secondHeight);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_4_4:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray4 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-(rect.size.height-((_currentHeight-2*_gap)*0.9-_gap)*0.45));
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_5_1:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray1 removeAllObjects];
    CGPoint p = CGPointMake(0, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image1.size.height-((_currentHeight-2*_gap)*0.9-_gap)*0.5);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(secondWidth, _image1.size.height-rect.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image1.size.height);
    [self.pointArray1 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_5_2:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight andThirdWidth:(float)thirdWidth
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-secondHeight);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(thirdWidth, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_5_3:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight 
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-secondHeight);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_5_4:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray4 removeAllObjects];
    CGPoint p = CGPointMake(0, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-3*_gap)*0.5, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-(rect.size.height-secondHeight));
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_5_5:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray5 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-(rect.size.height-((_currentHeight-2*_gap)*0.9-_gap)*0.45));
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_6_4:(CGRect)rect withSecondHeight:(float)secondHeight
{
    [self.pointArray4 removeAllObjects];
    CGPoint p = CGPointMake(0, _image4.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-4*_gap)*0.3, _image4.size.height-rect.size.height);
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image4.size.height-(rect.size.height-secondHeight));
    [self.pointArray4 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_6_5:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray5 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image5.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake((_currentWidth-4*_gap)*0.3, _image5.size.height-rect.size.height);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image5.size.height-secondHeight);
    [self.pointArray5 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_6_6:(CGRect)rect withSecondWidth:(float)secondWidth
{
    [self.pointArray6 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image6.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-rect.size.height);
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image6.size.height-(rect.size.height-((_currentHeight-2*_gap)*0.9-_gap)*0.45));
    [self.pointArray6 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_7_2:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray2 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image2.size.height-secondHeight);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height-rect.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image2.size.height);
    [self.pointArray2 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_7_3:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight andThirdWidth:(float)thirdWidth andThirdHeight:(float)thirdHeight
{
    [self.pointArray3 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image3.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image3.size.height-secondHeight);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(thirdWidth, _image3.size.height-rect.size.height);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image3.size.height-thirdHeight);
    [self.pointArray3 addObject:[NSValue valueWithCGPoint:p]];
}

- (void)creatPointsArrayWithRect15_7_7:(CGRect)rect withSecondWidth:(float)secondWidth andSecondHeight:(float)secondHeight
{
    [self.pointArray7 removeAllObjects];
    CGPoint p = CGPointMake(secondWidth, _image7.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _image7.size.height+secondHeight-rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height-rect.size.height);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(rect.size.width, _image7.size.height-rect.size.height+((_currentHeight-2*_gap)*0.9-_gap)*0.3);
    [self.pointArray7 addObject:[NSValue valueWithCGPoint:p]];
}

#pragma mark set selected or edit image
#pragma mark -- reselect image, or edit image
- (void)setSelectedImage:(UIImage*)image
{
    NSUInteger _selectedIndex = 0;
    
    for (NSUInteger i=0; i<_selectedImagesCount; i++) {
        ZBPosterCollageScrollView *_scrollView = (ZBPosterCollageScrollView*)[self viewWithTag:kPosterImageViewStartTag+i];
        if (_scrollView.isSelected) {
            _selectedIndex = i;
            _scrollView.isSelected = NO;
            break;
        }
    }
    
    switch (_selectedIndex) {
        case 0:
        {
            [self.selectedImagesArray replaceObjectAtIndex:0 withObject:image];
        }
            break;
        case 1:
        {
            [self.selectedImagesArray replaceObjectAtIndex:1 withObject:image];
        }
            break;
        case 2:
        {
            [self.selectedImagesArray replaceObjectAtIndex:2 withObject:image];
        }
            break;
        case 3:
        {
            [self.selectedImagesArray replaceObjectAtIndex:3 withObject:image];
        }
            break;
        case 4:
        {
            [self.selectedImagesArray replaceObjectAtIndex:4 withObject:image];
        }
            break;
        case 5:
        {
            [self.selectedImagesArray replaceObjectAtIndex:5 withObject:image];
        }
            break;
        case 6:
        {
            [self.selectedImagesArray replaceObjectAtIndex:6 withObject:image];
        }
            break;
        default:
            break;
    }
    
    [self selectAnTemplateWithImagesCount:_selectedImagesCount];
}


#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_isRegularTemplate && self.selectedImagesArray.count>1)
    {
        NSMutableArray *_pointArray = [[NSMutableArray alloc] initWithCapacity:2];
        CGPoint _currentOffset = scrollView.contentOffset;
        if (scrollView.tag == kPosterImageViewStartTag) {
            if (nil == self.pointArray1 || self.pointArray1.count<=0) {
                return;
            }
            for (NSUInteger i=0; i<self.pointArray1.count; i++) {
                NSValue *_value = [self.pointArray1 objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            ((ZBPosterCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_image1 withPoints:_pointArray];
        }
        else if(scrollView.tag == kPosterImageViewStartTag+1)
        {
            if (nil == self.pointArray2 || self.pointArray2.count<=0) {
                return;
            }
            for (NSUInteger i=0; i<self.pointArray2.count; i++) {
                NSValue *_value = [self.pointArray2 objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            ((ZBPosterCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_image2 withPoints:_pointArray];
        }
        else if(scrollView.tag == kPosterImageViewStartTag+2)
        {
            if (nil == self.pointArray3 || self.pointArray3.count<=0) {
                return;
            }
            for (NSUInteger i=0; i<self.pointArray3.count; i++) {
                NSValue *_value = [self.pointArray3 objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            ((ZBPosterCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_image3 withPoints:_pointArray];
        }
        else if(scrollView.tag == kPosterImageViewStartTag+3)
        {
            if (nil == self.pointArray4 || self.pointArray4.count<=0) {
                return;
            }
            for (NSUInteger i=0; i<self.pointArray4.count; i++) {
                NSValue *_value = [self.pointArray4 objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            ((ZBPosterCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_image4 withPoints:_pointArray];
        }
        else if(scrollView.tag == kPosterImageViewStartTag+4)
        {
            if (nil == self.pointArray5 || self.pointArray5.count<=0) {
                return;
            }
            for (NSUInteger i=0; i<self.pointArray5.count; i++) {
                NSValue *_value = [self.pointArray5 objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            ((ZBPosterCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_image5 withPoints:_pointArray];
        }
        else if(scrollView.tag == kPosterImageViewStartTag+5)
        {
            if (nil == self.pointArray6 || self.pointArray6.count<=0) {
                return;
            }
            for (NSUInteger i=0; i<self.pointArray6.count; i++) {
                NSValue *_value = [self.pointArray6 objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            ((ZBPosterCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_image6 withPoints:_pointArray];
        }
        else if(scrollView.tag == kPosterImageViewStartTag+6)
        {
            if (nil == self.pointArray7 || self.pointArray7.count<=0) {
                return;
            }
            for (NSUInteger i=0; i<self.pointArray7.count; i++) {
                NSValue *_value = [self.pointArray7 objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            ((ZBPosterCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_image7 withPoints:_pointArray];
        }
    }
}

//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return ((ZBPosterCollageScrollView*)scrollView).imageView;
//}
//
//- (void)scrollViewDidZoom:(UIScrollView *)scrollView
//{
//    if (!_isRegularTemplate && self.selectedImagesArray.count>1)
//        scrollView.contentOffset = CGPointZero;
//}
//
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
//{
//    if (scale<=1) {
//        return;
//    }
//    NSLog(@"scale %f,%@",scale,scrollView);
////    [scrollView setZoomScale:scale animated:NO];
//
//    _isGetOriginImage = NO;
//    //缩放操作中被调用
//    if (scrollView.tag == kPosterImageViewStartTag) {
//        
//        _image1 = [ImageUtil scaleImage:_image1 toScale:scale];
//        ((ZBPosterCollageScrollView*)scrollView).isSelected = YES;
//        [self setSelectedImage:_image1];
//        
//    }
//    else if(scrollView.tag == kPosterImageViewStartTag+1)
//    {
//        
//        _image2 = [ImageUtil scaleImage:_image2 toScale:scale];
//        ((ZBPosterCollageScrollView*)scrollView).isSelected = YES;
//        [self setSelectedImage:_image2];
//        
//    }
//    else if(scrollView.tag == kPosterImageViewStartTag+2)
//    {
//        _image3 = [ImageUtil scaleImage:_image3 toScale:scale];
//        ((ZBPosterCollageScrollView*)scrollView).isSelected = YES;
//        [self setSelectedImage:_image3];
//    }
//
//}



@end
