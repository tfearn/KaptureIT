//
//  User.m
//  KaptureIt
//
//  Created by Todd Fearn on 9/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize objectId = _objectId;
@synthesize username = _username;
@synthesize imageFile = _imageFile;
@synthesize imageUrl = _imageUrl;
@synthesize displayName = _displayName;

- (void)assignValuesFromObject:(PFObject *)object {
    self.objectId = [object objectId];
    self.username = [object objectForKey:@"username"];
    self.imageFile = [object objectForKey:@"imageFile"];
    self.imageUrl = [object objectForKey:@"imageUrl"];
    self.displayName = [object objectForKey:@"displayname"];
}

@end
