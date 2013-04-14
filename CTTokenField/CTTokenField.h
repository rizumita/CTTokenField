//
//  CTTokenField.h
//  CTTokenField
//
//  Created by 和泉田 領一 on 2013/04/10.
//  Copyright (c) 2013年 CAPH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define CTTokenFieldDefaultRowHeight 40.0

#define CTTokenFieldAddButtonPadding 5.0

#define CTTokenFieldLabelPadding 5.0

#define CTTokenFieldTokenViewInterval 5.0

#define CTTokenFieldTextFieldMinWidth 50.0

#define CTTokenFieldAnimationDuration 0.2

extern NSString *const CTTokenFieldChangeFrameKey;

extern NSString *const CTTokenFieldChangeFrameAnimationOptionKey;

extern NSString *const CTTokenFieldChangeFrameAnimationDurationKey;

@class CTTokenView;

@protocol CTTokenFieldDataSource;

@protocol CTTokenFieldDelegate;


@interface CTTokenField : UIView <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet id <CTTokenFieldDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id <CTTokenFieldDelegate> delegate;

/* Configuring a Token Field */
@property (nonatomic, readonly) NSUInteger numberOfTokenViews;
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic, readonly) UILabel *label;
@property (nonatomic, readonly) UITextField *textField;

@property (nonatomic, readonly) CTTokenView *selectedTokenView;
@property (nonatomic, readonly) NSUInteger selectedTokenViewIndex;

@property (nonatomic, readonly) CGFloat maxTokenViewWidth;

- (void)reloadData;

- (void)removeTokenView:(CTTokenView *)tokenView;

- (void)insertText:(NSString *)text;

- (NSInteger)indexForSelectedTokenView;

- (NSUInteger)indexForTokenView:(CTTokenView *)tokenView;

- (CTTokenView *)tokenViewAtIndex:(NSUInteger)index;

- (void)selectTokenViewAtIndex:(NSUInteger)index;

- (void)deselectTokenViewAtIndex:(NSUInteger)index;

- (CTTokenView *)tokenViewAtLocation:(CGPoint)location;
@end


@protocol CTTokenFieldDataSource <NSObject>
- (NSUInteger)numberOfTokensInTokenField:(CTTokenField *)tokenField;

- (CTTokenView *)tokenField:(CTTokenField *)tokenField tokenViewAtIndex:(NSUInteger)index;

- (BOOL)tokenField:(CTTokenField *)tokenField shouldAddTokenViewWithText:(NSString *)text;

- (void)tokenField:(CTTokenField *)tokenField willAddTokenViewWithText:(NSString *)text atIndex:(NSUInteger)index;

- (void)tokenField:(CTTokenField *)tokenField willRemoveTokenViewAtIndex:(NSUInteger)index;

- (void)tokenField:(CTTokenField *)tokenField willMoveTokenViewFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@optional
- (void)tokenField:(CTTokenField *)tokenField didAddTokenViewWithText:(NSString *)text atIndex:(NSUInteger)index;

- (void)tokenField:(CTTokenField *)tokenField didRemoveTokenViewAtIndex:(NSUInteger)index;

- (void)tokenField:(CTTokenField *)tokenField didMoveTokenViewFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end


@protocol CTTokenFieldDelegate <NSObject>
@optional

/* Configuring for the Token Field */
- (CGFloat)heightForRowInTokenField:(CTTokenField *)tokenField;

- (NSString *)labelTextInTokenField:(CTTokenField *)tokenField;


/* Managing Selections */
- (void)tokenField:(CTTokenField *)tokenField willSelectTokenAtIndex:(NSUInteger)index;

- (void)tokenField:(CTTokenField *)tokenField didSelectTokenAtIndex:(NSUInteger)index;

- (void)tokenField:(CTTokenField *)tokenField willDeselectTokenAtIndex:(NSUInteger)index;

- (void)tokenField:(CTTokenField *)tokenField didDeselectTokenAtIndex:(NSUInteger)index;


/* Managing Add Button */
- (UIButton *)addButtonInTokenField:(CTTokenField *)tokenField;

- (void)addButtonDidTappedInTokenField:(CTTokenField *)tokenField;


/* Propagate Changing Frame */
- (void)tokenField:(CTTokenField *)tokenField willChangeFrameWithInfo:(NSDictionary *)info;

- (void)tokenField:(CTTokenField *)tokenField didChangeFrameWithInfo:(NSDictionary *)info;

@end
