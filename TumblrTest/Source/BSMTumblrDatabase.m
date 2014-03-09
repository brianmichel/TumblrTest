//
//  BSMTumblrDatabase.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <YapDatabase/YapDatabase.h>
#import <YapDatabase/YapDatabaseView.h>
#import "BSMTumblrDatabase.h"
#import "BSMPost.h"

@interface BSMTumblrDatabase ()
@property (strong) YapDatabase *database;
@property (strong) YapDatabaseConnection *writeConnection;
@property (strong) YapDatabaseConnection *readConnection;
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

- (YapDatabaseConnection *)newLonglivedDatabaseConnection {
    YapDatabaseConnection *connection = [self.database newConnection];
    [connection beginLongLivedReadTransaction];
    return connection;
}

- (void)setupDatabaseAndConnections {
    self.database = [[YapDatabase alloc] initWithPath:[self databasePath]];
    self.database.defaultObjectPolicy = YapDatabasePolicyCopy;
    self.database.defaultMetadataPolicy = YapDatabasePolicyCopy;
    
    self.writeConnection = [self.database newConnection];
    self.readConnection = [self.database newConnection];
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

#pragma mark - Views
- (void)registerView:(YapDatabaseView *)view withName:(NSString *)name {
    [self.database registerExtension:view withName:name];
}

- (void)deregisterViewWithName:(NSString *)name {
    [self.database unregisterExtension:name];
}

- (NSArray *)allViews {
    return [[self.database registeredExtensions] allValues];
}

@end
