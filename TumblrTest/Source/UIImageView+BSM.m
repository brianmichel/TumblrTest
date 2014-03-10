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
- (void)bsm_loadImageAtURLAndFlash:(NSURL *)url {
    
    __weak typeof(self) weak = self;
    [[SDWebImageManager sharedManager] downloadWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
        if (SDImageCacheTypeNone) {
            if (image) {
                [UIView animateWithDuration:0.1 animations:^{
                    weak.alpha = 0.0;
                } completion:^(BOOL finished) {
                    weak.image = image;
                    [UIView animateWithDuration:0.1 animations:^{
                        weak.alpha = 1.0;
                    }];
                }];
            }
        } else {
            weak.image = image;
        }
    }];
}
@end
