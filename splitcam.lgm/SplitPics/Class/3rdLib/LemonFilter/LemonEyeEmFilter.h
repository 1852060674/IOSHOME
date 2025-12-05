//
//  LemonEyeEmFilter.h
//  LemonCamera
//
//  Created by shen on 14-8-4.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import "LemonFilter.h"

@interface LemonEyeEmFilter : LemonFilter
{
    GLint colorMapIndexUniform;
    GLint gradientIndexUniform;
    GLint frameBlendModeUniform;
}
@property (nonatomic, readwrite) NSInteger colorMapIndex;
@property (nonatomic, readwrite) NSInteger gradientIndex;
@property (nonatomic, readwrite) NSInteger blendMode;

@end
