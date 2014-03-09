//
//  BSMBaseContentView.m
//  TumblrTest
//
//  Created by Brian Michel on 3/9/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import "BSMBaseContentView.h"
#import "BSMPost.h"

@implementation BSMBaseContentView

@synthesize post = _post;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPost:(BSMPost *)post {
    if ([_post isEqual:post]) {
        return;
    }
    _post = post;
    [self updateFrameAfterSettingPost];
}

- (BSMPost *)post {
    return _post;
}

- (void)updateFrameAfterSettingPost {
    self.frame = CGRectMake(0, 0, self.frame.size.width, 80.0);
}

@end
