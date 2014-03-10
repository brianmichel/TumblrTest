//
//  NSDateFormatter+BSM.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import "NSDateFormatter+BSM.h"

@implementation NSDateFormatter (BSM)
+ (NSDateFormatter *)bsm_shortRelativeDateFormatter {
    static dispatch_once_t onceToken;
    static NSDateFormatter *shortRelativeDateFormatter = nil;
    dispatch_once(&onceToken, ^{
        shortRelativeDateFormatter = [[NSDateFormatter alloc] init];
        shortRelativeDateFormatter.doesRelativeDateFormatting = YES;
        shortRelativeDateFormatter.dateStyle = NSDateFormatterShortStyle;
        shortRelativeDateFormatter.timeStyle = NSDateFormatterNoStyle;
    });
    return shortRelativeDateFormatter;
}
@end
