//
//  DMVInstagramClient.h
//  DMVPhotoViewer
//
//  Created by Dmitry Volkov on 30-11-13.
//  Copyright (c) 2013 Dmitry Volkov. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

typedef void (^DMVInstagramClientCompletiotionBlock)(BOOL success, NSDictionary *response, NSError *error);

@class InstagramImage;

//
// DMVInstagramClient connects to Instagram api and retrives images
//
@interface DMVInstagramClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;
- (void)retrivePopularImages:(DMVInstagramClientCompletiotionBlock)completitionBlock;
- (void)retriveImage:(InstagramImage *)instagramImage;
- (void)retriveFullImage:(InstagramImage *)instagramImage
       completitionBlock:(DMVInstagramClientCompletiotionBlock)completitionBlock;

@end
