//
//  StartupViewController.m
//  Joios
//
//  Created by Todd Fearn on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StartupViewController.h"

@implementation StartupViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.view.backgroundColor = backgroundColor;
    [backgroundColor release];    
}

- (void)dealloc {
    [super dealloc];
}

- (IBAction)loginWithFacebookButtonPressed:(id)sender {
    
	// TODO: Don't retain this object
	NSArray* permissions =  [[NSArray arrayWithObjects:@"email", @"publish_stream", @"offline_access", nil] retain];
    
    [self showWaitView:@"Please Wait..."];
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        if(!user) {
            [self dismissWaitView];
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Facebook Error" message:@"The Facebook login was cancelled.  A Facebook login is required to continue." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
            [alert show];
        } 
        else  {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[PFFacebookUtils facebook].accessToken forKey:kFacebookAccessTokenKey];
            [defaults setObject:[PFFacebookUtils facebook].expirationDate forKey:kFacebookExpirationDateKey];
            [defaults synchronize];
            
            // Save the user object
            PFUser *user = [PFUser currentUser];
            [user saveInBackground];
            
            if(user.isNew) {
                // Post to Facebook
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params setObject:@"Just joined KaptureIt, welcome!" forKey:@"message"];
                [[PFFacebookUtils facebook]  requestWithMethodName:@"facebook.Stream.publish" andParams:params andHttpMethod:@"POST" andDelegate:nil];
            }
            
            // Grab the Facebook graph
            [[PFFacebookUtils facebook] requestWithGraphPath:@"me" andDelegate:self];
        }
    }];
}

- (IBAction)loginWithTwitterButtonPressed:(id)sender {
}

#pragma mark -
#pragma mark PF_FBRequestDelegate methods

- (void)request:(PF_FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
}

- (void)request:(PF_FBRequest *)request didLoad:(id)result {
	NSDictionary *dict = result;
	MyLog(@"%@", dict);
    
    PFUser *user = [PFUser currentUser];
    NSString *fb_username = [dict objectForKey:@"name"];
    NSString *fb_userid = [dict objectForKey:@"id"];
    
    // Retrieve the facebook image
    NSString *imageUrl = [NSString stringWithFormat:kUrlFacebookPicture, fb_userid];
    NSURL *url = [NSURL URLWithString:imageUrl];
    __block ASIHTTPRequest *picRequest = [ASIHTTPRequest requestWithURL:url];
    [picRequest setCompletionBlock:^{
        NSData *imageData = [picRequest responseData];
        
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error != nil) {
                [self dismissWaitView];
                UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Facebook Error" message:@"Could not save Facebook user information, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
                [alert show];
                return;
            }
            
            // Update the User record
            [user setObject:fb_username forKey:@"displayname"];
            [user setObject:imageUrl forKey:@"imageUrl"];
            [user setObject:imageFile forKey:@"imageFile"];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error != nil) {
                    [self dismissWaitView];
                    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Database Error" message:@"Could not save Facebook user information, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
                    [alert show];
                    return;
                }
                
                // Delete any prior FacebookInfo record for this username
                PFQuery *query = [PFQuery queryWithClassName:@"FacebookInfo"];
                [query whereKey:@"username" equalTo:user.username];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if(error == nil)
                        [object deleteEventually];
                }];
                
                // Save the new Facebook graph data
                SBJsonWriter *writer = [SBJsonWriter new];
                NSString *jsonString = [writer stringWithObject:dict];
                PFObject *facebookInfo = [PFObject objectWithClassName:@"FacebookInfo"];
                [facebookInfo setObject:jsonString forKey:@"fb_graph"];
                NSString *fb_email = [dict objectForKey:@"email"];
                [facebookInfo setObject:fb_email forKey:@"fb_email"];
                [facebookInfo setObject:fb_username forKey:@"fb_username"];
                [facebookInfo setObject:user.username forKey:@"username"];
                [facebookInfo saveEventually];
                [writer release];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginComplete object:self userInfo:nil];
            }];
        }];
    }];
    [picRequest setFailedBlock:^{
        [self dismissWaitView];
        NSError *error = [picRequest error];
        MyLog(@"%@", [error description]);
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Facebook Error" message:@"Could not retrieve Facebook user information, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [alert show];
    }];
    [picRequest startAsynchronous];   
};

- (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error {
    [self dismissWaitView];
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Facebook Error" message:@"A Facebook request error occurred, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
    [alert show];
};

@end
