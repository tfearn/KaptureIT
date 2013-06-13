//
//  WinnerInfo.h
//  KaptureIt
//
//  Created by Todd Fearn on 6/13/13.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface WinnerInfo : NSObject {
    NSString *_objectId;
    NSString *_message;
    NSString *_promo;
    NSString *_place;
    NSString *_street;
    NSString *_city;
    NSString *_state;
    NSString *_zip;
    NSString *_phone;
    PFGeoPoint *_acquireLocation;
}
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *promo;
@property (nonatomic, strong) NSString *place;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *zip;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) PFGeoPoint *acquireLocation;

- (void)assignValuesFromObject:(PFObject *)object;

@end
