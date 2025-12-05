//
//  Card.m 
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "Card.h"

@implementation Card

@synthesize seq = _seq;
@synthesize layer = _layer;
@synthesize row = _row;
@synthesize col = _col;
@synthesize state = _state;
@synthesize no = _no;

- (id)initWithSeq:(int)theSeq layer:(int)z row:(int)y col:(int)x state:(int)st no:(int)n
{
    self = [super init];
    if (self) {
        _seq = theSeq;
        _layer = z;
        _row = y;
        _col = x;
        _state = st;
        _no = n;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_seq forKey:@"seq"];
    [aCoder encodeInteger:_no forKey:@"no"];
    [aCoder encodeInteger:_layer forKey:@"layer"];
    [aCoder encodeInteger:_row forKey:@"row"];
    [aCoder encodeInteger:_col forKey:@"col"];
    [aCoder encodeInteger:_state forKey:@"state"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _seq = [aDecoder decodeIntegerForKey:@"seq"];
        _no = [aDecoder decodeIntegerForKey:@"no"];
        _layer = [aDecoder decodeIntegerForKey:@"layer"];
        _row = [aDecoder decodeIntegerForKey:@"row"];
        _col = [aDecoder decodeIntegerForKey:@"col"];
        _state = [aDecoder decodeIntegerForKey:@"state"];
    }
    return self;
}

- (NSUInteger)hash {
    return _no;
}

- (BOOL)isEqual:(id)other {
    return _no == [other no];
}

- (BOOL)match:(Card*)other
{
    if (_seq == other.seq) {
        return YES;
    }
    else if (_seq >= 34 && _seq <= 37 && other.seq >= 34 && other.seq <= 37)
    {
        return YES;
    }
    else if (_seq >= 38 && _seq <= 41 && other.seq >= 38 && other.seq <= 41)
    {
        return YES;
    }
    else
        return NO;
}

- (void)swapXYZ:(Card*)other
{
    if (other != nil) {
        int sw = _layer;
        _layer = other.layer;
        other.layer = sw;
        sw = _row;
        _row = other.row;
        other.row = sw;
        sw = _col;
        _col = other.col;
        other.col = sw;
        sw = _state;
        _state = other.state;
        other.state = sw;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%d",_seq];
}

- (id)copyWithZone:(NSZone *)zone {
    Card *copy = [[Card allocWithZone:zone] initWithSeq:_seq layer:_layer row:_row col:_col state:_state no:_no];
    return copy;
}

- (void)assignWithCard:(Card*)other
{
    _seq = other.seq;
    _layer = other.layer;
    _row = other.row;
    _col = other.col;
    _state = other.state;
    _no = other.no;
}

@end
