//
//  BSMViewController.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <YapDatabase/YapDatabase.h>
#import "BSMCollectionViewController.h"
#import "BSMPost.h"
#import "BSMTumblrDatabase.h"
#import "YapDatabaseView+BSM.h"
#import "UIScrollView+BSM.h"
#import "BSMPostBaseCell.h"
#import "BSMPostContentViewFactory.h"

@interface BSMCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong) UICollectionView *collectionView;
@property (strong) UIView *statusBarBackground;
@property (strong) UIActivityIndicatorView *loadingNextSpinner;
@end

@implementation BSMCollectionViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        [self.collectionView registerClass:[BSMPostBaseCell class] forCellWithReuseIdentifier:ViewControllerCellID];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView addSubview:self.refreshControl];
        
        self.statusBarBackground = [UIView newAutoLayoutView];
        self.statusBarBackground.backgroundColor = [UIColor bsm_TumblrBlue];
        
        self.loadingNextSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.loadingNextSpinner.translatesAutoresizingMaskIntoConstraints = NO;
        [self.loadingNextSpinner startAnimating];
        self.loadingNextSpinner.alpha = 0.0;
        //I really wish I could figure out why topLayoutGuide isn't set :(
        self.collectionView.contentInset = UIEdgeInsetsMake(25, 10, self.loadingNextSpinner.frame.size.height + (MarginSizes.large * 2.0), 10);
        self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(20, 0, 0, -4);
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bsm_TumblrBlue];
    [self.view addSubview:self.loadingNextSpinner];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.statusBarBackground];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //send to back, like the tumblr app
    [self.collectionView sendSubviewToBack:self.refreshControl];
    [self.refreshControl beginRefreshing];
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x, -self.refreshControl.frame.size.height) animated:YES];
    [self didBeginRefreshing:self.refreshControl];
    [self setupScrollIndicatorImages];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self.collectionView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    [self.statusBarBackground autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0.0];
    [self.statusBarBackground autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0];
    [self.statusBarBackground autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0.0];
    [self.statusBarBackground autoSetDimension:ALDimensionHeight toSize:20.0];
    
    [self.loadingNextSpinner autoAlignAxis:ALAxisVertical toSameAxisOfView:self.view];
    [self.loadingNextSpinner autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:MarginSizes.large];
}

- (void)fetchNextPageOfPosts {
    [UIView animateWithDuration:0.3 animations:^{
        self.loadingNextSpinner.alpha = 1.0;
    } completion:^(BOOL finished) {
        [super fetchNextPageOfPosts];
    }];
}

- (void)didEndRefreshing {
    [UIView animateWithDuration:0.3 animations:^{
        self.loadingNextSpinner.alpha = 0.0;
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UICollectionViewDataSource / UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.mappings.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.mappings numberOfItemsInSection:section];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIEdgeInsets insets = collectionView.contentInset;
    
    BSMPost *post = [self postForIndexPath:indexPath];

    CGFloat width = collectionView.frame.size.width - (insets.left + insets.right);
    UIView *view = [BSMPostContentViewFactory contentViewForPost:post constrainedToWidth:width];
    return CGSizeMake(width, view.frame.size.height + [BSMPostContentViewFactory defaultElementsHeight]);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BSMPostBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ViewControllerCellID forIndexPath:indexPath];
    
    BSMPost *post = [self postForIndexPath:indexPath];
    cell.post = post;
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //TODO this feels kind of ugly, is there a better way?
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat contentSizeHeight = scrollView.contentSize.height;
    CGFloat scrollViewHeight = scrollView.frame.size.height;
    
    static CGFloat lastPercentageScrolled = 0.0;

    CGFloat percentageScrolled = (offsetY + scrollViewHeight) / contentSizeHeight;
    if (percentageScrolled < CGFLOAT_MAX) {
        if (percentageScrolled > BSMViewControllerScrollLoadThreshhold && percentageScrolled > lastPercentageScrolled && !self.loading) {
            [self fetchNextPageOfPosts];
        }
        lastPercentageScrolled = percentageScrolled;
    }
}

#pragma mark - Notifications
- (void)yapDatabaseModified:(NSNotification *)notification {
    NSArray *notifications = [self.connection beginLongLivedReadTransaction];

    NSArray *sectionChanges = nil;
    NSArray *rowChanges = nil;
    
    [[self.connection ext:DashboardViewID] getSectionChanges:&sectionChanges
                                                  rowChanges:&rowChanges
                                            forNotifications:notifications
                                                withMappings:self.mappings];
    
    if ([sectionChanges count] == 0 & [rowChanges count] == 0) {
        return;
    }

    [self.collectionView performBatchUpdates:^{
        for (YapDatabaseViewRowChange *rowChange in rowChanges) {
            switch (rowChange.type) {
                case YapDatabaseViewChangeDelete: {
                    [self.collectionView deleteItemsAtIndexPaths:@[rowChange.indexPath]];
                    break;
                }
                case YapDatabaseViewChangeInsert: {
                    [self.collectionView insertItemsAtIndexPaths:@[rowChange.newIndexPath]];
                    break;
                }
                case YapDatabaseViewChangeMove:{
                    [self.collectionView moveItemAtIndexPath:rowChange.indexPath toIndexPath:rowChange.newIndexPath];
                    break;
                }
                case YapDatabaseViewChangeUpdate:{
                    [self.collectionView reloadItemsAtIndexPaths:@[rowChange.indexPath]];
                    break;
                }
            }
        }
    } completion:nil];
}

#pragma mark - Actions
- (void)setupScrollIndicatorImages {
    UIView *verticalScrollIndicatorView = [self.collectionView bsm_scrollIndicatorForPosition:ScrollIndicatorPositionVertical];
    if ([verticalScrollIndicatorView isKindOfClass:[UIImageView class]]) {
        UIImage *indicatorImage = [UIImage bsm_coloredImageOfSize:CGSizeMake(4, 4) color:[UIColor whiteColor] scale:[UIScreen mainScreen].scale alpha:0.2];
        indicatorImage = [indicatorImage resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
        ((UIImageView *)verticalScrollIndicatorView).image = indicatorImage;
    }
}
@end
