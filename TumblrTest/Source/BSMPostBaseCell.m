//
//  BSMPostBaseCell.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import "BSMPostBaseCell.h"
#import "BSMPost.h"
#import "NSDateFormatter+BSM.h"

@interface BSMPostBaseCell ()
@property (strong) UILabel *dateLabel;
@end

@implementation BSMPostBaseCell

@synthesize post = _post;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dateLabel = [UILabel newAutoLayoutView];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.contentView addSubview:self.dateLabel];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.dateLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void)setPost:(BSMPost *)post {
    if (_post != post) {
        _post = post;
        //stuff
        self.dateLabel.text = [[NSDateFormatter bsm_shortRelativeDateFormatter] stringFromDate:_post.date];
        
        [self setNeedsUpdateConstraints];
    }
}

- (BSMPost *)post {
    return _post;
}

@end
