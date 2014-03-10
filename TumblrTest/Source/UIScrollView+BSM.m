//
//  UIScrollView+BSM.m
//  TumblrTest
//
//  Created by Brian Michel on 3/9/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <objc/runtime.h>
#import "UIScrollView+BSM.h"

@implementation UIScrollView (BSM)

//This seems a little like the may fall into the gray area with Apple
//but looking at it more and more, I don't think it's illegal, however,
//it has the potential to fail in the future
- (UIView *)bsm_scrollIndicatorForPosition:(ScrollIndicatorPosition)position {
    [self flashScrollIndicators];
    UIView *viewToReturn = nil;
    NSString *indicatorIvarString = nil;
    switch (position) {
        case ScrollIndicatorPositionHorizontal:
            indicatorIvarString = @"_horizontalScrollIndicator";
            break;
        case ScrollIndicatorPositionVertical:
            indicatorIvarString = @"_verticalScrollIndicator";
            break;
        default:
            break;
    }
    if (indicatorIvarString) {
        Ivar indicator = class_getInstanceVariable([self class], [indicatorIvarString cStringUsingEncoding:NSUTF8StringEncoding]);
        if (indicator) {
            id iVarValue = object_getIvar(self, indicator);
            if ([iVarValue isKindOfClass:[UIView class]]) {
                viewToReturn = (UIView *)iVarValue;
            }
        }
    }
    return viewToReturn;
}
@end
