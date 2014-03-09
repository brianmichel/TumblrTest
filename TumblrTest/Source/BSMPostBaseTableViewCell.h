//
//  BSMPostBaseTableViewCell.h
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BSMPost;

@interface BSMPostBaseTableViewCell : UITableViewCell
@property (strong, readonly) UIView *containerView;
@property (strong) BSMPost *post;
@end
