CTTokenField
============

CTTokenField is a token filed component for iOS6+.

![CTTokenField](http://f.cl.ly/items/02123U0r3j1i2v3e250r/cttokenfield.png)

Sample
==========

Prepare data container
----------
```Objective-C
self.texts = [NSMutableArray array];
```

Create token field view
----------
```Objective-C
self.tokenField = [[CTTokenField alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), 0.0)];
self.tokenField.dataSource = self;
self.tokenField.delegate = self;
[self.view addSubview:self.tokenField];
```

Implement data source methods
----------
```Objective-C
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

- (BOOL)tokenField:(CTTokenField *)tokenField shouldAddTokenViewWithText:(NSString *)text
{
    return YES;
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
    NSString *string = [self.texts objectAtIndex:fromIndex];
    [self.texts removeObjectAtIndex:fromIndex];
    [self.texts insertObject:string atIndex:toIndex];
}
```

Implement delegate methods
----------
```Objective-C
- (NSString *)labelTextInTokenField:(CTTokenField *)tokenField
{
    return @"Sample:";
}

- (void)addButtonDidTappedInTokenField:(CTTokenField *)tokenField
{
    [self.texts addObject:@"Foo"];
    [tokenField reloadData];
}
```

License
===============
CTTokenField is available under the MIT license. See the LICENSE file for more info.
