//
//  CTViewController.h
//  CTTokenFieldSample
//
//  Created by 和泉田 領一 on 2013/04/10.
//  Copyright (c) 2013年 CAPH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTTokenField.h"

@interface CTViewController : UIViewController <CTTokenFieldDataSource, CTTokenFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet CTTokenField *tokenField;

@end
