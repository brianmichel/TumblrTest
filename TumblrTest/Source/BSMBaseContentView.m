//
//  BSMBaseContentView.m
//  TumblrTest
//
//  Created by Brian Michel on 3/9/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import "BSMBaseContentView.h"
#import "BSMPost.h"

@interface BSMBaseContentView ()
@property (strong) UILabel *postTypeLabel;
@end

@implementation BSMBaseContentView

@synthesize post = _post;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.postTypeLabel = [[UILabel alloc] init];
        self.postTypeLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.postTypeLabel.textAlignment = NSTextAlignmentCenter;
        self.postTypeLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:30.0];
        self.postTypeLabel.textColor = [UIColor darkGrayColor];
        
        [self addSubview:self.postTypeLabel];
    }
    return self;
}

- (void)setPost:(BSMPost *)post {
    if ([_post isEqual:post]) {
        return;
    }
    _post = post;
    self.postTypeLabel.text = [BSMPost typeStringFromPostType:_post.type];
    [self updateFrameAfterSettingPost];
}

- (BSMPost *)post {
    return _post;
}

- (void)updateFrameAfterSettingPost {
    self.frame = CGRectMake(0, 0, self.frame.size.width, 80.0);
}

@end
