//
//  Location.h
//  KaptureIt
//
//  Created by Todd Fearn on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Location : NSObject <MKAnnotation> {
    int _number;
    NSString *_name;
    NSString *_subname;
    CLLocationCoordinate2D _coordinate;
}
@property int number;
@property (copy) NSString *name;
@property (copy) NSString *subname;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithName:(NSString*)name subname:(NSString*)subname number:(int)number coordinate:(CLLocationCoordinate2D)coordinate;

@end
