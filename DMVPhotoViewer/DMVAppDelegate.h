//
//  DMVAppDelegate.h
//  DMVPhotoViewer
//
//  Created by Dmitry Volkov on 30-11-13.
//  Copyright (c) 2013 Dmitry Volkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface DMVAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
