//
//  BSMTheme.h
//  TumblrTest
//
//  Created by Brian Michel on 3/9/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const struct MarginSizes {
    CGFloat small;
    CGFloat medium;
    CGFloat large;
    CGFloat xlarge;
} MarginSizes;

@interface BSMTheme : NSObject
@end

@interface UIColor (BSM_Theme)
+ (UIColor *)bsm_TumblrBlue;
+ (UIColor *)bsm_tumblrGreen;
+ (UIColor *)bsm_tumblrLightGray;
@end

@interface UIImage (BSM_Theme)
+ (UIImage *)bsm_coloredImageOfSize:(CGSize)size color:(UIColor *)color scale:(CGFloat)scale alpha:(CGFloat)alpha;
@end