//
//  DMVImageViewController.h
//  DMVPhotoViewer
//
//  Created by Dmitry Volkov on 01-12-13.
//  Copyright (c) 2013 Dmitry Volkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMVImageViewController : UIViewController

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

- (id)initWithPageIndex:(NSInteger)pageIndex;
- (NSInteger)pageIndex;

@end
