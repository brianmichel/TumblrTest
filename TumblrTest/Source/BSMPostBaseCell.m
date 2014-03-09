//
//  BSMPostBaseCell.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <UIColor-Crayola/UIColor+Crayola.h>
#import "BSMPostBaseCell.h"
#import "BSMPost.h"
#import "BSMSimpleLabelCollectionViewCell.h"
#import "NSDateFormatter+BSM.h"
#import "BSMPostContentViewFactory.h"

#define POST_LABEL_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]

@interface BSMPostBaseCell () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, readwrite) UIView *containerView;
@property (strong) UILabel *dateLabel;
@property (strong) UICollectionView *tagsCollectionView;
@end

@implementation BSMPostBaseCell

@synthesize post = _post;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.containerView = [UIView newAutoLayoutView];
        self.containerView.backgroundColor = [UIColor lightGrayColor];
        
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
        
        self.dateLabel = [UILabel newAutoLayoutView];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        self.dateLabel.font = POST_LABEL_FONT;
        
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.tagsCollectionView];
        [self.contentView addSubview:self.containerView];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.dateLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5.0];
    [self.dateLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:5.0];
    
    [self.tagsCollectionView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:5.0];
    [self.tagsCollectionView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5.0];
    [self.tagsCollectionView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:self.dateLabel withOffset:-5.0];
    [self.tagsCollectionView autoConstrainAttribute:ALDimensionHeight toAttribute:ALDimensionHeight ofView:self.dateLabel];
    
    [self.containerView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:5.0];
    [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:5.0];
    [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5.0];
    [self.containerView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.dateLabel];
}

- (void)prepareForReuse {
    [self.tagsCollectionView reloadData];
    for (UIView *subview in [self.containerView subviews]) {
        [subview removeFromSuperview];
    }
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
    label.text = [NSString stringWithFormat:@"#%@", self.post.tags[indexPath.row]];
    CGSize size = [label systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BSMSimpleLabelCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.font = POST_LABEL_FONT;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    
    cell.textLabel.text = [NSString stringWithFormat:@"#%@", self.post.tags[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - Properties
- (void)setPost:(BSMPost *)post {
    if (_post != post) {
        _post = post;
        //stuff
        self.dateLabel.text = [[NSDateFormatter bsm_shortRelativeDateFormatter] stringFromDate:_post.date];
        
        UIView *view = [BSMPostContentViewFactory contentViewForPost:_post constrainedToWidth:0.0];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.containerView addSubview:view];
        
        [view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        
        self.backgroundColor = [self colorForPostType:self.post.type];
        [self setNeedsUpdateConstraints];
    }
}

- (BSMPost *)post {
    return _post;
}

- (UIColor *)colorForPostType:(NSNumber *)postType {
    BSMPostType type = [postType integerValue];
    switch (type) {
        case BSMPostTypeText:
            return [UIColor crayolaAmethystColor];
        case BSMPostTypePhoto:
            return [UIColor crayolaOceanGreenPearlColor];
        case BSMPostTypeAudio:
            return [UIColor crayolaAtomicTangerineColor];
        case BSMPostTypeAnswer:
            return [UIColor crayolaShampooColor];
        case BSMPostTypeVideo:
            return [UIColor crayolaSizzlingSunriseColor];
        case BSMPostTypeQuote:
            return [UIColor crayolaSkyBlueColor];
        default:
            return [UIColor lightGrayColor];
            break;
    }
}

@end
