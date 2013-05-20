//
//  PlayerAnnotation.m
//  KaptureIt
//
//  Created by Todd Fearn on 9/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerAnnotation.h"

@implementation PlayerAnnotation
@synthesize name = _name;
@synthesize subname = _subname;
@synthesize coordinate = _coordinate;
@synthesize player = _player;

- (id)initWithName:(NSString*)name subname:(NSString *)subname coordinate:(CLLocationCoordinate2D)coordinate player:(Player *)player {
    if ((self = [super init])) {
        _name = [name copy];
        _subname = [subname copy];
        _coordinate = coordinate;
        _player = player;
    }
    return self;
}

- (NSString *)title {
    return _name;
}

- (NSString *)subtitle {
    return _subname;
}

@end
