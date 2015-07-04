#import <Specta/Specta.h>
#import "Expecta.h"
#import <OCMock/OCMock.h>
#import "NSObject+MTKTest.h"

#import "Game.h"
#import "GameDependencyFactory.h"
#import "GameBoard.h"
#import "GameFlow.h"
#import "CallNextWaveGameAction.h"
#import "ShiftEnemiesLeftGameAction.h"
#import "ShiftEnemiesRightGameAction.h"

@interface Game (Testing)
@property (nonatomic, strong) GameBoard *board;
@end

SpecBegin(Game)

describe(@"Game", ^{
    __block Game *sut;
    __block id factoryMock;
    __block id flowMock;
    __block id boardMock;
    
    beforeEach(^{
        sut = [[Game alloc] init];
        factoryMock = OCMProtocolMock(@protocol(GameDependencyFactory));
        sut.factory = factoryMock;
        flowMock = OCMClassMock([GameFlow class]);
        sut.flow = flowMock;
        boardMock = OCMClassMock([GameBoard class]);
        sut.board = boardMock;
    });
    
    context(@"when starting the game", ^{
        //TODO: figure out how to load initial blocks on the new board
        it(@"should create a new board and set the game to in progress", ^{
            //context
            NSInteger rows = 5;
            NSInteger columns = 5;
            id boardMock = OCMClassMock([GameBoard class]);
            OCMStub([factoryMock createGameBoardWithRows:rows columns:columns]).andReturn(boardMock);
            
            //because
            [sut commandStartGameWithRows:rows columns:columns];
            [sut notifyKeyPath:@"board.isActive" setTo:@YES];
            
            //expect
            expect(sut.board).toNot.beNil();
            expect(sut.gameInProgress).to.beTruthy();
            
            //cleanup
            [boardMock stopMocking];
        });
    });
    
    context(@"when board score changes", ^{
        it(@"should update the score", ^{
            //context
            NSInteger score = 5;
            
            //because
            [sut notifyKeyPath:@"board.score" setTo:@(score)];
            
            //expect
            expect(sut.score).to.equal(score);
        });
    });
    
    context(@"when board active status changes", ^{
        it(@"should update game in progress", ^{
            //context
            BOOL status = YES;
            
            //because
            [sut notifyKeyPath:@"board.isActive" setTo:@(status)];
            
            //expect
            expect(sut.gameInProgress).to.equal(@(status));
        });
    });
    
    context(@"when calling the next wave", ^{
        it(@"should add a game action to the flow", ^{
            //context
            id gameActionMock = OCMClassMock([CallNextWaveGameAction class]);
            OCMStub([factoryMock createCallNextWaveGameActionWithBoard:boardMock]).andReturn(gameActionMock);
            
            //because
            [sut commandCallNextWave];
            
            //expect
            OCMVerify([factoryMock createCallNextWaveGameActionWithBoard:boardMock]);
            OCMVerify([flowMock addGameAction:gameActionMock]);
            
            //cleanup
            [gameActionMock stopMocking];
        });
    });
    
    context(@"when swiping left", ^{
        it(@"should add the command to the flow", ^{
            //context
            NSInteger row = 3;
            id gameActionMock = OCMClassMock([ShiftEnemiesLeftGameAction class]);
            OCMStub([factoryMock createShiftEnemiesLeftGameActionWithBoard:boardMock row:row]).andReturn(gameActionMock);
            
            //because
            [sut commandSwipeLeftOnRow:row];
            
            //expect
            OCMVerify([factoryMock createShiftEnemiesLeftGameActionWithBoard:boardMock row:row]);
            OCMVerify([flowMock addGameAction:gameActionMock]);
            
            //cleanup
            [gameActionMock stopMocking];
        });
    });

    context(@"when swiping right", ^{
        it(@"should add the command to the flow", ^{
            //context
            NSInteger row = 3;
            id gameActionMock = OCMClassMock([ShiftEnemiesRightGameAction class]);
            OCMStub([factoryMock createShiftEnemiesRightGameActionWithBoard:boardMock row:row]).andReturn(gameActionMock);
            
            //because
            [sut commandSwipeRightOnRow:row];
            
            //expect
            OCMVerify([factoryMock createShiftEnemiesRightGameActionWithBoard:boardMock row:row]);
            OCMVerify([flowMock addGameAction:gameActionMock]);
            
            //cleanup
            [gameActionMock stopMocking];
        });
    });
    
    afterEach(^{
        [factoryMock stopMocking];
        [flowMock stopMocking];
        [boardMock stopMocking];
    });
});

SpecEnd
