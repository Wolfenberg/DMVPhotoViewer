//
//  DMVImageViewController.m
//  DMVPhotoViewer
//
//  Created by Dmitry Volkov on 01-12-13.
//  Copyright (c) 2013 Dmitry Volkov. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "DMVImageViewController.h"

@interface DMVImageViewController () {
    NSInteger _pageIndex;
}

@end

@implementation DMVImageViewController

- (id)initWithPageIndex:(NSInteger)pageIndex
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _pageIndex = pageIndex;
    }
    return self;
}

- (NSInteger)pageIndex
{
    return _pageIndex;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blackColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = view;
    
    _imageView = [[UIImageView alloc] init];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_imageView];
    
    // TODO: center indicator
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:_activityIndicator];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(pinch:)];
    [_imageView addGestureRecognizer:pinchGesture];
    _imageView.userInteractionEnabled = YES;
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    static CGRect initialBounds;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            initialBounds = _imageView.bounds;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGFloat factor = gesture.scale;
            
            CGAffineTransform zt = CGAffineTransformScale(CGAffineTransformIdentity, factor, factor);
            _imageView.layer.bounds = CGRectApplyAffineTransform(initialBounds, zt);
            
            self.view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
            self.parentViewController.view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [UIView animateWithDuration:0.5 animations:^{
                CGAffineTransform zt = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);
                _imageView.layer.bounds = CGRectApplyAffineTransform(initialBounds, zt);
            } completion:^(BOOL finished) {
                [self.parentViewController.view removeFromSuperview];
            }];
            
            break;
        }
        default: break;
    }
}

@end
