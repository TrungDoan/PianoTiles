//
//  GameData.m
// PianoTiles
//
//  Copyright (c) 2014 Allanunu Studio. All rights reserved.
//

#import "GameData.h"
#import "PRPDebug.h"

//this defines the static arrays for the songs
static NSArray *_songsArray;
static NSArray *_song1Ary;
static NSArray *_song2Ary;
static NSArray *_song3Ary;
static NSArray *_sizeOfSongArray;
static int _maxSongCount = 3;

@implementation GameData {
    
    SKAction *_soundAry[kMaxSoundFileCounter];
    
    int _noteInSongCounter; // this keeps track of which note of current song it's currently playing
    int _songCounter; // this keeps track of the song number
    
    //array to hold best records
    NSMutableArray *_bestRecordArray;
    
    CGRect _deviceScreenFrame;
    
    //current game type
    int _gameTypeValue;
}

@synthesize deviceScreenFrame=_deviceScreenFrame;
@synthesize gameTypeValue=_gameTypeValue;

//to make this class singleton
static GameData *sharedHelper = nil;

+(GameData *) sharedInstance {
    
    if (!sharedHelper) {
    
        sharedHelper = [[GameData alloc] init];
        
//===================================================
//define the songs here
        
        // 0 - do
        // 1 - re
        // 2 - mi
        // 3 - fa
        // 4 - so
        // 5 - la
        // 6 - ti
        // 7 - do
        
        _song1Ary = [NSArray arrayWithObjects:  //song #1
                     @"2", @"4", @"4", @"2",
                     @"1", @"3", @"3", @"1",
                     @"0", @"2", @"2", @"0",
                     @"1", @"4", @"4",
                     @"2", @"4", @"4", @"2",
                     @"1", @"3", @"3", @"1",
                     @"2", @"0", @"1", @"1",
                     @"0",
                     nil];
        
        _song2Ary = [NSArray arrayWithObjects:  //song #2
                     @"0", @"0", @"4", @"4",
                     @"5", @"5", @"4",
                     @"3", @"3", @"2", @"2",
                     @"1", @"1", @"0",
                     @"4", @"4", @"3", @"3",
                     @"2", @"2", @"1",
                     @"4", @"4", @"3", @"3",
                     @"2", @"2", @"1",
                     @"0", @"0", @"4", @"4",
                     @"5", @"5", @"4",
                     @"3", @"3", @"2", @"2",
                     @"1", @"1", @"0",
                     nil];
        
        _song3Ary = [NSArray arrayWithObjects:  //song #3
                     @"0", @"4", @"2", @"4",
                     @"0", @"4", @"2", @"4",
                     @"1", @"5", @"3", @"5",
                     @"1", @"5", @"3", @"5",
                     nil];
        
        _songsArray = [NSArray arrayWithObjects:_song1Ary, _song2Ary, _song3Ary, nil];
        
        //the number of notes in each song
        _sizeOfSongArray = [NSArray arrayWithObjects:
                            [NSNumber numberWithInt:28],
                            [NSNumber numberWithInt:42],
                            [NSNumber numberWithInt:16],
                            nil];

//===================================================
        
    }
    return sharedHelper;
}

-(void)initAllData {
    
    //load do(C) - so(G)
    for (int ii=0; ii<5; ii++) {
        
        _soundAry[ii] = [SKAction playSoundFileNamed: [NSString stringWithFormat:@"piano-%c.caf", 67+ii]  //ascii code of "C" is 67
                                  waitForCompletion: NO];
    }
    
    //remaining la(A), ti(B), high-do(HighC)
    _soundAry[5] = [SKAction playSoundFileNamed: @"piano-A.caf" waitForCompletion: NO];
    _soundAry[6] = [SKAction playSoundFileNamed: @"piano-B.caf" waitForCompletion: NO];
    _soundAry[7] = [SKAction playSoundFileNamed: @"piano-HighC.caf" waitForCompletion: NO];
    
    //declare best record array
    _bestRecordArray = [[NSMutableArray alloc] initWithCapacity:kMAX_NUMBER_ELEMENT_IN_BEST_RECORD_ARRAY];
    
    //load best record data from NSUserDefaults
    [self loadDataFromNSUserDefaults];
    
    _noteInSongCounter=0;
    _songCounter=0;

}

-(SKAction *)getButtonTappedSound {
    return [SKAction playSoundFileNamed: @"pop.caf" waitForCompletion: NO];
}

-(SKAction *)getMainMenuStartUpSound {
    
    SKAction *notesReturned = [SKAction sequence:@[
                                                [SKAction waitForDuration:0.4],
                                                _soundAry[0],
                                                [SKAction waitForDuration:0.2],
                                                _soundAry[4],
                                                [SKAction waitForDuration:0.2],
                                                _soundAry[2],
                                                [SKAction waitForDuration:0.2],
                                                _soundAry[4],
                                                [SKAction waitForDuration:0.2],
                                                _soundAry[0],
                                                ]];
    return notesReturned;
}

-(SKAction *)getNewRecordSound {
    return [SKAction playSoundFileNamed:@"CrowdCheer1.caf" waitForCompletion:NO];
}

-(SKAction *)getSuccessNotes {
    return [SKAction playSoundFileNamed:@"CrowdCheer2.caf" waitForCompletion:NO];
}

-(SKAction *)getFailedNotes {
    
    SKAction *notesReturned = [SKAction sequence:@[
                                                   _soundAry[0],
                                                   [SKAction waitForDuration:0.5],
                                                   _soundAry[0]
                                                   ]];
    return notesReturned;
}

//updates song counter after game ended
-(void)nextSongAfterGameEnded {
    //PRPLog(@"[%@ %@] Start ", CLS_STR, CMD_STR);
    _songCounter++;
    _noteInSongCounter=0;
    if (_songCounter>=_maxSongCount) {
        _songCounter=0;
    }
}

-(SKAction *)getNextNoteAsSKActionToPlay {
    
    //PRPLog(@"[%@ %@] !!! soundCounter=%d", CLS_STR, CMD_STR, _soundCounter);
    
    NSArray *currentSong = _songsArray[_songCounter];
    int songMaxNoteSize = [(NSNumber *)_sizeOfSongArray[_songCounter] intValue];
    
    NSString *_nextNote = (NSString *)[currentSong objectAtIndex:_noteInSongCounter];
    
    int _noteValue = [_nextNote intValue];
    
    //PRPLog(@"[%@ %@] _songArray[_soundCounter]=[%@], NextNote=[%@], noteValue=%d", CLS_STR, CMD_STR, [_songArray objectAtIndex:_soundCounter], _nextNote, _noteValue);
    
    _noteInSongCounter++;
    if (_noteInSongCounter >= songMaxNoteSize) {
        _noteInSongCounter = 0;
    }
    
    SKAction *oneNote = _soundAry[_noteValue];
    
    return oneNote;
}

-(SKAction *)getFlashAnimation {
    
    float actionTime = 0.25f;
    
    SKAction *tileHide = [SKAction colorizeWithColorBlendFactor:0 duration:actionTime];
    SKAction *tileShow = [SKAction colorizeWithColorBlendFactor:1 duration:actionTime];
    
    SKAction *flashing = [SKAction sequence:@[tileHide, tileShow, tileHide, tileShow, tileHide, tileShow, tileHide, tileShow]];
    
    return flashing;
}

-(SKAction *)getViewDroppingFromTopAnimation:(float)finalYPos {

    SKAction *returningAction = [SKAction sequence:@[
                                                     [SKAction waitForDuration:1.0f],
                                                     [SKAction moveToY:finalYPos duration:0.5f],
                                                     [SKAction moveToY:finalYPos+50 duration:0.3f],
                                                     [SKAction moveToY:finalYPos duration:0.3f],
                                                     [SKAction moveToY:finalYPos+20 duration:0.1f],
                                                     [SKAction moveToY:finalYPos duration:0.1f]
                                                     ]];
    
    return returningAction;
}

-(SKAction *)getGrowAndShrinkButtonAfterTappedAnimation {
    
    SKAction *returningAction = [SKAction sequence:@[
                                                    [self getButtonTappedSound],
                                                    [SKAction waitForDuration:0.10f],
                                                    [SKAction scaleBy:1.1f duration:0.15f],
                                                    [SKAction scaleBy:0.9f duration:0.15f],
                                                    [SKAction scaleBy:1.1f duration:0.15f],
                                                    //[SKAction scaleBy:0.9f duration:0.15f],
                                                    [SKAction scaleBy:1.0f duration:0.10f],
                                                    [SKAction waitForDuration:0.20f]
                                                    
                                                    ]];
    return returningAction;
}

-(NSString *)getBestRecordKeyName:(int)index {
    
    int tmpIndex = index;
    
    if (tmpIndex>=kMAX_NUMBER_ELEMENT_IN_BEST_RECORD_ARRAY) {
        tmpIndex = kMAX_NUMBER_ELEMENT_IN_BEST_RECORD_ARRAY - 1;
    }
    
    return [NSString stringWithFormat:@"%@-%i", kNameBestRecordKeyName, tmpIndex];
}

-(float)getBestRecord {
    
    int tmpIndex;
    
    if (_gameTypeValue==kValueLevel1) {
        tmpIndex = 0;
    } else {
        tmpIndex = 1;
    }
    
    return [_bestRecordArray[tmpIndex] floatValue];
}

-(BOOL)updateAndCheckIfNewRecord:(float)resultOfCurrentGame {
    
    //PRPLog(@"[%@ %@] Start, resultOfCurrentGame=%f", CLS_STR, CMD_STR, resultOfCurrentGame);
    
    BOOL ifNewRecord = NO;
    int tmpIndex;
    
    if (_gameTypeValue==kValueLevel1) {
        tmpIndex = 0;
    } else {
        tmpIndex = 1;
    }
    
    if (tmpIndex>=kMAX_NUMBER_ELEMENT_IN_BEST_RECORD_ARRAY) {
        tmpIndex = kMAX_NUMBER_ELEMENT_IN_BEST_RECORD_ARRAY - 1;
    }
    
    if (resultOfCurrentGame <= [_bestRecordArray[tmpIndex] floatValue]) {
        
        //PRPLog(@"[%@ %@] New best time %f for index %d!! ", CLS_STR, CMD_STR, resultOfCurrentGame, tmpIndex);
        
        _bestRecordArray[tmpIndex] = [NSNumber numberWithFloat:resultOfCurrentGame];
        
        [self saveDataToNSUserDefaults];
        
        ifNewRecord = YES;
    }
    
    //move to next song
    [self nextSongAfterGameEnded];
    
    return ifNewRecord;
}

-(NSNumber *)getNSUserDefaultsValueInNSNumber:(NSUserDefaults *)defSettings keyName:(NSString *)keyName {
    
    if (![defSettings objectForKey:keyName]) {
        [defSettings setObject:[NSNumber numberWithFloat:kDefaultBestTimeValue] forKey:keyName];
    }
    
    return (NSNumber *)[defSettings objectForKey:keyName];
}

-(void)clearBestRecords {
    
    for (int ii=0; ii<kMAX_NUMBER_ELEMENT_IN_BEST_RECORD_ARRAY; ii++) {
        
        _bestRecordArray[ii] = [NSNumber numberWithFloat:kDefaultBestTimeValue];
        
        [kNSUserDefaultSettings setObject:_bestRecordArray[ii]
                                   forKey:[self getBestRecordKeyName:ii]];
    }
    
    [kNSUserDefaultSettings synchronize];
    
}

-(void)loadDataFromNSUserDefaults {
    
    //PRPLog(@"[%@ %@] Start ", CLS_STR, CMD_STR);
    
    for (int ii=0; ii<kMAX_NUMBER_ELEMENT_IN_BEST_RECORD_ARRAY; ii++) {
        
        _bestRecordArray[ii] = [self getNSUserDefaultsValueInNSNumber:kNSUserDefaultSettings keyName:[self getBestRecordKeyName:ii]];
        
        
        //PRPLog(@"[%@ %@] bestRecordArray[%d]=%f ", CLS_STR, CMD_STR, ii, [_bestRecordArray[ii] floatValue]);
    }
    
}

//save settings to NSUserDefaults
-(void)saveDataToNSUserDefaults {
    
    //PRPLog(@"[%@ %@] Start ", CLS_STR, CMD_STR);
        
    for (int ii=0; ii<kMAX_NUMBER_ELEMENT_IN_BEST_RECORD_ARRAY; ii++) {
        
        [kNSUserDefaultSettings setObject:_bestRecordArray[ii]
                                   forKey:[self getBestRecordKeyName:ii]];
    }
    
    [kNSUserDefaultSettings synchronize];
}

-(void)callSocialSharingMethod {
    
    //PRPLog(@"[%@ %@] Start ", CLS_STR, CMD_STR);
    
    NSString *text = @"Check out my score in Piano Tiles Open Source, this is so cool!";
    NSURL *url = [NSURL URLWithString:kVIEW_URL_APP_STORE];
    UIImage *image = [UIImage imageNamed:kImageToUseForTwitterAndFacebook];
    
    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[text, url, image]
     applicationActivities:nil];
    
    [self.vController presentViewController:controller animated:YES completion:nil];
}


@end
