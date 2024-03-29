//
//  Contest.m
//  KaptureIt
//
//  Created by Todd Fearn on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Contest.h"

@implementation Contest;
@synthesize objectId = _objectId;
@synthesize name = _name;
@synthesize subtitle = _subtitle;
@synthesize starttime = _starttime;
@synthesize endtime = _endtime;
@synthesize description = _description;
@synthesize startlocation = _startlocation;
@synthesize endlocation = _endlocation;
@synthesize active = _active;
@synthesize imagefile = _imagefile;
@synthesize acquirerange = _acquirerange;
@synthesize maxplayers = _maxplayers;
@synthesize shieldtime = _shieldtime;
@synthesize winnerInfo = _winnerInfo;

- (id)init {
    if (self = [super init]) {
		_winnerInfo = [[WinnerInfo alloc] init];
    }
    return self;
}

- (void)assignValuesFromObject:(PFObject *)object {
    self.objectId = [object objectId];
    self.name = [object objectForKey:@"name"];
    self.subtitle = [object objectForKey:@"subtitle"];
    self.starttime = [object objectForKey:@"starttime"];
    self.endtime = [object objectForKey:@"endtime"];
    self.description = [object objectForKey:@"description"];
    self.startlocation = [object objectForKey:@"startlocation"];
    self.endlocation = [object objectForKey:@"endlocation"];
    self.active = [[object objectForKey:@"active"] intValue];
    self.imagefile = [object objectForKey:@"image"];
    self.acquirerange = [[object objectForKey:@"acquirerange"] intValue];
    self.maxplayers = [[object objectForKey:@"maxplayers"] intValue];
    self.shieldtime = [[object objectForKey:@"shieldtime"] intValue];
    
    PFObject *winnerInfoObject = [object objectForKey:@"winnerInfoObject"];
    if(winnerInfoObject != nil)
        [self.winnerInfo assignValuesFromObject:winnerInfoObject];
}

@end
