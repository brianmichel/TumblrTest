//
//  BSMPhotoContentView.m
//  TumblrTest
//
//  Created by Brian Michel on 3/9/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "BSMPhotoContentView.h"
#import "BSMPost.h"
#import "BSMPhoto.h"
#import "UIImageView+BSM.h"

@interface BSMPhotoContentView ()
@property (strong) UIImageView *imageView;
@end

@implementation BSMPhotoContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.clipsToBounds = YES;
        
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) {
        BSMPhotoPost *photoPost = [self photoPost];
        BSMPhotoSize *size = [self photoSizeForPhoto:photoPost];
        if (size) {
            [self.imageView bsm_loadImageAtURLAndFlash:size.URL];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

#pragma mark - Properties
- (void)updateFrameAfterSettingPost {
    [super updateFrameAfterSettingPost];
    
    BSMPhotoPost *photoPost = [self photoPost];
    BSMPhotoSize *photoSize = [self photoSizeForPhoto:photoPost];
    
    if (photoSize) {
        NSInteger width = [photoSize.width integerValue];
        NSInteger height = [photoSize.height integerValue];
        
        CGSize size = [self sizeForImageWithSize:CGSizeMake(width, height) viewSize:CGSizeMake(250.0, 300)];
        self.frame = CGRectMake(0, 0, size.width, size.height);
    }
}

- (BSMPhotoSize *)photoSizeForPhoto:(BSMPhotoPost *)photo {
    BSMPhoto *selectedPhoto = [photo.photos firstObject];
    if (selectedPhoto) {
        NSArray *sizes = selectedPhoto.sizes;
        //TODO there's probably a better hueristic for this
        //could possibly hoist the size up to form a key?
        if ([sizes count] >= 2) {
            return sizes[1];
        }
    }
    return nil;
}

- (BSMPhotoPost *)photoPost {
    return (BSMPhotoPost *)self.post;
}

- (CGSize)sizeForImageWithSize:(CGSize)imageSize viewSize:(CGSize)viewSize {
    CGFloat returnWidth = 0.0;
    CGFloat returnHeight = 0.0;

    returnWidth = viewSize.width;
    returnHeight = returnWidth * (imageSize.height / imageSize.width);
    
    return CGSizeMake(returnWidth, returnHeight);
}

@end
