//
//  FirstLevel.m
//  trialsofgoku
//
//  Created by Matt on 11/16/14.
//  Copyright (c) 2014 Matt Myers. All rights reserved.
//

#import "FirstLevel.h"

@implementation FirstLevel
{
    NSTimer *enemyHitTimer; // pauses the enemy when hit
    BOOL ballSpawnFlag;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

        #pragma mark Initial Set Up
        ballSpawnFlag = NO;
        self.levelRange = 20;
        self.currentLevelLocation = 0;
        
        #pragma mark Set Up Background
        self.background1 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"bg1"] size:[[UIScreen mainScreen] bounds].size];
        self.background1.position = CGPointMake( CGRectGetMidX([[UIScreen mainScreen] bounds]) , CGRectGetMidY([[UIScreen mainScreen] bounds]));
        self.background2 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"bg1"] size:[[UIScreen mainScreen] bounds].size];
        self.background2.position = CGPointMake( CGRectGetMidX([[UIScreen mainScreen] bounds])+self.background2.frame.size.width , CGRectGetMidY([[UIScreen mainScreen] bounds]));
        
        #pragma mark Set Up Goku
        self.goku = [[Goku alloc] init];
        self.goku = [self.goku setUpGoku];
        [self.goku setUpHealthBar];
        self.goku.delegate = self;  // passes back move background object
        
        #pragma mark Set Up Minions
        self.minion1 = [[Minion alloc] init];
        self.minion1 = [self.minion1 setUpMinionWithName:@"minion1"];
        [self.minion1 setUpHealthBar];
        self.minion2 = [[Minion alloc] init];
        self.minion2 = [self.minion2 setUpMinionWithName:@"minion2"];
        [self.minion2 setUpHealthBar];
        self.minion3 = [[Minion alloc] init];
        self.minion3 = [self.minion3 setUpMinionWithName:@"minion3"];
        [self.minion3 setUpHealthBar];
        self.minion4 = [[Minion alloc] init];
        self.minion4 = [self.minion4 setUpMinionWithName:@"minion4"];
        [self.minion4 setUpHealthBar];

        
        
        
        
        #pragma mark Set Up Buu
 /*       self.finalBoss = [[Buu alloc] init];
        self.finalBoss = [self.finalBoss setUpBuu];
        [self.finalBoss setUpHealthBar];   */
        self.finalBoss = [[Cell alloc] init];
        self.finalBoss = [self.finalBoss setUpCell];
        [self.finalBoss setUpHealthBar];
    
    }
    return self;
}


-(void)setUpLevelForScene:(SKScene *)scene{
    
    self.minion1.position = CGPointMake(700,35);
    self.minion2.position = CGPointMake(self.goku.position.x + 700,35);
    self.minion3.position = CGPointMake(self.goku.position.x + 700,35);
    self.minion4.position = CGPointMake(self.goku.position.x + 350,35);
    
    self.finalBoss.position = CGPointMake(700, 40);
    
    [scene addChild:self.background1];
    [scene addChild:self.background2];
    [scene addChild:self.goku];
    [scene addChild:self.goku.healthBar];

}

-(void)runLevelFor:(SKScene*)scene{
    
    switch (self.currentLevelLocation) {  // activates enemies at necessary times
        case 0://minion1
            if (!self.minion1.isActivated) {
                self.minion1.isActivated=true;
                [scene addChild:self.minion1];
                [scene addChild:self.minion1.healthBar];
            }
        case 1:
            // minion 2
            if(!self.minion2.isActivated && self.minion1.isDead){
                self.minion2.isActivated = true;
                [scene addChild:self.minion2];
                [scene addChild:self.minion2.healthBar];
            }
            break;
        
        case 2://minion3
            if(!self.minion3.isActivated && self.minion1.isDead && self.minion2.isDead)
            {
                self.minion3.isActivated = true;
                [scene addChild:self.minion3];
                [scene addChild:self.minion3.healthBar];
            }
            if(!self.minion4.isActivated && self.minion1.isDead && self.minion2.isDead && self.minion3.isDead){
                self.minion4.isActivated = true;
                [scene addChild:self.minion4];
                [scene addChild:self.minion4.healthBar];
            }
            
            if(!self.finalBoss.isActivated && self.minion1.isDead && self.minion2.isDead && self.minion3.isDead && self.minion4.isDead){
                self.finalBoss.isActivated = true;
                self.finalBoss.position = CGPointMake(self.goku.position.x+320,35);
                [scene addChild:self.finalBoss];
                [scene addChild:self.finalBoss.healthBar];
            }
            break;

        case 3:
            
            if(!self.minion3.isActivated && self.minion2.isDead)
            {
                
            }
            
            break;
            
        default:
            break;
    }
    
    
    [self.goku spawnAndMoveBallsAlongScene:scene];
    [self.goku moveGoku]; // also moves background
    
    // Only 4 minions
    if(self.minion1 != nil)
        [self.minion1 moveInRelationTo:self.goku andBackgroundFlag:self.bgIsMoving];
    if(self.minion2 != nil)
        [self.minion2 moveInRelationTo:self.goku andBackgroundFlag:self.bgIsMoving];
    if(self.minion3 != nil)
        [self.minion3 moveInRelationTo:self.goku andBackgroundFlag:self.bgIsMoving];
    if(self.minion4 != nil)
        [self.minion4 moveInRelationTo:self.goku andBackgroundFlag:self.bgIsMoving];
    if(self.finalBoss != nil)
        [self.finalBoss moveInRelationTo:self.goku andBackgroundFlag:self.bgIsMoving];
}

-(void)handleBossCollisions:(SKPhysicsContact *)contact
{
    // final boss collisions
    if(self.finalBoss != nil) {
        if(self.finalBoss.isActivated){
            if(!self.finalBoss.isDead){
                NSArray* nodeNames = @[contact.bodyA.node.name, contact.bodyB.node.name];
                if ([nodeNames containsObject:@"boss"] && [nodeNames containsObject:@"ball1"]) {
                    [self.finalBoss handleCollisionWithGoku:self.goku];
                }else if ([nodeNames containsObject:@"boss"] && [nodeNames containsObject:@"ball2"]) {
                    [self.finalBoss handleCollisionWithGoku:self.goku];
                }
            }
        }
    }
    
    // minion collisions
    [self handleMinionCollisions:contact];
  
}

@end
