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
@synthesize toolbar = _toolbar;
@synthesize timeleft = _timeLeft;
@synthesize mapView = _mapView;
@synthesize status = _status;
@synthesize distance = _distance;
@synthesize initialLocation = _initialLocation;
@synthesize contest = _contest;
@synthesize players = _players;
@synthesize refreshTimer = _refreshTimer;
@synthesize countdownTimer = _countdownTimer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [self.contest.name uppercaseString];
    
    [self.toolbar setFrame:CGRectMake(0, 0, 320, 28)];
    
    // Create a spacer button
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [spacer setWidth:8];
    
    // Add a close button on the nav bar
    UIImage *image = [UIImage imageNamed:@"CancelButton"];
    UIImage *imageHighlighted = [UIImage imageNamed:@"CancelButtonHighlighted"];
    UIButton *buttonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [buttonView addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView setBackgroundImage:image forState:UIControlStateNormal];
    [buttonView setBackgroundImage:imageHighlighted forState:UIControlStateHighlighted];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    NSArray *leftBarButtons = [[NSArray alloc] initWithObjects:spacer, closeButton, nil];
    [self.navigationItem setLeftBarButtonItems:leftBarButtons];
    
    [self showWaitView:@"Please wait..."];
    
    // Check if I have an existing Player record for this competition
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Player"];
    [query whereKey:@"userObject" equalTo:[PFObject objectWithoutDataWithClassName:@"_User" objectId:user.objectId]]; 
    [query whereKey:@"contestObject" equalTo:[PFObject objectWithoutDataWithClassName:@"Contest" objectId:self.contest.objectId]]; 
    [query includeKey:@"contestObject.winnerInfoObject"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error != nil) {
            [self dismissWaitView];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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

    // Setup a contest countdown timer
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdownTimerCalled) userInfo:nil repeats:YES];

    // Setup a timer to periodically retrieve players and update positions
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
}

- (IBAction)cancelButtonPressed:(id)sender {
    NSString *message = @"Are you sure you want to quit this contest?";
    if(hasPrize)
        message = @"Are you sure you want to quit this contest?  You have a prize and you will lose it when you quit.";
        
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Exit" message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // NO = 0, YES = 1
    if(buttonIndex == 0) {
        return;
    }
    
    [self endContest];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)endContest {

    // Find my player object
    Player *playerMe = nil;
    for(int i=0; i<[self.players count]; i++) {
        Player *player = [self.players objectAtIndex:i];

        PFUser *user = [PFUser currentUser];
        if([user.objectId isEqualToString:player.user.objectId]) {
            playerMe = player;
            break;
        }
    }
    
    // I'm no longer in a contest
    [Globals deleteContestPlayerObjectId];
    
    // Kill the timers
    [self.countdownTimer invalidate];
    [self.refreshTimer invalidate];
    
    // Make the player inactive for the contest
    [self showSpinnerView];
    PFObject *playerObject = [PFObject objectWithClassName:@"Player"];
    [playerObject setObjectId:playerMe.objectId];
    [playerObject setObject:[NSNumber numberWithInt:0] forKey:@"active"];
    [playerObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self dismissSpinnerView];
        if(error != nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        // Unsubscribe from the Contest push notifications
        NSError *unsubscribeError = nil;
        NSString *serverChannel = [NSString stringWithFormat:@"contest_%@", self.contest.objectId];
        [PFPush unsubscribeFromChannel:serverChannel error:&unsubscribeError];
    }];
}

- (void)countdownTimerCalled {
    
    TimePassedFormatter *timePassedFormatter = [[TimePassedFormatter alloc] init];
    NSString *timeRemaining = [timePassedFormatter format:self.contest.endtime];
    self.timeleft.text = [NSString stringWithFormat:@" %@ ", timeRemaining];
    [self.timeleft sizeToFit];

    NSTimeInterval diff = [self.contest.endtime timeIntervalSinceDate:[NSDate date]];
    if(diff <= 0.0) {
        [self endContest];
    }
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
        PFGeoPoint *point = [[PFGeoPoint alloc] init];
        point.longitude = userLocation.coordinate.longitude;
        point.latitude = userLocation.coordinate.latitude;
        PFObject *playerObject = [PFObject objectWithClassName:@"Player"];
        NSString *objectId = [Globals getContestPlayerObjectId];
        if(objectId != nil) {
            [playerObject setObjectId:objectId];
            [playerObject setObject:point forKey:@"location"];
            [playerObject setObject:[NSNumber numberWithInt:1] forKey:@"active"];
            [playerObject saveInBackground];
            
            [self updateDistance:userLocation];
        }
    }
    @catch (NSException *exception) {
        // An exception is sometimes being thrown on PFGeoPoint when returning from the background.  The exception
        // is an invalid Point range.  We do nothing here to fix the problem.
    }
}

- (void)updateDistance:(MKUserLocation *)userLocation {
    CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
    CLLocation *destinationLocation = nil;
    
    for(int i=0; i<[self.players count]; i++) {
        Player *player = [self.players objectAtIndex:i];
        
        // Do I have the prize?
        if(player.hasPrize && [[PFUser currentUser].objectId isEqualToString:player.user.objectId]) {
            destinationLocation = [[CLLocation alloc] initWithLatitude:self.contest.endlocation.latitude longitude:self.contest.endlocation.longitude];
            break;
        }
        // Another player has the prize?
        else if(player.hasPrize) {
            destinationLocation = [[CLLocation alloc] initWithLatitude:player.location.latitude longitude:player.location.longitude];
            break;
        }
    }
    
    if(destinationLocation == nil)
        destinationLocation = [[CLLocation alloc] initWithLatitude:self.contest.startlocation.latitude longitude:self.contest.startlocation.longitude];
    
    CLLocationDistance meters = [myLocation distanceFromLocation:destinationLocation];
    CGFloat feet = meters * 3.28084;
    self.distance.text = [NSString stringWithFormat:@" %.0f ft ", feet];
    
    [self.distance sizeToFit];
    CGRect frame = self.distance.frame;
    frame.origin.x = 320 - frame.size.width;
    self.distance.frame = frame;
}

- (NSString *)getFirstName:(NSString *)fullname {
    NSArray *firstlast = [fullname componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [firstlast objectAtIndex:0];
}

- (void)getData {
    if(retrievingData)
        return;
    retrievingData = YES;
    

    // Retrieve the players
    PFQuery *query = [PFQuery queryWithClassName:@"Player"];
    [query whereKey:@"contestObject" equalTo:[PFObject objectWithoutDataWithClassName:@"Contest" objectId:self.contest.objectId]]; 
    [query includeKey:@"contestObject"];
    [query includeKey:@"contestObject.winnerInfoObject"];
    [query includeKey:@"userObject"];
    [query whereKey:@"active" equalTo:[NSNumber numberWithInt:1]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error != nil) {
            MyLog(@"%@", [error description]);
            retrievingData = NO;
            return;
        }
        
        self.players = nil;
        _players = [[NSMutableArray alloc] init];
        
        for(int i=0; i<[objects count]; i++) {
            PFObject *object = [objects objectAtIndex:i];
            Player *player = [[Player alloc] init];
            [player assignValuesFromObject:object];
            
            [self.players addObject:player];
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
                
                // Am I a winner?
                if(player.winner) {
                    [self endContest];

                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You Won" message:@"You have won the prize. Please go to your Profile for instructions on how to redeem it." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    return;
                }
                
                // Do I have the prize?
                if(player.hasPrize) {
                    if(hasPrize == NO) {
                        NotifHasPrizeViewController *controller = [[NotifHasPrizeViewController alloc] init];
                        [self presentModalViewController:controller animated:YES];
                    }

                    hasPrize = YES;
                    self.status.text = [NSString stringWithFormat:@"GET WITHIN %d FEET OF A STORE TO WIN!", self.contest.acquirerange];
                }
                else {
                    if(hasPrize == YES) {
                        NotifLostPrizeViewController *controller = [[NotifLostPrizeViewController alloc] init];
                        controller.contest = self.contest;
                        [self presentModalViewController:controller animated:YES];
                    }
                    
                    hasPrize = NO;
                }
                
                continue;
            }

            if(player.hasPrize) {
                if(player.shielded) {
                    self.status.text = [NSString stringWithFormat:@"GET WITHIN %d FEET OF THE PRIZE", self.contest.acquirerange];
                }
                else {
                    self.status.text = [NSString stringWithFormat:@"GET WITHIN %d FEET OF THE PRIZE", self.contest.acquirerange];
                }
            }
            
            // Add the annotation
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = player.location.latitude;
            coordinate.longitude = player.location.longitude;

            NSString *name = @"Bot";
            if(player.bot) {
                if(player.endlocation)
                    name = @"Store";
                else if(player.hasPrize)
                    name = @"Prize";
            }
            else {
                if(player.user != nil && player.user.displayName != nil) {
                    if(player.hasPrize)
                        name = @"Prize";
                    else
                        name = @"Competitor";
                }
            }
            
            // Don't show competitors unless I have the prize
            if([name isEqualToString:@"Competitor"] && hasPrize)
                continue;
            
            // Don't show the store unless I have the prize
            if([name isEqualToString:@"Store"] && !hasPrize)
                continue;
            
            PlayerAnnotation *annotation = [[PlayerAnnotation alloc] initWithName:name subname:@"" coordinate:coordinate player:player];
            [self.mapView addAnnotation:annotation];
        }
        
        retrievingData = NO;
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
        pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    else if(annotation.player.hasPrize)
        pinAnnotationView.image = [UIImage imageNamed:@"pin-prize"];
    else if(annotation.player.bot && annotation.player.endlocation)
        pinAnnotationView.image = [UIImage imageNamed:@"pin-store"];
    else if(annotation.player.bot)
        pinAnnotationView.image = [UIImage imageNamed:@"pin-enemy"];
    else
        pinAnnotationView.image = [UIImage imageNamed:@"pin-enemy"];
        
    pinAnnotationView.canShowCallout = YES;
    pinAnnotationView.annotation = annotation;
    
    return pinAnnotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
}

#if 0
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if(![view.annotation isKindOfClass:[MKUserLocation class]]) {
        ContestCalloutView *contestCalloutView = (ContestCalloutView *)[[[NSBundle mainBundle] loadNibNamed:@"ContestCalloutView" owner:self options:nil] objectAtIndex:0];
        CGRect frame = contestCalloutView.frame;
        frame.origin = CGPointMake(-frame.size.width/2 + 15, -frame.size.height);
        contestCalloutView.frame = frame;
        [contestCalloutView.calloutLabel setText:[(myAnnotation*)[view annotation] title]];
        [view addSubview:contestCalloutView];
    }
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    for (UIView *subview in view.subviews ){
        [subview removeFromSuperview];
    }
}
#endif

@end
