//
//  Prize.m
//  KaptureIt
//
//  Created by Todd Fearn on 6/12/13.
//
//

#import "Prize.h"

@implementation Prize
@synthesize objectId = _objectId;
@synthesize redeemed = _redeemed;
@synthesize contest = _contest;

- (void)assignValuesFromObject:(PFObject *)object {
    self.objectId = [object objectId];
    self.redeemed = [[object objectForKey:@"redeemed"] boolValue];
    
    PFObject *contestObject = [object objectForKey:@"contestObject"];
    if(contestObject != nil)
        [self.contest assignValuesFromObject:contestObject];
}

@end
