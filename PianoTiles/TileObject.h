//
//  TileObject.h
//  PianoTiles
//
//  Copyright (c) 2014 Allanunu Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface TileObject : SKSpriteNode

@property (nonatomic) BOOL hasBeenTapped;
@property (nonatomic) BOOL isBlackTile;
@property (nonatomic) BOOL isTappable;

-(void)changeTileImageAfterTouched:(BOOL)isCorrect;

@end
