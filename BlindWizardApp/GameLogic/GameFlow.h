//
//  GameFlow.h
//  BlindWizardApp
//
//  Created by N A on 7/1/15.
//  Copyright (c) 2015 Adronitis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameAction.h"

@class Queue;
@class GameBoard;

@interface GameFlow : NSObject
@property (nonatomic, strong) Queue *queue; //inject
@property (nonatomic, strong) GameBoard *gameBoard; //inject
- (void) addGameAction:(id<GameAction>)gameAction;
@end
