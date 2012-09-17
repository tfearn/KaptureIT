//
//  Player.m
//  KaptureIt
//
//  Created by Todd Fearn on 9/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Player.h"

@implementation Player
@synthesize objectId = _objectId;
@synthesize location = _location;
@synthesize active = _active;
@synthesize hasPrize = _hasPrize;
@synthesize acquiredPrizeAt = _acquiredPrizeAt;
@synthesize winner = _winner;
@synthesize user = _user;
@synthesize contest = _contest;

- (id)init {
    if (self = [super init]) {
		_user = [[User alloc] init];
        _contest = [[Contest alloc] init];
    }
    return self;
}

- (void)assignValuesFromObject:(PFObject *)object {
    self.objectId = [object objectId];
    self.location = [object objectForKey:@"location"];
    self.active = [[object objectForKey:@"active"] intValue];
    self.hasPrize = [[object objectForKey:@"hasprize"] intValue];
    self.acquiredPrizeAt = [object objectForKey:@"acquiredprizeAt"];
    self.winner = [[object objectForKey:@"winner"] intValue];
    
    PFObject *userObject = [object objectForKey:@"userObject"];
    if(userObject != nil)
        [self.user assignValuesFromObject:userObject];

    PFObject *contestObject = [object objectForKey:@"contestObject"];
    if(contestObject != nil)
        [self.contest assignValuesFromObject:contestObject];
}

- (void)dealloc {
    self.objectId = nil;
    self.location = nil;
    self.acquiredPrizeAt = nil;
    self.user = nil;
    self.contest = nil;
    [super dealloc];
}

@end
