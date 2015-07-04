//
//  GameObjectFactory.m
//  BlindWizardApp
//
//  Created by N A on 6/26/15.
//  Copyright (c) 2015 Adronitis. All rights reserved.
//

#import "GameObjectFactory.h"
#import "EnemyView.h"
#import "EnemyViewModel.h"
#import "GridCalculator.h"

@implementation GameObjectFactory

- (EnemyViewModel *) createEnemyWithType:(NSInteger)type atRow:(NSInteger)row column:(NSInteger)column {
    CGPoint point = [self.gridCalculator calculatePointForRow:row column:column];
    
    EnemyViewModel *evm = [[EnemyViewModel alloc] init];
    evm.enemyType = type;
    evm.frame = CGRectMake(point.x, point.y, self.gridCalculator.squareWidth, self.gridCalculator.squareHeight);
    
    EnemyView *ev = [[EnemyView alloc] init];
    ev.viewModel = evm;
    [self.view addSubview:ev];
    
    return evm;
}

@end