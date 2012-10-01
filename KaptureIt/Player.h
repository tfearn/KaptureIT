//
//  Player.h
//  KaptureIt
//
//  Created by Todd Fearn on 9/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "User.h"
#import "Contest.h"

@interface Player : NSObject {
    NSString *_objectId;
    PFGeoPoint *_location;
    int _active;
    int _hasPrize;
    int _shielded;
    NSDate *_acquiredPrizeAt;
    int _winner;
    int _bot;
    User *_user;
    Contest *_contest;
}
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) PFGeoPoint *location;
@property int active;
@property int hasPrize;
@property int shielded;
@property (nonatomic, retain) NSDate *acquiredPrizeAt;
@property int winner;
@property int bot;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Contest *contest;

- (void)assignValuesFromObject:(PFObject *)object;

@end
