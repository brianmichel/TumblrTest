//
//  BSMPost.h
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
/**
  text, quote, link, answer, video, audio, photo, chat
 */

typedef NS_ENUM(NSInteger, BSMPostType) {
    BSMPostTypeUnknown = -1,
    BSMPostTypeText,
    BSMPostTypeQuote,
    BSMPostTypeLink,
    BSMPostTypeAnswer,
    BSMPostTypeVideo,
    BSMPostTypeAudio,
    BSMPostTypePhoto,
    BSMPostTypeChat
};

@interface BSMPost : MTLModel <MTLJSONSerializing>
@property (copy, readonly) NSNumber *postID;
@property (copy, readonly) NSString *blogName;
@property (copy, readonly) NSURL *postURL;
@property (copy, readonly) NSURL *shortURL;
@property (copy, readonly) NSDate *date;
@property (copy, readonly) NSNumber *notes;
@property (copy, readonly) NSArray *tags;
@property (copy, readonly) NSNumber *type;

+ (BSMPostType)postTypeFromString:(NSString *)string;
+ (NSString *)typeStringFromPostType:(NSNumber *)type;
@end

@interface BSMTextPost : BSMPost
@property (copy, readonly) NSString *title;
@property (copy, readonly) NSString *body;
@end

@interface BSMPhotoPost : BSMPost
@property (copy, readonly) NSArray *photos;
@property (copy, readonly) NSString *caption;
@property (copy, readonly) NSNumber *width;
@property (copy, readonly) NSNumber *height;
@end

@interface BSMQuotePost : BSMPost
@property (copy, readonly) NSString *text;
@property (copy, readonly) NSString *source;
@end

@interface BSMLinkPost : BSMPost
@property (copy, readonly) NSString *title;
@property (copy, readonly) NSURL *URL;
@property (copy, readonly) NSString *postDescription;
@end

@interface BSMChatPost : BSMPost
@property (copy, readonly) NSString *title;
@property (copy, readonly) NSString *body;
@property (copy, readonly) NSArray *dialog;
@end

@interface BSMAudioPost : BSMPost
@property (copy, readonly) NSString *caption;
@property (copy, readonly) NSString *player;
@property (copy, readonly) NSNumber *plays;
@property (copy, readonly) NSURL *albumArtURL;
@property (copy, readonly) NSString *artist;
@property (copy, readonly) NSString *album;
@property (copy, readonly) NSString *trackName;
@property (copy, readonly) NSNumber *trackNumber;
@property (copy, readonly) NSNumber *year;
@end

@interface BSMVideoPost : BSMPost
@property (copy, readonly) NSString *caption;
@property (copy, readonly) NSArray *player;
@end

//Need Audio
//Need Video