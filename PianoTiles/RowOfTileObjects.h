//
//  RowOfTileObjects.h
//  PianoTiles
//
//  Copyright (c) 2014 Allanunu Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "TileObject.h"

@interface RowOfTileObjects : SKSpriteNode

//-(id)initWithSizeAndRowNumber:(int)rowSize rowNumber:(int)rowNumber;
-(id)initWithSizeAndRowNumber:(CGSize)frameSize //rowSize:(int)rowSize
                    rowNumber:(int)rowNumber;
-(TileObject *)getOneTileFromPos:(int)tilePos;
-(void)resetRowOfTileObjects;
-(void)enableOrDisableRowOfTileToBeTapped:(BOOL)ifTappable;

@end
