//
//  YapDatabaseView+BSM.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import "YapDatabaseView+BSM.h"
#import "BSMPost.h"

@implementation YapDatabaseView (BSM)
+ (YapDatabaseView *)bsm_dashboardPostsView {
    YapDatabaseViewBlockType groupingBlockType = YapDatabaseViewBlockTypeWithKey;
    YapDatabaseViewGroupingBlock groupingBlock = ^ NSString * (NSString *collection, NSString *key) {
        if ([collection isEqualToString:@"posts"]) {
            return @"posts";
        }
        return nil;
    };
    
    YapDatabaseViewBlockType sortingBlockType = YapDatabaseViewBlockTypeWithObject;
    YapDatabaseViewSortingBlock sortingBlock = ^ NSComparisonResult (NSString *group, NSString *collection1, NSString *key1, id object1,NSString *collection2, NSString *key2, id object2) {
        BSMPost *post1 = object1;
        BSMPost *post2 = object2;
        return [post1.postID compare:post2.postID];
    };
    YapDatabaseView *dashboardPostsView = [[YapDatabaseView alloc] initWithGroupingBlock:groupingBlock groupingBlockType:groupingBlockType sortingBlock:sortingBlock sortingBlockType:sortingBlockType];
    
    return dashboardPostsView;
}
@end
