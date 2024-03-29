//
//  BSMViewController.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <YapDatabase/YapDatabase.h>
#import <Mantle/Mantle.h>
#import "BSMBasePostsViewController.h"
#import "BSMTumblrDatabase.h"
#import "YapDatabaseView+BSM.h"
#import "BSMPost.h"

NSString * const ViewControllerCellID = @"cell";
NSString * const DashboardViewID = @"dashboard";

const NSInteger BSMViewControllerNumberOfItemsPerPage = 20;
const CGFloat BSMViewControllerScrollLoadThreshhold = 0.99;
@interface BSMBasePostsViewController ()

@end

@implementation BSMBasePostsViewController

- (void)commonInit {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(didBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    self.processingQueue = dispatch_queue_create("com.bsm.tumblr.processing", DISPATCH_QUEUE_CONCURRENT);
    [[BSMTumblrDatabase sharedDatabase] registerView:[YapDatabaseView bsm_dashboardPostsView] withName:DashboardViewID];
    
    self.connection = [[BSMTumblrDatabase sharedDatabase] newLonglivedDatabaseConnection];
    self.mappings = [[YapDatabaseViewMappings alloc] initWithGroups:@[@"posts"] view:DashboardViewID];
    
    [self.connection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
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
    [[TMAPIClient sharedInstance] dashboard:[parameters mtl_dictionaryByAddingEntriesFromDictionary:@{@"notes_info" : @YES}] callback:^(id dashboard, NSError *error) {
        if (dashboard) {
            dispatch_async(self.processingQueue, ^{
                NSArray *posts = dashboard[@"posts"];
                for (NSDictionary *post in posts) {
                    NSError *error = nil;
                    BSMPost *postModel = [MTLJSONAdapter modelOfClass:[BSMPost class] fromJSONDictionary:post error:&error];
                    [[BSMTumblrDatabase sharedDatabase] savePost:postModel withCallback:nil];
                }
                weak.loading = NO;
            });
        } else {
            weak.loading = NO;
        }
        
        //well endRefresh seems to really like stopping scrolling events, this forces it to wait
        //until the next swing of the runloop to do anything. :(
        //Seems like others are experiencing this: http://blog.wednesdaynight.org/2014/2/2/endRefreshing-while-decelerating
        [weak.refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0];
        [weak didEndRefreshing];
    }];
}

#pragma mark - Actions
- (void)didBeginRefreshing:(UIRefreshControl *)control {
    [self fetchNewPostsSinceMostRecentPost];
}

- (void)didEndRefreshing {}

- (BSMPost *)postForIndexPath:(NSIndexPath *)indexPath {
    __block BSMPost *post = nil;
    NSString *group = [self.mappings groupForSection:indexPath.section];
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        post = [[transaction ext:DashboardViewID] objectAtIndex:indexPath.row inGroup:group];
    }];
    
    return post;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Notification
- (void)yapDatabaseModified:(NSNotification *)notification {
    //override in subclass
}

#pragma mark - Helpers
- (NSNumber *)mostRecentID {
    BSMPost *post = [self postForIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
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
