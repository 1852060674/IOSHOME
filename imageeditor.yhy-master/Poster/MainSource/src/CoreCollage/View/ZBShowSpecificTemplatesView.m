//
//  ZBShowSpecificTemplatesView.m
//  Collage
//
//  Created by shen on 13-6-25.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBShowSpecificTemplatesView.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"
#import "BHPromptFrameView.h"
#import "ZBButtonWithImageName.h"
#import "ZBCommonMethod.h"
#import "ZBColorDefine.h"

@interface ZBShowSpecificTemplatesView()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    NSUInteger _templateButtonEdge;
    NSUInteger _templateButtonGap;
    NSInteger _originY;
    float _scrollViewHeight;
    float _segmentItemWidth;
    float _segmentWidth;
}

@property (nonatomic, strong)NSMutableArray *templateImageName;

@end

@implementation ZBShowSpecificTemplatesView

@synthesize delegate;
@synthesize currentTemplateCount;
@synthesize templateImageName;

- (void)dealloc
{
    for (UIView *_aView in [_scrollView subviews]) {
        [_aView removeFromSuperview];
    }
    _scrollView.delegate = nil;
}

- (id)initWithFrame:(CGRect)frame withSelectedImagesCount:(NSUInteger)imagesCount
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.currentTemplateCount = imagesCount;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            _scrollViewHeight = 80;
            _templateButtonEdge = 44;
            _templateButtonGap = 6;
            _originY = 8;
            _segmentItemWidth = 75;
            _segmentWidth = kBottomBarWidth;
        }
        else
        {
            _scrollViewHeight = 110;
            _templateButtonEdge = 70;
            _templateButtonGap  = 10;
            _originY = 10;
            _segmentItemWidth = 100;
            _segmentWidth = 400;
        }
        
        self.templateImageName = [[NSMutableArray alloc] initWithCapacity:1];
        
        
        BHPromptFrameView *_promptFrame = [[BHPromptFrameView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.frame.size.height)];
        _promptFrame.arrowDirection = 2;
        _promptFrame.arrowPosition = 0;
        _promptFrame.arrowPoint = CGPointMake((kScreenWidth-_segmentWidth)/2+0.5*_segmentItemWidth, frame.size.height);
        _promptFrame.cornerRadius = 3;
        _promptFrame.baseColor = kPromptFrameViewBaseColor;
        
        [self addSubview:_promptFrame];
        
        self.backgroundColor = kTransparentColor;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, _scrollViewHeight)];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = kTransparentColor;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        [self loadTemplates];
    }
    return self;
}

- (void)loadTemplates
{
    NSUInteger _imageStartIndex = 0;
    [self.templateImageName removeAllObjects];
    switch (self.currentTemplateCount) {
        case 1:
        {
            [self.templateImageName addObject:@"template1_1"];
            
        }
            break;
        case 2:
        {
            if ([ZBCommonMethod isShowRegularTemplateInFont]) {
                for (NSUInteger i=0; i<kTemplateTwoCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template2_%d",i+1]];
                }
            }
            else
            {
                for (NSUInteger i=0; i<kIrregularTemplateTwoCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template2_%d",i+1+kRegularTemplateTwoCount]];
                }
                for (NSUInteger i=0; i<kRegularTemplateTwoCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template2_%d",i+1]];
                }
            }
            
            _imageStartIndex=kTemplateOneCount;
            
        }
            break;
        case 3:
        {
            if ([ZBCommonMethod isShowRegularTemplateInFont]) {
                for (NSUInteger i=0; i<kTemplateThreeCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template3_%d", i+1]];
                }
            }
            else
            {
                for (NSUInteger i=0; i<kIrregularTemplateThreeCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template3_%d",i+1+kRegularTemplateThreeCount]];
                }
                for (NSUInteger i=0; i<kRegularTemplateThreeCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template3_%d",i+1]];
                }
            }
            
            _imageStartIndex=kTemplateOneCount+kTemplateTwoCount;
            
        }
            break;
        case 4:
        {
            if ([ZBCommonMethod isShowRegularTemplateInFont]) {
                for (NSUInteger i=0; i<kTemplateFourCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template4_%d",i+1]];
                }
            }
            else
            {
                for (NSUInteger i=0; i<kIrregularTemplateFourCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template4_%d",i+1+kRegularTemplateFourCount]];
                }
                for (NSUInteger i=0; i<kRegularTemplateFourCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template4_%d",i+1]];
                }
            }
            
            _imageStartIndex=kTemplateOneCount+kTemplateTwoCount+kTemplateThreeCount;
        }
            break;
        case 5:
        {
            if ([ZBCommonMethod isShowRegularTemplateInFont])
            {
                for (NSUInteger i=0; i<kTemplateFiveCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template5_%d",i+1]];
                }
            }
            else
            {
                for (NSUInteger i=0; i<kIrregularTemplateFiveCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template5_%d",i+1+kRegularTemplateFiveCount]];
                }
                for (NSUInteger i=0; i<kRegularTemplateFiveCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template5_%d",i+1]];
                }
            }
            
            _imageStartIndex=kTemplateOneCount+kTemplateTwoCount+kTemplateThreeCount+kTemplateFourCount;
        }
            break;
        case 6:
        {
            if ([ZBCommonMethod isShowRegularTemplateInFont])
            {
                for (NSUInteger i=0; i<kTemplateSixCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template6_%d",i+1]];
                }
            }
            else
            {
                for (NSUInteger i=0; i<kIrregularTemplateSixCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template6_%d",i+1+kRegularTemplateSixCount]];
                }
                for (NSUInteger i=0; i<kRegularTemplateSixCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template6_%d",i+1]];
                }
            }
            
            _imageStartIndex=kTemplateOneCount+kTemplateTwoCount+kTemplateThreeCount+kTemplateFourCount+kTemplateFiveCount;
        }
            break;
        case 7:
        {
            if ([ZBCommonMethod isShowRegularTemplateInFont])
            {
                for (NSUInteger i=0; i<kTemplateSevenCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template7_%d",i+1]];
                }
            }
            else
            {
                for (NSUInteger i=0; i<kIrregularTemplateSevenCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template7_%d",i+1+kRegularTemplateSevenCount]];
                }
                for (NSUInteger i=0; i<kRegularTemplateSevenCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template7_%d",i+1]];
                }
            }
            _imageStartIndex=kTemplateOneCount+kTemplateTwoCount+kTemplateThreeCount+kTemplateFourCount+kTemplateFiveCount+kTemplateSixCount;
        }
            break;
        default:
        {
            if ([ZBCommonMethod isShowRegularTemplateInFont])
            {
                for (NSUInteger i=0; i<kTemplateSevenCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template7_%d",i+1]];
                }
            }
            else
            {
                for (NSUInteger i=0; i<kIrregularTemplateSevenCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template7_%d",i+1+kRegularTemplateSevenCount]];
                }
                for (NSUInteger i=0; i<kRegularTemplateSevenCount; i++) {
                    [self.templateImageName addObject:[NSString stringWithFormat:@"template7_%d",i+1]];
                }
            }
            _imageStartIndex=kTemplateOneCount+kTemplateTwoCount+kTemplateThreeCount+kTemplateFourCount+kTemplateFiveCount+kTemplateSixCount;
        }
            break;
    }
    
    for (NSInteger i=0; i<self.templateImageName.count; i++)
    {
        ZBButtonWithImageName *_templateButton = [ZBButtonWithImageName buttonWithType:UIButtonTypeCustom];
        _templateButton.frame = CGRectMake((_templateButtonEdge+_templateButtonGap)*i+_templateButtonGap, _originY, _templateButtonEdge, _templateButtonEdge);
        NSString *_imageName = [self.templateImageName objectAtIndex:i];
        _templateButton.imageName = _imageName;
        
        
        if ([ZBCommonMethod isShowRegularTemplateInFont])
        {
            _templateButton.templateIndex = _imageStartIndex+i;
        }
        else
        {
            switch (self.currentTemplateCount)
            {
                case 2:
                {
                    if (i<kIrregularTemplateTwoCount) {
                        _templateButton.templateIndex = _imageStartIndex+i+kRegularTemplateTwoCount;
                    }
                        
                    if (i>=kIrregularTemplateTwoCount) {
                        _templateButton.templateIndex = _imageStartIndex+i-kIrregularTemplateTwoCount;
                    }
                }
                    break;
                case 3:
                {
                    if (i<kIrregularTemplateThreeCount) {
                        _templateButton.templateIndex = _imageStartIndex+i+kRegularTemplateThreeCount;
                    }
                    
                    if (i>=kIrregularTemplateThreeCount) {
                        _templateButton.templateIndex = _imageStartIndex+i-kIrregularTemplateThreeCount;
                    }
                }
                    break;
                case 4:
                {
                    if (i<kIrregularTemplateFourCount) {
                        _templateButton.templateIndex = _imageStartIndex+i+kRegularTemplateFourCount;
                    }
                    
                    if (i>=kIrregularTemplateFourCount) {
                        _templateButton.templateIndex = _imageStartIndex+i-kIrregularTemplateFourCount;
                    }
                }
                    break;
                case 5:
                {
                    if (i<kIrregularTemplateFiveCount) {
                        _templateButton.templateIndex = _imageStartIndex+i+kRegularTemplateFiveCount;
                    }
                    
                    if (i>=kIrregularTemplateFiveCount) {
                        _templateButton.templateIndex = _imageStartIndex+i-kIrregularTemplateFiveCount;
                    }
                }
                    break;
                case 6:
                {
                    if (i<kIrregularTemplateSixCount) {
                        _templateButton.templateIndex = _imageStartIndex+i+kRegularTemplateSixCount;
                    }
                    
                    if (i>=kIrregularTemplateSixCount) {
                        _templateButton.templateIndex = _imageStartIndex+i-kIrregularTemplateSixCount;
                    }
                }
                    break;
                case 7:
                {
                    if (i<kIrregularTemplateSevenCount) {
                        _templateButton.templateIndex = _imageStartIndex+i+kRegularTemplateSevenCount;
                    }
                    
                    if (i>=kIrregularTemplateSevenCount) {
                        _templateButton.templateIndex = _imageStartIndex+i-kIrregularTemplateSevenCount;
                    }
                }
                    break;
                default:
                    break;
            }
        }
        [_templateButton setImage:[ImageUtil loadResourceImage:_imageName] forState:UIControlStateNormal];
        [_templateButton addTarget:self action:@selector(changeTemplate:) forControlEvents:UIControlEventTouchUpInside];
        _templateButton.tag = kTemplateButtonStartTag+i;
        [_scrollView addSubview:_templateButton];
    }
    _scrollView.contentSize = CGSizeMake(self.templateImageName.count*(_templateButtonEdge+_templateButtonGap)+_templateButtonGap,  _scrollViewHeight);
}

- (void)changeTemplate:(id)sender
{
    ZBButtonWithImageName *_button = (ZBButtonWithImageName*)sender;
//    NSString *_selectedImageName = _button.imageName;
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedATemplate:)]) {
        [self.delegate selectedATemplate:_button.templateIndex];
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
