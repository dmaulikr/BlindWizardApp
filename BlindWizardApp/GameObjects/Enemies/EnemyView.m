//
//  EnemyView.m
//  BlindWizardApp
//
//  Created by N A on 6/26/15.
//  Copyright (c) 2015 Adronitis. All rights reserved.
//

#import "EnemyView.h"
#import "EnemyViewModel.h"
#import "MTKObserving.h"

@interface EnemyView ()
@property (nonatomic, strong) EnemyViewModel *viewModel; //inject
@property (nonatomic, weak) UIView *bg;
@end

@implementation EnemyView

- (id) initWithViewModel:(EnemyViewModel *)viewModel {
    self = [super init];
    if(!self) return nil;
    
    //vm
    self.viewModel = viewModel;
    
    //bind
    [self removeAllObservations];
    [self observeProperty:@keypath(self.viewModel.animationType) withSelector:@selector(runAnimation)];
    [self map:@keypath(self.viewModel.face) to:@keypath(self.text) null:@""];
    
    //background
    UIView *bg = [[UIView alloc] initWithFrame:self.bounds];
    bg.backgroundColor = [self.viewModel color];
    bg.alpha = 0.2;
    bg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:bg];
    self.bg = bg;
    
    //view
    self.layer.borderColor = [self.viewModel color].CGColor;
    self.layer.borderWidth = 3;
    self.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.textColor = self.viewModel.color;
    self.font = [UIFont systemFontOfSize:20];
    self.textAlignment = NSTextAlignmentCenter;
    
    return self;
}

- (void) runAnimation {
    //run
    switch (self.viewModel.animationType) {
        case CreateAnimation:
            [self runCreateAnimation];
            break;
        case MoveAnimation:
            [self runMoveAnimation];
            break;
        case SnapAndMoveAnimation:
            [self runSnapAndMoveAnimation];
            break;
        case MoveAndRemoveAnimation:
            [self runMoveAndRemoveAnimation];
            break;
        case DestroyAndRemoveAnimation:
            [self destroyAndRemoveAnimation];
            break;
        default:
            break;
    }
}

- (void) runCreateAnimation {
    self.alpha = 0;
    self.transform = CGAffineTransformMakeScale(1.1, 1.1);
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    }];
}

- (void) runMoveAnimation {
    [UIView animateWithDuration:self.viewModel.moveDuration animations:^{
        self.frame = CGRectMake(self.viewModel.movePoint.x, self.viewModel.movePoint.y, self.bounds.size.width, self.bounds.size.height);
    }completion:^(BOOL finished) {
        [self.viewModel runNeutralAnimation];
    }];
}

- (void) runSnapAndMoveAnimation {
    self.frame = CGRectMake(self.viewModel.snapPoint.x, self.viewModel.snapPoint.y, self.bounds.size.width, self.bounds.size.height);
    [UIView animateWithDuration:self.viewModel.moveDuration animations:^{
        self.frame = CGRectMake(self.viewModel.movePoint.x, self.viewModel.movePoint.y, self.bounds.size.width, self.bounds.size.height);
    }completion:^(BOOL finished) {
        [self.viewModel runNeutralAnimation];
    }];
}

- (void) runMoveAndRemoveAnimation {
    [UIView animateWithDuration:self.viewModel.moveDuration animations:^{
        self.frame = CGRectMake(self.viewModel.movePoint.x, self.viewModel.movePoint.y, self.bounds.size.width, self.bounds.size.height);
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void) destroyAndRemoveAnimation {
    [self.superview sendSubviewToBack:self];
    [UIView animateWithDuration:0.4 animations:^{
        self.transform = CGAffineTransformMakeScale(0.05, 0.05);
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void) dealloc {
    [self removeAllObservations];
}

@end
