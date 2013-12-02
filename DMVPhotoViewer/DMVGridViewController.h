//
//  DMVGridViewController.h
//  DMVPhotoViewer
//
//  Created by Dmitry Volkov on 01-12-13.
//  Copyright (c) 2013 Dmitry Volkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface DMVGridViewController : UICollectionViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
