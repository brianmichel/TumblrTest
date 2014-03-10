//
//  BSMPostBaseTableViewCell.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <UIColor-Crayola/UIColor+Crayola.h>
#import "BSMPostBaseTableViewCell.h"
#import "BSMSimpleLabelCollectionViewCell.h"
#import "BSMPost.h"
#import "BSMSimpleLabelCollectionViewCell.h"
#import "NSDateFormatter+BSM.h"
#import "NSString+BSM.h"

#define POST_LABEL_FONT [UIFont fontWithName:@"HelveticaNeue" size:14.0]

@interface BSMPostBaseTableViewCell () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong) UILabel *dateLabel;
@property (strong, readwrite) UIView *containerView;
@property (strong) UICollectionView *tagsCollectionView;
@property (strong) UILabel *captionLabel;

@property (assign) BOOL updatedConstraints;
@end

@implementation BSMPostBaseTableViewCell

@synthesize post = _post;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.containerView = [UIView newAutoLayoutView];
        self.containerView.backgroundColor = [UIColor magentaColor];
        
        self.captionLabel = [UILabel newAutoLayoutView];
        self.captionLabel.numberOfLines = 0;
        self.captionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.containerView addSubview:self.captionLabel];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.tagsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
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
        
        [self.contentView addSubview:self.containerView];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.tagsCollectionView];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    if (self.updatedConstraints) {
        return;
    }
    [self.containerView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:5.0];
    [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:5.0];
    [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5.0];
    
    [self.dateLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.dateLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.containerView];
    [self.dateLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5.0];
    [self.dateLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:5.0];
    
    [self.tagsCollectionView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.tagsCollectionView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:5.0];
    [self.tagsCollectionView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5.0];
    [self.tagsCollectionView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:self.dateLabel withOffset:-5.0];
    [self.tagsCollectionView autoConstrainAttribute:ALDimensionHeight toAttribute:ALDimensionHeight ofView:self.dateLabel];
    
    [self.captionLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    self.updatedConstraints = YES;
}

- (void)prepareForReuse {
    self.updatedConstraints = NO;
    [self.tagsCollectionView reloadData];
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
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    
    cell.textLabel.text = [self.post.tags[indexPath.row] bsm_hashTagify];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - Properties
- (void)setPost:(BSMPost *)post {
    if (_post != post) {
        _post = post;
        self.dateLabel.text = [[NSDateFormatter bsm_shortRelativeDateFormatter] stringFromDate:_post.date];
        
        switch ([_post.type integerValue]) {
            case BSMPostTypePhoto: {
                BSMPhotoPost *photo = (BSMPhotoPost *)_post;
                self.captionLabel.text = photo.caption;
            }
            default:
                break;
        }
        
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
