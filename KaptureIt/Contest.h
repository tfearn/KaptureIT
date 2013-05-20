//
//  Contest.h
//  KaptureIt
//
//  Created by Todd Fearn on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Contest : NSObject {
    NSString *_objectId;
    NSString *_name;
    NSString *_subtitle;
    NSDate *_starttime;
    NSDate *_endtime;
    NSString *_description;
    PFGeoPoint *_startlocation;
    PFGeoPoint *_endlocation;
    int _active;
    PFFile *_imagefile;
    int _acquirerange;
    int _maxplayers;
    int _shieldtime;
}
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSDate *starttime;
@property (nonatomic, retain) NSDate *endtime;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) PFGeoPoint *startlocation;
@property (nonatomic, retain) PFGeoPoint *endlocation;
@property int active;
@property (nonatomic, retain) PFFile *imagefile;
@property int acquirerange;
@property int maxplayers;
@property int shieldtime;

- (void)assignValuesFromObject:(PFObject *)object;

@end
