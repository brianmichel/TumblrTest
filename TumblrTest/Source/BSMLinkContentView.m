//
//  BSMLinkContentView.m
//  TumblrTest
//
//  Created by Brian Michel on 3/9/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <UIColor-Crayola/UIColor+Crayola.h>
#import <DTCoreText/DTCoreText.h>
#import "BSMLinkContentView.h"
#import "BSMPost.h"

@interface BSMLinkContentView ()
@property (strong) UIButton *linkButton;
@property (strong) UILabel *linkDescriptionLabel;
@end

@implementation BSMLinkContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.linkButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.linkButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.linkButton setTitleColor:[UIColor crayolaBlueberryColor] forState:UIControlStateNormal];
        self.linkButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.linkButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0];
        
        self.linkButton.backgroundColor = [UIColor crayolaSpringGreenColor];
        
        self.linkDescriptionLabel = [UILabel newAutoLayoutView];
        self.linkDescriptionLabel.numberOfLines = 0;
        self.linkDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        [self addSubview:self.linkButton];
        [self addSubview:self.linkDescriptionLabel];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    [self.linkButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.linkButton autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0.0];
    [self.linkButton autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0.0];
    [self.linkButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0];
    [self.linkButton autoSetDimension:ALDimensionHeight toSize:50.0];
    
    [self.linkDescriptionLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.linkDescriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0.0];
    [self.linkDescriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0.0];
    [self.linkDescriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0];
    [self.linkDescriptionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.linkButton withOffset:0.0];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.linkDescriptionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.frame);
}

- (void)updateFrameAfterSettingPost {
    [super updateFrameAfterSettingPost];
    self.postTypeLabel.hidden = YES;
    BSMLinkPost *linkPost = [self linkPost];
    
    //make sure we have something for the layout solver to use
    self.bounds = CGRectMake(0, 0, self.constraintWidth, 100);
        
    [self.linkButton setTitle:linkPost.title forState:UIControlStateNormal];
    self.linkDescriptionLabel.text = linkPost.postDescription;
    
    //force a layout pass when the solver is ready
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    CGSize buttonSize = [self.linkButton systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    CGSize labelSize = [self.linkDescriptionLabel systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    self.frame = CGRectMake(0, 0, self.constraintWidth, buttonSize.height + labelSize.height);
}

- (BSMLinkPost *)linkPost {
    return (BSMLinkPost *)self.post;
}

@end
