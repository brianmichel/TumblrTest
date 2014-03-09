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

@interface BSMPhotoContentView ()
@property (strong) UIImageView *imageView;
@end

@implementation BSMPhotoContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageView = [[UIImageView alloc] init];
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

#pragma mark - Properties
- (void)updateFrameAfterSettingPost {
    [super updateFrameAfterSettingPost];
    
    BSMPhotoPost *photoPost = [self photoPost];
    BSMPhoto *photo = [photoPost.photos firstObject];
    if (photo) {
        NSArray *sizes = photo.sizes;
        BSMPhotoSize *firstSize = sizes[1];
        NSInteger width = [firstSize.width integerValue];
        NSInteger height = [firstSize.height integerValue];
        
        CGSize size = [self sizeForImageWithSize:CGSizeMake(width, height) viewSize:CGSizeMake(250.0, 300)];
 
        [self.imageView setImageWithURL:firstSize.URL];
        self.frame = CGRectMake(0, 0, size.width, size.height);
    }
}

- (BSMPhotoPost *)photoPost {
    return (BSMPhotoPost *)self.post;
}

- (void)prepareForReuse {
    [self.imageView cancelCurrentImageLoad];
}

- (CGSize)sizeForImageWithSize:(CGSize)imageSize viewSize:(CGSize)viewSize {
    CGFloat returnWidth = 0.0;
    CGFloat returnHeight = 0.0;

    returnWidth = viewSize.width;
    returnHeight = returnWidth * (imageSize.height / imageSize.width);
    
    return CGSizeMake(returnWidth, returnHeight);
}

@end
