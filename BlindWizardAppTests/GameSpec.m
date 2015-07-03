#import <Specta/Specta.h>
#import "Expecta.h"
#import <OCMock/OCMock.h>

#import "Game.h"
#import "GameConstants.h"
#import "GameActionFlow.h"
#import "GameBoardLogic.h"

SpecBegin(Game)

describe(@"Game", ^{
    __block Game *sut;
    __block id gameBoardLogicMock;
    __block id gameActionFlowMock;
    
    beforeEach(^{
        sut = [[Game alloc] init];
        gameActionFlowMock = OCMClassMock([GameActionFlow class]);
        sut.gameActionFlow = gameActionFlowMock;
        gameBoardLogicMock = OCMClassMock([GameBoardLogic class]);
        sut.gameBoardLogic = gameBoardLogicMock;
    });
    
    context(@"commands", ^{
        //TODO: start game
        context(@"when starting the game", ^{
            pending(@"should load initial blocks", ^{
                //because
                [sut commandStartGame];
            });
            
            pending(@"should set the game to the starting state", ^{
                //because
                [sut commandStartGame];
                
                //expect
                expect(sut.gameInProgress).to.beTruthy();
            });
        });
        
        context(@"when calling the next wave", ^{
            it(@"should add the command to the flow", ^{
                //because
                [sut commandCallNextWave];
                
                //expect
                OCMVerify([gameActionFlowMock commandCallNextWave]);
            });
        });
        
        context(@"when swiping left", ^{
            it(@"should add the command to the flow", ^{
                //context
                NSInteger row = 1;
                
                //because
                [sut commandSwipeLeftOnRow:row];
                
                //expect
                OCMVerify([gameActionFlowMock commandSwipeLeftOnRow:row]);
            });
        });
        
        context(@"when swiping right", ^{
            it(@"should add the command to the flow", ^{
                //context
                NSInteger row = 1;
                
                //because
                [sut commandSwipeRightOnRow:row];
                
                //expect
                OCMVerify([gameActionFlowMock commandSwipeRightOnRow:row]);
            });
        });
    });
    
    //UGH beginning the question necessity of game.h, as in theory can have gameboardlogic just listen directly for game actions, like it's an unnecessary object almost
    //but maybe ok because he'll end up with the data
    //for scanner purposes and shit
    //and score might change things?
    context(@"game actions", ^{
        context(@"when there is a call next wave game action", ^{
            it(@"should execute it", ^{
                //context
                NSNotification *notification = [NSNotification notificationWithName:GameActionCallNextWave object:nil];

                //because
                [sut executeGameActionCallNextWave:notification];
                
                //expect
                OCMVerify([gameBoardLogicMock executeGameActionCallNextWave]);
            });
        });
        
        context(@"when there is a shift enemies left game action", ^{
            it(@"should execute it", ^{
                //context
                NSInteger row = 1;
                NSDictionary *userInfo = @{@"row" : @(row)};
                NSNotification *notification = [NSNotification notificationWithName:GameActionShiftEnemiesLeft object:nil userInfo:userInfo];

                //because
                [sut executeGameActionShiftEnemiesLeft:notification];
                
                //expect
                OCMVerify([gameBoardLogicMock executeGameActionShiftEnemiesLeftOnRow:row]);
            });
        });
        
        context(@"when there is a shift enemies right game action", ^{
            it(@"should execute it", ^{
                //context
                NSInteger row = 1;
                NSDictionary *userInfo = @{@"row" : @(row)};
                NSNotification *notification = [NSNotification notificationWithName:GameActionShiftEnemiesRight object:nil userInfo:userInfo];
                
                //because
                [sut executeGameActionShiftEnemiesRight:notification];
                
                //expect
                OCMVerify([gameBoardLogicMock executeGameActionShiftEnemiesRightOnRow:row]);
            });
        });
        
        context(@"when there is a destroy enemies game action", ^{
            it(@"should execute it", ^{
                //context
                NSNotification *notification = [NSNotification notificationWithName:GameActionDestroyEnemyGroups object:nil];
                
                //because
                [sut executeGameActionDestroyEnemyGroups:notification];
                
                //expect
                OCMVerify([gameBoardLogicMock executeGameActionDestroyEnemyGroups]);
            });
        });
        
        context(@"when there is a drop enemies game action", ^{
            it(@"should execute it", ^{
                //context
                NSNotification *notification = [NSNotification notificationWithName:GameActionDropEnemiesDown object:nil];
                
                //because
                [sut executeGameActionDropEnemiesDown:notification];
                
                //expect
                OCMVerify([gameBoardLogicMock executeGameActionDropEnemiesDown]);
            });
        });
    });
    
    afterEach(^{
        [gameActionFlowMock stopMocking];
        [gameBoardLogicMock stopMocking];
    });
});

SpecEnd

//TODO: score
//TODO: danger
//TODO: pacify
//TODO: losing