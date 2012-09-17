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
                
                [self refresh];
            }];
        }
        else {
            // Grab my Player.objectId
            PFObject *object = [objects objectAtIndex:0];
            [Globals setContestPlayerObjectId:object.objectId];
            
            // Save my current location
            [self updateMyLocation:self.mapView.userLocation];

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
    self.timer = nil;
    [super dealloc];
}

- (NSString *)stringFromTimeLeft:(NSTimeInterval)seconds {
    int minutes = round(seconds / 60.0);
    if(minutes < 1)
        return @"less than a minute";
    else if(minutes == 1)
        return [NSString stringWithFormat:@"%d minute", minutes];
    else
        return [NSString stringWithFormat:@"%d minutes", minutes];
}

- (void)zoomToUserLocation:(MKUserLocation *)userLocation {
    if (!userLocation)
        return;

    if(self.initialLocation != nil)
        return;
    
    self.initialLocation = userLocation.location;
    
    MKCoordinateRegion region;
    region.center = self.mapView.userLocation.coordinate;
    region.span = MKCoordinateSpanMake(0.005, 0.005);
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}

- (void)updateMyLocation:(MKUserLocation *)userLocation {
    PFGeoPoint *point = [[[PFGeoPoint alloc] init] autorelease];
    point.longitude = userLocation.coordinate.longitude;
    point.latitude = userLocation.coordinate.latitude;
    PFObject *playerObject = [PFObject objectWithClassName:@"Player"];
    NSString *objectId = [Globals getContestPlayerObjectId];
    [playerObject setObjectId:objectId];
    [playerObject setObject:point forKey:@"location"];
    [playerObject saveEventually];
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
            
            // Is this player me?  Skip it
            PFUser *user = [PFUser currentUser];
            if([user.objectId isEqualToString:player.user.objectId]) {
                if(player.hasPrize) {
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
                NSTimeInterval elapsed = [player.acquiredPrizeAt timeIntervalSinceNow] * -1;
                NSTimeInterval timeLeft = (60 *3) - elapsed;
                if(timeLeft > 0)
                    self.status.text = [NSString stringWithFormat:@"%@ has the prize, get within 100 ft to acquire it. Protected for %.0f seconds.", player.user.displayName, timeLeft];
                else
                    self.status.text = [NSString stringWithFormat:@"%@ has the prize, get within 100 ft to acquire it.", player.user.displayName];
            }
            
            // Add the annotation
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = player.location.latitude;
            coordinate.longitude = player.location.longitude;
            
            NSString *name = @"Bot";
            if(player.user != nil && player.user.displayName != nil)
                name = player.user.displayName;
            
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
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(PlayerAnnotation *)annotation {
    static NSString *AnnotationViewID = @"annotationViewID";
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (annotationView == nil)
        annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID] autorelease];
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        annotationView.image = [UIImage imageNamed:@"pin-me.png"];
    else if(annotation.player.hasPrize)
        annotationView.image = [UIImage imageNamed:@"pin-enemy-with-flag.png"];
    else
        annotationView.image = [UIImage imageNamed:@"pin-enemy.png"];
        
    annotationView.annotation = annotation;
    
    return annotationView;
}

#if 0
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(PlayerAnnotation *)annotation {
    
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Add the pin
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinView"];
    if(!pinView) {
        pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"] autorelease];
    } 
    else {
        pinView.annotation = annotation;
    }
    
    if(annotation.player.hasPrize)
        pinView.pinColor = MKPinAnnotationColorGreen;
    else
        pinView.pinColor = MKPinAnnotationColorRed;
    pinView.canShowCallout = YES;
    return pinView;
}
#endif

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
}

@end
