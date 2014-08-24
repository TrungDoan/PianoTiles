//
//  GameData.h
//  PianoTiles
//
//  Copyright (c) 2013 Allanunu Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "ViewController.h"

#define kVERSION_NUMBER @"1.00"

#define kNSUserDefaultSettings [NSUserDefaults standardUserDefaults]

#define kMAX_NUMBER_OF_ROWS_PER_GAME (kNUMB_OF_ROWS_PER_COLUMN+2)

#define kSYSTEM_FONT_NAME @"MarkerFelt-Wide"

#define kMenuLabelName @"Label-"
#define kMenuButtonName @"Button-"
#define kGAME_NAME_PREFIX @"Classic"
#define kNameBestRecordKeyName @"BestRecordList"

#define kVIEW_URL_APP_STORE @"https://itunes.apple.com/us/app/piano-tiles-open-sourced/id905313423?ls=1&mt=8"
#define kImageToUseForTwitterAndFacebook @"PianoTilesOpenSource256x256.png"

#define KVIEW_URL_SOURCE @"http://allanunustudio.blogspot.com.au/2014/08/new-open-source-game.html"

#define kMaxSoundFileCounter 8

#define kMAX_NUMBER_ELEMENT_IN_BEST_RECORD_ARRAY 2

#define kBackgroundColour [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0]
#define kBackgroundColourFailed  [SKColor colorWithRed:0.85 green:0.15 blue:0.15 alpha:1.0]

#define kSingleTileImage @"White16x16.png"

#define NOTIFICATION_LOAD_NORMAL_GAME_SCENE @"NOTIFICATION_LOAD_NORMAL_GAME_SCENE"
#define NOTIFICATION_LOAD_MAIN_MENU_SCENE @"NOTIFICATION_LOAD_MAIN_MENU_SCENE"

//number of tiles to complete for each level
#define kValueLevel1 25
#define kValueLevel2 50

#define kDefaultBestTimeValue 999.9

typedef enum {
    kGameMainMenu,
    kGameWaitingToStart,
    kGameStarted,
    kGameOverCompleted,
    kGameOverIncorrect,
} gameStatus;

typedef enum {
    kIPhone3=100,
    kIPhoneRetina,
    kIPhoneRetina5,
    kIPhoneRetina6,
    kIPad2,
    kIPadRetina
} deviceTypeDef;


@interface GameData : NSObject

@property (nonatomic) deviceTypeDef deviceType;
@property (nonatomic) CGRect deviceScreenFrame;
@property (nonatomic) gameStatus curGameStatus;
@property (nonatomic) int gameTypeValue;
@property (nonatomic) float tileWidth;
@property (nonatomic) float tileHeight;

@property (nonatomic) ViewController *vController;

//to make this class a singleton
+ (GameData *)sharedInstance;

-(void)initAllData;

//song/sound related
-(SKAction *)getButtonTappedSound;
-(SKAction *)getMainMenuStartUpSound;
-(SKAction *)getNextNoteAsSKActionToPlay;
-(SKAction *)getSuccessNotes;
-(SKAction *)getFailedNotes;
-(SKAction *)getNewRecordSound;

//animation
-(SKAction *)getFlashAnimation;
-(SKAction *)getViewDroppingFromTopAnimation:(float)finalYPos;
-(SKAction *)getGrowAndShrinkButtonAfterTappedAnimation;

-(void)loadDataFromNSUserDefaults;
-(void)callSocialSharingMethod;
-(void)nextSongAfterGameEnded;
-(BOOL)updateAndCheckIfNewRecord:(float)resultOfCurrentGame;
-(float)getBestRecord;
-(void)clearBestRecords;

@end
