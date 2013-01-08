//
//  NearbyViewController.m
//  KaptureIt
//
//  Created by Todd Fearn on 9/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NearbyViewController.h"
#import "Location.h"

@interface NearbyViewController (PRIVATE)
- (void)getData;
- (void)refresh;
@end

@implementation NearbyViewController
@synthesize mapView = _mapView;
@synthesize initialLocation = _initialLocation;
@synthesize contests = _contests;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Add a refresh button on the nav bar
    UIImage *image = [UIImage imageNamed:@"refresh-button"];
    UIImage *imageHighlighted = [UIImage imageNamed:@"refresh-button-highlighted"];
    UIButton *buttonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [buttonView addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    [buttonView setBackgroundImage:image forState:UIControlStateNormal];
    [buttonView setBackgroundImage:imageHighlighted forState:UIControlStateHighlighted];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    [self.navigationItem setLeftBarButtonItem:refreshButton];
    [buttonView release];
    [refreshButton release];
    
    // Add a settings button on the nav bar
    image = [UIImage imageNamed:@"settings-button"];
    imageHighlighted = [UIImage imageNamed:@"settings-button-highlighted"];
    buttonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [buttonView addTarget:self action:@selector(settingsPressed) forControlEvents:UIControlEventTouchUpInside];
    [buttonView setBackgroundImage:image forState:UIControlStateNormal];
    [buttonView setBackgroundImage:imageHighlighted forState:UIControlStateHighlighted];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    [self.navigationItem setRightBarButtonItem:settingsButton];
    [buttonView release];
    [settingsButton release];
    
    
    [self refresh];
}

- (void)dealloc {
    self.mapView = nil;
    self.initialLocation = nil;
    self.contests = nil;
    [super dealloc];
}

- (void)getData {
    [self showWaitView:@"Please wait..."];
    
    // Retrieve the contests 
    PFQuery *query = [PFQuery queryWithClassName:@"Contest"];
    [query orderByAscending:@"startdate"];
    [query whereKey:@"active" equalTo:[NSNumber numberWithInt:1]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self dismissWaitView];
        if(error != nil) {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Database Error" message:[error description] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
            [alert show];
            return;
        }
        
        self.contests = nil;
        _contests = [[NSMutableArray alloc] init];
        
        for(int i=0, count=0; i<[objects count]; i++) {
            PFObject *object = [objects objectAtIndex:i];
            Contest *contest = [[Contest alloc] init];
            [contest assignValuesFromObject:object];
            
            // Compare the end date with current time. If greater than skip it
            NSTimeInterval interval = [contest.endtime timeIntervalSinceNow];
            NSTimeInterval hours = interval / 60 / 60;
            if(hours < 0.0) {
                [contest release];
                continue;
            }
            
            // Add the annotation
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = contest.startlocation.latitude;
            coordinate.longitude = contest.startlocation.longitude;   
            Location *annotation = [[[Location alloc] initWithName:contest.name subname:contest.subtitle number:count++ coordinate:coordinate] autorelease];
            [self.mapView addAnnotation:annotation];   
            
            [self.contests addObject:contest];
            [contest release];
        }
    }];
}

- (void)refresh {
	[self getData];
}

- (void)settingsPressed {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:@"Game Rules", @"Kapture it Support", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:super.view];
    [popupQuery release];
}

#pragma mark -
#pragma mark UIActionSheetDelegate Methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
            break;
            
        case 1:
        {
            // Game Rules
            GameRulesViewController *controller = [[GameRulesViewController alloc] init];
            UINavigationController *navBar = [[UINavigationController alloc] initWithRootViewController:controller];
            [self presentModalViewController:navBar animated:YES];
            [controller release];
            [navBar release];
            break;
        }
            
        case 2:
        {
            // Kapture it Support
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setToRecipients:[NSArray arrayWithObject: @"support@kaptureit.com"]];
            [controller setSubject:@"Kapture it Support Request"];
            [controller setMessageBody:@"" isHTML:NO];
            [self presentModalViewController:controller animated:YES];
            [controller release];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
	if (result == MFMailComposeResultSent) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Your e-mail message has been sent" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
		[alert show];
	}
	
	if(error != nil) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"E-Mail Error" message:[error description] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
		[alert show];
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark MapViewDelegate Methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if ( ! self.initialLocation ) {
        self.initialLocation = userLocation.location;
        
        MKCoordinateRegion region;
        region.center = mapView.userLocation.coordinate;
        region.span = MKCoordinateSpanMake(0.3, 0.3);
        
        region = [mapView regionThatFits:region];
        [self.mapView setRegion:region animated:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(Location *)annotation {
    
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinView"];
    if (!pinView) {
        pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"] autorelease];
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        pinView.tag = annotation.number;
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.rightCalloutAccessoryView = rightButton;
    } else {
        pinView.annotation = annotation;
    }
    return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    Contest *contest = [self.contests objectAtIndex:view.tag];
    
	ContestDetailViewController *controller = [[ContestDetailViewController alloc] init];
	controller.contest = contest;
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}


@end
