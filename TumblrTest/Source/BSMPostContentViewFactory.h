//
//  BSMPostContentViewFactory.h
//  TumblrTest
//
//  Created by Brian Michel on 3/9/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BSMPost;

@interface BSMPostContentViewFactory : NSObject
+ (UIView *)contentViewForPost:(BSMPost *)post constrainedToWidth:(CGFloat)width;
@end
