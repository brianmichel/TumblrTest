//
//  BSMViewController.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <YapDatabase/YapDatabase.h>
#import "BSMViewController.h"
#import "BSMPost.h"
#import "BSMTumblrDatabase.h"
#import "YapDatabaseView+BSM.h"
#import "BSMPostBaseCell.h"

NSString * const CollectionViewCellID = @"cell";
NSString * const DashboardViewID = @"dashboard";

const NSInteger BSMViewControllerNumberOfItemsPerPage = 20;
const CGFloat BSMViewControllerScrollLoadThreshhold = 0.99;

@interface BSMViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong) dispatch_queue_t processingQueue;
@property (strong) YapDatabaseConnection *connection;
@property (strong) YapDatabaseViewMappings *mappings;

@property (strong) UICollectionView *collectionView;
@property (strong) UIRefreshControl *refreshControl;

@property (assign) BOOL loading;
@end

@implementation BSMViewController

- (void)commonInit {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl sizeToFit];
    [self.refreshControl addTarget:self action:@selector(didBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[BSMPostBaseCell class] forCellWithReuseIdentifier:CollectionViewCellID];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.collectionView addSubview:self.refreshControl];
    
    self.processingQueue = dispatch_queue_create("com.bsm.tumblr.processing", DISPATCH_QUEUE_CONCURRENT);
    [[BSMTumblrDatabase sharedDatabase] registerView:[YapDatabaseView bsm_dashboardPostsView] withName:DashboardViewID];
    
    self.connection = [[BSMTumblrDatabase sharedDatabase] newLonglivedDatabaseConnection];
    self.mappings = [[YapDatabaseViewMappings alloc] initWithGroups:@[@"posts"] view:DashboardViewID];
    
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [self.mappings updateWithTransaction:transaction];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yapDatabaseModified:) name:YapDatabaseModifiedNotification object:self.connection.database];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.refreshControl beginRefreshing];
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x, -self.refreshControl.frame.size.height) animated:YES];
    [self didBeginRefreshing:self.refreshControl];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self.collectionView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
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
    return CGSizeMake(collectionView.frame.size.width - (insets.left + insets.right), 200);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BSMPostBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellID forIndexPath:indexPath];
    
    __block BSMPost *post = nil;
    NSString *group = [self.mappings groupForSection:indexPath.section];
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        post = [[transaction ext:DashboardViewID] objectAtIndex:indexPath.row inGroup:group];
    }];
    cell.post = post;
    cell.backgroundColor = [UIColor redColor];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat contentSizeHeight = scrollView.contentSize.height;
    CGFloat scrollViewHeight = scrollView.frame.size.height;
    
    static CGFloat lastPercentageScrolled = 0.0;

    CGFloat percentageScrolled = (offsetY + scrollViewHeight) / contentSizeHeight;
    if (percentageScrolled > BSMViewControllerScrollLoadThreshhold && percentageScrolled > lastPercentageScrolled && !self.loading) {
        [self fetchNextPageOfPosts];
    }
    lastPercentageScrolled = percentageScrolled;
}

#pragma mark - Networking
- (void)fetchNewPostsSinceMostRecentPost {
    NSNumber *mostRecentID = [self mostRecentID];
    NSDictionary *paramaters = nil;
    if (mostRecentID) {
        paramaters = @{@"since_id" : mostRecentID};
    }
    [self fetchPostsWithParameters:paramaters];
}

- (void)fetchNextPageOfPosts {
    NSNumber *lastPostPageNumber = [self nextPageIndex];
    [self fetchPostsWithParameters:@{@"offset" : lastPostPageNumber}];
}

- (void)fetchPostsWithParameters:(NSDictionary *)parameters {
    if (self.loading) {return;}
    
    self.loading = YES;
    
    __weak typeof(self) weak = self;
    [[TMAPIClient sharedInstance] dashboard:parameters callback:^(id dashboard, NSError *error) {
        if (dashboard) {
            dispatch_async(self.processingQueue, ^{
                NSArray *posts = dashboard[@"posts"];
                for (NSDictionary *post in posts) {
                    NSError *error = nil;
                    BSMPost *postModel = [MTLJSONAdapter modelOfClass:[BSMPost class] fromJSONDictionary:post error:&error];
                    [[BSMTumblrDatabase sharedDatabase] savePost:postModel withCallback:nil];
                }
            });
        }
        weak.loading = NO;
        [weak.refreshControl endRefreshing];
    }];
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
- (void)didBeginRefreshing:(UIRefreshControl *)control {
    [self fetchNewPostsSinceMostRecentPost];
}

#pragma mark - Helpers
- (NSNumber *)mostRecentID {
    NSString *group = [self.mappings groupForSection:0];
    __block BSMPost *post = nil;
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        post = [[transaction ext:DashboardViewID] objectAtIndex:0 inGroup:group];
    }];
    
    return post.postID;
}

- (NSNumber *)nextPageIndex {
    NSInteger totalNumberOfItems = [self.mappings numberOfItemsInAllGroups];
    return @(totalNumberOfItems + 1);
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
