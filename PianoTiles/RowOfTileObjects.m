//
//  RowOfTileObjects.m
//  PianoTiles
//
//  Copyright (c) 2014 Allanunu Studio. All rights reserved.
//

#import "RowOfTileObjects.h"
#import "PRPDebug.h"
#import "GameData.h"

@implementation RowOfTileObjects {
    
    int _curRowSize;
    int _rowNumber;
    
    int _blackTilePos;
    
    NSMutableArray *_poolOfTileObjects;
}

-(id)initWithSizeAndRowNumber:(CGSize)frameSize
                    rowNumber:(int)rowNumber
{
    
      if (self = [super init]) {
          
          //PRPLog(@"[%@ %@] Start, frameSize(w,h)=(%f,%f)", CLS_STR, CMD_STR, frameSize.width, frameSize.height);
          
          self.size = frameSize;
          
          _curRowSize = kNUMB_OF_TILES_PER_ROW;
          _rowNumber = rowNumber;
          
          _poolOfTileObjects = [NSMutableArray arrayWithCapacity:_curRowSize];
          
          float unitSize = self.size.width / kNUMB_OF_TILES_PER_ROW;
          
          _blackTilePos = (int)(arc4random() % _curRowSize);
          
          //slightly shrink the tile size, which automatically shows the border lines using the darker background
          CGSize tileSize = CGSizeMake([[GameData sharedInstance] tileWidth] - 1.0f, [[GameData sharedInstance] tileHeight] - 1.0f);
          
          //PRPLog(@"[%@ %@] _blackTilePos=%d", CLS_STR, CMD_STR, _blackTilePos);
          //PRPLog(@"[%@ %@] tileSize(w,h)=(%f,%f)", CLS_STR, CMD_STR, tileSize.width, tileSize.height);
          
          for (int ii=0; ii<_curRowSize; ii++) {
              
              TileObject *newTile = [TileObject spriteNodeWithTexture:[SKTexture textureWithImageNamed:kSingleTileImage]];
              
              newTile.size = tileSize;
              
              newTile.anchorPoint = CGPointMake(0.5f, 0.5f);
              
              newTile.name = [NSString stringWithFormat:@"%@-%d-%d", kTILE_SPRITE_NAME_PREFIX, rowNumber, ii];
              
              if (ii==_blackTilePos) {
                  
                  newTile.isBlackTile = YES;
                  newTile.color = [SKColor blackColor];
                  
              } else {
                  
                  newTile.isBlackTile = NO;
                  newTile.color = [SKColor whiteColor];
              
              }
              
              newTile.colorBlendFactor = 1.0;
              
              //PRPLog(@"[%@ %@] Tile %d, isBlackTile=%@", CLS_STR, CMD_STR, ii, (newTile.isBlackTile ? @"YES" : @"NO"));
              
              newTile.hasBeenTapped = NO;
              newTile.isTappable = NO;
              
              newTile.position = CGPointMake(unitSize * (0.5+ii), self.size.height * 0.5f);
              
              [_poolOfTileObjects insertObject:newTile atIndex:ii];
              
              [self addChild:newTile];
              
          }
          
          //PRPLog(@"[%@ %@] [_poolOfTileObjects count]=%d", CLS_STR, CMD_STR, [_poolOfTileObjects count]);
      }
    
    return self;
}

-(void)resetRowOfTileObjects {
    
    //PRPLog(@"[%@ %@] Start, old _blackTilePos=%d, [_poolOfTileObjects count]=%d", CLS_STR, CMD_STR, _blackTilePos, [_poolOfTileObjects count]);
    
    _blackTilePos = (int)(arc4random() % _curRowSize);
    
    //PRPLog(@"[%@ %@] _blackTilePos=%d", CLS_STR, CMD_STR, _blackTilePos);
    
    for (int ii=0; ii<_curRowSize; ii++) {
        
        TileObject *oneTile = [_poolOfTileObjects objectAtIndex:ii];
        
       // oneTile.texture = [self getImageSKTexture:(ii==_blackTilePos)];
        
        //oneTile.isBlackTile = (ii==_blackTilePos);
        if (ii==_blackTilePos) {
            
            oneTile.isBlackTile = YES;
            oneTile.color = [SKColor blackColor];
            
        } else {
            oneTile.isBlackTile = NO;
            oneTile.color = [SKColor whiteColor];
        }
        
        //PRPLog(@"[%@ %@] Tile %d, isBlackTile=%@", CLS_STR, CMD_STR, ii, (oneTile.isBlackTile ? @"YES" : @"NO"));
        
        oneTile.hasBeenTapped = NO;
        
        oneTile.isTappable = YES;
        
    }
    
}

-(void)enableOrDisableRowOfTileToBeTapped:(BOOL)ifTappable {
    
    //PRPLog(@"[%@ %@] Start, ifTappable=%@", CLS_STR, CMD_STR, (ifTappable ? @"YES" : @"NO"));
    
    for (int ii=0; ii<_curRowSize; ii++) {
        
        TileObject *oneTile = [_poolOfTileObjects objectAtIndex:ii];
        oneTile.isTappable = ifTappable;
    
    }
}

-(TileObject *)getOneTileFromPos:(int)tilePos {
    
    //PRPLog(@"[%@ %@] Start, tilePos=%d, [_poolOfTileObjects count]=%d", CLS_STR, CMD_STR, tilePos, [_poolOfTileObjects count]);
    
    if (tilePos < [_poolOfTileObjects count]) {
        
        //PRPLog(@"[%@ %@] tilePos < [_poolOfTileObjects count]", CLS_STR, CMD_STR);
        
        TileObject *retTile = [_poolOfTileObjects objectAtIndex:tilePos];
        
        //PRPLog(@"[%@ %@] tile.isBlackTile=%@", CLS_STR, CMD_STR, (retTile.isBlackTile ? @"YES": @"NO"));
        
        return retTile;
        
    } else {
        
        //PRPLog(@"[%@ %@] tilePos >= [_poolOfTileObjects count], returning nil", CLS_STR, CMD_STR);
        
        return nil;
    }
}

@end
