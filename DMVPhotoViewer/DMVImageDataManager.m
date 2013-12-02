//
//  DMVImageDataManager.m
//  DMVPhotoViewer
//
//  Created by Dmitry Volkov on 01-12-13.
//  Copyright (c) 2013 Dmitry Volkov. All rights reserved.
//

#import "DMVImageDataManager.h"
#import "DMVInstagramClient.h"
#import "InstagramImage.h"

@implementation DMVImageDataManager

+ (void)downloadNewPopularImagesToContext:(NSManagedObjectContext *)managedObjectContext {
    [[DMVInstagramClient sharedClient] retrivePopularImages:^(BOOL success, NSDictionary *response, NSError *error) {
        if (success) {
            NSArray *data = response[@"data"];
            NSString *instagramImageClassName = NSStringFromClass([InstagramImage class]);
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                InstagramImage *instagramImage = nil;
                instagramImage = (InstagramImage *)[NSEntityDescription insertNewObjectForEntityForName:instagramImageClassName
                                                                                 inManagedObjectContext:managedObjectContext];
                // TODO: skip images with existing id
                instagramImage.instagramId = obj[@"id"];
                instagramImage.thumbnailURL = obj[@"images"][@"thumbnail"][@"url"];
                instagramImage.standardResolutionUrl = obj[@"images"][@"standard_resolution"][@"url"];
                [managedObjectContext insertObject:instagramImage];
            }];
        } else {
            ALog(@"Failed to download popular images. %@", [error localizedDescription]);
        }
    }];
}

@end
