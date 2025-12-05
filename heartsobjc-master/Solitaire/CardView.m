//
//  CardView.m
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "CardView.h"
#import "SolitaireView.h"
#import "Card.h"

static NSString *backImageName = @"CardBack-GreenPattern";
static NSString *emptyImageName = @"SpotTableauBlack";
static NSString *stockImageName = @"SpotStockBlack";
static NSString *foundationImageName = @"SpotFoundationBlack";
static NSString *hintImageName = @"HintGlow";
static UIImage *backImage = nil;
static UIImage *emptyImage = nil;
static UIImage *stockImage = nil;
static UIImage *foundationImage = nil;
static UIImage *hintImage = nil;

// Shamelessly copied from TouchFoo
@implementation CardView {
    CGPoint touchStartPoint;
    CGPoint startCenter;
}

@synthesize cardImage = _cardImage;
@synthesize card = _card;
@synthesize oriTtansform = _oriTtansform;
@synthesize rotatedFlag = _rotatedFlag;

- (id)initWithFrame:(CGRect)frame andCard:(Card *)card
{
    self = [super initWithFrame:frame];
    if (self) {
        if ( nil == card ) {
            _cardImage = [CardView emptyImage];
//            [self setUserInteractionEnabled:NO];
        } else {
            _cardImage = [UIImage imageNamed:[card description]];
            _card = card;
        }
        self.opaque = NO;
        _oriTtansform = self.transform;
        _rotatedFlag = NO;
    }
    return self;
}

+ (CGFloat)hintWidth
{
    CGFloat hintWidth = 8;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        hintWidth = 16;
    }
    return hintWidth;
}

- (void)setNewCard:(Card*)card
{
    self.cardImage = [UIImage imageNamed:[card description]];
    self.card = card;
}

- (void)updateClassic:(Card*)card
{
    self.cardImage = [UIImage imageNamed:[card description]];
}

- (id)initWithFrame:(CGRect)frame specialCard:(NSInteger)type
{
    self = [super initWithFrame:frame];
    if (self) {
        if (type == TYPE_EMPTY) {
            _cardImage = [CardView emptyImage];
        }
        else if (type == TYPE_STOCK)
        {
            _cardImage = [CardView stockImage];
        }
        else if (type == TYPE_FOUNDATION)
        {
            _cardImage = [CardView foundationImage];
        }
        else
        {
            _cardImage = [CardView emptyImage];
        }
        self.opaque = NO;
        _oriTtansform = self.transform;
        _rotatedFlag = NO;
    }
    return self;
}

- (NSUInteger)hash {
    return [_card hash]; // Returns 0 to 51
}

- (BOOL)isEqual:(id)other {
    
    // Travis told me to do this
    if ([other class] == [Card class] ) {
        return [_card isEqual:other];
    }
    
    if ([other class] == [CardView class])
    {
        return [_card isEqual:[other card]];
    }
    else
        return NO;
}

- (void)drawRect:(CGRect)rect
{
    UIImage *hint = [CardView hintImage];
    if (_card.glow) {
        [hint drawInRect:rect];
    }
    if (nil == _card || _card.faceUp)
    {
        CGRect tempRect = rect;
        if (_card.glow)
        {
            CGFloat w = [CardView hintWidth];
            tempRect = CGRectMake(rect.origin.x + w, rect.origin.y + w, rect.size.width - 2*w, rect.size.height - 2*w);
        }
        [self.cardImage drawInRect:tempRect];
    }
    else {
        [[CardView backImage] drawInRect:rect];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SolitaireView *parentView = (SolitaireView *) [self superview];
    [parentView touchesBegan:touches withEvent:event withCardView:self];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    SolitaireView *parentView = (SolitaireView *) [self superview];
    [parentView touchesMoved:touches withEvent:event withCardView:self];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    SolitaireView *parentView = (SolitaireView *) [self superview];
    [parentView touchesCancelled:touches withEvent:event withCardView:self];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    SolitaireView *parentView = (SolitaireView *) [self superview];
    [parentView touchesEnded:touches withEvent:event withCardView:self];
}

- (void)rotateAngle:(CGFloat)angle animation:(BOOL)animation
{
    if (!animation) {
        self.layer.anchorPoint = CGPointMake(0.5,0.5);
        CGAffineTransform transform = CGAffineTransformRotate(_oriTtansform, angle*M_PI/180.0);
        self.transform = transform;
    }
    else
    {
        _rotatedFlag = YES;
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:1.0*SPEED_TIME];
        self.layer.anchorPoint = CGPointMake(0.5,0.5);
        CGAffineTransform transform = CGAffineTransformRotate(_oriTtansform, angle*M_PI/180.0);
        self.transform = transform;
        [UIView commitAnimations];
    }
}

- (void)scaleRate:(CGFloat)rate
{
    CGAffineTransform transform = CGAffineTransformScale(_oriTtansform, rate, rate);
    self.transform = transform;
}

- (void)rotateScale:(CGFloat)angle animation:(BOOL)animation rate:(CGFloat)rate
{
//    self.transform = CGAffineTransformMakeScale(2.5, 2.5);
    if (!animation) {
        self.layer.anchorPoint = CGPointMake(0.5,0.5);
        CGAffineTransform transform = CGAffineTransformRotate(_oriTtansform, angle*M_PI/180.0);
        transform = CGAffineTransformScale(transform, rate, rate);
        self.transform = transform;
    }
    else
    {
        _rotatedFlag = YES;
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:1.0*SPEED_TIME];
        self.layer.anchorPoint = CGPointMake(0.5,0.5);
        CGAffineTransform transform = CGAffineTransformRotate(_oriTtansform, angle*M_PI/180.0);
        // 0402
        transform = CGAffineTransformScale(transform, rate * 1.2,  rate * 1.2);
        self.transform = transform;
        [UIView commitAnimations];
    }
}

// Static method for referencing the image on back of all cards
+ (UIImage *)backImage {
    //static UIImage *backImage = nil;
    if (nil == backImage) {
        backImage = [UIImage imageNamed:backImageName];
        //backImage = [UIImage imageNamed:@"CardBack-GreenPattern"];
    }
    
    return backImage;
}

// Static method for referencing the image of a blank card
+ (UIImage *)emptyImage {
    //static UIImage *emptyImage = nil;
    if (nil == emptyImage) {
        emptyImage = [UIImage imageNamed:emptyImageName];
        //emptyImage = [UIImage imageNamed:@"SpotTableauYellow"];
    }
    
    return emptyImage;
}

+ (UIImage *)stockImage
{
    //static UIImage *stockImage = nil;
    if (nil == stockImage) {
        stockImage = [UIImage imageNamed:stockImageName];
    }
    
    return stockImage;
}

+ (UIImage *)foundationImage
{
    //static UIImage *foundationImage = nil;
    if (nil == foundationImage) {
        foundationImage = [UIImage imageNamed:foundationImageName];
    }
    
    return foundationImage;
}

+ (UIImage *)hintImage
{
    if (nil == hintImage) {
        hintImage = [UIImage imageNamed:hintImageName];
    }
    
    return hintImage;
}

+ (void)setBackImage:(NSString*)imageName
{
    if (![backImageName isEqualToString:imageName]) {
        backImageName = imageName;
        if ([backImageName hasPrefix:@"userdefined"]) {
            NSString* userImagName = [NSString stringWithFormat:@"%@/Documents/%@.png",NSHomeDirectory(), backImageName];
            backImage = [UIImage imageWithContentsOfFile:userImagName];
        }
        else
        {
            backImage = [UIImage imageNamed:imageName];
        }
    }
}

+ (void)setEmptyImage:(NSString*)imageName
{
    if (![emptyImageName isEqualToString:imageName]) {
        emptyImageName = imageName;
        emptyImage = [UIImage imageNamed:imageName];
    }
}

+ (void)setStockImage:(NSString*)imageName
{
    if (![stockImageName isEqualToString:imageName]) {
        stockImageName = imageName;
        stockImage = [UIImage imageNamed:imageName];
    }
}

+ (void)setFoundationImage:(NSString*)imageName
{
    if (![foundationImageName isEqualToString:imageName]) {
        foundationImageName = imageName;
        foundationImage = [UIImage imageNamed:imageName];
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
