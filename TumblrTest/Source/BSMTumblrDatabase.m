//
//  BSMTumblrDatabase.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <YapDatabase/YapDatabase.h>
#import "BSMTumblrDatabase.h"
#import "BSMPost.h"

@interface BSMTumblrDatabase ()
@property (strong) YapDatabase *database;
@property (strong) YapDatabaseConnection *writeConnection;
@end

@implementation BSMTumblrDatabase

+ (instancetype)sharedDatabase {
    static dispatch_once_t onceToken;
    static BSMTumblrDatabase *sharedDatabase = nil;
    dispatch_once(&onceToken, ^{
        sharedDatabase = [[BSMTumblrDatabase alloc] init];
    });
    
    return sharedDatabase;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupDatabaseAndConnections];
    }
    return self;
}

- (void)setupDatabaseAndConnections {
    self.database = [[YapDatabase alloc] initWithPath:[self databasePath]];
    self.writeConnection = [self.database newConnection];
}

- (NSString *)databasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return [NSString stringWithFormat:@"%@/%@", basePath, [self databaseName]];
}

- (NSString *)databaseName {
    return @"TumblrTest.sqlite";
}

#pragma mark - Posts
- (void)savePost:(BSMPost *)post withCallback:(dispatch_block_t)callback {
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:post forKey:[NSString stringWithFormat:@"%li", (long)[post.postID integerValue]] inCollection:@"posts"];
    } completionBlock:callback];
}

- (void)deletePost:(BSMPost *)post withCallback:(dispatch_block_t)callback {
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeObjectForKey:[NSString stringWithFormat:@"%li", (long)[post.postID integerValue]] inCollection:@"posts"];
    } completionBlock:callback];
}
@end
