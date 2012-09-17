//
//  PlayerAnnotation.h
//  KaptureIt
//
//  Created by Todd Fearn on 9/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Player.h"

@interface PlayerAnnotation : NSObject <MKAnnotation> {
    NSString *_title;
    NSString *_subname;
    CLLocationCoordinate2D _coordinate;
    Player *_player;
}
@property (copy) NSString *name;
@property (copy) NSString *subname;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) Player *player;

- (id)initWithName:(NSString*)name subname:(NSString *)subname coordinate:(CLLocationCoordinate2D)coordinate player:(Player *)player;

@end
