//
// Created by rizumita on 2013/04/12.
//


#import "CTTokenTextField.h"
#import "CTTokenField.h"

@implementation CTTokenTextField
{

}

- (void)deleteBackward
{
    if (self.text.length == 0) {
        NSUInteger number = [(CTTokenField *)self.delegate numberOfTokenViews];
        if (number > 0) {
            [(CTTokenField *)self.delegate selectTokenViewAtIndex:number - 1];
        }
    }

    [super deleteBackward];
}

@end