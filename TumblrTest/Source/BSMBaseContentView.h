//
//  BSMBaseContentView.h
//  TumblrTest
//
//  Created by Brian Michel on 3/9/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BSMPost;

@interface BSMBaseContentView : UIView

@property (strong, readonly) UILabel *postTypeLabel;
@property (assign, readonly) CGFloat constraintWidth;
@property (strong) BSMPost *post;

- (instancetype)initWithConstraintWidth:(CGFloat)width;
- (void)updateFrameAfterSettingPost;
- (void)prepareForReuse;
@end
