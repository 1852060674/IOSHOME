//
//  GPUImageSufaceSmoothFilter.m
//  Plastic Surgeon
//
//  Created by ZB_Mac on 15/12/28.
//  Copyright © 2015年 ZB_Mac. All rights reserved.
//

#import "GPUImageSufaceSmoothFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageThreholdFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;

 uniform highp float threhold;
 uniform highp float xOffset;
 uniform highp float yOffset;
 uniform highp float strenght;
 
 const int RADIUS = 4;

 void main()
 {
     mediump vec3 textureColor = texture2D(inputImageTexture, textureCoordinate).rgb;
     mediump vec3 textureColor_2;

     mediump vec3 colorSum = vec3(0.0);
     mediump vec3 weightSum = vec3(0.0);
     
     mediump vec3 weight = vec3(1.0);
     for (int i=-RADIUS; i<=RADIUS; ++i)
     {
         for (int j=-RADIUS; j<=RADIUS; ++j)
         {
             textureColor_2 = texture2D(inputImageTexture, textureCoordinate+vec2(xOffset*float(i), yOffset*float(j))).rgb;
             weight = clamp(vec3(0.0), vec3(1.0)-abs(textureColor-textureColor_2)/vec3(threhold), vec3(1.0));
             
             weightSum = weightSum+weight;
             colorSum = colorSum+textureColor_2*weight;
         }
     }
     
     textureColor_2 = colorSum/weightSum;
//     textureColor_2 = mix(vec3(1.0)-(vec3(1.0)-textureColor_2)*(vec3(1.0)-textureColor_2), textureColor_2, 0.4);
     mediump vec3 highPass = (textureColor-textureColor_2)*((1.0-strenght)*0.5+0.5)+0.5;
//     mediump vec3 highPass = (textureColor-textureColor_2)+0.5;
//     highPass = (1.0-2.0*highPass)*highPass*highPass+2.0*highPass*highPass;
//     textureColor_2 = mix(textureColor_2, (1.0-2.0*textureColor_2)*textureColor_2*textureColor_2+2.0*textureColor_2*textureColor_2, 0.325);
     textureColor_2 = (1.0-2.0*highPass)*textureColor_2*textureColor_2+2.0*textureColor_2*highPass;
     
     gl_FragColor = vec4(mix(textureColor, textureColor_2, strenght), 1.0);
 }
 );
#else
NSString *const kGPUImageThreholdFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform float threhold;
 uniform float xOffset;
 uniform float yOffset;
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     gl_FragColor = vec4(textureColor.rgb * pow(2.0, exposure), textureColor.w);
 }
 );
#endif

@interface GPUImageSufaceSmoothFilter ()
{

}
@end

@implementation GPUImageSufaceSmoothFilter

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageThreholdFragmentShaderString]))
    {
        return nil;
    }
    
    threholdUniform = [filterProgram uniformIndex:@"threhold"];

    self.threhold = 20.0;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setThrehold:(CGFloat)threhold
{
    _threhold = threhold;
    
    [self setFloat:_threhold*2.5/255.0 forUniform:threholdUniform program:filterProgram];
}

-(void)setXOffset:(CGFloat)xOffset
{
    _xOffset = xOffset;
    
    [self setFloat:_xOffset forUniformName:@"xOffset"];
}

-(void)setYOffset:(CGFloat)yOffset
{
    _yOffset = yOffset;
    
    [self setFloat:_yOffset forUniformName:@"yOffset"];
}

-(void)setStrenght:(CGFloat)strenght
{
    _strenght = strenght;
    
    [self setFloat:_strenght forUniformName:@"strenght"];
}

@end
