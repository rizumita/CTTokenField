//
// Created by rizumita on 2013/04/11.
//


#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "CTTokenView.h"
#import "CTTokenField.h"


@implementation CTTokenView
{
    UILabel *_textLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpTextLabel];
        self.backgroundColor = [UIColor clearColor];
    }

    return self;
}

- (void)dealloc
{
    [self.textLabel removeObserver:self forKeyPath:@"text"];
}

- (void)setUpTextLabel
{
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(2.0, 0.0, CGRectGetWidth(self.frame) - 4.0, CGRectGetHeight(self.frame))];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.font = [UIFont systemFontOfSize:14];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [_textLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];

    [self addSubview:_textLabel];
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;

    [self setNeedsDisplay];
}

- (void)setFloating:(BOOL)floating
{
    _floating = floating;

    self.highlighted = _floating;

    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0, 3.0);
    if (floating) {
        self.layer.shadowOpacity = 0.5;

        [self becomeFirstResponder];
    } else {
        self.layer.shadowOpacity = 0.0;

        [self resignFirstResponder];
    }

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [animation setDuration:0.2];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    if (_floating) {
        animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.15, 1.15, 1.0)];

        [self.layer addAnimation:animation forKey:@"zoomUp"];
    } else {
        animation.delegate = self;

        animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.15, 1.15, 1.0)];
        animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];

        [self.layer addAnimation:animation forKey:@"zoomDown"];
    }
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
    if (animation == [self.layer animationForKey:@"zoomDown"]) {
        [self.layer removeAllAnimations];
    }
}

- (UILabel *)textLabel
{
    return _textLabel;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]) {
        [self sizeToFit];
        [self setNeedsLayout];
    }
}

- (CGFloat)widthConstrainedToWidth:(CGFloat)width
{
    CGSize textSize = [self.textLabel.text sizeWithFont:self.textLabel.font];
    return MIN(textSize.width + 30.0, width);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize textSize = [self.textLabel.text sizeWithFont:self.textLabel.font];
    CGSize newSize = CGSizeMake(MIN(self.tokenField.maxTokenViewWidth, textSize.width + 30.0), 28.0);
    return newSize;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

//// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

//// Color Declarations
    UIColor *fillColor;
    if (self.highlighted) {
        fillColor = [UIColor colorWithRed:0.346 green:0.486 blue:0.971 alpha:0.8];
        self.textLabel.textColor = [UIColor whiteColor];
    } else {
        fillColor = [UIColor colorWithRed:0.655 green:0.732 blue:1 alpha:1];
        self.textLabel.textColor = [UIColor blackColor];
    }
    UIColor *strokeColor = [UIColor colorWithRed:0.48 green:0.613 blue:0.975 alpha:1];

//// Gradient Declarations
    NSArray *gradientColors = [NSArray arrayWithObjects:
                                               (id)fillColor.CGColor,
                                               (id)strokeColor.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);

//// Frames
    CGRect frame = CGRectMake(15, 0, CGRectGetWidth(rect) - 30, 28);


//// Rounded Rectangle Drawing
    CGRect roundedRectangleRect = CGRectMake(CGRectGetMinX(frame) - 15, CGRectGetMinY(frame), CGRectGetWidth(frame) + 30, 28);
    UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:roundedRectangleRect cornerRadius:14];
    CGContextSaveGState(context);
    [roundedRectanglePath addClip];
    CGContextDrawLinearGradient(context, gradient,
            CGPointMake(CGRectGetMidX(roundedRectangleRect), CGRectGetMinY(roundedRectangleRect)),
            CGPointMake(CGRectGetMidX(roundedRectangleRect), CGRectGetMaxY(roundedRectangleRect)),
            0);
    CGContextRestoreGState(context);


//// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect frame = self.textLabel.frame;
    if (CGRectGetWidth(frame) + 20 > CGRectGetWidth(self.frame)) {
        frame.size.width = CGRectGetWidth(self.frame) - 20;
    }
    frame.origin.x = (CGRectGetWidth(self.frame) - CGRectGetWidth(frame)) / 2.0;
    frame.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(frame)) / 2.0;
    self.textLabel.frame = frame;
}

#pragma mark - Responder chain

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (UIResponder *)nextResponder
{
    NSInteger selectedIndex = [self.tokenField indexForTokenView:self];
    BOOL isLastTokenView = (selectedIndex == self.tokenField.numberOfTokenViews - 1);
    if (isLastTokenView) return self.tokenField.textField;

    return [self.tokenField tokenViewAtIndex:(NSUInteger)(selectedIndex + 1)];
}

#pragma mark - UIKeyInput

- (void)deleteBackward
{
    [self.tokenField removeTokenView:self];
    [self.tokenField setNeedsLayout];
}

- (BOOL)hasText
{
    return NO;
}

- (void)insertText:(NSString *)text
{
    if ([text isEqualToString:@"\t"]) {
        [self.nextResponder becomeFirstResponder];
    } else {
        [self.tokenField removeTokenView:self];
        [self.tokenField insertText:text];
    }
}

@end