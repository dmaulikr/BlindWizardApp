//
//  ShiftEnemiesRightGameAction.h
//  BlindWizardApp
//
//  Created by N A on 7/4/15.
//  Copyright (c) 2015 Adronitis. All rights reserved.
//

#import "GameAction.h"

@protocol GameDependencyFactory;
@class GameBoard;

@interface ShiftEnemiesRightGameAction : NSObject <GameAction>
@property (nonatomic, assign, readonly) CGFloat duration;
- (id) initWithRow:(NSInteger)row gameBoard:(GameBoard *)board factory:(id<GameDependencyFactory>)factory;
- (void) execute;
- (BOOL) isValid;
- (NSArray *) generateNextGameActions;
@end
