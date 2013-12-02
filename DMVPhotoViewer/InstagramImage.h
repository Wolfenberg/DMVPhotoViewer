//
//  InstagramImage.h
//  DMVPhotoViewer
//
//  Created by Dmitry Volkov on 01-12-13.
//  Copyright (c) 2013 Dmitry Volkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface InstagramImage : NSManagedObject

@property (nonatomic, retain) NSData * standardResolution;
@property (nonatomic, retain) NSString * instagramId;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * standardResolutionUrl;

@end
