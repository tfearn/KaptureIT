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
    IBOutlet UILabel *_timeLeft;
    IBOutlet MKMapView *_mapView;
    IBOutlet UILabel *_status;
    CLLocation *_initialLocation;
    Contest *_contest;
    NSMutableArray *_players;
    Player *_winner;
    NSTimer *_refreshTimer;
    NSTimer *_countdownTimer;
    
    BOOL hasPrize;
}
@property (nonatomic, retain) UILabel *timeleft;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UILabel *status;
@property (nonatomic, retain) CLLocation *initialLocation;
@property (nonatomic, retain) Contest *contest;
@property (nonatomic, retain) NSMutableArray *players;
@property (nonatomic, retain) Player *winner;
@property (nonatomic, retain) NSTimer *refreshTimer;
@property (nonatomic, retain) NSTimer *countdownTimer;

@end
