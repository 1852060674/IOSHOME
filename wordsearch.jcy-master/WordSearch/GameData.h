//
//  GameData.h
//  WordSearch
//
//  Created by apple on 13-8-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject <NSCoding>

@property (strong, nonatomic) NSMutableArray* packNames;
@property (strong, nonatomic) NSMutableArray* packPuzzles;
@property (strong, nonatomic) NSMutableArray* packExplaned;
@property (assign, nonatomic) NSInteger section;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSInteger version;

- (void)loadPuzzlesFromFile;

@end
