//
//  UIScrollView+BSM.h
//  TumblrTest
//
//  Created by Brian Michel on 3/9/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ScrollIndicatorPosition) {
    ScrollIndicatorPositionVertical = 0,
    ScrollIndicatorPositionHorizontal
};

@interface UIScrollView (BSM)
- (UIView *)bsm_scrollIndicatorForPosition:(ScrollIndicatorPosition)position;
@end
