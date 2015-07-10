//
//  ShiftEnemiesRightGameAction.m
//  BlindWizardApp
//
//  Created by N A on 7/4/15.
//  Copyright (c) 2015 Adronitis. All rights reserved.
//

#import "ShiftEnemiesRightGameAction.h"
#import "GameDependencyFactory.h"
#import "GameBoard.h"
#import "GameConstants.h"

@interface ShiftEnemiesRightGameAction ()
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, strong) id<GameDependencyFactory> factory; //inject
@property (nonatomic, strong) GameBoard *gameBoard; //inject
@property (nonatomic, assign) CGFloat duration; //inject
@end

@implementation ShiftEnemiesRightGameAction

- (id) initWithRow:(NSInteger)row gameBoard:(GameBoard *)board factory:(id<GameDependencyFactory>)factory duration:(CGFloat)duration {
    self = [super init];
    if(!self) return nil;
    
    self.row = row;
    self.gameBoard = board;
    self.factory = factory;
    self.duration = duration;

    return self;
}

- (void) execute {
    NSNumber *castedRow = @(self.row);
    NSInteger index = ((self.row+1)*self.gameBoard.numColumns)-1;
    NSNumber *tail = [self.gameBoard.data objectAtIndex:index];
    index--;
    
    //shift right
    for(NSInteger column=self.gameBoard.numColumns-2; column>=0; column--,index--) {
        //data
        NSNumber *n = [self.gameBoard.data objectAtIndex:index];
        
        //save
        [self.gameBoard.data setObject:n atIndexedSubscript:index+1];
        
        //notify
        if([n integerValue] != 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GameUpdateShiftEnemyRight
                                                                object:self
                                                              userInfo:@{
                                                                         @"row" : castedRow,
                                                                         @"column" : @(column)
                                                                         }];
        }
    }
    
    //move to head
    [self.gameBoard.data setObject:tail atIndexedSubscript:index+1];
    
    //notify
    if([tail integerValue] != 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GameUpdateMoveEnemyToRowHead
                                                            object:self
                                                          userInfo:@{
                                                                     @"row" : castedRow,
                                                                     @"column" : @(self.gameBoard.numColumns-1)
                                                                     }];
    }
}

- (BOOL) isValid {
    //start index
    NSInteger index = self.row*self.gameBoard.numColumns;
    
    //scan columns of row
    for(NSInteger column=0; column<self.gameBoard.numColumns; column++,index++) {
        //current
        NSNumber *n = [self.gameBoard.data objectAtIndex:index];
        
        //check valid
        if([n integerValue] != 0) {
            return YES;
        }
    }
    
    //invalid
    return NO;
}

- (NSArray *) generateNextGameActions {
    return @[
             [self.factory checkDangerousGameActionWithBoard:self.gameBoard],
             [self.factory destroyEnemyGroupsGameActionWithBoard:self.gameBoard],
             [self.factory dropEnemiesDownGameActionWithBoard:self.gameBoard]
             ];
}

@end
