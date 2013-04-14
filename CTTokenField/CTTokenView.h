//
// Created by rizumita on 2013/04/11.
//


#import <UIKit/UIKit.h>

@class CTTokenField;


@interface CTTokenView : UIView <UIKeyInput>
@property (nonatomic, strong) CTTokenField *tokenField;

@property (nonatomic) BOOL highlighted;
@property (nonatomic) BOOL floating;
@property (nonatomic, readonly) UILabel *textLabel;

- (CGFloat)widthConstrainedToWidth:(CGFloat)width;
@end