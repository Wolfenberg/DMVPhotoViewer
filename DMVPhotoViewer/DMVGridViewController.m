//
//  DMVGridViewController.m
//  DMVPhotoViewer
//
//  Created by Dmitry Volkov on 01-12-13.
//  Copyright (c) 2013 Dmitry Volkov. All rights reserved.
//

#import "DMVChangedObject.h"
#import "DMVGridViewController.h"
#import "DMVImageCell.h"
#import "DMVInstagramClient.h"
#import "InstagramImage.h"
#import "DMVImageDataManager.h"
#import "DMVImageViewController.h"

@interface DMVGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate,
    NSFetchedResultsControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation DMVGridViewController

static NSString *cellIdentifier = @"Cell";
static CGSize const CellSize = {150, 150};

- (void)viewDidLoad
{
    [super viewDidLoad];
    	
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[DMVImageCell class] forCellWithReuseIdentifier:cellIdentifier];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(pinch:)];
    [self.collectionView addGestureRecognizer:pinchGesture];
    
    [self enableRefreshControl];
}

#pragma mark - Pinch gesture

- (void)pinch:(UIPinchGestureRecognizer *)gesture {
    
    static DMVImageCell *targetCell;
    static CGRect initialBounds;
    static NSIndexPath *indexPath;

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint point = [gesture locationInView:self.collectionView];
            indexPath = [self.collectionView indexPathForItemAtPoint:point];
            targetCell = (DMVImageCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [self.collectionView bringSubviewToFront:targetCell];
            initialBounds = targetCell.bounds;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGFloat factor = gesture.scale;
            CGAffineTransform zt = CGAffineTransformScale(CGAffineTransformIdentity, factor, factor);
            targetCell.imageView.layer.bounds = CGRectApplyAffineTransform(initialBounds, zt);
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            CGFloat maxViewSize = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
            CGFloat maxImageSide = MIN(initialBounds.size.width, initialBounds.size.height);
            CGFloat maxResizeFactor = maxViewSize / maxImageSide;
            [UIView animateWithDuration:0.5 animations:^{
                CGAffineTransform zt = CGAffineTransformScale(CGAffineTransformIdentity, maxResizeFactor, maxResizeFactor);
                targetCell.imageView.layer.bounds = CGRectApplyAffineTransform(initialBounds, zt);
            } completion:^(BOOL finished) {
                [self showPageViewControllerAtIndex:indexPath.row];
                CGAffineTransform zt = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                targetCell.imageView.layer.bounds = CGRectApplyAffineTransform(initialBounds, zt);
                targetCell = nil;
            }];
            break;
        }
        default: break;
    }
}

#pragma mark - UIPageViewController

- (void)showPageViewControllerAtIndex:(NSInteger)index
{
    UIPageViewController *viewController;
    viewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                     navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                   options:@{ UIPageViewControllerOptionInterPageSpacingKey : @10.f }];
    viewController.dataSource = self;
    viewController.view.backgroundColor = [UIColor blackColor];
    
    DMVImageViewController *pageZero = [self configuredImageViewControllerAtIndex:index];
    [viewController setViewControllers:@[pageZero]
                             direction:UIPageViewControllerNavigationDirectionForward
                              animated:NO
                            completion:nil];
    
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc
      viewControllerBeforeViewController:(DMVImageViewController *)vc
{
    NSInteger index = vc.pageIndex;
    if (index > 0) {
        return [self configuredImageViewControllerAtIndex:index - 1];
    } else {
        return nil;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc
       viewControllerAfterViewController:(DMVImageViewController *)vc
{
    NSInteger index = vc.pageIndex;
    if (index < [self.fetchedResultsController.fetchedObjects count] - 1) {
        return [self configuredImageViewControllerAtIndex:index + 1];
    } else {
        return nil;
    }
}

- (DMVImageViewController *)configuredImageViewControllerAtIndex:(NSInteger)index
{
    DMVImageViewController *imageViewController;
    imageViewController = [[DMVImageViewController alloc] initWithPageIndex:index];
    [imageViewController.view setNeedsDisplay];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:imageViewController.pageIndex inSection:0];
    InstagramImage *instagramImage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (instagramImage.standardResolution) {
        UIImage *image = [UIImage imageWithData:instagramImage.standardResolution];
        imageViewController.imageView.image = image;
    } else {
        UIImage *lowResolutionThumbnail = [UIImage imageWithData:instagramImage.thumbnail];
        if (lowResolutionThumbnail) {
            imageViewController.imageView.image = lowResolutionThumbnail;
        } else {
            [imageViewController.activityIndicator startAnimating];
        }
        [[DMVInstagramClient sharedClient] retriveFullImage:instagramImage
                                          completitionBlock:^(BOOL success, NSDictionary *response, NSError *error) {
                                              imageViewController.imageView.image = [UIImage imageWithData:instagramImage.standardResolution];
                                              [imageViewController.activityIndicator stopAnimating];
                                          }];
    }
    return imageViewController;
}

#pragma mark - Refresing

- (void)enableRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshBookmarks:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
}

- (void)refreshBookmarks:(UIRefreshControl *)refreshControl
{
    [DMVImageDataManager downloadNewPopularImagesToContext:self.managedObjectContext];
    [refreshControl endRefreshing];
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController)
        return _fetchedResultsController;
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = nil;
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([InstagramImage class])];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"instagramId"
                                                         ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSFetchedResultsController *frc = nil;
    frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                              managedObjectContext:moc
                                                sectionNameKeyPath:nil
                                                         cacheName:@"Master"];
    
    [self setFetchedResultsController:frc];
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    ZAssert([self.fetchedResultsController performFetch:&error],
            @"Unresolved error %@\n%@", [error localizedDescription], [error userInfo]);
    
    return _fetchedResultsController;
}

#pragma mark - NSFetchedResultsControllerDelegate

NSMutableArray *_changedObjects;

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    _changedObjects = [[NSMutableArray alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    [_changedObjects addObject:[[DMVChangedObject alloc] initWithObject:anObject
                                                              indexPath:indexPath
                                                           newIndexPath:newIndexPath
                                                                   type:type]];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView performBatchUpdates:^{
        for (DMVChangedObject *changedObject in _changedObjects) {
            NSIndexPath *indexPath = changedObject.indexPath;
            NSIndexPath *indexPathNew = changedObject.indexPathNew;
            switch (changedObject.type) {
                case NSFetchedResultsChangeInsert:
                    [self.collectionView insertItemsAtIndexPaths:@[indexPathNew]];
                    break;
                case NSFetchedResultsChangeDelete:
                    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                    break;
                case NSFetchedResultsChangeUpdate:
                    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                    break;
                case NSFetchedResultsChangeMove:
                    [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:indexPathNew];
                    break;
            }
        }
        _changedObjects = nil;
    } completion:nil];
}

#pragma mark - Collection View Data Sources

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.fetchedResultsController.fetchedObjects count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DMVImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                   forIndexPath:indexPath];
    InstagramImage *instagramImage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (instagramImage.thumbnail) {
        cell.imageView.image = [UIImage imageWithData:instagramImage.thumbnail];
        [cell.activityIndicator stopAnimating];
    } else {
        cell.imageView.image = nil;
        [cell.activityIndicator startAnimating];
        [[DMVInstagramClient sharedClient] retriveImage:instagramImage];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CellSize;
}

@end
