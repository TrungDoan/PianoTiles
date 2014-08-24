//
//  TileObject.m
//  PianoTiles
//
//  Copyright (c) 2014 Allanunu Studio. All rights reserved.
//

#import "TileObject.h"
#import "GameData.h"

@implementation TileObject

-(void)changeTileImageAfterTouched:(BOOL)isCorrect {
    
    self.color = (isCorrect ? [SKColor grayColor] : [SKColor redColor]);

}

@end
