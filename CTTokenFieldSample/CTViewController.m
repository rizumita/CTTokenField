//
//  CTViewController.m
//  CTTokenFieldSample
//
//  Created by 和泉田 領一 on 2013/04/10.
//  Copyright (c) 2013年 CAPH. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "CTViewController.h"
#import "CTTokenField.h"
#import "CTTokenView.h"

@interface CTViewController ()

@property (nonatomic, strong) NSMutableArray *texts;
@property (nonatomic, strong) NSMutableArray *secondTexts;
@property (nonatomic, strong) CTTokenField *secondTokenField;
@end

@implementation CTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.texts = [NSMutableArray array];
    self.secondTexts = [NSMutableArray array];
    self.secondTokenField = [[CTTokenField alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), 0.0)];
    self.secondTokenField.dataSource = self;
    self.secondTokenField.delegate = self;
    [self.view addSubview:self.secondTokenField];
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
    if (tokenField == self.secondTokenField) {
        return self.secondTexts.count;
    } else {
        return self.texts.count;
    }
}

- (CTTokenView *)tokenField:(CTTokenField *)tokenField tokenViewAtIndex:(NSUInteger)index
{
    CTTokenView *tokenView = [[CTTokenView alloc] initWithFrame:CGRectZero];
    if (tokenField == self.secondTokenField) {
        tokenView.textLabel.text = self.secondTexts[index];
    } else {
        tokenView.textLabel.text = self.texts[index];
    }
    return tokenView;
}

- (BOOL)tokenField:(CTTokenField *)tokenField shouldAddTokenViewWithText:(NSString *)text
{
    return YES;
}

- (void)tokenField:(CTTokenField *)tokenField willAddTokenViewWithText:(NSString *)text atIndex:(NSUInteger)index
{
    if (tokenField == self.secondTokenField) {
        [self.secondTexts insertObject:text atIndex:index];
    } else {
        [self.texts insertObject:text atIndex:index];
    }
}

- (void)tokenField:(CTTokenField *)tokenField willRemoveTokenViewAtIndex:(NSUInteger)index
{
    if (tokenField == self.secondTokenField) {
        [self.secondTexts removeObjectAtIndex:index];
    } else {
        [self.texts removeObjectAtIndex:index];
    }
}

- (void)tokenField:(CTTokenField *)tokenField willMoveTokenViewFromIndex:(NSUInteger)fromIndex
           toIndex:(NSUInteger)toIndex
{
    if (tokenField == self.secondTokenField) {
        NSString *string = [self.secondTexts objectAtIndex:fromIndex];
        [self.secondTexts removeObjectAtIndex:fromIndex];
        [self.secondTexts insertObject:string atIndex:toIndex];
    } else {
        NSString *string = [self.texts objectAtIndex:fromIndex];
        [self.texts removeObjectAtIndex:fromIndex];
        [self.texts insertObject:string atIndex:toIndex];
    }
}

#pragma mark - CTTokenFieldDelegate

- (void)addButtonDidTappedInTokenField:(CTTokenField *)tokenField
{
    if (tokenField == self.secondTokenField) {
        [self.secondTexts addObject:@"Foo"];
    } else {
        [self.texts addObject:@"Foo"];
    }
    [tokenField reloadData];
}

- (CGFloat)heightForRowInTokenField:(CTTokenField *)tokenField
{
    if (tokenField == self.secondTokenField) {
        return 35.0;
    } else {
        return 44.0;
    }
}

- (void)tokenField:(CTTokenField *)tokenField willSelectTokenAtIndex:(NSUInteger)index1
{

}

- (void)tokenField:(CTTokenField *)tokenField didSelectTokenAtIndex:(NSUInteger)index1
{

}

- (void)tokenField:(CTTokenField *)tokenField willDeselectTokenAtIndex:(NSUInteger)index1
{

}

- (void)tokenField:(CTTokenField *)tokenField didDeselectTokenAtIndex:(NSUInteger)index1
{

}

- (void)tokenField:(CTTokenField *)tokenField willChangeFrameWithInfo:(NSDictionary *)info
{
    if (tokenField != self.secondTokenField) {
        if (info[CTTokenFieldChangeFrameAnimationOptionKey]) {
            CGRect frame = self.secondTokenField.frame;
            frame.origin.y = CGRectGetMaxY([info[CTTokenFieldChangeFrameKey] CGRectValue]);
            [UIView animateWithDuration:[info[CTTokenFieldChangeFrameAnimationDurationKey] doubleValue] delay:0.0 options:(UIViewAnimationOptions)[info[CTTokenFieldChangeFrameAnimationOptionKey] unsignedIntegerValue] animations:^{
                self.secondTokenField.frame = frame;
            }                completion:nil];
        } else {
            CGRect frame = self.secondTokenField.frame;
            frame.origin.y = CGRectGetMaxY([info[CTTokenFieldChangeFrameKey] CGRectValue]);
            self.secondTokenField.frame = frame;
        }
    }
}

- (void)tokenField:(CTTokenField *)tokenField didChangeFrameWithInfo:(NSDictionary *)info
{
}

- (NSString *)labelTextInTokenField:(CTTokenField *)tokenField
{
    if (tokenField == self.secondTokenField) {
        return @"Second:";
    } else {
        return @"Sample:";
    }
}

- (void)tokenField:(CTTokenField *)tokenField textFieldWillChangeWithText:(NSString *)text
{
    NSLog(@"%@", text);
}

@end
