//
//  Prize.h
//  KaptureIt
//
//  Created by Todd Fearn on 6/12/13.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Contest.h"

@interface Prize : NSObject {
    NSString *_objectId;
    BOOL _redeemed;
    Contest *_contest;
}
@property (nonatomic, strong) NSString *objectId;
@property BOOL redeemed;
@property (nonatomic, strong) Contest *contest;

- (void)assignValuesFromObject:(PFObject *)object;

@end
