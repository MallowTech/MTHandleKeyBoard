//
//  UIScrollView+CustomScrollView.m
//  MTHandleKeyboard
//
//  Created by Jayaprakash Kaliappan on 17/01/14.
//  Copyright (c) 2014 Mallow Technologies Pvt ltd. All rights reserved.
//

#import "UIScrollView+CustomScrollView.h"

@implementation UIScrollView (CustomScrollView)

- (CGFloat)getBottomInset {
    return self.contentInset.bottom;
}

@end
