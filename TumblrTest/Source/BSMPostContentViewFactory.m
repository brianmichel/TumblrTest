//
//  BSMPostContentViewFactory.m
//  TumblrTest
//
//  Created by Brian Michel on 3/9/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import "BSMPostContentViewFactory.h"
#import "BSMBaseContentView.h"
#import "BSMPhotoContentView.h"
#import "BSMPost.h"

@implementation BSMPostContentViewFactory
+ (UIView *)contentViewForPost:(BSMPost *)post constrainedToWidth:(CGFloat)width {
    BSMBaseContentView *contentView = nil;
    switch ([post.type integerValue]) {
        case BSMPostTypePhoto:
            contentView = [[BSMPhotoContentView alloc] init];
            break;
        default:
            contentView = [[BSMBaseContentView alloc] init];
            break;
    }
    contentView.post = post;
    
    return contentView;
}
@end
