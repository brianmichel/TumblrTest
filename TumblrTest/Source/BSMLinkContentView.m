//
//  BSMLinkContentView.m
//  TumblrTest
//
//  Created by Brian Michel on 3/9/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <UIColor-Crayola/UIColor+Crayola.h>
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
        self.backgroundColor = [UIColor bsm_tumblrGreen];
        self.linkButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.linkButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.linkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.linkButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.linkButton.titleLabel.numberOfLines = 0;
        self.linkButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.linkButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0];
        
        self.linkDescriptionLabel = [UILabel newAutoLayoutView];
        self.linkDescriptionLabel.numberOfLines = 0;
        self.linkDescriptionLabel.textColor = [UIColor whiteColor];
        self.linkDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        [self addSubview:self.linkButton];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    [self.linkButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.linkButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.linkButton.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.frame);
}

- (void)updateFrameAfterSettingPost {
    [super updateFrameAfterSettingPost];
    self.postTypeLabel.hidden = YES;
    BSMLinkPost *linkPost = [self linkPost];
    
    //make sure we have something for the layout solver to use
    self.bounds = CGRectMake(0, 0, self.constraintWidth, 100);
            
    [self.linkButton setAttributedTitle:[self attributedButtonTitleForLinkPost:linkPost] forState:UIControlStateNormal];
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

- (NSAttributedString *)attributedButtonTitleForLinkPost:(BSMLinkPost *)post {
    NSString *title = post.title;
    NSString *host = [post.URL host];
    
    NSString *combinedString = [NSString stringWithFormat:@"%@ \n\n %@", title, host];
    
    NSRange hostRange = [combinedString rangeOfString:host];
    NSRange fullRange = NSMakeRange(0, [combinedString length]);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:combinedString];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0] range:fullRange];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:20.0] range:hostRange];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:fullRange];
    
    return [[NSAttributedString alloc] initWithAttributedString:attributedString];
}

@end
