//
//  NSString+BSM.m
//  TumblrTest
//
//  Created by Brian Michel on 3/9/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import "NSString+BSM.h"

@implementation NSString (BSM)
- (NSString *)bsm_hashTagify {
    NSString *potentialHash = [self substringToIndex:1];
    if ([potentialHash isEqualToString:@"#"]) {
        //already hashtagified
        return self;
    }
    return [NSString stringWithFormat:@"#%@", self];
}
@end
