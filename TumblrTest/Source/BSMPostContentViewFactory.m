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
#import "BSMLinkContentView.h"
#import "BSMPost.h"

static NSCache *postContentViewCache = nil;

@implementation BSMPostContentViewFactory
+ (UIView *)contentViewForPost:(BSMPost *)post constrainedToWidth:(CGFloat)width {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        postContentViewCache = [[NSCache alloc] init];
    });
    
    
    BSMBaseContentView *contentView = nil;

    switch ([post.type integerValue]) {
        case BSMPostTypePhoto:
            contentView = [[BSMPhotoContentView alloc] initWithConstraintWidth:width];
            break;
        case BSMPostTypeLink:
            contentView = [[BSMLinkContentView alloc] initWithConstraintWidth:width];
            break;
        default:
            contentView = [[BSMBaseContentView alloc] initWithConstraintWidth:width];
            break;
    }
    contentView.post = post;
        
    return contentView;
}

+ (CGFloat)defaultElementsHeight {
    return 110.0;
}
@end
