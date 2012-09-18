//
//  AppDelegate.m
//  KaptureIt
//
//  Created by Todd Fearn on 9/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "NearbyViewController.h"
#import "StartupViewController.h"
#import "ContestViewController.h"
#import "Player.h"

@interface AppDelegate (Private)
- (void)doLogin;
- (void)loginComplete;
@end


@implementation AppDelegate
@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize locationManager = _locationManager;

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Initialize Parse
    [Parse setApplicationId:@"E5JCy0JxXTEHJH5cdvABZYufNSwYCkyZJ63WSB0D"
                  clientKey:@"L6dJIBNPgGVZe3K5WkcoTKz5zfD26B3lNIxbiKF2"];
    
    // Initialize Facebook
    [PFFacebookUtils initializeWithApplicationId:kFacebookAppID];

    // Register for notifications
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
    
    // Create the main window
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    UIViewController *viewController = [[[NearbyViewController alloc] initWithNibName:@"NearbyViewController" bundle:nil] autorelease];
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    [self subscribeToPushNotifications];

    // Delete the contest player object ID key before we start the location manager
    [Globals deleteContestPlayerObjectId];
    
    // Setup the location manager
    _locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    
    // Observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginComplete) name:kNotificationLoginComplete object:nil];
    
    // Perform login check process
    [self doLogin];
    
    // Leave the splash view in place for a little while
    [NSThread sleepForTimeInterval: kStartupDelay];

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
    [self.locationManager startUpdatingLocation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self.locationManager stopUpdatingLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Tell Parse about the device token.
    [PFPush storeDeviceToken:newDeviceToken];
    // Subscribe to the global broadcast channel.
    [PFPush subscribeToChannelInBackground:@""];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    PFUser *user = [PFUser currentUser];
    NSString *sendingUsername = [userInfo objectForKey:@"username"];
    if(! [sendingUsername isEqualToString:user.username])
        [PFPush handlePush:userInfo];
}

// Required by Parse for Facebook
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url]; 
}

// LocationManager Delegates
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    // Are we part of a contest?
    NSString *objectId = [Globals getContestPlayerObjectId];
    if(objectId != nil) {
        
        // Save our position
        PFGeoPoint *point = [[[PFGeoPoint alloc] init] autorelease];
        point.longitude = newLocation.coordinate.longitude;
        point.latitude = newLocation.coordinate.latitude;
        PFObject *playerObject = [PFObject objectWithClassName:@"Player"];
        [playerObject setObjectId:objectId];
        [playerObject setObject:point forKey:@"location"];
        [playerObject saveInBackground];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
}

// Private methods
//

- (void)subscribeToPushNotifications {
    
    // Make sure we have a User record before subscribing
    PFUser *user = [PFUser currentUser];
    if(user != nil && [user objectForKey:@"username"] != nil) {

        // Subscribe to my personal channel - this channel is used to send messages from the Joios server to this device
        NSString *serverChannel = [NSString stringWithFormat:@"server_%@", [user objectId]];
        [PFPush subscribeToChannelInBackground:serverChannel];
    }
}

- (void)doLogin {
    [PFFacebookUtils facebook].accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kFacebookAccessTokenKey];
    [PFFacebookUtils facebook].expirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:kFacebookExpirationDateKey];
    
    if([PFUser currentUser] == nil) {
        StartupViewController *viewController = [[StartupViewController alloc] init];
        [self.navigationController presentModalViewController: viewController animated:YES];
        [viewController release];
    }
    else {
        // Check if I have an existing Player record
        PFUser *user = [PFUser currentUser];
        PFQuery *query = [PFQuery queryWithClassName:@"Player"];
        [query whereKey:@"userObject" equalTo:[PFObject objectWithoutDataWithClassName:@"_User" objectId:user.objectId]];
        [query includeKey:@"userObject"];
        [query includeKey:@"contestObject"];
        NSError *error = nil;
        NSArray *objects = [query findObjects:&error];
        if(error == nil && [objects count] > 0) {
            PFObject *object = [objects objectAtIndex:0];
            Player *player = [[Player alloc] init];
            [player assignValuesFromObject:object];
            
            [Globals setContestPlayerObjectId:player.objectId];
            
            // Load the contest view controller
            ContestViewController *viewController = [[ContestViewController alloc] init];
            viewController.contest = player.contest;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

- (void)loginComplete {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

@end
