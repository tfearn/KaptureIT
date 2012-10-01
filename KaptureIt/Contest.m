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
@synthesize active = _active;
@synthesize imagefile = _imagefile;
@synthesize acquirerange = _acquirerange;
@synthesize maxplayers = _maxplayers;
@synthesize shieldtime = _shieldtime;

- (void)assignValuesFromObject:(PFObject *)object {
    self.objectId = [object objectId];
    self.name = [object objectForKey:@"name"];
    self.subtitle = [object objectForKey:@"subtitle"];
    self.starttime = [object objectForKey:@"starttime"];
    self.endtime = [object objectForKey:@"endtime"];
    self.description = [object objectForKey:@"description"];
    self.startlocation = [object objectForKey:@"startlocation"];
    self.active = [[object objectForKey:@"active"] intValue];
    self.imagefile = [object objectForKey:@"image"];
    self.acquirerange = [[object objectForKey:@"acquirerange"] intValue];
    self.maxplayers = [[object objectForKey:@"maxplayers"] intValue];
    self.shieldtime = [[object objectForKey:@"shieldtime"] intValue];
}

- (void)dealloc {
    self.objectId = nil;
    self.name = nil;
    self.subtitle = nil;
    self.starttime = nil;
    self.endtime = nil;
    self.description = nil;
    self.startlocation = nil;
    self.imagefile = nil;
    
    [super dealloc];
}

@end
