//
//  ViewControllerAssembly.m
//  BlindWizardApp
//
//  Created by N A on 7/6/15.
//  Copyright (c) 2015 Adronitis. All rights reserved.
//

#import "ViewControllerAssembly.h"
#import "GameAssembly.h"
#import "GeneralAssembly.h"

#import "TitleViewController.h"
#import "LeaderboardViewController.h"
#import "PlayViewController.h"
#import "PlayViewModel.h"
#import "BoardViewController.h"
#import "BoardViewModel.h"

@implementation ViewControllerAssembly

- (TitleViewController *) titleViewController {
    return [TyphoonDefinition withClass:[TitleViewController class]];
}

- (LeaderboardViewController *) leaderboardViewController {
    return [TyphoonDefinition withClass:[LeaderboardViewController class]];
}

- (PlayViewController *) playViewController {
    return [TyphoonDefinition withClass:[PlayViewController class] configuration:^(TyphoonDefinition* definition) {
        [definition injectProperty:@selector(viewModel) with:[self playViewModel]];
        [definition injectProperty:@selector(factory) with:self.generalAssembly];
    }];
}

- (PlayViewModel *) playViewModel {
    return [TyphoonDefinition withClass:[PlayViewModel class] configuration:^(TyphoonDefinition* definition) {
        Game *game = [self.gameAssembly game];
        [definition injectProperty:@selector(game) with:game];
        [definition injectProperty:@selector(waveController) with:[self.gameAssembly waveControllerWithGame:game]];
        //GridCalculator needs to be manually injected by the VC
    }];
}

- (BoardViewController *) boardViewController {
    return [TyphoonDefinition withClass:[BoardViewController class] configuration:^(TyphoonDefinition* definition) {
        [definition injectProperty:@selector(viewModel) with:[self boardViewModel]];
        [definition injectProperty:@selector(calculatorFactory) with:self.generalAssembly];
        [definition injectProperty:@selector(gameObjectFactoryFactory) with:self.gameObjectAssembly];
    }];
}

- (BoardViewModel *) boardViewModel {
    return [TyphoonDefinition withClass:[BoardViewModel class] configuration:^(TyphoonDefinition* definition) {
        [definition injectProperty:@selector(game) with:[self.gameAssembly game]];
        [definition injectProperty:@selector(gridStorage) with:[self.generalAssembly gridStorage]];
        //GridCalculator needs to be manually injected by the VC
        //GameObjectFactory needs to be manually injected by the VC
    }];
}

@end
