//
//  BaseCharacter.m
//  trialsofgoku
//
//  Created by Matt on 11/15/14.
//  Copyright (c) 2014 Matt Myers. All rights reserved.
//

#import "BaseObject.h"
#import "Goku.h"
#import "Buu.h"

@implementation BaseObject
{
    NSTimer* hitTimer;
}

-(void)updateHealthBar
{
    // 3 sizes
    float ratio = (float)self.health/(float)self.totalHealth;
    
    if(ratio == 0){
        [self.healthBar runAction:[SKAction animateWithTextures:[NSArray arrayWithObject:[SKTexture textureWithImageNamed:@"dead_health"]] timePerFrame:0]];
    }else if(ratio < .34){
        [self.healthBar runAction:[SKAction animateWithTextures:[NSArray arrayWithObject:[SKTexture textureWithImageNamed:@"low_health"]] timePerFrame:0]];
    }else if (ratio < .67){
        [self.healthBar runAction:[SKAction animateWithTextures:[NSArray arrayWithObject:[SKTexture textureWithImageNamed:@"medium_health"]] timePerFrame:0]];
    }
    
}

-(void)moveHealthBar
{
    if(self.healthBar != nil)
        self.healthBar.position = CGPointMake(self.position.x, self.position.y+30);
}
-(void)setUpHealthBar
{
    self.healthBar = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"full_health"] size:CGSizeMake(40, 15)];
}

-(void)runAnimation:(NSArray*)animationFrames atFrequency:(float)frequency withKey:(NSString*)animationKey{
    [self runAction:[SKAction repeatActionForever:
                     [SKAction animateWithTextures:animationFrames
                                      timePerFrame:frequency
                                            resize:NO
                                           restore:YES]] withKey:animationKey];
    return;
}
-(void)runCountedAnimation:(NSArray*)animationFrames withCount:(int)myCount atFrequency:(float)frequency withKey:(NSString*)animationKey{
    [self runAction:[SKAction repeatAction:
                     [SKAction animateWithTextures:animationFrames
                                      timePerFrame:frequency
                                            resize:NO
                                           restore:YES] count:myCount] withKey:animationKey];
    return;
    
}

-(void)haltVelocity:(NSString*)axis
{
    if([[axis uppercaseString] isEqualToString:@"X"]){
        self.velocity = CGPointMake(0, self.velocity.y);
    }else if([[axis uppercaseString] isEqualToString:@"Y"]){
        self.velocity = CGPointMake(self.velocity.x, 0);
    }else{
        self.velocity = CGPointMake(0, 0);
    }
}


-(void)moveInRelationTo:(Goku*)goku andBackgroundFlag:(BOOL)bgIsMoving
{
    if(self != nil){
        if(self.isActivated){
            if(!self.isDead){
                
                [self moveHealthBar];
                
                if(!self.isHit){
                    if(self.position.x > goku.position.x){ // minion to the right
                        if([self.lastDirection isEqualToString:@"right"]){
                            self.velocity = CGPointMake(-1,self.velocity.y);
                            self.xScale = -1;
                            self.lastDirection = @"left";
                        }
                    }else{ // buu to the left
                        if([self.lastDirection isEqualToString:@"left"]){
                            self.velocity = CGPointMake(1,self.velocity.y);
                            self.xScale = 1;
                            self.lastDirection = @"right";
                        }
                    }
                    if(bgIsMoving)
                        self.position = CGPointMake(self.position.x+self.velocity.x- goku.velocity.x,self.position.y);
                    else
                        self.position = CGPointMake(self.position.x+self.velocity.x-(goku.velocity.x/50),self.position.y);
                    
                }else{
                    if(bgIsMoving)
                        self.position = CGPointMake(self.position.x - goku.velocity.x, self.position.y);
                    
                }
            }else{
                if(bgIsMoving){
                    self.position = CGPointMake(self.position.x - goku.velocity.x, self.position.y);
                    [self moveHealthBar];
                    
                }
            }
        }
    }
}


-(void)handleCollisionWithGoku:(Goku*)goku
{
    switch ([goku getBallSize:1]) {
        case 1:
            self.health -= 10;
            break;
        case 2:
            self.health -= 20;
            break;
        case 3:
            self.health -= 30;
            break;
    }
    if(self.health <= 0){
        self.health = 0;
        self.isDead = true;
        if([self.typeOfObject isEqualToString:@"buu"]){
            [self runAnimation:[NSMutableArray arrayWithObject:[SKTexture textureWithImageNamed:@"buu_deadfrom_right"]] atFrequency:.2f withKey:@"final_boss_animation_key"]; // animate death
        }else if([self.typeOfObject isEqualToString:@"cell"]){
            [self runAnimation:[NSMutableArray arrayWithObject:[SKTexture textureWithImageNamed:@"cell_deadfrom_right"]] atFrequency:.2f withKey:@"final_boss_animation_key"]; // animate death
        }else if([self.typeOfObject isEqualToString:@"minion"]){
            [self runAnimation:[NSMutableArray arrayWithObject:[SKTexture textureWithImageNamed:@"minion_deadfrom_right"]] atFrequency:.2f withKey:@"final_boss_animation_key"]; // animate death
        }
        
        
    }else{
        self.isHit = true;
        
        // create
        hitTimer = [NSTimer scheduledTimerWithTimeInterval: .5
                                                    target:self
                                                  selector:@selector(handleHit:)
                                                  userInfo:nil
                                                   repeats:NO];
        
        if([self.typeOfObject isEqualToString:@"buu"]){
            [self runCountedAnimation:[NSMutableArray arrayWithObject:[SKTexture textureWithImageNamed:@"buu_hitfrom_right_1"]] withCount:1 atFrequency:.5f withKey:@"final_boss_animation_key"]; // animate hit
        }else if([self.typeOfObject isEqualToString:@"cell"]){
            [self runCountedAnimation:[NSMutableArray arrayWithObject:[SKTexture textureWithImageNamed:@"cell_hitfrom_right_1"]] withCount:1 atFrequency:.5f withKey:@"final_boss_animation_key"]; // animate hit
        }else if([self.typeOfObject isEqualToString:@"minion"]){
            [self runCountedAnimation:[NSMutableArray arrayWithObject:[SKTexture textureWithImageNamed:@"minion_hitfrom_right_1"]] withCount:1 atFrequency:.5f withKey:@"final_boss_animation_key"]; // animate hit
        }
    }
    [self updateHealthBar];
}


-(void)handleHit:(NSTimer*) timer
{
    self.isHit = false;
}




@end
