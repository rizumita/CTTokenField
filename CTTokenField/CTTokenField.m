//
//  CTTokenField.m
//  CTTokenField
//
//  Created by 和泉田 領一 on 2013/04/10.
//  Copyright (c) 2013年 CAPH. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "CTTokenField.h"
#import "CTTokenView.h"
#import "CTTokenTextField.h"


NSString *const CTTokenFieldFrameKey = @"CTTokenFieldFrame";


@interface CTTokenField ()
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSMutableOrderedSet *tokenViews;
@property (nonatomic) NSUInteger rowNumber;
@property (nonatomic, readonly) CGRect textFieldFrame;
@property (nonatomic, readonly) CTTokenView *floatingTokenView;
@end

@implementation CTTokenField
{
    UILabel *_label;
    UITextField *_textField;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    self.rowHeight = 0.0;
    self.rowNumber = 1;
    self.tokenViews = [NSMutableOrderedSet orderedSet];

    [self setUpLabel];
    [self setUpTextField];

    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
    [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)]];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:panGestureRecognizer];
}

- (void)setUpLabel
{
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = [UIColor grayColor];
    [self addSubview:_label];
}

- (void)setUpTextField
{
    _textField = [[CTTokenTextField alloc] initWithFrame:CGRectZero];
    _textField.font = [UIFont systemFontOfSize:14];
    _textField.delegate = self;
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self addSubview:_textField];
}

- (UIButton *)addButton
{
    if (_addButton) return _addButton;

    if ([self.delegate respondsToSelector:@selector(addButtonInTokenField:)]) {
        _addButton = [self.delegate addButtonInTokenField:self];
    } else {
        _addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    }

    [_addButton addTarget:self action:@selector(addButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addButton];

    return _addButton;
}

- (void)addButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(addButtonDidTappedInTokenField:)]) {
        [self.delegate addButtonDidTappedInTokenField:self];
    }
}

- (CTTokenView *)floatingTokenView
{
    __block CTTokenView *floatingTokenView;
    [self.tokenViews enumerateObjectsUsingBlock:^(CTTokenView *tokenView, NSUInteger idx, BOOL *stop) {
        if (tokenView.floating) {
            floatingTokenView = tokenView;
            *stop = YES;
        }
    }];
    return floatingTokenView;
}

- (NSUInteger)numberOfTokenViews
{
    return self.tokenViews.count;
}

- (CGFloat)rowHeight
{
    if (_rowHeight > 0.0) return _rowHeight;

    if ([self.delegate respondsToSelector:@selector(heightForRowInTokenField:)]) {
        _rowHeight = [self.delegate heightForRowInTokenField:self];
    } else {
        _rowHeight = CTTokenFieldDefaultRowHeight;
    }

    return _rowHeight;
}

- (UILabel *)label
{
    return _label;
}

- (UITextField *)textField
{
    return _textField;
}

- (NSInteger)indexForSelectedTokenView
{
    NSInteger result = NSNotFound;

    for (NSInteger index = 0; index < self.tokenViews.count; index++) {
        CTTokenView *tokenView = self.tokenViews[(NSUInteger)index];
        if (tokenView.highlighted) {
            result = index;
            break;
        }
    }

    return result;
}

- (CTTokenView *)selectedTokenView
{
    NSUInteger index = self.selectedTokenViewIndex;

    if (index == NSNotFound) return nil;

    return self.tokenViews[index];
}

- (NSUInteger)selectedTokenViewIndex
{
    NSUInteger selectedTokenViewIndex = NSNotFound;

    for (NSUInteger index = 0; index < self.tokenViews.count; index++) {
        if ([[self.tokenViews objectAtIndex:index] highlighted]) {
            selectedTokenViewIndex = index;
            break;
        }
    }

    return selectedTokenViewIndex;
}


- (CGFloat)maxTokenViewWidth
{
    CGFloat result;
    if (self.tokenViews.count <= 1) {
        result = CGRectGetWidth(self.frame) - CGRectGetWidth(self.label.frame) - CTTokenFieldLabelPadding * 2;
    } else {
        result = CGRectGetWidth(self.frame) - CTTokenFieldTokenViewInterval * 2;
    }
    return result;
}

- (void)reloadDataIfNeeded
{
    if (self.tokenViews.count == 0) {
        [self reloadData];
    }
}

- (void)reloadData
{
    @synchronized (self) {
        [self.tokenViews.array makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.tokenViews removeAllObjects];

        NSUInteger number = [self.dataSource numberOfTokensInTokenField:self];
        for (NSUInteger index = 0; index < number; index++) {
            CTTokenView *tokenView = [self.dataSource tokenField:self tokenViewAtIndex:index];
            tokenView.tokenField = self;
            [self.tokenViews addObject:tokenView];
            [self addSubview:tokenView];
        }

        [self layoutTokenViewsAnimated:NO];
        [self layoutTextField];
        [self layoutAddButton];
        [self resizeIfNeeded:NO];
    }
}

- (void)addTokenViewWithText:(NSString *)text
{
    NSUInteger index = self.tokenViews.count;

    [self deselectTokenViewAtIndex:self.selectedTokenViewIndex];

    [self.dataSource tokenField:self willAddTokenViewWithText:text atIndex:index];

    CTTokenView *tokenView = [self.dataSource tokenField:self tokenViewAtIndex:index];
    tokenView.tokenField = self;
    [self addSubview:tokenView];
    [self.tokenViews insertObject:tokenView atIndex:index];

    if ([self.dataSource respondsToSelector:@selector(tokenField:didAddTokenViewWithText:atIndex:)]) {
        [self.dataSource tokenField:self didAddTokenViewWithText:text atIndex:index];
    }

    [self layoutTokenViewsAnimated:NO];
    [self layoutTextField];
    [self layoutAddButton];
    [self resizeIfNeeded:YES];
}

- (void)removeTokenView:(CTTokenView *)tokenView
{
    NSUInteger index = [self indexForTokenView:tokenView];

    [self.dataSource tokenField:self willRemoveTokenViewAtIndex:index];

    [tokenView removeFromSuperview];
    [self.tokenViews removeObjectAtIndex:index];

    if ([self.dataSource respondsToSelector:@selector(tokenField:didRemoveTokenViewAtIndex:)]) {
        [self.dataSource tokenField:self didRemoveTokenViewAtIndex:index];
    }
}

- (void)insertText:(NSString *)text
{
    self.textField.text = text;
    [self.textField becomeFirstResponder];
}

- (NSUInteger)indexForTokenView:(CTTokenView *)tokenView
{
    return [self.tokenViews indexOfObject:tokenView];
}

- (CTTokenView *)tokenViewAtIndex:(NSUInteger)index
{
    if (self.tokenViews.count <= index) return nil;
    return self.tokenViews[index];
}

- (CTTokenView *)tokenViewAtLocation:(CGPoint)location
{
    CTTokenView *result;

    for (CTTokenView *tokenView in self.tokenViews) {
        if (!tokenView.floating && CGRectContainsPoint(tokenView.frame, location)) {
            result = tokenView;
            break;
        }
    }

    return result;
}

- (void)selectTokenViewAtIndex:(NSUInteger)index
{
    if ([self.delegate respondsToSelector:@selector(tokenField:willSelectTokenAtIndex:)]) {
        [self.delegate tokenField:self willSelectTokenAtIndex:index];
    }

    CTTokenView *tokenView = [self tokenViewAtIndex:index];
    tokenView.highlighted = YES;
    [tokenView becomeFirstResponder];

    if ([self.delegate respondsToSelector:@selector(tokenField:didSelectTokenAtIndex:)]) {
        [self.delegate tokenField:self didSelectTokenAtIndex:index];
    }
}

- (void)deselectTokenViewAtIndex:(NSUInteger)index
{
    CTTokenView *tokenView = [self tokenViewAtIndex:index];
    if (!tokenView.highlighted) return;

    if ([self.delegate respondsToSelector:@selector(tokenField:willDeselectTokenAtIndex:)]) {
        [self.delegate tokenField:self willDeselectTokenAtIndex:index];
    }

    tokenView.highlighted = NO;
    [tokenView resignFirstResponder];

    if ([self.delegate respondsToSelector:@selector(tokenField:didDeselectTokenAtIndex:)]) {
        [self.delegate tokenField:self didDeselectTokenAtIndex:index];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawBottomLineWithRect:rect context:context];
}

- (void)drawBottomLineWithRect:(CGRect)rect context:(CGContextRef)context
{
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGPoint line[2];
    line[0] = CGPointMake(0.0, CGRectGetMaxY(rect));
    line[1] = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextStrokeLineSegments(context, line, 2);
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self reloadDataIfNeeded];

    [self layoutLabel];
    [self layoutTokenViewsAnimated:YES];
    [self layoutTextField];
    [self layoutAddButton];

    [self resizeIfNeeded:NO];
}

- (void)layoutLabel
{
    if ([self.delegate respondsToSelector:@selector(labelTextInTokenField:)]) {
        self.label.text = [self.delegate labelTextInTokenField:self];
    }
    [self.label sizeToFit];
    CGRect frame = self.label.frame;
    frame.origin.x = 5.0;
    frame.origin.y = (self.rowHeight - frame.size.height) / 2;
    self.label.frame = frame;
}

- (void)layoutTokenViewsAnimated:(BOOL)animated
{
    int row = 1;
    NSUInteger tokenViewIndex = 0;
    CGFloat offset = 0.0;
    NSUInteger numberInRow = 0;

    while (YES) {
        CTTokenView *tokenView = [self tokenViewAtIndex:tokenViewIndex];
        if (!tokenView) break;

        CGRect tokenViewFrame = tokenView.frame;

        CGRect containerFrame = [self containerFrameAtRow:row];

        [tokenView sizeToFit];
        tokenViewFrame.size.width = [tokenView widthConstrainedToWidth:CGRectGetWidth(containerFrame) - CTTokenFieldTokenViewInterval];

        if (CGRectGetWidth(tokenViewFrame) + offset > CGRectGetWidth(containerFrame)) {
            row++;
            offset = 0.0;
            numberInRow = 0;
            continue;
        }

        tokenView.frame = tokenViewFrame;

        tokenViewFrame.origin.x = CGRectGetMinX(containerFrame) + offset;
        tokenViewFrame.origin.y = (row - 1) * self.rowHeight + (self.rowHeight - tokenViewFrame.size.height) / 2;

        if (!tokenView.floating) {
            if (animated) {
                [UIView animateWithDuration:0.2 animations:^{
                    tokenView.frame = tokenViewFrame;
                }];
            } else {
                tokenView.frame = tokenViewFrame;
            }
        }

        offset += CGRectGetWidth(tokenViewFrame) + 5.0;

        numberInRow++;
        tokenViewIndex++;
    }

    self.rowNumber = (NSUInteger)row;
}

- (CGRect)containerFrameAtRow:(int)row
{
    if (row == 1) {
        return CGRectMake(CGRectGetMaxX(self.label.frame) + 10.0, 0.0, CGRectGetWidth(self.frame) - CGRectGetMaxX(self.label.frame) - 10.0, self.rowHeight);
    } else {
        return CGRectMake(10.0, self.rowHeight * (row - 1), CGRectGetWidth(self.frame) - CTTokenFieldTokenViewInterval * 2, self.rowHeight);
    }
}

- (void)layoutTextField
{
    CGFloat addButtonWidthWithSideSpace = CGRectGetWidth(self.addButton.frame) + CTTokenFieldAddButtonPadding * 2;

    __block void (^block)(NSUInteger row) = ^(NSUInteger row) {
        CGRect containerFrame = [self containerFrameAtRow:row];
        NSArray *tokenViews = [self tokenViewsInContainerFrame:containerFrame];
        containerFrame.size.width -= addButtonWidthWithSideSpace - CTTokenFieldTokenViewInterval;

        if (tokenViews.count > 0) {
            CGFloat newOriginX = CGRectGetMaxX([tokenViews.lastObject frame]) + CTTokenFieldTokenViewInterval;
            containerFrame.size.width -= newOriginX - containerFrame.origin.x;
            containerFrame.origin.x = newOriginX;
        }

        if (CGRectGetWidth(containerFrame) < CTTokenFieldTextFieldMinWidth) {
            if (self.rowNumber == row) {
                block(row + 1);
            }
        } else {
            self.textField.frame = containerFrame;
        }
    };

    block(self.rowNumber);

    self.rowNumber = (NSUInteger)(CGRectGetMaxY(self.textField.frame) / self.rowHeight);
}

- (NSArray *)tokenViewsInContainerFrame:(CGRect)containerFrame
{
    NSMutableArray *result = [NSMutableArray array];

    for (CTTokenView *tokenView in self.tokenViews) {
        if (CGRectIntersectsRect(containerFrame, tokenView.frame)) {
            [result addObject:tokenView];
        }
    }

    return result;
}

- (void)layoutAddButton
{
    CGRect frame = self.addButton.frame;
    frame.origin.x = self.frame.size.width - frame.size.width - CTTokenFieldAddButtonPadding;
    frame.origin.y = self.rowHeight * (self.rowNumber - 1) + (self.rowHeight - frame.size.height) / 2;
    self.addButton.frame = frame;
}

- (void)resizeIfNeeded:(BOOL)animated
{
    CGRect frame = self.frame;
    CGFloat newHeight = self.rowHeight * self.rowNumber;

    if (frame.size.height == newHeight) return;

    frame.size.height = newHeight;

    if ([self.delegate respondsToSelector:@selector(tokenField:willChangeFrameWithInfo:)]) {
        [self.delegate tokenField:self willChangeFrameWithInfo:@{CTTokenFieldFrameKey : [NSValue valueWithCGRect:frame]}];
    }

    if (animated) {
        [UIView animateWithDuration:CTTokenFieldAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.frame = frame;
        }                completion:^(BOOL finished) {
            [self setNeedsDisplay];

            if ([self.delegate respondsToSelector:@selector(tokenField:didChangeFrameWithInfo:)]) {
                [self.delegate tokenField:self didChangeFrameWithInfo:@{CTTokenFieldFrameKey : [NSValue valueWithCGRect:frame]}];
            }
        }];
    } else {
        self.frame = frame;
        [self setNeedsDisplay];

        if ([self.delegate respondsToSelector:@selector(tokenField:didChangeFrameWithInfo:)]) {
            [self.delegate tokenField:self didChangeFrameWithInfo:@{CTTokenFieldFrameKey : [NSValue valueWithCGRect:frame]}];
        }
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(size.width, self.rowNumber * self.rowHeight);
}

#pragma mark - Gesture handling

- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self];
    CTTokenView *touchedTokenView = [self tokenViewAtLocation:location];
    CTTokenView *highlightedTokenView = self.selectedTokenView;

    if (!touchedTokenView) {
        [self.textField becomeFirstResponder];
        return;
    }

    [self.textField resignFirstResponder];

    if (touchedTokenView == highlightedTokenView) {
        return;
    }

    if (highlightedTokenView) {
        NSUInteger index = [self.tokenViews indexOfObject:highlightedTokenView];
        [self deselectTokenViewAtIndex:index];
    }

    if (touchedTokenView) {
        NSUInteger index = [self.tokenViews indexOfObject:touchedTokenView];
        [self selectTokenViewAtIndex:index];
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self];
    CTTokenView *tokenView = [self tokenViewAtLocation:location];

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        tokenView.floating = YES;
        [self insertSubview:tokenView atIndex:self.subviews.count - 1];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.floatingTokenView.floating = NO;
        [self.textField becomeFirstResponder];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self];
    CTTokenView *floatingTokenView = [self floatingTokenView];
    CGPoint movedCenter = CGPointMake(floatingTokenView.center.x + translation.x, floatingTokenView.center.y + translation.y);
    floatingTokenView.center = movedCenter;

    [self moveTokenViewFromIndex:[self indexForTokenView:floatingTokenView] toIndex:[self indexToMoveAtLocation:floatingTokenView.center]];

    [gestureRecognizer setTranslation:CGPointZero inView:self];

    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        floatingTokenView.floating = NO;
        [self layoutTokenViewsAnimated:YES];
        [self layoutTextField];
        [self layoutAddButton];

        [self resizeIfNeeded:YES];
    }
}

- (NSUInteger)indexToMoveAtLocation:(CGPoint)location
{
    CTTokenView *tokenView = [self tokenViewAtLocation:location];
    if (!tokenView) {
        if (CGRectContainsPoint(self.textField.frame, location)) {
            return self.tokenViews.count - 1;
        } else {
            return NSNotFound;
        }
    }

    return [self indexForTokenView:tokenView];
}

- (void)moveTokenViewFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if (fromIndex == toIndex) return;
    if (fromIndex == NSNotFound || toIndex == NSNotFound) return;

    [self.dataSource tokenField:self willMoveTokenViewFromIndex:fromIndex toIndex:toIndex];

    [self.tokenViews moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:fromIndex] toIndex:toIndex];

    if ([self.dataSource respondsToSelector:@selector(tokenField:didMoveTokenViewFromIndex:toIndex:)]) {
        [self.dataSource tokenField:self didMoveTokenViewFromIndex:fromIndex toIndex:toIndex];
    }

    [self layoutTokenViewsAnimated:YES];
    [self layoutTextField];
    [self layoutAddButton];

    [self resizeIfNeeded:YES];
}

- (BOOL)                         gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if (text.length == 0) {
        [self.nextResponder becomeFirstResponder];
        return NO;
    }

    if ([self.dataSource tokenField:self shouldAddTokenViewWithText:text]) {
        [self addTokenViewWithText:text];
        textField.text = nil;
    }

    [textField becomeFirstResponder];

    return NO;
}

@end
