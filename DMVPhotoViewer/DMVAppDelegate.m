//
//  DMVAppDelegate.m
//  DMVPhotoViewer
//
//  Created by Dmitry Volkov on 30-11-13.
//  Copyright (c) 2013 Dmitry Volkov. All rights reserved.
//

#import "DMVAppDelegate.h"
#import "DMVGridViewController.h"
#import "DMVInstagramClient.h"
#import "DMVImageDataManager.h"

@implementation DMVAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeCoreDataStack];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [self saveContext];
}

#pragma mark - Core Data stack

- (void)initializeCoreDataStack
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DMVInstagramImages"
                                              withExtension:@"momd"];
    ZAssert(modelURL, @"Failed to find model URL");
    
    NSManagedObjectModel *mom = nil;
    mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    ZAssert(mom, @"Failed to initialize model");
    
    NSPersistentStoreCoordinator *psc = nil;
    psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    ZAssert(psc, @"Failed to initialize persistent store coordinator");
    
    NSManagedObjectContext *moc = nil;
    NSManagedObjectContextConcurrencyType ccType = NSMainQueueConcurrencyType;
    moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:ccType];
    [moc setPersistentStoreCoordinator:psc];
    [self setManagedObjectContext:moc];
    
    dispatch_queue_t queue = NULL;
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *directoryArray = [fileManager URLsForDirectory:NSDocumentDirectory
                                                      inDomains:NSUserDomainMask];
        
        NSURL *storeURL = nil;
        storeURL = [directoryArray lastObject];
        storeURL = [storeURL URLByAppendingPathComponent:@"DMVInstagramImages.sqlite"];
        
        NSError *error = nil;
        NSPersistentStore *store = nil;
        
        store = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                  configuration:nil
                                            URL:storeURL
                                        options:nil
                                          error:&error];
        if (!store) {
            ALog(@"Error adding persistent store to coordinator %@\n%@",
                 [error localizedDescription], [error userInfo]);
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self contextInitialized];
        });
    });
}

- (void)contextInitialized;
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    DMVGridViewController *gridViewController = [[DMVGridViewController alloc] initWithCollectionViewLayout:flowLayout];
    gridViewController.managedObjectContext = _managedObjectContext;
    self.window.rootViewController = gridViewController;
    [self.window makeKeyAndVisible];
    
    [DMVImageDataManager downloadNewPopularImagesToContext:self.managedObjectContext];
}

- (void)saveContext
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    if (!moc) return;
    if (![moc hasChanges]) return;
    
    NSError *error = nil;
    ZAssert([moc save:&error], @"Error saving MOC: %@\n%@", [error localizedDescription], [error userInfo]);
}

@end
