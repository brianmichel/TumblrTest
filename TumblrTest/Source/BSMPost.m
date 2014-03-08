//
//  BSMPost.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import "BSMPost.h"

static NSDictionary *postTypeToStringMapping = nil;

@implementation BSMPost

//text, quote, link, answer, video, audio, photo, chat
+ (BSMPostType)postTypeFromString:(NSString *)string {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        postTypeToStringMapping = @{
                                    @"text" : @(BSMPostTypeText),
                                    @"quote" : @(BSMPostTypeQuote),
                                    @"link" : @(BSMPostTypeLink),
                                    @"answer" : @(BSMPostTypeAnswer),
                                    @"video" : @(BSMPostTypeVideo),
                                    @"audio" : @(BSMPostTypeAudio),
                                    @"photo" : @(BSMPostTypePhoto),
                                    @"chat" : @(BSMPostTypeChat)
                                    };
    });
    NSNumber *postTypeNumber = postTypeToStringMapping[string];
    return postTypeNumber ? [postTypeNumber integerValue] : BSMPostTypeUnknown;
}

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {
    BSMPostType type = [[self class] postTypeFromString:JSONDictionary[@"type"]];
    switch (type) {
        case BSMPostTypeText:
            return [BSMTextPost class];
        case BSMPostTypeLink:
            return [BSMLinkPost class];
        case BSMPostTypeQuote:
            return [BSMQuotePost class];
        default:
            return [self class];
    }
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"postID" : @"id",
             @"blogName" : @"blog_name",
             @"caption" : @"caption",
             @"postURL" : @"post_url",
             @"shortURL" : @"short_url",
             @"date" : @"timestamp",
             @"tags" : @"tags",
             @"type" : @"type"
             };
}

+ (NSValueTransformer *)dateJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^id(id timestamp) {
        if (timestamp) {
            return [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
        }
        return nil;
    }];
}

+ (NSValueTransformer *)postURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)shortURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)typeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:postTypeToStringMapping];
}

@end

@implementation BSMTextPost

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:
             @{
               @"title" : @"title",
               @"body" : @"body"
               }];
}

@end

@implementation BSMQuotePost

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:
            @{
              @"text" : @"text",
              @"source" :@"soruce"
              }];
}

@end

@implementation BSMLinkPost

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:
            @{
              @"title" : @"title",
              @"URL" : @"url",
              @"postDescription" : @"description"
              }];
}

+ (NSValueTransformer *)urlJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
