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
#import "ContestCalloutView.h"
#import "ContestDetailViewController.h"
#import "Player.h"
#import "TimePassedFormatter.h"
#import "NotifHasPrizeViewController.h"
#import "NotifLostPrizeViewController.h"

@interface ContestViewController : BaseViewController {
    IBOutlet UIToolbar *_toolbar;
    IBOutlet UILabel *_timeLeft;
    IBOutlet MKMapView *_mapView;
    IBOutlet UILabel *_status;
    IBOutlet UILabel *_distance;
    CLLocation *_initialLocation;
    Contest *_contest;
    NSMutableArray *_players;
    NSTimer *_refreshTimer;
    NSTimer *_countdownTimer;
    
    BOOL hasPrize;
    BOOL retrievingData;
}
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, retain) UILabel *timeleft;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UILabel *status;
@property (nonatomic, retain) UILabel *distance;
@property (nonatomic, retain) CLLocation *initialLocation;
@property (nonatomic, retain) Contest *contest;
@property (nonatomic, retain) NSMutableArray *players;
@property (nonatomic, retain) NSTimer *refreshTimer;
@property (nonatomic, retain) NSTimer *countdownTimer;

@end
