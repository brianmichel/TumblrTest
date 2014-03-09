//
//  BSMViewController.h
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YapDatabaseConnection;
@class YapDatabaseViewMappings;
@class BSMPost;

extern NSString * const ViewControllerCellID;
extern NSString * const DashboardViewID;

extern const NSInteger BSMViewControllerNumberOfItemsPerPage;
extern const CGFloat BSMViewControllerScrollLoadThreshhold;

@interface BSMViewController : UIViewController
@property (strong) dispatch_queue_t processingQueue;
@property (strong) YapDatabaseConnection *connection;
@property (strong) YapDatabaseViewMappings *mappings;
@property (strong) UIRefreshControl *refreshControl;

@property (assign) BOOL loading;

- (void)fetchNewPostsSinceMostRecentPost;
- (void)fetchNextPageOfPosts;
- (void)fetchPostsWithParameters:(NSDictionary *)parameters;
- (void)yapDatabaseModified:(NSNotification *)notification;
- (void)didBeginRefreshing:(UIRefreshControl *)control;

- (BSMPost *)postForIndexPath:(NSIndexPath *)indexPath;
@end
