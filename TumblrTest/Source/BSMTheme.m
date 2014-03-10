//
//  BSMTheme.m
//  TumblrTest
//
//  Created by Brian Michel on 3/9/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import "BSMTheme.h"

const struct MarginSizes MarginSizes = {
    .small = 5.0,
    .medium = 10.0,
    .large = 15.0,
    .xlarge = 20.0
};

@implementation BSMTheme

@end

@implementation UIColor (BSM)

+ (UIColor *)bsm_TumblrBlue {
    return [UIColor colorWithRed:0.173 green:0.278 blue:0.384 alpha:1.0];
}

+ (UIColor *)bsm_tumblrGreen {
    return [UIColor colorWithRed:0.337 green:0.737 blue:0.541 alpha:1.0];
}

+ (UIColor *)bsm_tumblrLightGray {
    return [UIColor colorWithRed:0.857 green:0.857 blue:0.857 alpha:1.0];
}

@end
