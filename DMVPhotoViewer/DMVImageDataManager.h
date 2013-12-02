//
//  DMVImageDataManager.h
//  DMVPhotoViewer
//
//  Created by Dmitry Volkov on 01-12-13.
//  Copyright (c) 2013 Dmitry Volkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMVImageDataManager : NSObject

+ (void)downloadNewPopularImagesToContext:(NSManagedObjectContext *)managedObjectContext;

@end
