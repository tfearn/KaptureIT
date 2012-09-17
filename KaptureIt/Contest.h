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
    NSDate *starttime;
    NSDate *endtime;
    NSString *_description;
    PFGeoPoint *_startlocation;
    int _active;
    PFFile *_imagefile;
}
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSDate *starttime;
@property (nonatomic, retain) NSDate *endtime;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) PFGeoPoint *startlocation;
@property int active;
@property (nonatomic, retain) PFFile *imagefile;

- (void)assignValuesFromObject:(PFObject *)object;

@end
