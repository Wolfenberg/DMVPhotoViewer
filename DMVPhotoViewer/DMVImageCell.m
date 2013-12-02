//
//  DMVImageCell.m
//  DMVPhotoViewer
//
//  Created by Dmitry Volkov on 01-12-13.
//  Copyright (c) 2013 Dmitry Volkov. All rights reserved.
//

#import "DMVImageCell.h"

@implementation DMVImageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        //TODO: center indicator
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicator.hidesWhenStopped = YES;
        [self addSubview:_imageView];
        [self addSubview:_activityIndicator];
    }
    return self;
}

@end
