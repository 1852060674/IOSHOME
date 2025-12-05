//
//  MoveAction.m
//  Solitaire
//
//  Created by apple on 13-7-3.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "MoveAction.h"

@implementation MoveAction 

@synthesize act = _act;
@synthesize from = _from;
@synthesize to = _to;
@synthesize cardcnt = _cardcnt;
@synthesize fromIdx = _fromIdx;
@synthesize toIdx = _toIdx;

- (id)initWithAct:(NSInteger)act from:(NSInteger)f to:(NSInteger)t cardcnt:(NSInteger)c fromIdx:(NSInteger)fi toIdx:(NSInteger)ti
{
    self = [super init];
    if (self) {
        self.act = act;
        self.from = f;
        self.to = t;
        self.cardcnt = c;
        self.fromIdx = fi;
        self.toIdx = ti;
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:_act forKey:@"act"];
    [aCoder encodeInt:_from forKey:@"from"];
    [aCoder encodeInt:_to forKey:@"to"];
    [aCoder encodeInt:_cardcnt forKey:@"cardcnt"];
    [aCoder encodeInt:_fromIdx forKey:@"fromidx"];
    [aCoder encodeInt:_toIdx forKey:@"toidx"];
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        _act = [aDecoder decodeIntForKey:@"act"];
        _from = [aDecoder decodeIntForKey:@"from"];
        _to = [aDecoder decodeIntForKey:@"to"];
        _cardcnt = [aDecoder decodeIntForKey:@"cardcnt"];
        _fromIdx = [aDecoder decodeIntForKey:@"fromidx"];
        _toIdx = [aDecoder decodeIntForKey:@"toidx"];
    }
    return self;
    
}

-(NSString*) description
{
    NSString *description = [NSString stringWithFormat:@"(%d,%d,%d,%d,%d,%d)",_act,_from,_to,_fromIdx,_toIdx,_cardcnt];
    return description;
}

@end



#ifndef __OPTIMIZE__
#define capture_view_hierarchy
#else

#endif

#ifdef capture_view_hierarchy
@interface UITextView(MYTextView)

@end

@implementation UITextView (MYTextView)
- (void)_firstBaselineOffsetFromTop {

}

- (void)_baselineOffsetFromBottom {

}

@end
#endif

