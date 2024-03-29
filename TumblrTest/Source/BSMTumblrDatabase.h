//
//  BSMTumblrDatabase.h
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YapDatabaseConnection;
@class YapDatabaseView;
@class BSMPost;

@interface BSMTumblrDatabase : NSObject

+ (instancetype)sharedDatabase;
- (YapDatabaseConnection *)newLonglivedDatabaseConnection;

- (void)savePost:(BSMPost *)post withCallback:(dispatch_block_t)callback;
- (void)deletePost:(BSMPost *)post withCallback:(dispatch_block_t)callback;

- (void)registerView:(YapDatabaseView *)view withName:(NSString *)name;
- (void)deregisterViewWithName:(NSString *)name;
- (NSArray *)allViews;
@end
