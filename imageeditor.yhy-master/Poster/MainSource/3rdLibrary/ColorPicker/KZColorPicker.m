//
//  KZColorWheelView.m
//
//  Created by Alex Restrepo on 5/11/11.
//  Copyright 2011 KZLabs http://kzlabs.me
//  All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KZColorPicker.h"
#import "KZColorPickerHSWheel.h"
#import "KZColorPickerBrightnessSlider.h"
#import "KZColorPickerAlphaSlider.h"
#import "HSV.h"
#import "UIColor-Expanded.h"
#import "KZColorPickerSwatchView.h"
#import "KZColorCompareView.h"
#import "ZBCommonDefine.h"

@interface KZColorPicker()
{
    float _buttonEdge;
}
@property (nonatomic, strong) KZColorPickerHSWheel *colorWheel;
@property (nonatomic, strong) KZColorPickerBrightnessSlider *brightnessSlider;
@property (nonatomic, strong) KZColorPickerAlphaSlider *alphaSlider;
@property (nonatomic, strong) KZColorCompareView *currentColorView;
@property (nonatomic, strong) NSMutableArray *swatches;
- (void) fixLocations;
@end


@implementation KZColorPicker
@synthesize colorWheel;
@synthesize brightnessSlider;
@synthesize selectedColor = _selectedColor;
@synthesize alphaSlider;
@synthesize swatches;
@synthesize oldColor = _oldColor;
@synthesize currentColorView = _currentColorView;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) 
	{
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
        
        float _wheelX = 5;
        float _sliderWidth = 0;
        float _sliderHeight = 0;
        float _brightnessSliderY = 0;
        float _alphaSliderY = 0;
        
        if (IS_IPAD) {
            _sliderWidth = self.frame.size.width-60;
            _brightnessSliderY = 285;
            _alphaSliderY = 330;
            _sliderHeight = 40;
            _buttonEdge = 80;
            _wheelX = 20;
        }
        else
        {
            _sliderWidth = self.frame.size.width-60;
            _brightnessSliderY = 145;
            _alphaSliderY = 165;
            _sliderHeight = 20;
            _buttonEdge = 40;
        }
        // HS wheel
        KZColorPickerHSWheel *wheel = [[KZColorPickerHSWheel alloc] initAtOrigin:CGPointMake(_wheelX, 5)];
        [wheel addTarget:self action:@selector(colorWheelColorChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:wheel];
        self.colorWheel = wheel;
        
        // brightness slider
        KZColorPickerBrightnessSlider *slider = [[KZColorPickerBrightnessSlider alloc] initWithFrame:CGRectMake(2,
                                                                                                                _brightnessSliderY,
                                                                                                                _sliderWidth,
                                                                                                                _sliderHeight)];
        [slider addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:slider];
        self.brightnessSlider = slider;
        
        // alpha slider
        KZColorPickerAlphaSlider *alpha = [[KZColorPickerAlphaSlider alloc] initWithFrame:CGRectMake(2,
                                                                                                     _alphaSliderY,
                                                                                                     _sliderWidth,
                                                                                                     _sliderHeight)];
        [alpha addTarget:self action:@selector(alphaChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:alpha];
        self.alphaSlider = alpha;
        
        // current color indicator hier.
        KZColorCompareView *colorView = [[KZColorCompareView alloc] initWithFrame:CGRectMake(self.frame.size.width-10-_buttonEdge, 10, _buttonEdge, _buttonEdge)];
        //    [colorView addTarget:self action:@selector(oldColor:) forControlEvents:UIControlEventTouchUpInside];
        //    colorView.oldColor = self.oldColor;
        self.currentColorView = colorView;
        [self addSubview:colorView];
        
        
        KZColorPickerSwatchView *swatch = nil;
        self.swatches = [NSMutableArray array];
        swatch = [[KZColorPickerSwatchView alloc] initWithFrame:CGRectZero];
        swatch.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1]; //添加白色
        [swatch addTarget:self action:@selector(swatchAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:swatch];
        [swatches addObject:swatch];
        
        swatch = [[KZColorPickerSwatchView alloc] initWithFrame:CGRectZero];
        swatch.color = [UIColor colorWithRed:0 green:0 blue:0 alpha:1]; //添加黑色
        [swatch addTarget:self action:@selector(swatchAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:swatch];
        [swatches addObject:swatch];
        
        self.selectedColor = [UIColor whiteColor];//[UIColor colorWithRed:0.349 green:0.613 blue:0.378 alpha:1.000];
        [self fixLocations];
    }
    return self;
}

- (void)dealloc 
{

}

RGBType rgbWithUIColor(UIColor *color)
{
	const CGFloat *components = CGColorGetComponents(color.CGColor);
	
	CGFloat r,g,b;
	
	switch (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor))) 
	{
		case kCGColorSpaceModelMonochrome:
			r = g = b = components[0];
			break;
		case kCGColorSpaceModelRGB:
			r = components[0];
			g = components[1];
			b = components[2];
			break;
		default:	// We don't know how to handle this model
			return RGBTypeMake(0, 0, 0);
	}
	
	return RGBTypeMake(r, g, b);
}

- (void) setSelectedColor:(UIColor *)color animated:(BOOL)animated
{
	if (animated) 
	{
		[UIView beginAnimations:nil context:nil];
		self.selectedColor = color;
		[UIView commitAnimations];
	}
	else 
	{
		self.selectedColor = color;
	}
}
//- (void) setOldColor:(UIColor *)col
//{
//    [col retain];
//    [_oldColor release];
//    
//    _oldColor = col;
//    self.currentColorView.oldColor = _oldColor;
//}

- (void) setSelectedColor:(UIColor *)c
{
//	[c retain];
//	[sselectedColor release];
	_selectedColor = c;
	
	RGBType rgb = rgbWithUIColor(c);
	HSVType hsv = RGB_to_HSV(rgb);
	
	self.colorWheel.currentHSV = hsv;
	self.brightnessSlider.value = hsv.v;
    self.alphaSlider.value = [c alpha];
	
    UIColor *keyColor = [UIColor colorWithHue:hsv.h 
                                   saturation:hsv.s
                                   brightness:1.0
                                        alpha:1.0];
	[self.brightnessSlider setKeyColor:keyColor];
    
    keyColor = [UIColor colorWithHue:hsv.h 
                          saturation:hsv.s
                          brightness:hsv.v
                               alpha:1.0];
    [self.alphaSlider setKeyColor:keyColor];
	
	self.currentColorView.currentColor = c;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) colorWheelColorChanged:(KZColorPickerHSWheel *)wheel
{
	HSVType hsv = wheel.currentHSV;
	self.selectedColor = [UIColor colorWithHue:hsv.h
									saturation:hsv.s
									brightness:self.brightnessSlider.value
										 alpha:self.alphaSlider.value];		
	
	//[self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) brightnessChanged:(KZColorPickerBrightnessSlider *)slider
{
	HSVType hsv = self.colorWheel.currentHSV;
	
	self.selectedColor = [UIColor colorWithHue:hsv.h
									saturation:hsv.s
									brightness:self.brightnessSlider.value
										 alpha:self.alphaSlider.value];
	
	//[self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) alphaChanged:(KZColorPickerAlphaSlider *)slider
{
	HSVType hsv = self.colorWheel.currentHSV;
	
	self.selectedColor = [UIColor colorWithHue:hsv.h
									saturation:hsv.s
									brightness:self.brightnessSlider.value
										 alpha:self.alphaSlider.value];
	
	//[self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) swatchAction:(KZColorPickerSwatchView *)sender
{
	[self setSelectedColor:sender.color animated:YES];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) fixLocations
{
    int sx = self.frame.size.width-10-_buttonEdge;
    int sy = 20+_buttonEdge;
    for (KZColorPickerSwatchView *swatch in self.swatches)
    {
        swatch.frame = CGRectMake(sx, sy, _buttonEdge, _buttonEdge);
        sy += 10+_buttonEdge;
    }

}

- (void) layoutSubviews
{
    [UIView beginAnimations:nil context:nil];
    
    [self fixLocations];
    
    [UIView commitAnimations];
}

@end
