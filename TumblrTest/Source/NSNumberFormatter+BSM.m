//
//  NSNumberFormatter+BSM.m
//  TumblrTest
//
//  Created by Brian Michel on 3/9/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import "NSNumberFormatter+BSM.h"

@implementation NSNumberFormatter (BSM)
+ (NSNumberFormatter *)bsm_standardNumberFormatter {
    static dispatch_once_t onceToken;
    static NSNumberFormatter *standardNumberFormatter = nil;
    dispatch_once(&onceToken, ^{
        standardNumberFormatter = [[NSNumberFormatter alloc] init];
        standardNumberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    });
    return standardNumberFormatter;
}
@end
