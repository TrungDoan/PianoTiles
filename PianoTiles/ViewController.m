//
//  ViewController.m
//  PianoTiles
//
//  Copyright (c) 2014 Allanunu Studio. All rights reserved.
//

#import "ViewController.h"
#import "MainMenuScene.h"
#import "GameScene.h"
#import "GameData.h"
#import "PRPDebug.h"

@implementation ViewController {
    
    SKView *skView;
    SKTransition *revealTransition;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(loadNormalGameScene)
                                                 name: NOTIFICATION_LOAD_NORMAL_GAME_SCENE
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(loadMainMenuScene)
                                                 name: NOTIFICATION_LOAD_MAIN_MENU_SCENE
                                               object: nil];
    

    // Configure the view.
    skView = (SKView *)self.view;
    
    //enable these 2 lines to show FPS and node count
    //skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    
    revealTransition = [SKTransition flipHorizontalWithDuration:0.85f];
    
    [self setupData];
    
}

-(void)loadMainMenuScene
{
    //PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    
    SKScene *scene = [MainMenuScene sceneWithSize:skView.bounds.size];
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene
    [skView presentScene:scene transition:revealTransition];

}

-(void)loadNormalGameScene
{
    //PRPLog(@"[%@ %@] Start, levelValue=%d", CLS_STR, CMD_STR, [[GameData sharedInstance] gameTypeValue]);
    
    GameScene *myScene = [[GameScene alloc] initWithSizeAndTargetTileCount:skView.bounds.size targetTileCount:[[GameData sharedInstance] gameTypeValue]];
    
    myScene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene
    [skView presentScene:myScene transition:revealTransition];
    
}

-(void)setupData
{
    //PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    [[GameData sharedInstance] setDeviceScreenFrame:self.view.frame];
    
    [[GameData sharedInstance] setVController:self];
    
    //PRPLog(@"[%@ %@] screenWidth=%f, screenHeight=%f", CLS_STR, CMD_STR,screenWidth, screenHeight);
    
    float uiscale = [[UIScreen mainScreen] scale];
    
    //PRPLog(@"[%@ %@] uiscale=%f", CLS_STR, CMD_STR, uiscale);
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //PRPLog(@"[%@ %@] - is iPhone (UIUserInterfaceIdiomPhone)", CLS_STR, CMD_STR);
        
        if (uiscale <2.0) {
            
            //PRPLog(@"[%@ %@] it's iPhone 3 ", CLS_STR, CMD_STR);
            [[GameData sharedInstance] setDeviceType:kIPhone3];
            
        } else {
            
            //The iPhone is 320×480, the iPhone 4 is 640×960 and the iPhone 5 is 640×1136
            
            if (screenHeight==568) {
                //PRPLog(@"[%@ %@] it's iPhone 5 ", CLS_STR, CMD_STR);
                [[GameData sharedInstance] setDeviceType:kIPhoneRetina5];
                
            } else {
                //PRPLog(@"[%@ %@] it's iPhone 4 ", CLS_STR, CMD_STR);
                [[GameData sharedInstance] setDeviceType:kIPhoneRetina];
            }
        }
        
    } else {
        //PRPLog(@"[%@ %@] - is NOT iPhone (UIUserInterfaceIdiomPhone)", CLS_STR, CMD_STR);

        if (uiscale <2.0) {
            [[GameData sharedInstance] setDeviceType:kIPad2];
        } else {
            [[GameData sharedInstance] setDeviceType:kIPadRetina];
        }
    }
   
    [[GameData sharedInstance] initAllData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOAD_MAIN_MENU_SCENE object: nil];

}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
