//
//  ContestViewController.m
//  KaptureIt
//
//  Created by Todd Fearn on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContestViewController.h"

@interface ContestViewController (PRIVATE)
- (void)getData;
- (void)refresh;
@end

@implementation ContestViewController
@synthesize mapView = _mapView;
@synthesize status = _status;
@synthesize initialLocation = _initialLocation;
@synthesize contest = _contest;
@synthesize players = _players;
@synthesize timer = _timer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add a status button on the nav bar
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonPressed:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    [leftButton release];
    
    [self showWaitView:@"Please wait..."];
    
    // Check if I have an existing Player record for this competition
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Player"];
    [query whereKey:@"userObject" equalTo:[PFObject objectWithoutDataWithClassName:@"_User" objectId:user.objectId]]; 
    [query whereKey:@"contestObject" equalTo:[PFObject objectWithoutDataWithClassName:@"Contest" objectId:self.contest.objectId]]; 
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error != nil) {
            [self dismissWaitView];
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Database Error" message:[error description] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
            [alert show];
            return;
        }
        
        if(objects == nil || [objects count] ==0) {
            // I'm a new Player
            PFObject *playerObject = [PFObject objectWithClassName:@"Player"];
            [playerObject setObject:[NSNumber numberWithInt:1] forKey:@"active"];
            
            PFUser *user = [PFUser currentUser];
            PFObject *userObject = [PFObject objectWithClassName:@"_User"];
            [userObject setObjectId:[user objectId]];
            [playerObject setObject:userObject forKey:@"userObject"];
            
            PFObject *contestObject = [PFObject objectWithClassName:@"Contest"];
            [contestObject setObjectId:self.contest.objectId];
            [playerObject setObject:contestObject forKey:@"contestObject"];
            
            [playerObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self dismissWaitView];
                if(error != nil) {
                    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Database Error" message:[error description] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
                    [alert show];
                    return;
                }
                
                // Save the Player.objectId
                [Globals setContestPlayerObjectId:playerObject.objectId];
                
                // Save my current location
                [self updateMyLocation:self.mapView.userLocation];
                
                // Subscribe to the Contest notification
                NSString *serverChannel = [NSString stringWithFormat:@"contest_%@", self.contest.objectId];
                [PFPush subscribeToChannelInBackground:serverChannel];
                
                [self refresh];
            }];
        }
        else {
            // Grab my Player.objectId
            PFObject *object = [objects objectAtIndex:0];

            [Globals setContestPlayerObjectId:object.objectId];
            
            // Save my current location
            [self updateMyLocation:self.mapView.userLocation];
            
            // Subscribe to the Contest notification
            NSString *serverChannel = [NSString stringWithFormat:@"contest_%@", self.contest.objectId];
            [PFPush subscribeToChannelInBackground:serverChannel];

            [self dismissWaitView];
            [self refresh];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Zoom to our location
    [self zoomToUserLocation:self.mapView.userLocation];

    // Setup a timer to periodically retrieve players and update positions
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
}

- (void)dealloc {
    self.mapView = nil;
    self.status = nil;
    self.initialLocation = nil;
    self.contest = nil;
    self.players = nil;
    [self.timer invalidate];
    self.timer = nil;
    [super dealloc];
}

- (IBAction)stopButtonPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Exit" message:@"Are you sure you want to quit this contest?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];    
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // NO = 0, YES = 1
    if(buttonIndex == 0) {
        return;
    }
    
    // Find my player object
    Player *playerMe = nil;
    for(int i=0; i<[self.players count]; i++) {
        Player *player = [self.players objectAtIndex:i];
        
        // Is this player me?  Skip it
        PFUser *user = [PFUser currentUser];
        if([user.objectId isEqualToString:player.user.objectId]) {
            playerMe = player;
            break;
        }
    }
    
    // I'm no longer in a contest
    [Globals deleteContestPlayerObjectId];

    // Make the player inactive for the contest
    [self showWaitView:@"Please wait..."];
    PFObject *playerObject = [PFObject objectWithClassName:@"Player"];
    [playerObject setObjectId:playerMe.objectId];
    [playerObject setObject:[NSNumber numberWithInt:0] forKey:@"active"];
    [playerObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error != nil) {
            [self dismissWaitView];
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Database Error" message:[error description] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
            [alert show];
            return;
        }

        // Unsubscribe from the Contest push notifications
        NSError *unsubscribeError = nil;
        NSString *serverChannel = [NSString stringWithFormat:@"contest_%@", self.contest.objectId];
        [PFPush unsubscribeFromChannel:serverChannel error:&unsubscribeError];
        
        // If they have the prize, notify them that they have dropped it
        if(playerMe.hasPrize) {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Dropped Prize" message:@"You have dropped the prize." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
            [alert show];
        }
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (void)zoomToUserLocation:(MKUserLocation *)userLocation {
    if (!userLocation)
        return;

    if(self.initialLocation != nil)
        return;
    
    self.initialLocation = userLocation.location;
    
    MKCoordinateRegion region;
    region.center = self.mapView.userLocation.coordinate;
    region.span = MKCoordinateSpanMake(0.01, 0.01);
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}

- (void)updateMyLocation:(MKUserLocation *)userLocation {
    @try {
        PFGeoPoint *point = [[[PFGeoPoint alloc] init] autorelease];
        point.longitude = userLocation.coordinate.longitude;
        point.latitude = userLocation.coordinate.latitude;
        PFObject *playerObject = [PFObject objectWithClassName:@"Player"];
        NSString *objectId = [Globals getContestPlayerObjectId];
        if(objectId != nil) {
            [playerObject setObjectId:objectId];
            [playerObject setObject:point forKey:@"location"];
            [playerObject setObject:[NSNumber numberWithInt:1] forKey:@"active"];
            [playerObject saveInBackground];
        }
    }
    @catch (NSException *exception) {
        // An exception is sometimes being thrown on PFGeoPoint when returning from the background.  The exception
        // is an invalid Point range.  We do nothing here to fix the problem.
    }
}

- (void)getData {

    // Retrieve the players 
    PFQuery *query = [PFQuery queryWithClassName:@"Player"];
    [query whereKey:@"contestObject" equalTo:[PFObject objectWithoutDataWithClassName:@"Contest" objectId:self.contest.objectId]]; 
    [query includeKey:@"contestObject"];
    [query includeKey:@"userObject"];
    [query whereKey:@"active" equalTo:[NSNumber numberWithInt:1]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error != nil) {
            MyLog(@"%@", [error description]);
            return;
        }
        
        self.players = nil;
        _players = [[NSMutableArray alloc] init];
        
        for(int i=0; i<[objects count]; i++) {
            PFObject *object = [objects objectAtIndex:i];
            Player *player = [[Player alloc] init];
            [player assignValuesFromObject:object];
            
            [self.players addObject:player];
            [player release];
        }
        
        // Remove the existing annotations - Will get a flash, but ok for now
        for(PlayerAnnotation *annotation in self.mapView.annotations) {
            if ([annotation isKindOfClass:[MKUserLocation class]])
                continue;
            [self.mapView removeAnnotation:annotation];
        }
        // Cycle through the players
        for(int i=0; i<[self.players count]; i++) {
            Player *player = [self.players objectAtIndex:i];
            
            // Is this player me? 
            PFUser *user = [PFUser currentUser];
            if([user.objectId isEqualToString:player.user.objectId]) {
                if(player.hasPrize) {
                    hasPrize = YES;
                    
                    NSTimeInterval elapsed = [player.acquiredPrizeAt timeIntervalSinceNow] * -1;
                    NSTimeInterval timeLeft = (60 *3) - elapsed;
                    if(timeLeft > 0) {
                        self.status.text = [NSString stringWithFormat:@"You have the prize, stay away from others. You are protected for %.0f seconds.", timeLeft];
                    }
                    else
                        self.status.text = @"You have the prize, stay away from others.";
                }
                
                continue;
            }

            if(player.hasPrize) {
                hasPrize = NO;
                
                NSTimeInterval elapsed = [player.acquiredPrizeAt timeIntervalSinceNow] * -1;
                NSTimeInterval timeLeft = (60 *3) - elapsed;
                if(timeLeft > 0) {
                    self.status.text = [NSString stringWithFormat:@"%@ has the prize, get within %d ft to acquire it. Protected for %.0f seconds.", player.user.displayName, self.contest.acquirerange, timeLeft];
                }
                else {
                    if(player.bot > 0)
                        self.status.text = [NSString stringWithFormat:@"The prize has been dropped, get within %d ft to acquire it.", self.contest.acquirerange];
                    else
                        self.status.text = [NSString stringWithFormat:@"%@ has the prize, get within %d ft to acquire it.", player.user.displayName, self.contest.acquirerange];
                }
            }
            
            // Add the annotation
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = player.location.latitude;
            coordinate.longitude = player.location.longitude;
            
            NSString *name = @"Bot";
            if(player.user.displayName
               == nil && player.hasPrize)
                name = @"Prize";
            else if(player.user != nil && player.user.displayName != nil) {
                NSArray *firstlast = [player.user.displayName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                name = [firstlast objectAtIndex:0];
            }
            
            PlayerAnnotation *annotation = [[PlayerAnnotation alloc] initWithName:name subname:@"" coordinate:coordinate player:player];
            [self.mapView addAnnotation:annotation]; 
        }
    }];
}

- (void)refresh {
	[self getData];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    [self zoomToUserLocation:userLocation];
    
    [self updateMyLocation:userLocation];
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(PlayerAnnotation *)annotation {
    static NSString *AnnotationViewID = @"annotationViewID";
    
    MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (pinAnnotationView == nil)
        pinAnnotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID] autorelease];
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    else if(annotation.player.hasPrize)
        pinAnnotationView.image = [UIImage imageNamed:@"pin-red-flag.png"];
    else if(annotation.player.bot)
        pinAnnotationView.image = [UIImage imageNamed:@"pin-green.png"];
    else
        pinAnnotationView.image = [UIImage imageNamed:@"pin-red.png"];
        
    pinAnnotationView.canShowCallout = YES;
    pinAnnotationView.annotation = annotation;
    
    return pinAnnotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
}

@end