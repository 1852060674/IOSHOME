//
//  ColorManger.m
//  HairColor
//
//  Created by ZB_Mac on 15/5/11.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "ColorManger.h"
#import "UIImage+Coloration.h"
#import "UIColor+Hex.h"
#import "PhotoStore.h"
#import "UIImage+Blend.h"

#define GROUP_LOCK_KEY @"groupLock"
#define GROUP_NAME_KEY @"groupName"
#define GROUP_COVER_ICON_KEY @"groupCoverIcon"
#define GROUP_COLORS_KEY @"groupColors"
#define COLOR_GROUP_INDEX_KEY @"groupIndex"

#define COLOR_ICON_KEY @"colorIcon"
#define COLOR_LOCK_KEY @"colorLock"
#define COLOR_RATING_LOCK_KEY @"colorRatingLock"
#define COLOR_VALUE_KEY @"colorValue"
#define COLORATION_MODE_KEY @"colorationMode"
#define COLORATION_HL_KEY @"colorationHighlight"
#define COLORATION_HL_FACTOR_KEY @"colorationHighlightFactor"

#define SYSTEM_COLOR_PLIST @"systemcolors"
#define SYSTEM_COLOR_PLIST2 @"systemcolors"
#define USER_COLOR_PLIST @"usercolors"
#define USER_COLOR_VERSION @"usercolorversion"

@interface ColorManger ()
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSString *path;

@property (strong, nonatomic) PhotoStore *photoStore;
@end

@implementation ColorManger
+(ColorManger *)systemManger
{
    static dispatch_once_t once;
    static ColorManger* manger = nil;
    dispatch_once(&once, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:SYSTEM_COLOR_PLIST ofType:@"plist"];
        manger = [[self alloc] initWithPath:path];
    });
    return manger;
}

+(ColorManger *)systemManger_2
{
    static dispatch_once_t once;
    static ColorManger* manger = nil;
    dispatch_once(&once, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:SYSTEM_COLOR_PLIST2 ofType:@"plist"];
        manger = [[self alloc] initWithPath:path];
    });
    return manger;
}

+(ColorManger *)defaultUserManger
{
    static dispatch_once_t once;
    static ColorManger* manger = nil;
    dispatch_once(&once, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:USER_COLOR_PLIST ofType:@"plist"];
        path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:USER_COLOR_PLIST] stringByAppendingPathExtension:@"plist"];
        manger = [[self alloc] initWithPath:path];
        
        if (manger.data.count == 0) {
            NSMutableDictionary *groupDesc = [NSMutableDictionary dictionary];
            [groupDesc setObject:@(2.0) forKey:USER_COLOR_VERSION];
            [groupDesc setObject:@"Custom" forKey:GROUP_NAME_KEY];
            [groupDesc setObject:@"btn_custom.png" forKey:GROUP_COVER_ICON_KEY];
            [groupDesc setObject:@(NO) forKey:GROUP_LOCK_KEY];
            NSMutableArray *colors = [NSMutableArray array];
            
            NSMutableDictionary *colorDesc = [NSMutableDictionary dictionary];
            [colorDesc setObject:@"#000000" forKey:COLOR_VALUE_KEY];
            [colorDesc setObject:@"btn_create.png" forKey:COLOR_ICON_KEY];
            [colors addObject:colorDesc];
            
            colorDesc = [NSMutableDictionary dictionary];
            [colorDesc setObject:@"#000000" forKey:COLOR_VALUE_KEY];
            [colorDesc setObject:@"btn_dropper.png" forKey:COLOR_ICON_KEY];
            [colors addObject:colorDesc];
            
            [groupDesc setObject:colors forKey:GROUP_COLORS_KEY];
            
            [manger.data addObject:groupDesc];
            [manger.data writeToFile:path atomically:YES];
        }
        [manger checkOldUserColor_1];
    });
    return manger;
}

-(id)initWithPath:(NSString*)path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        self.data = [NSMutableArray arrayWithContentsOfFile:path];
    }
    else
    {
        self.data = [NSMutableArray array];
        [self.data writeToFile:path atomically:YES];
    }
    self.path = path;
    self.photoStore = [PhotoStore photoStoreWithIdentifier:path.lastPathComponent.stringByDeletingPathExtension];
    return self;
}

-(NSInteger)groupNumber
{
    return self.data.count;
}

-(BOOL)groupLockAtIndex:(NSInteger)groupIdx
{
    NSDictionary *groupDesc = self.data[groupIdx];
    BOOL lock = [[groupDesc objectForKey:GROUP_LOCK_KEY] boolValue];
    return lock;
}

-(NSString *)groupNameAtIndex:(NSInteger)groupIdx
{
    NSDictionary *groupDesc = self.data[groupIdx];
    NSString *name = [groupDesc objectForKey:GROUP_NAME_KEY];
    return name;
}

-(NSString *)groupCoverIconAtIndex:(NSInteger)groupIdx
{
    NSDictionary *groupDesc = self.data[groupIdx];
    NSString *icon = [groupDesc objectForKey:GROUP_COVER_ICON_KEY];
    return icon;
}

-(NSInteger)groupIndexAtIndex:(NSInteger)groupIdx
{
    NSDictionary *groupDesc = self.data[groupIdx];

    return [[groupDesc objectForKey:COLOR_GROUP_INDEX_KEY] integerValue];
}

-(NSInteger)colorNumberAtIndex:(NSInteger)groupIdx
{
    NSDictionary *groupDesc = self.data[groupIdx];
    NSArray *array = [groupDesc objectForKey:GROUP_COLORS_KEY];
    return array.count;
}

-(BOOL)colorLockAtPath:(NSIndexPath *)path
{
    NSDictionary *groupDesc = self.data[path.section];
    NSArray *array = [groupDesc objectForKey:GROUP_COLORS_KEY];
    NSDictionary *colorDesc = array[path.row];
    BOOL lock = [[colorDesc objectForKey:COLOR_LOCK_KEY] boolValue];
    return lock;
}

-(BOOL)colorRatingLockAtPath:(NSIndexPath *)path
{
    NSDictionary *groupDesc = self.data[path.section];
    NSArray *array = [groupDesc objectForKey:GROUP_COLORS_KEY];
    NSDictionary *colorDesc = array[path.row];
    BOOL lock = [[colorDesc objectForKey:COLOR_RATING_LOCK_KEY] boolValue];
    return lock;
}

-(NSString *)colorValueAtPath:(NSIndexPath *)path
{
    NSDictionary *groupDesc = self.data[path.section];
    NSArray *array = [groupDesc objectForKey:GROUP_COLORS_KEY];
    NSDictionary *colorDesc = array[path.row];
    NSString *color = [colorDesc objectForKey:COLOR_VALUE_KEY];
    return color;
}

-(BOOL)colorationHighlightAtPath:(NSIndexPath *)path
{
    NSDictionary *groupDesc = self.data[path.section];
    NSArray *array = [groupDesc objectForKey:GROUP_COLORS_KEY];
    NSDictionary *colorDesc = array[path.row];
    BOOL highlighted = [[colorDesc objectForKey:COLORATION_HL_KEY] boolValue];
    return highlighted;
}
-(NSInteger)colorationModeAtPath:(NSIndexPath *)path
{
    NSDictionary *groupDesc = self.data[path.section];
    NSArray *array = [groupDesc objectForKey:GROUP_COLORS_KEY];
    NSDictionary *colorDesc = array[path.row];
    NSInteger mode = [[colorDesc objectForKey:COLORATION_MODE_KEY] integerValue];
    return mode;
}

-(CGFloat)colorationHighlightFactorAtPath:(NSIndexPath *)path
{
    NSDictionary *groupDesc = self.data[path.section];
    NSArray *array = [groupDesc objectForKey:GROUP_COLORS_KEY];
    NSDictionary *colorDesc = array[path.row];
    CGFloat highlightFactor = [[colorDesc objectForKey:COLORATION_HL_FACTOR_KEY] floatValue];
    return highlightFactor;
}

-(NSString *)colorIconPathAtPath:(NSIndexPath *)path
{
    NSDictionary *groupDesc = self.data[path.section];
    NSArray *array = [groupDesc objectForKey:GROUP_COLORS_KEY];
    NSDictionary *colorDesc = array[path.row];
    NSString *icon = [colorDesc objectForKey:COLOR_ICON_KEY];
    return icon;
}

-(UIImage *)colorIconAtPath:(NSIndexPath *)path
{
    UIImage *image;
    if (self == [ColorManger systemManger] || self == [ColorManger systemManger_2]) {
        NSString *iconPath = [self colorIconPathAtPath:path];
        image = [UIImage imageNamed:iconPath];
    }
    else
    {
        if (path.row == 0 || path.row == 1) {
            NSString *iconPath = [self colorIconPathAtPath:path];
            image = [UIImage imageNamed:iconPath];
        }
        else
        {
            NSDictionary *groupDesc = self.data[path.section];
            NSArray *array = [groupDesc objectForKey:GROUP_COLORS_KEY];
            NSDictionary *colorDesc = array[path.row];
            NSInteger idx = [[colorDesc objectForKey:COLOR_ICON_KEY] integerValue];
            image = [self.photoStore imageAtIndex:idx];
        }
    }
    return image;;
}

-(BOOL)checkOldUserColor_1
{
    NSString *path = [[NSBundle mainBundle] pathForResource:USER_COLOR_PLIST ofType:@"plist"];
    path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:USER_COLOR_PLIST] stringByAppendingPathExtension:@"plist"];
    
    BOOL old = NO;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSMutableArray *groups = [NSMutableArray arrayWithContentsOfFile:path];
        NSMutableDictionary *groupDesc = groups.firstObject;
        
        if (groupDesc && [groupDesc[USER_COLOR_VERSION] floatValue]<2.0) {

            old = YES;
            
            NSMutableDictionary *newGroupDesc = [NSMutableDictionary dictionary];
            [newGroupDesc setObject:@(2.0) forKey:USER_COLOR_VERSION];
            [newGroupDesc setObject:@"Custom" forKey:GROUP_NAME_KEY];
            [newGroupDesc setObject:@"btn_custom.png" forKey:GROUP_COVER_ICON_KEY];
            [newGroupDesc setObject:@(NO) forKey:GROUP_LOCK_KEY];
            NSMutableArray *newColors = [NSMutableArray array];
            
            NSMutableDictionary *newColorDesc = [NSMutableDictionary dictionary];
            [newColorDesc setObject:@"#000000" forKey:COLOR_VALUE_KEY];
            [newColorDesc setObject:@"btn_create.png" forKey:COLOR_ICON_KEY];
            [newColors addObject:newColorDesc];
            
            newColorDesc = [NSMutableDictionary dictionary];
            [newColorDesc setObject:@"#000000" forKey:COLOR_VALUE_KEY];
            [newColorDesc setObject:@"btn_dropper.png" forKey:COLOR_ICON_KEY];
            [newColors addObject:newColorDesc];
            
            NSMutableArray *colors = groupDesc[GROUP_COLORS_KEY];
            
            for (NSInteger idx=2; idx<colors.count; ++idx) {
                NSMutableDictionary *color = colors[idx];
                newColorDesc = [NSMutableDictionary dictionary];
                
                NSString *colorValue = color[COLOR_VALUE_KEY];
                BOOL highlight = YES;
                NSInteger mode = 3;
                
                UIImage *image = [UIImage imageNamed:@"btn_hair_sample"];
                image = [[image imageWithColoration:[UIColor colorWithHexString:colorValue] highlight:highlight mode:mode] imageMaskedWithImage:image];
                
                NSInteger idx = [self.photoStore addItemImage:image andSmallImage:nil andMaskImage:nil];
                
                //    [colorDesc setObject:[self.photoStore imagePathAtIndex:idx] forKey:COLOR_ICON_KEY];
                [newColorDesc setObject:@(idx) forKey:COLOR_ICON_KEY];
                [newColorDesc setObject:colorValue forKey:COLOR_VALUE_KEY];
                [newColorDesc setObject:@(mode) forKey:COLORATION_MODE_KEY];
                [newColorDesc setObject:@(highlight) forKey:COLORATION_HL_KEY];
                [newColorDesc setObject:@(0.65) forKey:COLORATION_HL_FACTOR_KEY];
                [newColors addObject:newColorDesc];
            }

            [newGroupDesc setObject:newColors forKey:GROUP_COLORS_KEY];

            [self.data removeAllObjects];
            [self.data addObject:newGroupDesc];
            [self.data writeToFile:path atomically:YES];
        }
    }
    return YES;
}

-(void)addCustomColor:(NSString *)colorValue
{
    [self addCustomColor:colorValue andMode:3 andHighlight:YES];
}

-(void)addCustomColor:(NSString *)colorValue andMode:(NSInteger)mode andHighlight:(BOOL)highlight
{
    NSMutableDictionary *groupDesc = self.data.firstObject;
    
    NSMutableArray *colors = [groupDesc objectForKey:GROUP_COLORS_KEY];
    
    NSMutableDictionary *colorDesc = [NSMutableDictionary dictionary];
    
    UIImage *image = [UIImage imageNamed:@"btn_hair_sample"];
    image = [[image imageWithColoration:[UIColor colorWithHexString:colorValue] highlight:highlight mode:mode] imageMaskedWithImage:image];
    
    NSInteger idx = [self.photoStore addItemImage:image andSmallImage:nil andMaskImage:nil];
    
//    [colorDesc setObject:[self.photoStore imagePathAtIndex:idx] forKey:COLOR_ICON_KEY];
    [colorDesc setObject:@(idx) forKey:COLOR_ICON_KEY];
    [colorDesc setObject:colorValue forKey:COLOR_VALUE_KEY];
    [colorDesc setObject:@(mode) forKey:COLORATION_MODE_KEY];
    [colorDesc setObject:@(highlight) forKey:COLORATION_HL_KEY];
    [colorDesc setObject:@(0.65) forKey:COLORATION_HL_FACTOR_KEY];
    [colors insertObject:colorDesc atIndex:2];
    [groupDesc setObject:colors forKey:GROUP_COLORS_KEY];
    
    [self.data writeToFile:self.path atomically:YES];
}
@end
