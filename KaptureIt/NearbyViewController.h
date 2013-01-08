//
//  NearbyViewController.h
//  KaptureIt
//
//  Created by Todd Fearn on 9/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <Parse/Parse.h>
#import "BaseViewController.h"
#import "Contest.h"
#import "Location.h"
#import "ContestDetailViewController.h"
#import "GameRulesViewController.h"

@interface NearbyViewController : BaseViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    IBOutlet MKMapView *_mapView;
    CLLocation *_initialLocation;
    NSMutableArray *_contests;
}
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) CLLocation *initialLocation;
@property (nonatomic, retain) NSMutableArray *contests;

@end
