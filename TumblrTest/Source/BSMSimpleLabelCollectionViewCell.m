//
//  BSMSimpleLabelCollectionViewCell.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import "BSMSimpleLabelCollectionViewCell.h"

@interface BSMSimpleLabelCollectionViewCell ()
@property (strong, readwrite) UILabel *textLabel;
@end

@implementation BSMSimpleLabelCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.textLabel = [UILabel newAutoLayoutView];
        [self.contentView addSubview:self.textLabel];
                
        [self.textLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
