//
//  BSMPhoto.h
//  TumblrTest
//
//  Created by Brian Michel on 3/8/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface BSMPhoto : MTLModel <MTLJSONSerializing>
@property (copy, readonly) NSString *caption;
@property (copy, readonly) NSArray *sizes;
@end

@interface BSMPhotoSize : MTLModel <MTLJSONSerializing>
@property (copy, readonly) NSNumber *width;
@property (copy, readonly) NSNumber *height;
@property (copy, readonly) NSURL *URL;
@end
