//
//  LemonEyeEmFilter.m
//  LemonCamera
//
//  Created by shen on 14-8-4.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import "LemonEyeEmFilter.h"

NSString *const kLemonEyeEmShaderString = SHADER_STRING
(
 //
 //  Created by Travis Foster
 //  Copyright 2010 -. All rights reserved.
 //
 
#ifdef GL_ES
 // define default precision for float, vec, mat.
 precision mediump float;
#endif
 precision mediump float;

/*
 ** Photoshop & misc math
 ** Blending modes, RGB/HSL/Contrast/Desaturate, levels control
 **
 ** Romain Dura | Romz
 ** Blog: http://blog.mouaif.org
 ** Post: http://blog.mouaif.org/?p=94
 */
 
 
/*
 ** Desaturation
 */
 
 vec4 Desaturate(vec3 color, float Desaturation)
{
	vec3 grayXfer = vec3(0.3, 0.59, 0.11);
	vec3 gray = vec3(dot(grayXfer, color));
	return vec4(mix(color, gray, Desaturation), 1.0);
}
 
 
/*
 ** Hue, saturation, luminance
 */
 
 vec3 RGBToHSL(vec3 color)
{
	vec3 hsl; // init to 0 to avoid warnings ? (and reverse if + remove first part)
	
	float fmin = min(min(color.r, color.g), color.b);    //Min. value of RGB
	float fmax = max(max(color.r, color.g), color.b);    //Max. value of RGB
	float delta = fmax - fmin;             //Delta RGB value
	
	hsl.z = (fmax + fmin) / 2.0; // Luminance
	
	if (delta == 0.0)		//This is a gray, no chroma...
	{
		hsl.x = 0.0;	// Hue
		hsl.y = 0.0;	// Saturation
	}
	else                                    //Chromatic data...
	{
		if (hsl.z < 0.5)
			hsl.y = delta / (fmax + fmin); // Saturation
		else
			hsl.y = delta / (2.0 - fmax - fmin); // Saturation
		
		float deltaR = (((fmax - color.r) / 6.0) + (delta / 2.0)) / delta;
		float deltaG = (((fmax - color.g) / 6.0) + (delta / 2.0)) / delta;
		float deltaB = (((fmax - color.b) / 6.0) + (delta / 2.0)) / delta;
		
		if (color.r == fmax )
			hsl.x = deltaB - deltaG; // Hue
		else if (color.g == fmax)
			hsl.x = (1.0 / 3.0) + deltaR - deltaB; // Hue
		else if (color.b == fmax)
			hsl.x = (2.0 / 3.0) + deltaG - deltaR; // Hue
		
		if (hsl.x < 0.0)
			hsl.x += 1.0; // Hue
		else if (hsl.x > 1.0)
			hsl.x -= 1.0; // Hue
	}
	
	return hsl;
}
 
 float HueToRGB(float f1, float f2, float hue)
{
	if (hue < 0.0)
		hue += 1.0;
	else if (hue > 1.0)
		hue -= 1.0;
	float res;
	if ((6.0 * hue) < 1.0)
		res = f1 + (f2 - f1) * 6.0 * hue;
	else if ((2.0 * hue) < 1.0)
		res = f2;
	else if ((3.0 * hue) < 2.0)
		res = f1 + (f2 - f1) * ((2.0 / 3.0) - hue) * 6.0;
	else
		res = f1;
	return res;
}
 
 vec3 HSLToRGB(vec3 hsl)
{
	vec3 rgb;
	
	if (hsl.y == 0.0)
		rgb = vec3(hsl.z); // Luminance
	else
	{
		float f2;
		
		if (hsl.z < 0.5)
			f2 = hsl.z * (1.0 + hsl.y);
		else
			f2 = (hsl.z + hsl.y) - (hsl.y * hsl.z);
		
		float f1 = 2.0 * hsl.z - f2;
		
		rgb.r = HueToRGB(f1, f2, hsl.x + (1.0/3.0));
		rgb.g = HueToRGB(f1, f2, hsl.x);
		rgb.b = HueToRGB(f1, f2, hsl.x - (1.0/3.0));
	}
	
	return rgb;
}
 
 
/*
 ** Contrast, saturation, brightness
 ** Code of this function is from TGM's shader pack
 ** http://irrlicht.sourceforge.net/phpBB2/viewtopic.php?t=21057
 */
 
 // For all settings: 1.0 = 100% 0.5=50% 1.5 = 150%
 vec3 ContrastSaturationBrightness(vec3 color, float brt, float sat, float con)
{
	// Increase or decrease theese values to adjust r, g and b color channels seperately
	const float AvgLumR = 0.5;
	const float AvgLumG = 0.5;
	const float AvgLumB = 0.5;
	
	const vec3 LumCoeff = vec3(0.2125, 0.7154, 0.0721);
	
	vec3 AvgLumin = vec3(AvgLumR, AvgLumG, AvgLumB);
	vec3 brtColor = color * brt;
	vec3 intensity = vec3(dot(brtColor, LumCoeff));
	vec3 satColor = mix(intensity, brtColor, sat);
	vec3 conColor = mix(AvgLumin, satColor, con);
	return conColor;
}
 
 
/*
 ** Float blending modes
 ** Adapted from here: http://www.nathanm.com/photoshop-blending-math/
 ** But I modified the HardMix (wrong condition), Overlay, SoftLight, ColorDodge, ColorBurn, VividLight, PinLight (inverted layers) ones to have correct results
 */
 
#define BlendLinearDodgef 			BlendAddf
#define BlendLinearBurnf 			BlendSubstractf
#define BlendAddf(base, blend) 		min(base + blend, 1.0)
#define BlendSubstractf(base, blend) 	max(base + blend - 1.0, 0.0)
#define BlendLightenf(base, blend) 		max(blend, base)
#define BlendDarkenf(base, blend) 		min(blend, base)
#define BlendLinearLightf(base, blend) 	(blend < 0.5 ? BlendLinearBurnf(base, (2.0 * blend)) : BlendLinearDodgef(base, (2.0 * (blend - 0.5))))
#define BlendScreenf(base, blend) 		(1.0 - ((1.0 - base) * (1.0 - blend)))
#define BlendOverlayf(base, blend) 	(base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)))
 
#define BlendSoftLightf(base, blend) 	((blend < 0.5) ? (2.0 * base * blend + base * base * (1.0 - 2.0 * blend)) : (sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend)))
#define BlendColorDodgef(base, blend) 	((blend == 1.0) ? blend : min(base / (1.0 - blend), 1.0))
#define BlendColorBurnf(base, blend) 	((blend == 0.0) ? blend : max((1.0 - ((1.0 - base) / blend)), 0.0))
#define BlendVividLightf(base, blend) 	((blend < 0.5) ? BlendColorBurnf(base, (2.0 * blend)) : BlendColorDodgef(base, (2.0 * (blend - 0.5))))
#define BlendPinLightf(base, blend) 	((blend < 0.5) ? BlendDarkenf(base, (2.0 * blend)) : BlendLightenf(base, (2.0 *(blend - 0.5))))
#define BlendHardMixf(base, blend) 	((BlendVividLightf(base, blend) < 0.5) ? 0.0 : 1.0)
#define BlendReflectf(base, blend) 		((blend == 1.0) ? blend : min(base * base / (1.0 - blend), 1.0))
 
 
/*
 ** Vector3 blending modes
 */
 
 // Component wise blending
#define Blend(base, blend, funcf) 		vec3(funcf(base.r, blend.r), funcf(base.g, blend.g), funcf(base.b, blend.b))
 
 
#define BlendNormal(base, blend) 		(blend)
#define BlendLighten				BlendLightenf
#define BlendDarken				BlendDarkenf
#define BlendMultiply(base, blend) 		(base * blend)
#define BlendAverage(base, blend) 		((base + blend) / 2.0)
#define BlendAdd(base, blend) 		min(base + blend, vec3(1.0))
#define BlendSubstract(base, blend) 	max(base + blend - vec3(1.0), vec3(0.0))
#define BlendDifference(base, blend) 	abs(base - blend)
#define BlendNegation(base, blend) 	(vec3(1.0) - abs(vec3(1.0) - base - blend))
#define BlendExclusion(base, blend) 	(base + blend - 2.0 * base * blend)
 
#define BlendScreen(base, blend) 		Blend(base, blend, BlendScreenf)
#define BlendOverlay(base, blend) 		Blend(base, blend, BlendOverlayf)
 
#define BlendSoftLight(base, blend) 	Blend(base, blend, BlendSoftLightf)
#define BlendHardLight(base, blend) 	BlendOverlay(blend, base)
#define BlendColorDodge(base, blend) 	Blend(base, blend, BlendColorDodgef)
#define BlendColorBurn(base, blend) 	Blend(base, blend, BlendColorBurnf)
#define BlendLinearDodge			BlendAdd
#define BlendLinearBurn			BlendSubstract
 // Linear Light is another contrast-increasing mode
 // If the blend color is darker than midgray, Linear Light darkens the image by decreasing the brightness. If the blend color is lighter than midgray, the result is a brighter image due to increased brightness.
#define BlendLinearLight(base, blend) 	Blend(base, blend, BlendLinearLightf)
#define BlendVividLight(base, blend) 	Blend(base, blend, BlendVividLightf)
#define BlendPinLight(base, blend) 		Blend(base, blend, BlendPinLightf)
#define BlendHardMix(base, blend) 		Blend(base, blend, BlendHardMixf)
#define BlendReflect(base, blend) 		Blend(base, blend, BlendReflectf)
#define BlendGlow(base, blend) 		BlendReflect(blend, base)
#define BlendPhoenix(base, blend) 		(min(base, blend) - max(base, blend) + vec3(1.0))
#define BlendOpacity(base, blend, F, O) 	(F(base, blend) * O + blend * (1.0 - O))
 
 
 // Hue Blend mode creates the result color by combining the luminance and saturation of the base color with the hue of the blend color.
 vec3 BlendHue(vec3 base, vec3 blend)
{
	vec3 baseHSL = RGBToHSL(base);
	return HSLToRGB(vec3(RGBToHSL(blend).r, baseHSL.g, baseHSL.b));
}
 
 // Saturation Blend mode creates the result color by combining the luminance and hue of the base color with the saturation of the blend color.
 vec3 BlendSaturation(vec3 base, vec3 blend)
{
	vec3 baseHSL = RGBToHSL(base);
	return HSLToRGB(vec3(baseHSL.r, RGBToHSL(blend).g, baseHSL.b));
}
 
 // Color Mode keeps the brightness of the base color and applies both the hue and saturation of the blend color.
 vec3 BlendColor(vec3 base, vec3 blend)
{
	vec3 blendHSL = RGBToHSL(blend);
	return HSLToRGB(vec3(blendHSL.r, blendHSL.g, RGBToHSL(base).b));
}
 
 // Luminosity Blend mode creates the result color by combining the hue and saturation of the base color with the luminance of the blend color.
 vec3 BlendLuminosity(vec3 base, vec3 blend)
{
	vec3 baseHSL = RGBToHSL(base);
	return HSLToRGB(vec3(baseHSL.r, baseHSL.g, RGBToHSL(blend).b));
}
 
 
/*
 ** Gamma correction
 ** Details: http://blog.mouaif.org/2009/01/22/photoshop-gamma-correction-shader/
 */
 
#define GammaCorrection(color, gamma)								pow(color, 1.0 / gamma)
 
/*
 ** Levels control (input (+gamma), output)
 ** Details: http://blog.mouaif.org/2009/01/28/levels-control-shader/
 */
 
#define LevelsControlInputRange(color, minInput, maxInput)				min(max(color - vec3(minInput), vec3(0.0)) / (vec3(maxInput) - vec3(minInput)), vec3(1.0))
#define LevelsControlInput(color, minInput, gamma, maxInput)				GammaCorrection(LevelsControlInputRange(color, minInput, maxInput), gamma)
#define LevelsControlOutputRange(color, minOutput, maxOutput) 			mix(vec3(minOutput), vec3(maxOutput), color)
#define LevelsControl(color, minInput, gamma, maxInput, minOutput, maxOutput) 	LevelsControlOutputRange(LevelsControlInput(color, minInput, gamma, maxInput), minOutput, maxOutput)
 
 
#define kLookupStripColorHeight  5.0
#define kLookupStripsCount      24.0
#define kLookupStripsTotalHeight 360.0
#define kNormalizedChannelStripHeight (kLookupStripColorHeight / (3.0 * kLookupStripColorHeight * kLookupStripsCount))
 vec4 colorFromMap(vec3 color, sampler2D lookup, float index)
{
	float selector_r = (1.0 / kLookupStripsCount * (index - 1.0) ) + (1.0 * kNormalizedChannelStripHeight - (kLookupStripColorHeight / 2.0 / kLookupStripsTotalHeight));
	float selector_g = (1.0 / kLookupStripsCount * (index - 1.0) ) + (2.0 * kNormalizedChannelStripHeight - (kLookupStripColorHeight / 2.0 / kLookupStripsTotalHeight));
	float selector_b = (1.0 / kLookupStripsCount * (index - 1.0) ) + (3.0 * kNormalizedChannelStripHeight - (kLookupStripColorHeight / 2.0 / kLookupStripsTotalHeight));
    
	float r = texture2D(lookup, vec2(color.r, selector_r)).r;
	float g = texture2D(lookup, vec2(color.g, selector_g)).g;
	float b = texture2D(lookup, vec2(color.b, selector_b)).b;
    
	return vec4(r, g, b, 1.0);
}
 
 vec2 coordsForPackedTexture(vec2 texCoords, float texturePosition)
{
	float n = 3.0;
	float posX =  mod(texturePosition, n) / n;
	float posY =  floor(texturePosition / n) / n;
    
	return vec2(posX + texCoords.x / n, posY + texCoords.y / n);
}
 
 vec4 blend(vec4 overlying, vec4 underlying) {
     vec3 blended = overlying.rgb + ((1.0 - overlying.a) * underlying.rgb);
     float alpha   = underlying.a + (1.0 - underlying.a)*overlying.a;
     return vec4(blended, alpha);
 }
 
// precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; //look_up;
 uniform sampler2D inputImageTexture3; //gradient;
 uniform sampler2D inputImageTexture4; //frame;
 
 uniform float colorMapIndex;
 uniform float gradientIndex;
 uniform int photoFrameBlendMode;

 void main()
{
//    highp int photoFrameBlendMode=0;
	// 1 Photo
	highp vec4 pass001   = texture2D(inputImageTexture, textureCoordinate.xy).rgba;
	
	// 2 Texture C+F overlay 60%
//	highp vec2 texCF_coords = coordsForPackedTexture(textureCoordinate.xy, gradientIndex);
//	highp vec4 texCF_layer = texture2D(inputImageTexture3, texCF_coords).rgba;
//	highp vec3 overlay      = BlendOverlay(pass001, texCF_layer);
//	highp vec3 pass020      = mix(vec3(pass001), overlay, 0.30);
    
	// 3 Color map
	highp float index = colorMapIndex;
	highp vec4 pass030 = colorFromMap(pass001.xyz, inputImageTexture2, index);
	
	// Frame
//    highp vec4 frameLayer = texture2D(inputImageTexture4, textureCoordinate.xy).rgba;
    
	highp vec4 final;
    final = pass030;
//	if (photoFrameBlendMode == 0) {
//		final = pass030;
//	} else if (photoFrameBlendMode == 1) {
//		final = blend(frameLayer, pass030);
//	} else if (photoFrameBlendMode == 2) {
//		final = BlendMultiply(pass030, frameLayer);
//	}
	
	// Final
	gl_FragColor = final;
}
 );

@implementation LemonEyeEmFilter
- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kLemonEyeEmShaderString]))
    {
		return nil;
    }
    
    colorMapIndexUniform = [filterProgram uniformIndex:@"colorMapIndex"];
    gradientIndexUniform = [filterProgram uniformIndex:@"gradientIndex"];
    frameBlendModeUniform = [filterProgram uniformIndex:@"photoFrameBlendMode"];
    
    self.colorMapIndex = 0;
    self.gradientIndex = 4;
    self.blendMode = 0;
    return self;
}
#define COLOR_MAP_COUNT 24
-(void)setColorMapIndex:(NSInteger)colorMapIndex
{
    colorMapIndex = MAX(1, MIN(colorMapIndex, COLOR_MAP_COUNT));
    _colorMapIndex = colorMapIndex;
    [self setFloat:_colorMapIndex*1.0 forUniform:colorMapIndexUniform program:filterProgram];
}
#define GRADIENT_COUNT 9
-(void)setGradientIndex:(NSInteger)gradientIndex
{
    _gradientIndex = MAX(0, MIN(gradientIndex, GRADIENT_COUNT-1));
    [self setFloat:_gradientIndex*1.0 forUniform:gradientIndexUniform program:filterProgram];
}

#define BLEND_MODE_COUNT 3
-(void)setBlendMode:(NSInteger)blendMode
{
    _blendMode = MAX(0, MIN(blendMode, BLEND_MODE_COUNT-1));
    [self setInteger:(GLint)_blendMode forUniform:frameBlendModeUniform program:filterProgram];
}
@end
