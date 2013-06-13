//
//  WinnerInfo.m
//  KaptureIt
//
//  Created by Todd Fearn on 6/13/13.
//
//

#import "WinnerInfo.h"

@implementation WinnerInfo
@synthesize objectId = _objectId;
@synthesize message = _message;
@synthesize promo = _promo;
@synthesize place = _place;
@synthesize street = _street;
@synthesize city = _city;
@synthesize state = _state;
@synthesize zip = _zip;
@synthesize phone = _phone;
@synthesize acquireLocation = _acquireLocation;

- (void)assignValuesFromObject:(PFObject *)object {
    self.objectId = [object objectId];
    self.message = [object objectForKey:@"message"];
    self.promo = [object objectForKey:@"promo"];
    self.place = [object objectForKey:@"place"];
    self.street = [object objectForKey:@"street"];
    self.city = [object objectForKey:@"city"];
    self.state = [object objectForKey:@"state"];
    self.zip = [object objectForKey:@"zip"];
    self.phone = [object objectForKey:@"phone"];
    self.acquireLocation = [object objectForKey:@"acquireLocation"];
}

@end
