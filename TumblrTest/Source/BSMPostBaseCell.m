//
//  BSMPostBaseCell.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <UIColor-Crayola/UIColor+Crayola.h>
#import "UIImageView+BSM.h"
#import "BSMPostBaseCell.h"
#import "BSMPost.h"
#import "BSMSimpleLabelCollectionViewCell.h"
#import "NSDateFormatter+BSM.h"
#import "NSNumberFormatter+BSM.h"
#import "NSString+BSM.h"
#import "BSMPostContentViewFactory.h"
#import "BSMBaseContentView.h"

#define POST_LABEL_FONT [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:16.0]
#define POST_NOTES_FONT [UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:16.0]
#define POST_BLOG_FONT [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:18.0]

@interface BSMPostBaseCell () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, readwrite) UIView *containerView;
@property (strong) UILabel *notesLabel;
@property (strong) UILabel *blogNameLabel;
@property (strong) UICollectionView *tagsCollectionView;
@property (strong) UIImageView *avatarImageView;

@property (strong) UIView *bottomSectionBackground;
@property (strong) UIView *topDividerView;
@property (strong) UIView *notesDividerView;

@property (assign) BOOL didUpdateConstraints;
@end

@implementation BSMPostBaseCell

@synthesize post = _post;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        self.avatarImageView = [UIImageView newAutoLayoutView];
        self.avatarImageView.backgroundColor = [UIColor darkGrayColor];
        
        self.containerView = [UIView newAutoLayoutView];
        self.containerView.backgroundColor = [UIColor lightGrayColor];
        
        self.topDividerView = [UIView newAutoLayoutView];
        self.notesDividerView = [UIView newAutoLayoutView];

        self.topDividerView.backgroundColor = self.notesDividerView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.2];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.tagsCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        [self.tagsCollectionView registerClass:[BSMSimpleLabelCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        self.tagsCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        self.tagsCollectionView.backgroundColor = [UIColor clearColor];
        self.tagsCollectionView.showsHorizontalScrollIndicator = self.tagsCollectionView.showsVerticalScrollIndicator = NO;
        self.tagsCollectionView.delegate = self;
        self.tagsCollectionView.dataSource = self;
        self.tagsCollectionView.scrollsToTop = NO;
        self.tagsCollectionView.contentInset = UIEdgeInsetsMake(0, MarginSizes.small, 0, MarginSizes.small);
        
        self.blogNameLabel = [UILabel newAutoLayoutView];
        self.blogNameLabel.font = POST_BLOG_FONT;
        self.blogNameLabel.textColor = [UIColor crayolaBlackCoralPearlColor];
        
        self.notesLabel = [UILabel newAutoLayoutView];
        self.notesLabel.textAlignment = NSTextAlignmentCenter;
        self.notesLabel.textColor = [UIColor darkGrayColor];
        self.notesLabel.font = POST_NOTES_FONT;
        
        self.bottomSectionBackground = [UIView newAutoLayoutView];
        self.bottomSectionBackground.backgroundColor = [UIColor bsm_tumblrLightGray];
        
        [self.contentView addSubview:self.bottomSectionBackground];
        [self.contentView addSubview:self.blogNameLabel];
        [self.contentView addSubview:self.avatarImageView];
        [self.bottomSectionBackground addSubview:self.tagsCollectionView];
        [self.bottomSectionBackground addSubview:self.topDividerView];
        [self.bottomSectionBackground addSubview:self.notesDividerView];
        [self.bottomSectionBackground addSubview:self.notesLabel];
        [self.contentView addSubview:self.containerView];
        
        self.layer.cornerRadius = 4.0;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    if (self.didUpdateConstraints) {
        return;
    }
    
    [self.avatarImageView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.avatarImageView autoSetDimension:ALDimensionHeight toSize:32.0];
    [self.avatarImageView autoSetDimension:ALDimensionWidth toSize:32.0];
    [self.avatarImageView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:MarginSizes.small];
    [self.avatarImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:MarginSizes.small];
    
    [self.blogNameLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.blogNameLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.avatarImageView withOffset:MarginSizes.small];
    [self.blogNameLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:MarginSizes.small];
    [self.blogNameLabel  autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.avatarImageView];
    
    [self.bottomSectionBackground setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.bottomSectionBackground autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
    [self.bottomSectionBackground autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    [self.bottomSectionBackground autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    
    [self.topDividerView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.topDividerView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0.0];
    [self.topDividerView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0.0];
    [self.topDividerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0];
    [self.topDividerView autoSetDimension:ALDimensionHeight toSize:(1 / [UIScreen mainScreen].scale)];
    
    [self.tagsCollectionView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.tagsCollectionView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0.0];
    [self.tagsCollectionView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:1];
    [self.tagsCollectionView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0];
    [self.tagsCollectionView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:self.notesLabel withOffset:-MarginSizes.small];
    [self.tagsCollectionView autoSetDimension:ALDimensionHeight toSize:35.0];
    
    [self.notesLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.notesLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:MarginSizes.small];
    [self.notesLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:1];
    [self.notesLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0];
    
    [self.notesDividerView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.notesDividerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:MarginSizes.small];
    [self.notesDividerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:MarginSizes.small];
    [self.notesDividerView autoSetDimension:ALDimensionWidth toSize:(1 / [UIScreen mainScreen].scale)];
    [self.notesDividerView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.notesLabel withOffset:-MarginSizes.small];
    
    [self.containerView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.containerView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.avatarImageView withOffset:MarginSizes.small];
    [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:MarginSizes.small];
    [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:MarginSizes.small];
    [self.containerView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.bottomSectionBackground withOffset:-MarginSizes.small];
    
    self.didUpdateConstraints = YES;
}

- (void)prepareForReuse {
    [self.tagsCollectionView reloadData];
    self.didUpdateConstraints = NO;
}

#pragma mark - UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.post.tags count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UILabel *label = [[UILabel alloc] init];
    label.font = POST_LABEL_FONT;
    label.text = [self.post.tags[indexPath.row] bsm_hashTagify];
    CGSize size = [label systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BSMSimpleLabelCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.font = POST_LABEL_FONT;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
    
    cell.textLabel.text = [self.post.tags[indexPath.row] bsm_hashTagify];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - Properties
- (void)setPost:(BSMPost *)post {
    if (![_post isEqual:post]) {
        _post = post;
        NSString *notesString = [_post.notes integerValue] > 1 || [_post.notes integerValue] == 0 ? @"Notes" : @"Note";
        self.notesLabel.text = [NSString stringWithFormat:@"%@ %@", [[NSNumberFormatter bsm_standardNumberFormatter] stringFromNumber:_post.notes], notesString];
        self.blogNameLabel.text = _post.blogName;
        
        for (BSMBaseContentView *subview in [self.containerView subviews]) {
            [subview prepareForReuse];
            [subview removeFromSuperview];
        }
        
        UIView *view = [BSMPostContentViewFactory contentViewForPost:_post constrainedToWidth:0.0];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.containerView addSubview:view];
        [view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        
        [self.avatarImageView bsm_loadImageAtURLAndFlash:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@.tumblr.com/avatar/64", _post.blogName]]];
        
        self.containerView.backgroundColor = [self colorForPostType:self.post.type];
        [self setNeedsUpdateConstraints];
    }
}

- (BSMPost *)post {
    return _post;
}

- (UIColor *)colorForPostType:(NSNumber *)postType {
    BSMPostType type = [postType integerValue];
    switch (type) {
        case BSMPostTypeLink:
        case BSMPostTypePhoto:
            return nil;
        case BSMPostTypeText:
        case BSMPostTypeAudio:
        case BSMPostTypeAnswer:
        case BSMPostTypeVideo:
        case BSMPostTypeQuote:
        default:
            return [UIColor lightGrayColor];
    }
}

@end
