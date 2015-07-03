//
//  GameBoardLogic.m
//  BlindWizardApp
//
//  Created by N A on 6/30/15.
//  Copyright (c) 2015 Adronitis. All rights reserved.
//

#import "GameBoardLogic.h"
#import "RandomGenerator.h"
#import "GameConstants.h"

@implementation GameBoardLogic

- (NSInteger) indexFromRow:(NSInteger)row column:(NSInteger)column {
    return (row * self.numColumns) + column;
}

- (void) executeGameActionShiftLeftOnRow:(NSInteger)row {
    NSNumber *castedRow = @(row);
    NSInteger index = row*self.numColumns;
    NSNumber *head = [_data objectAtIndex:index];
    index++;
    
    //shift left
    for(NSInteger column=1; column<self.numColumns; column++,index++) {
        //data
        NSNumber *n = [self.data objectAtIndex:index];
        
        //save
        [self.data setObject:n atIndexedSubscript:index-1];
        
        //notify
        if([n integerValue] != 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GameUpdateShiftEnemyLeft
                                                                object:self
                                                              userInfo:@{
                                                                         @"row" : castedRow,
                                                                         @"column" : @(column)
                                                                         }];
        }
    }
    
    //move to tail
    [self.data setObject:head atIndexedSubscript:index-1];
    
    //notify
    if([head integerValue] != 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GameUpdateMoveEnemyToRowTail
                                                            object:self
                                                          userInfo:@{
                                                                     @"row" : castedRow,
                                                                     @"column" : @0
                                                                     }];
    }
}

- (void) executeGameActionShiftRightOnRow:(NSInteger)row {
    NSNumber *castedRow = @(row);
    NSInteger index = ((row+1)*self.numColumns)-1;
    NSNumber *tail = [_data objectAtIndex:index];
    index--;
    
    //shift right
    for(NSInteger column=self.numColumns-2; column>=0; column--,index--) {
        //data
        NSNumber *n = [self.data objectAtIndex:index];

        //save
        [self.data setObject:n atIndexedSubscript:index+1];
        
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
    [self.data setObject:tail atIndexedSubscript:index+1];
    
    //notify
    if([tail integerValue] != 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GameUpdateMoveEnemyToRowHead
                                                            object:self
                                                          userInfo:@{
                                                                     @"row" : castedRow,
                                                                     @"column" : @(self.numColumns-1)
                                                                     }];
    }
}

- (void) executeGameActionDropEnemiesDown {
    //loop through columns
    for(NSInteger column=0; column<self.numColumns; column++) {
        NSInteger replaceIndex = -1;
        NSInteger toRow = -1;
        
        //loop through rows of that column
        for(NSInteger row=0; row<self.numRows; row++) {
            //current
            NSInteger index = [self indexFromRow:row column:column];
            NSNumber *n = [self.data objectAtIndex:index];
            
            if(replaceIndex == -1) {
                //nothing to replace yet
                
                if([n integerValue] == 0) {
                    //it's 0, need to replace it
                    replaceIndex = index;
                    toRow = row;
                }
            }else {
                //searching to replace
                
                if([n integerValue] != 0) {
                    //found something
                    
                    //replace
                    [self.data setObject:n atIndexedSubscript:replaceIndex];
                    [self.data setObject:@0 atIndexedSubscript:index];
                    
                    //notify
                    [[NSNotificationCenter defaultCenter] postNotificationName:GameUpdateDropEnemyDown
                                                                        object:self
                                                                      userInfo:@{
                                                                                 @"column" : @(column),
                                                                                 @"fromRow" : @(row),
                                                                                 @"toRow" : @(toRow)
                                                                                 }];
                    //update vars
                    replaceIndex = index;
                    toRow = row;
                }
            }
        }
    }
}

- (void) executeGameActionCallNextWave {
    //loop through columns
    for(NSInteger column=0; column<self.numColumns; column++) {
        //loop through rows of that column
        for(NSInteger row=0; row<self.numRows; row++) {
            //current
            NSInteger index = [self indexFromRow:row column:column];
            NSNumber *n = [self.data objectAtIndex:index];
            
            if([n integerValue] == 0) {
                //found a free spot
                
                //add
                NSNumber *newNumber = @([self.randomGenerator generate]);
                [self.data setObject:newNumber atIndexedSubscript:index];
                
                //notify
                [[NSNotificationCenter defaultCenter] postNotificationName:GameUpdateCreateEnemy
                                                                    object:self
                                                                  userInfo:@{
                                                                             @"column" : @(column),
                                                                             @"row" : @(row),
                                                                             @"type" : newNumber
                                                                             }];
                
                //exit loop
                break;
            }
        }
    }
}

//TODO: consider refactoring this massive function into parts, like scan rows, scan columns, remove and notify
- (void) executeGameActionDestroyEnemyGroups {
    NSMutableArray *rowsToDestroy = [NSMutableArray new];
    NSMutableArray *columnsToDestroy = [NSMutableArray new];
    NSMutableArray *indicesToDestroy = [NSMutableArray new];

    //scan rows for 3+
    for(NSInteger row=0; row<self.numRows; row++) {
        //reset
        NSInteger lastType = 0;
        NSInteger count = 1;
        
        //scan through columns
        for(NSInteger column=0; column<self.numColumns; column++) {
            //current
            NSInteger index = [self indexFromRow:row column:column];
            NSInteger n = [[self.data objectAtIndex:index] integerValue];
            
            if(n != 0 && lastType == n) {
                //same type, increment counter
                count++;
            }else {
                //new type or 0
                
                //set to be destroyed
                if(count >= 3) {
                    //loop connected objects
                    for(NSInteger c=column-count; c<column; c++) {
                        NSNumber *indexToDestroy = @([self indexFromRow:row column:c]);
                        if(![indicesToDestroy containsObject:indexToDestroy]) {
                            //add to be destroyed
                            [indicesToDestroy addObject:indexToDestroy];
                            [rowsToDestroy addObject:@(row)];
                            [columnsToDestroy addObject:@(c)];
                        }
                    }
                }
                
                //set to new type
                lastType = n;
                count = 1;
            }
        }
        
        //end row, set to be destroyed
        if(count >= 3) {
            //loop connected objects
            for(NSInteger c=self.numColumns-count; c<self.numColumns; c++) {
                NSNumber *indexToDestroy = @([self indexFromRow:row column:c]);
                if(![indicesToDestroy containsObject:indexToDestroy]) {
                    //add to be destroyed
                    [indicesToDestroy addObject:indexToDestroy];
                    [rowsToDestroy addObject:@(row)];
                    [columnsToDestroy addObject:@(c)];
                }
            }
        }
    }
    
    //scan columns for 3+
    for(NSInteger column=0; column<self.numColumns; column++) {
        //reset
        NSInteger lastType = 0;
        NSInteger count = 1;

        //scan through rows
        for(NSInteger row=0; row<self.numRows; row++) {
            //current
            NSInteger index = [self indexFromRow:row column:column];
            NSInteger n = [[self.data objectAtIndex:index] integerValue];
            
            if(n != 0 && lastType == n) {
                //same type, increment counter
                count++;
            }else {
                //new type or 0
                
                //set to be destroyed
                if(count >= 3) {
                    //loop connected objects
                    for(NSInteger r=row-count; r<row; r++) {
                        NSNumber *indexToDestroy = @([self indexFromRow:r column:column]);
                        if(![indicesToDestroy containsObject:indexToDestroy]) {
                            //add to be destroyed
                            [indicesToDestroy addObject:indexToDestroy];
                            [rowsToDestroy addObject:@(r)];
                            [columnsToDestroy addObject:@(column)];
                        }
                    }
                }

                //set to new type
                lastType = n;
                count = 1;
            }
        }
        
        //end column, set to be destroyed
        if(count >= 3) {
            for(NSInteger r=self.numRows-count; r<self.numRows; r++) {
                NSNumber *indexToDestroy = @([self indexFromRow:r column:column]);
                if(![indicesToDestroy containsObject:indexToDestroy]) {
                    //add to be destroyed
                    [indicesToDestroy addObject:indexToDestroy];
                    [rowsToDestroy addObject:@(r)];
                    [columnsToDestroy addObject:@(column)];
                }
            }
        }
    }
    
    //remove and notify
    for(int i=0; i<indicesToDestroy.count; i++) {
        //remove from data
        NSInteger index = [[indicesToDestroy objectAtIndex:i] integerValue];
        [self.data setObject:@0 atIndexedSubscript:index];
        
        //notify
        [[NSNotificationCenter defaultCenter] postNotificationName:GameUpdateDestroyEnemy
                                                            object:self
                                                          userInfo:@{
                                                                     @"row" : [rowsToDestroy objectAtIndex:i],
                                                                     @"column" : [columnsToDestroy objectAtIndex:i]
                                                                     }];
    }
}

@end
