//
//  DMVChangedObject.h
//  DMVPhotoViewer
//
//  Created by Dmitry Volkov on 01-12-13.
//  Copyright (c) 2013 Dmitry Volkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DMVChangedObject : NSObject

@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSIndexPath *indexPathNew;
@property (nonatomic, assign) NSFetchedResultsChangeType type;

- (id)initWithObject:(id)object
           indexPath:(NSIndexPath *)indexPath
        newIndexPath:(NSIndexPath *)newIndexPath
                type:(NSFetchedResultsChangeType)type;


@end
