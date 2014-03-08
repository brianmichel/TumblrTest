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

@interface BSMViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong) dispatch_queue_t processingQueue;
@property (strong) YapDatabaseConnection *connection;
@property (strong) YapDatabaseViewMappings *mappings;

@property (strong) UICollectionView *collectionView;
@end

@implementation BSMViewController

- (void)commonInit {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[BSMPostBaseCell class] forCellWithReuseIdentifier:CollectionViewCellID];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.processingQueue = dispatch_queue_create("com.bsm.tumblr.processing", DISPATCH_QUEUE_CONCURRENT);
    [[BSMTumblrDatabase sharedDatabase] registerView:[YapDatabaseView bsm_dashboardPostsView] withName:DashboardViewID];
    NSLog(@"ALL EXTENSIONS: %@", [[BSMTumblrDatabase sharedDatabase] allViews]);
    
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
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.collectionView];
    //[self fetchNewPosts];
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

#pragma mark - Networking
- (void)fetchNewPosts {
    //todo need to store offsets
    [[TMAPIClient sharedInstance] dashboard:nil callback:^(id dashboard, NSError *error) {
        if (dashboard) {
            dispatch_async(self.processingQueue, ^{
                NSArray *posts = dashboard[@"posts"];
                for (NSDictionary *post in posts) {
                    NSError *error = nil;
                    BSMPost *postModel = [MTLJSONAdapter modelOfClass:[BSMPost class] fromJSONDictionary:post error:&error];
                    [[BSMTumblrDatabase sharedDatabase] savePost:postModel withCallback:nil];
                    NSLog(@"BASE POST: %@", postModel);
                }
            });
        }
        
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
    
    NSLog(@"SECTION CHANGES: %@", sectionChanges);
    NSLog(@"ROW CHANGES: %@", rowChanges);
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
