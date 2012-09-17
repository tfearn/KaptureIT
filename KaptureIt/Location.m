//
//  Location.m
//  KaptureIt
//
//  Created by Todd Fearn on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Location.h"

@implementation Location
@synthesize number = _number;
@synthesize name = _name;
@synthesize subname = _subname;
@synthesize coordinate = _coordinate;

- (id)initWithName:(NSString*)name subname:(NSString *)subname number:(int)number coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        _name = [name copy];
        _subname = [subname copy];
        _number = number;
        _coordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    return _name;
}

- (NSString *)subtitle {
    return _subname;
}

- (void)dealloc {
    self.name = nil;
    self.subname = nil;
    [super dealloc];
}

@end
