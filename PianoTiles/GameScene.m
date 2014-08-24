//
//  GameScene.m
//  PianoTiles
//
//  Copyright (c) 2014 Allanunu Studio. All rights reserved.
//


#import "GameScene.h"
#import "RowOfTileObjects.h"
#import "TileObject.h"
#import "PRPDebug.h"
#import "GameData.h"

#define kRESTART @"ButtonRestart"
#define kEXIT @"ButtonExit"
#define kSHARE @"ButtonShare"
#define kRESET @"ButtonReset"
#define kBESTTIME @"BestTime"

@implementation GameScene {
    
    float _tileWidth;
    float _tileHeight;
    
    //this holds the rows of tile objects
    NSMutableArray *_poolOfTileObjRows;
    
    //the rowNumber of the row that's holding the black tile that's expected to be tapped
    int _currentTargetRowNumberIndex;
    
    //how many successful moves so far
    int _totalMoveCount;
    
    //the "start" label on 1st black tile of 1st row when game starts
    SKLabelNode *_startLabelNode;
    
    //the label to display the current time
    SKLabelNode *_timerLabelNode;
    
    //the timer object
    NSTimer *_timer;
    
    //this stores the starting time
    double _startTime;
    
    //this stores the total time value after game successfully ended
    float _finalTimeValue;
    
    //the current game status
    gameStatus _curGameStatus;
    
    //the target number of tiles needed to achieve to pass current level
    int _maxTileCountToAchieve;
    
    //progress bar on top of screen
    SKSpriteNode *progressBar;
    
    //height of progress bar
    float progressBarHeight;
    
    //game over view
    SKSpriteNode *gameOverView;
    
    //label font sizes
    float labelGameOverTitleFontSize;
    float labelGameOverButtonsFontSize;
    float labelGameOverCurrentTimeFontSize;
    float labelGameOverBestTimeFontSize;
    
    float greyButtonBackgroundWidth; // width of label to indicate it's a tappable button
}

-(id)initWithSizeAndTargetTileCount:(CGSize)size targetTileCount:(int)targetTileCount {
    
    if (self = [super initWithSize:size]) {
        
        //PRPLog(@"[%@ %@] Start, size(w,h)=(%f,%f)", CLS_STR, CMD_STR, size.width, size.height);
        
        //set background color, this will also be the color of the border lines between all tiles
        self.backgroundColor = kBackgroundColour;
        
        _maxTileCountToAchieve = targetTileCount;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            labelGameOverTitleFontSize = 60.0f;
            labelGameOverButtonsFontSize = 30.0f;
            labelGameOverBestTimeFontSize = 40.0f;
            labelGameOverCurrentTimeFontSize = 80.0f;
            progressBarHeight = 10.0f;
            greyButtonBackgroundWidth = 80.0f;
            
        } else {
            
            labelGameOverTitleFontSize = 120.0f;
            labelGameOverButtonsFontSize = 60.0f;
            labelGameOverBestTimeFontSize = 80.0f;
            labelGameOverCurrentTimeFontSize = 160.0f;
            progressBarHeight = 20.0f;
            greyButtonBackgroundWidth = 160.0f;
        }
        
    }
    
    return self;
}

//this get called immediately after a scene is presented by a view
-(void)didMoveToView:(SKView *)view {
    
    //PRPLog(@"[%@ %@] Start, self.frame.size.height =%f", CLS_STR, CMD_STR, self.frame.size.height );
    
    _tileWidth = self.frame.size.width / kNUMB_OF_TILES_PER_ROW;
    _tileHeight = self.frame.size.height / kNUMB_OF_ROWS_PER_COLUMN;
    
    [[GameData sharedInstance] setTileHeight:_tileHeight];
    [[GameData sharedInstance] setTileWidth:_tileWidth];
    
    _currentTargetRowNumberIndex = 0;
    _curGameStatus = kGameWaitingToStart;
    
    _totalMoveCount = 0;
    
    //show time label as 0:00
    [self updateTimerDisplay:0.0 ifExactTime:YES];
    
    //setup progress bar
    progressBar = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:kSingleTileImage]];
    progressBar.size = CGSizeMake(0, progressBarHeight);
    progressBar.colorBlendFactor = 1.0f;
    progressBar.color = [SKColor redColor];
    progressBar.zPosition = 100;
    progressBar.position = CGPointMake(0, self.frame.size.height);// - progressBar.size.height);
    [self addChild:progressBar];
    
    
    //setup rows of tiles
    _poolOfTileObjRows = [NSMutableArray arrayWithCapacity:kMAX_NUMBER_OF_ROWS_PER_GAME];
    
    for (int ii=0; ii<kMAX_NUMBER_OF_ROWS_PER_GAME; ii++) {
        
        RowOfTileObjects *newRow = [[RowOfTileObjects alloc] initWithSizeAndRowNumber:CGSizeMake(self.frame.size.width, _tileHeight)
                                                                            rowNumber:ii];
        [newRow setAnchorPoint:CGPointMake(0, 0)];
        [newRow setPosition:CGPointMake(0, (ii+1)*_tileHeight)];
        [newRow setName:[NSString stringWithFormat:@"Row-%d", ii]];
        
        [_poolOfTileObjRows insertObject:newRow atIndex:ii];
        
        //PRPLog(@"[%@ %@] (%d) [_poolOfTileObjRows count]=%d", CLS_STR, CMD_STR, ii, [_poolOfTileObjRows count]);
        
        //originally only tiles on current row are tappable, now changed to all tappable with extra check to make sure the black tile on the expected row been tapped
        [newRow enableOrDisableRowOfTileToBeTapped:YES];
        
        [self addChild:newRow];
        
        //show "start" label on black tile of first row
        if (ii==0) {
            
            for (int jj=0; jj<kNUMB_OF_TILES_PER_ROW; jj++) {
                
                TileObject *tmpTile = [newRow getOneTileFromPos:jj];
                
                if (tmpTile.isBlackTile) {
                    
                    _startLabelNode = [SKLabelNode labelNodeWithFontNamed:kSYSTEM_FONT_NAME];
                    _startLabelNode.position = CGPointMake(0, 0);
                    _startLabelNode.zPosition = 1000;
                    _startLabelNode.text = @"Start";
                    _startLabelNode.fontSize = 30;
                    _startLabelNode.fontColor = [SKColor whiteColor];
                    [tmpTile addChild:_startLabelNode];
                }
            }
        }
    }
}

-(void)updateProgressBar {

    float valueToUse = 1.0f;
    float widthToUse;
    
    if (_totalMoveCount <= _maxTileCountToAchieve) {
        
        valueToUse = (float)_totalMoveCount / (float)_maxTileCountToAchieve;
        
        widthToUse = self.frame.size.width * valueToUse;
        
    }
    
    progressBar.size = CGSizeMake(widthToUse*2.0f, progressBarHeight);
   
    progressBar.position = CGPointMake(0, self.frame.size.height);
    
    progressBar.color = [SKColor colorWithRed:(1.0-valueToUse) green:valueToUse blue:0 alpha:1.0];
}

-(void)moveAllTilesForwardAfterCorrectMove {
    
    //PRPLog(@"[%@ %@] \n\nStart, currentTargetRowNumberIndex=%d, totalMoveCount=%d", CLS_STR, CMD_STR, _currentTargetRowNumberIndex, _totalMoveCount);
    
    _totalMoveCount++;
    [self updateProgressBar];
    
    //play sound
    SKAction *nextNote = [[GameData sharedInstance] getNextNoteAsSKActionToPlay];
    [self runAction:nextNote];
    
    //define the action
    float timeForMoving = 0.2f;
    
    SKAction *moveDown = [SKAction moveByX:0 y:-_tileHeight duration:timeForMoving];
    
    moveDown.timingMode = SKActionTimingEaseInEaseOut;
    
    
    //if not game completed, move all tiles downwards
    if (_totalMoveCount<_maxTileCountToAchieve) {
        
        //move all rows down
        for (int ii=0; ii<kMAX_NUMBER_OF_ROWS_PER_GAME; ii++) {
            
            RowOfTileObjects *rowOfTiles = [_poolOfTileObjRows objectAtIndex:ii];
           
            [rowOfTiles runAction:moveDown];
            
        }
        
    } else {
        //PRPLog(@"[%@ %@] stop moving tiles down as target achieved", CLS_STR, CMD_STR);
    }
    
    //only check out of screen tile rows after 1st move
    if (_totalMoveCount>1) {
        
        int indexOfTheRowOutOfScreen = ((_currentTargetRowNumberIndex-1) + kMAX_NUMBER_OF_ROWS_PER_GAME) % kMAX_NUMBER_OF_ROWS_PER_GAME;
        
        //PRPLog(@"[%@ %@] indexOfTheRowOutOfScreen=%d, totalMoveCount=%d, _maxTileCountToAchieve=%d", CLS_STR, CMD_STR, indexOfTheRowOutOfScreen, _totalMoveCount, _maxTileCountToAchieve);
        
        //stop moving out of screen rows to above when total number of moved tiles + number of rows per col to fill up screen height is
        //equal to target
        if (_totalMoveCount+kNUMB_OF_ROWS_PER_COLUMN<_maxTileCountToAchieve) {
            
            //reset and relocate the disappearing current row
            RowOfTileObjects *outOfScreenRowOfTiles = [_poolOfTileObjRows objectAtIndex:indexOfTheRowOutOfScreen];
            
            float timeToChange = 0.01;
            
            //wait first before moving to avoid flashing effect
            SKAction *actionForLastRow = [SKAction sequence:@[[SKAction waitForDuration:timeForMoving],
                                                              [SKAction moveByX:0 y:kMAX_NUMBER_OF_ROWS_PER_GAME*_tileHeight duration:timeToChange],
                                                              [SKAction runBlock:^{
                                                                [outOfScreenRowOfTiles resetRowOfTileObjects];
                                                              }],
                                                              ]];
            
            actionForLastRow.timingMode = SKActionTimingEaseInEaseOut;
            
            [outOfScreenRowOfTiles runAction:actionForLastRow];
            
        } else {
            
            //PRPLog(@"[%@ %@] stop moving tiles up!", CLS_STR, CMD_STR);
            
        }
        
    }
    
    //update counter
    _currentTargetRowNumberIndex = (_currentTargetRowNumberIndex+1) % kMAX_NUMBER_OF_ROWS_PER_GAME;
    
    //check if target number of tiles to move achieved
    if (_totalMoveCount>=_maxTileCountToAchieve) {

        _curGameStatus = kGameOverCompleted;
        [self showEndOfGameLabel];

    }
    
    //PRPLog(@"[%@ %@] End, currentTargetRowNumberIndex=%d, totalMoveCount=%d", CLS_STR, CMD_STR, _currentTargetRowNumberIndex, _totalMoveCount);
    
}

-(void)showLabelOnly:(NSString *)textName
             textStr:(NSString *)textStr
             textPos:(CGPoint)textPos
            fontSize:(float)fontSize
          parentNode:(SKSpriteNode *)parentNode
{
    SKLabelNode *newLNode = [SKLabelNode labelNodeWithFontNamed:kSYSTEM_FONT_NAME];
    newLNode.position = textPos;
    newLNode.zPosition = 800;
    newLNode.alpha = 1.0f;
    newLNode.text = textStr;
    newLNode.fontSize = fontSize;
    newLNode.fontColor = [SKColor whiteColor];
    newLNode.name = textName;
    [parentNode addChild:newLNode];
}

-(void)showLabelButton:(NSString *)textName
               textStr:(NSString *)textStr
               textPos:(CGPoint)textPos
              fontSize:(float)fontSize
            parentNode:(SKSpriteNode *)parentNode
{
    
    //PRPLog(@"[%@ %@] Adding label/button %@ at pos (%f,%f)", CLS_STR, CMD_STR, textName, textPos.x, textPos.y);
    //PRPLog(@"[%@ %@] String %@ length=%d", CLS_STR, CMD_STR, textStr, [textStr length]);
    
    SKSpriteNode *buttonNode1 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:kSingleTileImage]];
    buttonNode1.anchorPoint = CGPointMake(0.5f, 0.5f);
    buttonNode1.size = CGSizeMake(greyButtonBackgroundWidth, fontSize);
    buttonNode1.position = textPos;//CGPointMake(CGRectGetMidX(self.frame), 0.5f*self.frame.size.height);
    buttonNode1.colorBlendFactor = 1.0f;
    buttonNode1.color = [SKColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:0.5];
    buttonNode1.name = [self getMenuButton:textName];
    buttonNode1.zPosition = 1000;
    
    SKLabelNode *newLNode = [SKLabelNode labelNodeWithFontNamed:kSYSTEM_FONT_NAME];
    newLNode.position = CGPointMake(0,-0.4f*fontSize);;
    newLNode.zPosition = 800;
    newLNode.alpha = 1.0f;
    newLNode.text = textStr;
    newLNode.fontSize = fontSize;
    newLNode.fontColor = [SKColor whiteColor];
    newLNode.name = [self getMenuLabel:textName];
    [buttonNode1 addChild:newLNode];
    [parentNode addChild:buttonNode1];

}

-(void)showEndOfGameLabel {
    
    //PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    
    [self updateTimerLabel];
    [self stopNSTimer:_timer];
    
    //disable all tiles so not tappable
    for (int ii=0;ii<kMAX_NUMBER_OF_ROWS_PER_GAME; ii++) {
        
        RowOfTileObjects *rowOfTiles = [_poolOfTileObjRows objectAtIndex:ii];
        
        [rowOfTiles enableOrDisableRowOfTileToBeTapped:NO];
    }
    
    BOOL ifNewRecord = NO;
    
    //========================================
    //setup game over view plus animation
    
    gameOverView = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:kSingleTileImage]];
    gameOverView.size = self.frame.size;
    gameOverView.zPosition = 500;
    
    //initial position
    gameOverView.position = CGPointMake(CGRectGetMidX(self.frame), 2.0f*self.frame.size.height);
    
    gameOverView.colorBlendFactor = 1.0;
    
    //notes to play after animation
    SKAction *notesToPlay;
    
    NSString *titleString;
    
    //========================================
    //set background color, title string, notes to play and others depending on whether result is passed or failed
    if ((_curGameStatus != kGameOverIncorrect)) {
        
        gameOverView.color = kBackgroundColour;
        titleString = @"Success!";
        
        //check and update best time, also automatically calls nextSongAfterGameEnded
        ifNewRecord = [[GameData sharedInstance] updateAndCheckIfNewRecord:_finalTimeValue];
        
        //only show current time info if passed
        [self showLabelOnly:@"CurrentTime"
                    textStr:[NSString stringWithFormat:@"%.3f\"",_finalTimeValue]
                    textPos:CGPointMake(0, 0)
                   fontSize:labelGameOverCurrentTimeFontSize
                 parentNode:gameOverView];
        
        //get success notes
        notesToPlay = [[GameData sharedInstance] getSuccessNotes];
        
    } else {
        
        gameOverView.color = kBackgroundColourFailed;
        titleString = @"Failed!";
        
        //if game over due to incorrect move, only update song counter
        [[GameData sharedInstance] nextSongAfterGameEnded];

        //get failed notes
        notesToPlay = [[GameData sharedInstance] getFailedNotes];
        
    }
    
    //========================================
    //add game type info
    [self showLabelOnly:@"GameType"
                textStr:[NSString stringWithFormat:@"%@ %d", kGAME_NAME_PREFIX, _maxTileCountToAchieve]
                textPos:CGPointMake(0, self.frame.size.height*0.3f)
               fontSize:labelGameOverBestTimeFontSize
             parentNode:gameOverView];
    
    //========================================
    //add title
    [self showLabelOnly:@"GameOverTitle"
                textStr:titleString
                textPos:CGPointMake(0, self.frame.size.height*0.2f)
               fontSize:labelGameOverTitleFontSize
             parentNode:gameOverView];
    
    //========================================
    //add best time info
    float bestTime = [[GameData sharedInstance] getBestRecord];
    
    //PRPLog(@"[%@ %@] bestTime=%f", CLS_STR, CMD_STR, bestTime);
    
    //only show best time if it's not default value
    if (bestTime < kDefaultBestTimeValue) {
        [self showLabelOnly:kBESTTIME
                    textStr:[NSString stringWithFormat:@"Best: %.3f\"",bestTime]
                    textPos:CGPointMake(0, -self.frame.size.height*0.1f)
                   fontSize:labelGameOverBestTimeFontSize
                 parentNode:gameOverView];
    }
    
    //========================================
    //add label buttons
    float labelPosY = -self.frame.size.height*0.3f;
    
    [self showLabelButton:kSHARE
                  textStr:@"Share"
                  textPos:CGPointMake(-self.frame.size.width*0.25f, labelPosY)
                 fontSize:labelGameOverButtonsFontSize
               parentNode:gameOverView];
    
    [self showLabelButton:kEXIT
                  textStr:@"Exit"
                  textPos:CGPointMake(0, labelPosY)
                 fontSize:labelGameOverButtonsFontSize
               parentNode:gameOverView];
    
    [self showLabelButton:kRESTART
                  textStr:@"Again"
                  textPos:CGPointMake(self.frame.size.width*0.25f, labelPosY)
                 fontSize:labelGameOverButtonsFontSize
               parentNode:gameOverView];
    
    //add clear best time button
    
    [self showLabelButton:kRESET
                  textStr:@"Reset"
                  textPos:CGPointMake(-self.frame.size.width*0.4f, -self.frame.size.height*0.48f)
                 fontSize:labelGameOverButtonsFontSize*0.5f
               parentNode:gameOverView];
    
    [self addChild:gameOverView];
    
    //========================================
    //setup last actions depending on whether it's new record or not
    SKAction *lastAction;
    
    if (ifNewRecord) {
        
        SKAction *newRecordNotesToPlay = [[GameData sharedInstance] getNewRecordSound];
       
        lastAction = [SKAction sequence:@[
                                          notesToPlay,
                                          [SKAction runBlock:^{
        
            //add a "new record" label
            SKLabelNode *newLNode = [SKLabelNode labelNodeWithFontNamed:kSYSTEM_FONT_NAME];
            newLNode.position = CGPointMake(0, -self.frame.size.height*0.15f);
            newLNode.zPosition = 900;
            newLNode.alpha = 1.0f;
            newLNode.text = @"New Record";
            newLNode.fontSize = labelGameOverBestTimeFontSize*0.5f;
            newLNode.fontColor = [SKColor yellowColor];
            newLNode.name = @"NewRecord";
            [gameOverView addChild:newLNode];
            
        }],
                                          newRecordNotesToPlay]];
        
    } else {
        
        lastAction = notesToPlay;
    
    }
    
    SKAction *viewDroppingAction = [[GameData sharedInstance] getViewDroppingFromTopAnimation:self.frame.size.height*0.5f];
    
    //========================================
    //run action for gameOverView
    [gameOverView runAction:[SKAction sequence:@[
                                                 viewDroppingAction,
                                                 lastAction
                                                 ]]];
    
}

-(void)updateTimerDisplay:(double)displayTime ifExactTime:(BOOL)ifExactTime {
    
    if (_timerLabelNode==nil) {
        
        if (_timerLabelNode==nil) {
            _timerLabelNode = [SKLabelNode labelNodeWithFontNamed:kSYSTEM_FONT_NAME];
            _timerLabelNode.position = CGPointMake(self.frame.size.width*0.5f, self.frame.size.height*0.9f);
            _timerLabelNode.zPosition = 100;
            _timerLabelNode.text = @"0.000\"";
            _timerLabelNode.fontSize = 50;
            _timerLabelNode.fontColor = [SKColor redColor];
            [self addChild:_timerLabelNode];
        } else {
            
        }
        
    } else if (ifExactTime) {
    
        _finalTimeValue = displayTime;
        
        //PRPLog(@"[%@ %@] Start, _finalTimeValue=%f", CLS_STR, CMD_STR, _finalTimeValue);
        
        NSString *timeStr = [NSString stringWithFormat:@"%.3f\"",displayTime];
        _timerLabelNode.text = timeStr;
        
    } else {
        
        //append 2 random digits at the end
        int randDigit1 = (int)(arc4random() % 10);
        int randDigit2 = (int)(arc4random() % 10);
        
        NSString *timeStr = [NSString stringWithFormat:@"%.1f%d%d\"",displayTime, randDigit1, randDigit2];
        _timerLabelNode.text = timeStr;
    }
    
}

-(void)updateTimerLabel {
    
        double timeNow = CACurrentMediaTime();
        
        double timeDiff = (timeNow - _startTime);
        
        [self updateTimerDisplay:timeDiff ifExactTime:(_curGameStatus != kGameStarted)];
    
}

-(NSString *)getMenuLabel:(NSString *)value
{
    
    return [NSString stringWithFormat:@"%@%@", kMenuLabelName, value];
}

-(NSString *)getMenuButton:(NSString *)value
{
    
    return [NSString stringWithFormat:@"%@%@", kMenuButtonName, value];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //PRPLog(@"[%@ %@] Start, totalMoveCount=%d", CLS_STR, CMD_STR, _totalMoveCount);
    
    //remove start label
    if ((_totalMoveCount==0) && (_curGameStatus == kGameWaitingToStart)) {
        [_startLabelNode removeFromParent];
        
        _timer = [self startNSTimer:_timer interval:0.05f selector:@selector(updateTimerLabel)];
        
        _curGameStatus = kGameStarted;
        
        _startTime = CACurrentMediaTime();
        
        //PRPLog(@"[%@ %@] StartTime=%f", CLS_STR, CMD_STR, _startTime);
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint touchedPos = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:touchedPos];
    
    PRPLog(@"[%@ %@] touched node.name=%@, touchedPos=(%f,%f)", CLS_STR, CMD_STR, node.name, touchedPos.x, touchedPos.y);
    PRPLog(@"[%@ %@] [node.name rangeOfString:kMenuLabelName].location=%d", CLS_STR, CMD_STR, [node.name rangeOfString:kMenuLabelName].location);
    PRPLog(@"[%@ %@] [node.name rangeOfString:kMenuButtonName].location=%d", CLS_STR, CMD_STR, [node.name rangeOfString:kMenuButtonName].location);

    
    if (_curGameStatus == kGameStarted) {
        
        //if a tile been touched after game started
        if (([node.name hasPrefix:kTILE_SPRITE_NAME_PREFIX]) && ([node isKindOfClass:[TileObject class]])) {
            
            PRPLog(@"[%@ %@] prefix correct for tile, _currentTargetRowNumberIndex=%d", CLS_STR, CMD_STR, _currentTargetRowNumberIndex);
            
            //this is used to check if black tile on correct row been tapped
            NSString *subStrToCheck = [NSString stringWithFormat:@"-%d-",_currentTargetRowNumberIndex];
            
            TileObject *touchedTileObj = (TileObject *)node;
            
            if (touchedTileObj.isTappable) {
                
                [touchedTileObj changeTileImageAfterTouched:touchedTileObj.isBlackTile];
                
                //PRPLog(@"[%@ %@] Tapped tile name =%d", CLS_STR, CMD_STR);
                
                //check if tapped on black tile, and also check if the correct row been tapped
                if ((touchedTileObj.isBlackTile) && ([touchedTileObj.name rangeOfString:subStrToCheck].location != NSNotFound)) {
                    
                    //PRPLog(@"[%@ %@] Correct!", CLS_STR, CMD_STR);
                    
                    [self moveAllTilesForwardAfterCorrectMove];
                    
                } else {
                    
                    _curGameStatus = kGameOverIncorrect;
                    
                    //animation that flashes the incorrect tile a few times
                    [touchedTileObj runAction:[[GameData sharedInstance] getFlashAnimation]];
                
                    [self showEndOfGameLabel];
                    
                    //PRPLog(@"[%@ %@] Wrong!", CLS_STR, CMD_STR);
                }
            }
        }
        
    } else if (([node.name rangeOfString:kMenuLabelName].location != NSNotFound) ||
               ([node.name rangeOfString:kMenuButtonName].location != NSNotFound)) {
        
        [self runAction:[[GameData sharedInstance] getButtonTappedSound]];
        
        [self hideOrActionTappedButton:node buttonName:kRESTART];
        [self hideOrActionTappedButton:node buttonName:kEXIT];
        [self hideOrActionTappedButton:node buttonName:kSHARE];
        [self hideOrActionTappedButton:node buttonName:kRESET];
        
    } else {
     
        //PRPLog(@"[%@ %@] tapped on unknown stuff!", CLS_STR, CMD_STR);
    }
}

-(void)hideOrActionTappedButton:(SKNode *)tappedNode buttonName:(NSString *)buttonName
{
    PRPLog(@"[%@ %@] Start, node.name=%@, buttonName=%@, [tappedNode.name rangeOfString:buttonName].location =%d", CLS_STR, CMD_STR, tappedNode.name, buttonName, [tappedNode.name rangeOfString:buttonName].location );
    
    if ([tappedNode.name rangeOfString:buttonName].location != NSNotFound) {

        PRPLog(@"[%@ %@] matched", CLS_STR, CMD_STR);
        
        
        SKNode *button = [gameOverView childNodeWithName:[self getMenuButton:buttonName]];
        
        if (button != nil) {
        
            PRPLog(@"[%@ %@] button not nil", CLS_STR, CMD_STR);
            
            SKAction *growAndShrinkAction = [[GameData sharedInstance] getGrowAndShrinkButtonAfterTappedAnimation];
            
            //small animation on the button, then action on it
            [button runAction:[SKAction sequence:@[
                                                       growAndShrinkAction,
                                                       [SKAction runBlock:^{
                
                if ([buttonName isEqualToString:kRESTART]) {
                    
                    //PRPLog(@"[%@ %@] Restart!", CLS_STR, CMD_STR);
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOAD_NORMAL_GAME_SCENE object: nil];
                    
                } else if ([buttonName isEqualToString:kEXIT]) {
                    
                    //PRPLog(@"[%@ %@] Exit!", CLS_STR, CMD_STR);
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOAD_MAIN_MENU_SCENE object: nil];
                    
                } else if ([buttonName isEqualToString:kSHARE]) {
                    
                    //PRPLog(@"[%@ %@] Share!", CLS_STR, CMD_STR);
                    [[GameData sharedInstance] callSocialSharingMethod];
                    
                } else if ([buttonName isEqualToString:kRESET]) {
                    
                    //PRPLog(@"[%@ %@] Reset!", CLS_STR, CMD_STR);
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset Best Recrods"
                                                                    message:@"Do you really want to reset best time records?"
                                                                   delegate:self
                                                          cancelButtonTitle:@"No"
                                                          otherButtonTitles:nil];
                    // optional - add more buttons:
                    [alert addButtonWithTitle:@"Yes"];
                    [alert show];
                    
                }
                                                        }] // end of runBlock
                                                       ]]
            ];
        }
    } else {
        
        PRPLog(@"[%@ %@] not matching", CLS_STR, CMD_STR);
        
        SKNode *buttonToHide = [gameOverView childNodeWithName:[self getMenuButton:buttonName]];
        
        if (buttonToHide != nil) {
            
            SKAction *buttonAction;
            
            //if tapped button is "share" or "reset", but current button is not "share" or "reset", hide first, then reappear
            //so that when user comes back after "share"/"reset" view, will be back to same view with all 3 buttons as before
            if (([tappedNode.name rangeOfString:kSHARE].location != NSNotFound) ||
                ([tappedNode.name rangeOfString:kRESET].location != NSNotFound)) {

                buttonAction = [SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:0.5f], [SKAction fadeAlphaTo:1 duration:3.0f]]];
                
            } else {
                
                buttonAction = [SKAction fadeAlphaTo:0 duration:0.5f];
            
            }
            
            [buttonToHide runAction:buttonAction];
        }
    }
}

-(void)showButton:(NSString *)buttonName {
    
    SKNode *button = [gameOverView childNodeWithName:buttonName];
    
    if (button != nil) {
        [button setAlpha:1.0];
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    //PRPLog(@"[%@ %@] Start, buttonIndex=%d", CLS_STR, CMD_STR, buttonIndex);
    
    if (buttonIndex == 1) {
        [[GameData sharedInstance] clearBestRecords];
        
        //hide current best time label display, since it's been reset
        SKNode *tmpLabel = [gameOverView childNodeWithName:kBESTTIME];
        if (tmpLabel!=nil) {
            [tmpLabel setAlpha:0];
        }
    }
    
    [self showButton:kSHARE];
    [self showButton:kEXIT];
    [self showButton:kRESTART];
    
}

-(NSTimer *)startNSTimer:(NSTimer *)timerName
                interval:(float)interval
                selector: (SEL)selectorID
{
    //PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    if (![timerName isValid]) {
        timerName = [NSTimer scheduledTimerWithTimeInterval:interval
                                                     target:self
                                                   selector:selectorID
                                                   userInfo:nil
                                                    repeats:YES];
        return timerName;
        
    } else {
        return nil;
    }
}

-(void)stopNSTimer:(NSTimer *)timerName
{
    //PRPLog(@"[%@ %@] Start ", CLS_STR, CMD_STR);
    [timerName invalidate];
}

@end
