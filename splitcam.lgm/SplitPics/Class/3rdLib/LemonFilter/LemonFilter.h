//
//  LemonFilter.h
//  LemonCamera
//
//  Created by shen on 14-7-30.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import "GPUImageThreeInputFilter.h"

@interface LemonFilter : GPUImageThreeInputFilter
{
    GPUImageFramebuffer *fourthInputFramebuffer;
    GLint filterFourthTextureCoordinateAttribute;
    GLint filterInputTextureUniform4;
    GPUImageRotationMode inputRotation4;
    CMTime fourthFrameTime;
    BOOL hasSetThirdTexture, hasReceivedFourthFrame, fourthFrameWasVideo;
    BOOL fourthFrameCheckDisabled;
    
    GPUImageFramebuffer *fifthInputFramebuffer;
    GLint filterFifthTextureCoordinateAttribute;
    GLint filterInputTextureUniform5;
    GPUImageRotationMode inputRotation5;
    CMTime fifthFrameTime;
    BOOL hasSetFouredTexture, hasReceivedFifthFrame, fifthFrameWasVideo;
    BOOL fifthFrameCheckDisabled;
    
    GPUImageFramebuffer *sixthInputFramebuffer;
    GLint filterSixthTextureCoordinateAttribute;
    GLint filterInputTextureUniform6;
    GPUImageRotationMode inputRotation6;
    CMTime sixthFrameTime;
    BOOL hasSetFifthTexture, hasReceivedSixthFrame, sixthFrameWasVideo;
    BOOL sixthFrameCheckDisabled;
    
    GPUImageFramebuffer *seventhInputFramebuffer;
    GLint filterSeventhTextureCoordinateAttribute;
    GLint filterInputTextureUniform7;
    GPUImageRotationMode inputRotation7;
    CMTime seventhFrameTime;
    BOOL hasSetSixthTexture, hasReceivedSeventhFrame, seventhFrameWasVideo;
    BOOL seventhFrameCheckDisabled;
    
    BOOL hasSetSeventhTexture;
}
- (void)disableSeventhFrameCheck;
@end
