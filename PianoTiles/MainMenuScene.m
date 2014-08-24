//
//  MainMenuScene.m
//  PianoTiles
//
//  Copyright (c) 2014 Allanunu Studio. All rights reserved.
//

#import "MainMenuScene.h"
#import "GameData.h"
#import "PRPDebug.h"

#define kOpenSourceLinkName @"OpenSourceLinkName"

@implementation MainMenuScene {
    
    UIWebView *webView;
    
    float greyButtonBackgroundWidth; // width of label to indicate it's a tappable button
    
}

-(void)didMoveToView:(SKView *)view {
    
    //PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    
    float menuItemFontSize;
    
    [[GameData sharedInstance] setCurGameStatus:kGameMainMenu];
    
    self.backgroundColor = kBackgroundColour;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        menuItemFontSize = 40.0f;
        greyButtonBackgroundWidth = 200.0f;
        
    } else {
        
        menuItemFontSize = 80.0f;
        greyButtonBackgroundWidth = 400.0f;
        
    }
    
    //setup Main Menu
    
    [self runAction:[[GameData sharedInstance] getMainMenuStartUpSound]];
    
    //===============
    //Main menu title
    
    SKLabelNode *mainMenuTitleLabelNode = [SKLabelNode labelNodeWithFontNamed:kSYSTEM_FONT_NAME];
    mainMenuTitleLabelNode.position = CGPointMake(CGRectGetMidX(self.frame),0.7f*self.frame.size.height);
    mainMenuTitleLabelNode.zPosition = 1000;
    mainMenuTitleLabelNode.text = @"Main Menu";
    mainMenuTitleLabelNode.fontSize = menuItemFontSize*1.3f;
    mainMenuTitleLabelNode.fontColor = [SKColor whiteColor];
    mainMenuTitleLabelNode.name = @"MainMenu";
    [self addChild:mainMenuTitleLabelNode];
    
    //===============
    //button #1
    
    SKSpriteNode *buttonNode1 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:kSingleTileImage]];
    buttonNode1.anchorPoint = CGPointMake(0.5f, 0.5f);
    buttonNode1.size = CGSizeMake(greyButtonBackgroundWidth, menuItemFontSize*1.2f);
    buttonNode1.position = CGPointMake(CGRectGetMidX(self.frame), 0.5f*self.frame.size.height);
    buttonNode1.colorBlendFactor = 1.0f;
    buttonNode1.color = [SKColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:0.5];
    buttonNode1.name = [self getStartMenuButton:kValueLevel1];
    buttonNode1.zPosition = 1000;
    
    SKLabelNode *startLabelNode = [SKLabelNode labelNodeWithFontNamed:kSYSTEM_FONT_NAME];
    startLabelNode.position = CGPointMake(0,-0.4f*menuItemFontSize);
    startLabelNode.zPosition = 900;
    startLabelNode.text = [NSString stringWithFormat:@"%@ %d", kGAME_NAME_PREFIX, kValueLevel1];
    startLabelNode.fontSize = menuItemFontSize;
    startLabelNode.fontColor = [SKColor whiteColor];
    startLabelNode.name = [self getStartMenuLabel:kValueLevel1];
    [buttonNode1 addChild:startLabelNode];
    [self addChild:buttonNode1];
    
    //===============
    //button #2
    
    SKSpriteNode *buttonNode2 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:kSingleTileImage]];
    buttonNode2.anchorPoint = CGPointMake(0.5f, 0.5f);
    buttonNode2.size = CGSizeMake(greyButtonBackgroundWidth, menuItemFontSize*1.2f);
    buttonNode2.position = CGPointMake(CGRectGetMidX(self.frame), 0.3f*self.frame.size.height);
    buttonNode2.colorBlendFactor = 1.0f;
    buttonNode2.color = [SKColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:0.5];
    buttonNode2.name = [self getStartMenuButton:kValueLevel2];
    buttonNode2.zPosition = 1000;

    SKLabelNode *startLabelNode2 = [SKLabelNode labelNodeWithFontNamed:kSYSTEM_FONT_NAME];
    startLabelNode2.position = CGPointMake(0,-0.4f*menuItemFontSize);
    startLabelNode2.zPosition = 900;
    startLabelNode2.text = [NSString stringWithFormat:@"%@ %d", kGAME_NAME_PREFIX, kValueLevel2];
    startLabelNode2.fontSize = menuItemFontSize;
    startLabelNode2.fontColor = [SKColor whiteColor];
    startLabelNode2.userInteractionEnabled=NO;
    startLabelNode2.name = [self getStartMenuLabel:kValueLevel2];
    [buttonNode2 addChild:startLabelNode2];
    [self addChild:buttonNode2];
    
    //===============
    //Show version number
    
    SKLabelNode *mainMenuVersionNumberLabelNode = [SKLabelNode labelNodeWithFontNamed:kSYSTEM_FONT_NAME];
    mainMenuVersionNumberLabelNode.position = CGPointMake(0,0);
    mainMenuVersionNumberLabelNode.zPosition = 1000;
    mainMenuVersionNumberLabelNode.text = [NSString stringWithFormat:@"Ver %@",kVERSION_NUMBER];
    mainMenuVersionNumberLabelNode.fontSize = menuItemFontSize*0.5f;
    mainMenuVersionNumberLabelNode.fontColor = [SKColor whiteColor];
    mainMenuVersionNumberLabelNode.name = @"VersionNumber";
    [self addChild:mainMenuVersionNumberLabelNode];

    
    //===============
    //Show Open Source link
    
    SKSpriteNode *buttonNode3 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:kSingleTileImage]];
    buttonNode3.anchorPoint = CGPointMake(0.5f, 0.5f);
    buttonNode3.size = CGSizeMake(greyButtonBackgroundWidth*0.75f, menuItemFontSize*1.2f);
    buttonNode3.position = CGPointMake(self.frame.size.width*0.8f, 0);
    buttonNode3.colorBlendFactor = 1.0f;
    buttonNode3.color = [SKColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:0.5];
    buttonNode3.name = [NSString stringWithFormat:@"%@-%@", kMenuButtonName, kOpenSourceLinkName];
    buttonNode3.zPosition = 1000;
    
    SKLabelNode *mainMenuOpenSourceLabelNode = [SKLabelNode labelNodeWithFontNamed:kSYSTEM_FONT_NAME];
    mainMenuOpenSourceLabelNode.position = CGPointMake(0, 0.1*menuItemFontSize);//CGPointMake(0,-0.4f*menuItemFontSize);
    mainMenuOpenSourceLabelNode.zPosition = 1000;
    mainMenuOpenSourceLabelNode.text = @"Open Source link";
    mainMenuOpenSourceLabelNode.fontSize = menuItemFontSize*0.4f;
    mainMenuOpenSourceLabelNode.fontColor = [SKColor whiteColor];
    mainMenuOpenSourceLabelNode.name = [NSString stringWithFormat:@"%@-%@", kMenuLabelName, kOpenSourceLinkName];;
    [buttonNode3 addChild:mainMenuOpenSourceLabelNode];
    [self addChild:buttonNode3];
    
}

-(NSString *)getStartMenuLabel:(int)value
{

    return [NSString stringWithFormat:@"%@-%d", kMenuLabelName, value];
}

-(NSString *)getStartMenuButton:(int)value
{
    
    return [NSString stringWithFormat:@"%@-%d", kMenuButtonName, value];
}

-(void)performButtonAction:(int)levelValue {

    [[GameData sharedInstance] setGameTypeValue:levelValue];
    
    SKNode *button = [self childNodeWithName:[self getStartMenuButton:levelValue]];
    
    if (button != nil) {
        
        [button runAction:[SKAction sequence:@[
                                               [[GameData sharedInstance] getGrowAndShrinkButtonAfterTappedAnimation],
                                               [SKAction runBlock:^{
            
                                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOAD_NORMAL_GAME_SCENE
                                                                                                    object:nil];
            
                                               }] //end of block
                                              ]]];
    }
}

-(void)ShowUIWebView{
    
    PRPLog(@"[%@ %@] Start, KVIEW_URL_SOURCE=%@", CLS_STR, CMD_STR, KVIEW_URL_SOURCE);
 
    NSURL *urlApp = [NSURL URLWithString: KVIEW_URL_SOURCE];
    [[UIApplication sharedApplication] openURL:urlApp];
    
    PRPLog(@"[%@ %@] END", CLS_STR, CMD_STR);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    PRPLog(@"[%@ %@] Start, buttonIndex=%d", CLS_STR, CMD_STR, buttonIndex);
    
    if (buttonIndex == 1) {
        
        [self ShowUIWebView];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    PRPLog(@"[%@ %@] touched node.name=%@", CLS_STR, CMD_STR, node.name);
    
    if (node.name != nil) {
    
        if (([node.name isEqualToString:[self getStartMenuLabel:kValueLevel1]]) ||
            ([node.name isEqualToString:[self getStartMenuButton:kValueLevel1]]))
        {
            [self performButtonAction:kValueLevel1];
            
        } else if (([node.name isEqualToString:[self getStartMenuLabel:kValueLevel2]]) ||
                   ([node.name isEqualToString:[self getStartMenuButton:kValueLevel2]]))
        {
            [self performButtonAction:kValueLevel2];
            
        } else if ([node.name rangeOfString:kOpenSourceLinkName].location != NSNotFound) {
            
            SKNode *button = [self childNodeWithName:[NSString stringWithFormat:@"%@-%@", kMenuButtonName, kOpenSourceLinkName]];
            
            if (button != nil) {
                
                [button runAction:[SKAction sequence:@[
                                                       [[GameData sharedInstance] getGrowAndShrinkButtonAfterTappedAnimation],
                                                       [SKAction runBlock:^{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Open Source"
                                                                    message:@"This will open an external web link"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                          otherButtonTitles:nil];
                    [alert addButtonWithTitle:@"OK"];
                    [alert show];
                    
                }] //end of block
                                                       ]]];
            }
            
        }
    }
}

@end
