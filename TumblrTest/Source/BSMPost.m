//
//  BSMPost.m
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import "BSMPost.h"
#import "BSMPhoto.h"

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
        case BSMPostTypePhoto:
            return [BSMPhotoPost class];
        case BSMPostTypeAudio:
            return [BSMAudioPost class];
        case BSMPostTypeVideo:
            return [BSMVideoPost class];
        case BSMPostTypeAnswer:
            //unimplemented
        case BSMPostTypeChat:
            //unimplemented
        case BSMPostTypeUnknown:
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

@implementation BSMPhotoPost

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:
            @{
              @"photos" : @"photos",
              @"caption" : @"caption"
              }];
}

+ (NSValueTransformer *)photosJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[BSMPhoto class]];
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

@implementation BSMAudioPost

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:
            @{
              @"caption" : @"caption",
              @"player" : @"player",
              @"plays" : @"plays",
              @"albumArtURL" : @"album_art",
              @"artist" : @"artist",
              @"album" : @"album",
              @"trackName" : @"track_name",
              @"trackNumber" : @"track_number",
              @"year" : @"year"
              }];
}

+ (NSValueTransformer *)album_artJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end

@implementation BSMVideoPost

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:
            @{
              @"caption" : @"caption",
              @"player" : @"player"
              }];
}

@end