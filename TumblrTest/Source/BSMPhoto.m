//
//  BSMPhoto.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import "BSMPhoto.h"

@implementation BSMPhoto
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"caption" : @"caption",
             @"sizes" : @"alt_sizes"
             };
}

+ (NSValueTransformer *)sizesJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[BSMPhotoSize class]];
}
@end

@implementation BSMPhotoSize

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"width" : @"width",
             @"height" : @"height",
             @"URL" : @"url"
             };
}

+ (NSValueTransformer *)URLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
