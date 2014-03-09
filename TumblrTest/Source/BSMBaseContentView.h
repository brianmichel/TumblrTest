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
@property (strong) BSMPost *post;

- (void)updateFrameAfterSettingPost;
@end
