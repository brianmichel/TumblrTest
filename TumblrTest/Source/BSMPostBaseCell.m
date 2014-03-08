//
//  BSMPostBaseCell.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import "BSMPostBaseCell.h"
#import "BSMPost.h"
#import "BSMSimpleLabelCollectionViewCell.h"
#import "NSDateFormatter+BSM.h"

@interface BSMPostBaseCell () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
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
        
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.tagsCollectionView];
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
    [self.tagsCollectionView autoSetDimension:ALDimensionHeight toSize:20.0 relation:NSLayoutRelationGreaterThanOrEqual];
}

- (void)prepareForReuse {
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
    label.font = [UIFont systemFontOfSize:10.0];
    label.text = [NSString stringWithFormat:@"#%@", self.post.tags[indexPath.row]];
    CGSize size = [label systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BSMSimpleLabelCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.font = [UIFont systemFontOfSize:10.0];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
    
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
        [self setNeedsUpdateConstraints];
    }
}

- (BSMPost *)post {
    return _post;
}

@end
