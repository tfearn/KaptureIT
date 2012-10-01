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
    UIButton *buttonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [buttonView addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    [buttonView setBackgroundImage:image forState:UIControlStateNormal];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    [self.navigationItem setLeftBarButtonItem:refreshButton];
    [buttonView release];
    [refreshButton release];
    
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
        
        for(int i=0; i<[objects count]; i++) {
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
            Location *annotation = [[[Location alloc] initWithName:contest.name subname:contest.subtitle number:i coordinate:coordinate] autorelease];
            [self.mapView addAnnotation:annotation];   
            
            [self.contests addObject:contest];
            [contest release];
        }
    }];
}

- (void)refresh {
	[self getData];
}

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
