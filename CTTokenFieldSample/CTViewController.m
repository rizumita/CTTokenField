//
//  CTViewController.m
//  CTTokenFieldSample
//
//  Created by 和泉田 領一 on 2013/04/10.
//  Copyright (c) 2013年 CAPH. All rights reserved.
//

#import "CTViewController.h"
#import "CTTokenField.h"
#import "CTTokenView.h"

@interface CTViewController ()

@property (nonatomic, strong) NSMutableOrderedSet *texts;
@end

@implementation CTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.texts = [NSMutableOrderedSet orderedSet];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setTokenField:nil];
    [super viewDidUnload];
}

- (NSUInteger)numberOfTokensInTokenField:(CTTokenField *)tokenField
{
    return self.texts.count;

}

- (CTTokenView *)tokenField:(CTTokenField *)tokenField tokenViewAtIndex:(NSUInteger)index
{
    CTTokenView *tokenView = [[CTTokenView alloc] initWithFrame:CGRectZero];
    tokenView.textLabel.text = self.texts[index];
    return tokenView;
}

- (NSString *)labelTextInTokenField:(CTTokenField *)tokenField
{
    return @"Sample:";
}

- (void)tokenField:(CTTokenField *)tokenField willAddTokenViewWithText:(NSString *)text atIndex:(NSUInteger)index
{
    [self.texts insertObject:text atIndex:index];
}

- (void)tokenField:(CTTokenField *)tokenField willRemoveTokenViewAtIndex:(NSUInteger)index
{
    [self.texts removeObjectAtIndex:index];
}

- (void)tokenField:(CTTokenField *)tokenField willMoveTokenViewFromIndex:(NSUInteger)fromIndex
           toIndex:(NSUInteger)toIndex
{
    [self.texts moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:fromIndex] toIndex:toIndex];
}

#pragma mark - CTTokenFieldDelegate

- (void)addButtonDidTappedInTokenField:(CTTokenField *)tokenField
{
    [self.texts addObject:@"Foo"];
    [self.tokenField reloadData];
}

@end
