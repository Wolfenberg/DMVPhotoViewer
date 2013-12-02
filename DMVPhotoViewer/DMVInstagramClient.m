//
//  DMVInstagramClient.m
//  DMVPhotoViewer
//
//  Created by Dmitry Volkov on 30-11-13.
//  Copyright (c) 2013 Dmitry Volkov. All rights reserved.
//

#import "DMVInstagramClient.h"
#import "InstagramImage.h"
#import "AFURLSessionManager.h"

static NSString * const DMVInstagramBaseURLString = @"https://api.instagram.com";
static NSString * const DMVInstagramClientId = @"f33180311ceb42c3a9b0188ec3f1c43b";

@implementation DMVInstagramClient

+ (instancetype)sharedClient
{
    static DMVInstagramClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[DMVInstagramClient alloc] initWithBaseURL:[NSURL URLWithString:DMVInstagramBaseURLString]];
    });
    
    return _sharedClient;
}

- (void)retrivePopularImages:(DMVInstagramClientCompletiotionBlock)completitionBlock
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if ([[AFNetworkReachabilityManager sharedManager] isReachable]) {
            
            // Application list description
            [[DMVInstagramClient sharedClient] GET:@"/v1/media/popular/"
                                        parameters:[NSDictionary dictionaryWithObject:DMVInstagramClientId
                                                                               forKey:@"client_id"]
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         completitionBlock(YES, responseObject, nil);
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         completitionBlock(NO, nil, error);
                                     }];
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)retriveImage:(InstagramImage *)instagramImage
{
    if ([[AFNetworkReachabilityManager sharedManager] isReachable]) {
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:instagramImage.thumbnailURL]];
        AFHTTPRequestOperation *postOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        
        [postOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            instagramImage.thumbnail = responseObject;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ALog(@"Image error: %@", [error localizedDescription]);
        }];
        [postOperation start];
    }
}

- (void)retriveFullImage:(InstagramImage *)instagramImage
       completitionBlock:(DMVInstagramClientCompletiotionBlock)completitionBlock
{
    if ([[AFNetworkReachabilityManager sharedManager] isReachable]) {
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:instagramImage.standardResolutionUrl]];
        AFHTTPRequestOperation *postOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        
        [postOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            instagramImage.standardResolution = responseObject;
            completitionBlock(YES, nil, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completitionBlock(NO, nil, error);
        }];
        [postOperation start];
    }
}

@end
