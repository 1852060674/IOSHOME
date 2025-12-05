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
#import "UIImage+Tint.h"
#import "CAKeyframeAnimation+AHEasing.h"

#define IMAGE_ROWS 5
#define IMAGE_COLS 9

static NSString *tilesetImageName = @"xxx";
static UIImage *tilesetImage = nil;
static UIImage *shadowImage = nil;
static NSMutableArray *tileImages = nil;
static UIImage *pauseImageSource = nil;

static int lastTileIdx = 0;
static UIImage *selectedImageSource = nil;
static UIImage *backImageSource = nil;
static UIImage *bottomShadowImage = nil;

static double xBottomShadow = 1.21;
static double yBottomShadow = 1.17;

// Shamelessly copied from TouchFoo
@implementation CardView {
    CGPoint touchStartPoint;
    CGPoint startCenter;
    CGFloat BOUNCE_HEIGHT;
    UIImageView* shadowView;
    UIImageView* mahjongView;
    UIImageView* mahjongBackView;
    UIImageView* selectedView;
    UIImageView* bottomShadowView;
    //
}

@synthesize cardImage = _cardImage;
@synthesize card = _card;
@synthesize flyflag;

- (UIImage*)getImageFromTileset:(Card*)card
{
    /*
    if (tilesetImage == nil) {
        tilesetImage = [UIImage imageNamed:tilesetImageName];
    }
    CGFloat eachWidth = tilesetImage.size.width/IMAGE_COLS;
    CGFloat eachHeight = tilesetImage.size.height/IMAGE_ROWS;
    int row = card.seq/IMAGE_COLS;
    int col = card.seq%IMAGE_COLS;
    CGImageRef imageRef = CGImageCreateWithImageInRect([tilesetImage CGImage], CGRectMake(eachWidth*col, eachHeight*row, eachWidth, eachHeight));
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return img;
     */
    if (tileImages == nil)
        return nil;
    else
        return [tileImages objectAtIndex:card.seq];
}

- (id)initWithFrame:(CGRect)frame andCard:(Card *)card
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        //
        _cardImage = [self getImageFromTileset:card];
        _card = card;
        self.flyflag = NO;
        shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        shadowView.image = shadowImage;
        shadowView.alpha = 0;
        mahjongView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        mahjongView.image = _cardImage;
        mahjongBackView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        mahjongBackView.image = backImageSource;
        selectedView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        selectedView.image = selectedImageSource;
        bottomShadowView = [[UIImageView alloc] initWithFrame:CGRectMake(-frame.size.width * (xBottomShadow - 1)/2, -frame.size.height * (yBottomShadow - 1)/2, frame.size.width * xBottomShadow, frame.size.height*yBottomShadow)];
        bottomShadowView.image = bottomShadowImage;
        [self addSubview:bottomShadowView];
        [self addSubview:mahjongBackView];
        [self addSubview:mahjongView];
        [self addSubview:shadowView];
        [self addSubview:selectedView];
        self.opaque = NO;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            BOUNCE_HEIGHT = 16;
        }
        else
            BOUNCE_HEIGHT = 8;
    }
    return self;
}

- (void)setNewCard:(Card*)card
{
    self.cardImage = [self getImageFromTileset:card];
    mahjongView.image = self.cardImage;
    mahjongBackView.image = backImageSource;
    self.card.seq = card.seq;
}

- (NSUInteger)hash {
    return [_card hash];
}

- (BOOL)isEqual:(id)other {
    
    // Travis told me to do this
    if ([other class] == [Card class] ) {
        return [_card isEqual:other];
    }
    
    
    // zzx need secod update 11.13
//    [_card isEqual:[other card]]
    return FALSE;
}

- (void)drawRect:(CGRect)rect
{
    if (_card.state == CARD_STATE_SHOW) {
        self.hidden = NO;
        shadowView.alpha = 0;
        selectedView.alpha = 0;
        mahjongView.image = self.cardImage;
    }
    else if (_card.state == CARD_STATE_SELECTED)
    {
        mahjongView.image = self.cardImage;
        selectedView.alpha = 1;
        shadowView.alpha = 0;
        self.hidden = NO;
    }
    else if (_card.state == CARD_STATE_COVERED)
    {
        mahjongView.image = self.cardImage;
        selectedView.alpha = 0;
        shadowView.alpha = 1;
        self.hidden = NO;
    }
    else if (_card.state == CARD_STATE_HIDDEN)
    {
        self.hidden = YES;
    }
}

- (void)pauseChange
{
    mahjongView.image = pauseImageSource;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.flyflag)
        return;
    SolitaireView *parentView = (SolitaireView *) [[self superview] superview];
    [parentView touchesBegan:touches withEvent:event withCardView:self];
}

+ (NSString*)shadowImageNameByTileImageName:(NSString*)imageName
{
    NSString* shadowName = @"shadow1";
    if ([imageName isEqualToString:@"tileset_normal"])
        shadowName = @"shadow0";
    else if ([imageName isEqualToString:@"tileset_1"])
        shadowName = @"shadow1";
    else if ([imageName isEqualToString:@"tileset_2"])
        shadowName = @"shadow2";
    else if ([imageName isEqualToString:@"tileset_3"])
        shadowName = @"shadow3";
    else if ([imageName isEqualToString:@"tileset_4"])
        shadowName = @"shadow4";
    else if ([imageName isEqualToString:@"tileset_5"])
        shadowName = @"shadow5";
    else if ([imageName isEqualToString:@"tileset_6"])
        shadowName = @"shadow6";
    //
    return shadowName;
}

+ (void)setTilesetImage:(NSString *)imageName
{
    if (![tilesetImageName isEqualToString:imageName]) {
        tilesetImageName = imageName;
        tilesetImage = [UIImage imageNamed:imageName];
        shadowImage = [UIImage imageNamed:[self shadowImageNameByTileImageName:imageName]];
        //
        if (tileImages == nil)
            tileImages = [[NSMutableArray alloc] init];
        else
            [tileImages removeAllObjects];
        CGFloat eachWidth = tilesetImage.size.width/IMAGE_COLS;
        CGFloat eachHeight = tilesetImage.size.height/IMAGE_ROWS;
        for (int i = 0; i < NUM_TILE; i++)
        {
            int tr = i / IMAGE_COLS;
            int tc = i % IMAGE_COLS;
            CGImageRef imageRef = CGImageCreateWithImageInRect([tilesetImage CGImage], CGRectMake(eachWidth*tc, eachHeight*tr, eachWidth, eachHeight));
            UIImage *img = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            [tileImages addObject:img];
        }
        //
        CGImageRef imageRef = CGImageCreateWithImageInRect([tilesetImage CGImage], CGRectMake(eachWidth*(NUM_TILE%IMAGE_COLS), eachHeight*(NUM_TILE/IMAGE_COLS), eachWidth, eachHeight));
        pauseImageSource = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }
}

+ (void)initRes:(int)themeid
{
    if (tileImages == nil)
        tileImages = [[NSMutableArray alloc] init];
    //
    if ([tileImages count] != 0 && themeid == lastTileIdx) {
        return;
    }
    //
    [tileImages removeAllObjects];
    //
    for (int i = 0; i < NUM_TILE; i++) {
        UIImage* uii = [UIImage imageNamed:[NSString stringWithFormat:@"tile%d_%d",themeid,i]];
        [tileImages addObject:uii];
    }
    backImageSource = pauseImageSource = [UIImage imageNamed:[NSString stringWithFormat:@"tilebg%d",themeid]];
    selectedImageSource = [UIImage imageNamed:@"selected"];
    shadowImage = [UIImage imageNamed:[NSString stringWithFormat:@"shadow%d",themeid]];
    bottomShadowImage = [UIImage imageNamed:[NSString stringWithFormat:@"bottomshadow%d",themeid]];
    //
    lastTileIdx = themeid;
}

- (void)updateTheme:(Card *)card
{
    self.cardImage = [self getImageFromTileset:card];
    mahjongView.image = self.cardImage;
    mahjongBackView.image = backImageSource;
    shadowView.image = shadowImage;
    selectedView.image = selectedImageSource;
    bottomShadowView.image = bottomShadowImage;
}

- (void)bounce
{
    //mahjongView.image = [self.cardImage imageWithGradientTintColor:[UIColor colorWithRed:1 green:1 blue:0 alpha:0.35]];
    CGPoint targetCenter = self.center;
    [UIView animateWithDuration:0.1 animations:^(void){
        self.center = CGPointMake(targetCenter.x, targetCenter.y-BOUNCE_HEIGHT);
    }completion:^(BOOL finished){
        CALayer *layer= [self layer];
        [CATransaction begin];
        ///must before animation, otherwise invoked immediately
        [CATransaction setCompletionBlock:^{
            //mahjongView.image = self.cardImage;
        }];
        [CATransaction setValue:[NSNumber numberWithFloat:0.750] forKey:kCATransactionAnimationDuration];
        CAAnimation *chase = [CAKeyframeAnimation animationWithKeyPath:@"position" function:BounceEaseOut fromPoint:self.center toPoint:targetCenter];
        [chase setDelegate:self];
        [layer addAnimation:chase forKey:@"position"];
        [CATransaction commit];
        [self setCenter:targetCenter];
    }];
}

- (void)leftright
{
    CGAffineTransform origin = self.transform;
    [UIView animateWithDuration:0.1 animations:^(void){
        CGAffineTransform at = self.transform;
        at = CGAffineTransformRotate(at, M_PI/4);
        self.transform = at;
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.1 animations:^{
            CGAffineTransform at = self.transform;
            at = CGAffineTransformRotate(at, -M_PI/4);
            self.transform = at;
        } completion:^(BOOL finished) {
            self.transform = origin;
        }];
    }];
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
