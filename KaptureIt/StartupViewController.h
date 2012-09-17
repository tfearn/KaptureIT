//
//  StartupViewController.h
//  Joios
//
//  Created by Todd Fearn on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ASIHTTPRequest.h"
#import "Globals.h"
#import "BaseViewController.h"
#import "JSON.h"

@interface StartupViewController : BaseViewController <PF_FBRequestDelegate> {
}

- (IBAction)loginWithFacebookButtonPressed:(id)sender;

@end
