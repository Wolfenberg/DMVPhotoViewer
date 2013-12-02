//
//  DMVChangedObject.m
//  DMVPhotoViewer
//
//  Created by Dmitry Volkov on 01-12-13.
//  Copyright (c) 2013 Dmitry Volkov. All rights reserved.
//

#import "DMVChangedObject.h"

@implementation DMVChangedObject

- (id)initWithObject:(id)object
           indexPath:(NSIndexPath *)indexPath
        newIndexPath:(NSIndexPath *)newIndexPath
                type:(NSFetchedResultsChangeType)type
{
    self = [super init];
    if (self) {
        _indexPath = indexPath;
        _indexPathNew = newIndexPath;
        _type = type;
    }
    return self;
}

@end
