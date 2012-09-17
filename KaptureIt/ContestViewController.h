//
//  ContestViewController.h
//  KaptureIt
//
//  Created by Todd Fearn on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import <Parse/Parse.h>
#import "BaseViewController.h"
#import "Contest.h"
#import "PlayerAnnotation.h"
#import "ContestDetailViewController.h"
#import "Player.h"
#import "TimePassedFormatter.h"

@interface ContestViewController : BaseViewController {
    IBOutlet MKMapView *_mapView;
    IBOutlet UILabel *_status;
    CLLocation *_initialLocation;
    Contest *_contest;
    NSMutableArray *_players;
    NSTimer *_timer;
}
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UILabel *status;
@property (nonatomic, retain) CLLocation *initialLocation;
@property (nonatomic, retain) Contest *contest;
@property (nonatomic, retain) NSMutableArray *players;
@property (nonatomic, retain) NSTimer *timer;

@end
