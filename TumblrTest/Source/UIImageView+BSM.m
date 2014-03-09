//
//  UIImageView+BSM.m
//  TumblrTest
//
//  Created by Brian Michel on 3/9/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+BSM.h"

@implementation UIImageView (BSM)
- (void)loadImageAtURLAndFlash:(NSURL *)url {
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if (image) {
            [UIView animateWithDuration:0.1 animations:^{
                self.alpha = 0.0;
            } completion:^(BOOL finished) {
                self.image = image;
                [UIView animateWithDuration:0.1 animations:^{
                    self.alpha = 1.0;
                }];
            }];
        }
    }];
}
@end
