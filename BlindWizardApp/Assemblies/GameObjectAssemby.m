//
//  GameObjectAssemby.m
//  BlindWizardApp
//
//  Created by N A on 7/6/15.
//  Copyright (c) 2015 Adronitis. All rights reserved.
//

#import "GameObjectAssemby.h"
#import "EnemyView.h"
#import "EnemyViewModel.h"

@implementation GameObjectAssemby

- (EnemyView *) enemyViewWithViewModel:(EnemyViewModel *)viewModel {
    return nil;
}

- (EnemyViewModel *) enemyViewModelWithType:(NSInteger)type configuration:(NSDictionary *)config {
    return nil;
}

- (GameObjectFactory *) gameObjectFactoryWithView:(UIView *)view {
    return nil;
}

@end