//
//  BSMTableViewController.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <YapDatabase/YapDatabase.h>
#import "BSMTableViewController.h"
#import "BSMPost.h"
#import "BSMTumblrDatabase.h"
#import "YapDatabaseView+BSM.h"
#import "BSMPostBaseCell.h"
#import "BSMPostBaseTableViewCell.h"

@interface BSMTableViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong) UITableView *tableView;
@end

@implementation BSMTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView registerClass:[BSMPostBaseTableViewCell class] forCellReuseIdentifier:ViewControllerCellID];
        
        [self.tableView addSubview:self.refreshControl];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate / UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.mappings.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.mappings numberOfItemsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BSMPostBaseTableViewCell *cell = (BSMPostBaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ViewControllerCellID];
    
    __block BSMPost *post = nil;
    NSString *group = [self.mappings groupForSection:indexPath.section];
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        post = [[transaction ext:DashboardViewID] objectAtIndex:indexPath.row inGroup:group];
    }];
    cell.post = post;
    
    cell.bounds = CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1;
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BSMPostBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ViewControllerCellID];
    __block BSMPost *post = nil;
    NSString *group = [self.mappings groupForSection:indexPath.section];
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        post = [[transaction ext:DashboardViewID] objectAtIndex:indexPath.row inGroup:group];
    }];
    cell.post = post;
    
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
    
    [self.tableView beginUpdates];
    
    for (YapDatabaseViewRowChange *rowChange in rowChanges) {
        switch (rowChange.type) {
            case YapDatabaseViewChangeDelete: {
                [self.tableView deleteRowsAtIndexPaths:@[rowChange.indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeInsert: {
                [self.tableView insertRowsAtIndexPaths:@[rowChange.newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeMove:{
                [self.tableView moveRowAtIndexPath:rowChange.indexPath toIndexPath:rowChange.newIndexPath];
                break;
            }
            case YapDatabaseViewChangeUpdate:{
                [self.tableView reloadRowsAtIndexPaths:@[rowChange.indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
        }
    }
    
    [self.tableView endUpdates];
}
@end
