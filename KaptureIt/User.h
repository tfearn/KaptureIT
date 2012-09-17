//
//  User.h
//  KaptureIt
//
//  Created by Todd Fearn on 9/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface User : NSObject {
    NSString *_objectId;
    NSString *_username;
    PFFile *_imageFile;
    NSString *_imageUrl;
    NSString *_displayName;
}
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) PFFile *imageFile;
@property (nonatomic, retain) NSString *imageUrl;
@property (nonatomic, retain) NSString *displayName;

- (void)assignValuesFromObject:(PFObject *)object;

@end
