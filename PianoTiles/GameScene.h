//
//  GameScene.h
//  PianoTiles
//
//  Copyright (c) 2014 Allanunu Studio. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene <UIAlertViewDelegate>

-(id)initWithSizeAndTargetTileCount:(CGSize)size targetTileCount:(int)targetTileCount;

@end
