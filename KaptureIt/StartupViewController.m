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
}

- (IBAction)loginWithFacebookButtonPressed:(id)sender {
    
	// TODO: Don't retain this object
	NSArray* permissions =  [NSArray arrayWithObjects:@"email", @"publish_stream", @"offline_access", nil];
    
    [self showWaitView:@"Please Wait..."];
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        if(!user) {
            [self dismissWaitView];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Error" message:@"The Facebook login was cancelled.  A Facebook login is required to continue." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        } 
        else  {
            
            if(user.isNew) {
                // Post to Facebook
                PF_FBRequest *request = [PF_FBRequest requestForPostStatusUpdate:@"Just became part of Kapture | IT. Join in at www.kaptureit.com"];
                [request startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
                    // Don't worry about errors on this
                }];
            }
            
            // Grab the Facebook graph
            PF_FBRequest *request = [PF_FBRequest requestForMe];
            [request startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
                if(error != nil) {
                    [self dismissWaitView];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Error" message:@"A Facebook request error occurred, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                }
                else {
                    [self parseFacebookGraph:result];
                }
            }];
        }
    }];
}

- (void)parseFacebookGraph:(id)result {
	NSDictionary *dict = result;
	MyLog(@"%@", dict);
    
    PFUser *user = [PFUser currentUser];
    NSString *fb_username = [dict objectForKey:@"name"];
    NSString *fb_userid = [dict objectForKey:@"id"];
    
    // Retrieve the facebook image
    NSString *imageUrl = [NSString stringWithFormat:kUrlFacebookPicture, fb_userid];
    NSURL *url = [NSURL URLWithString:imageUrl];
    __weak ASIHTTPRequest *picRequest = [ASIHTTPRequest requestWithURL:url];
    [picRequest setCompletionBlock:^{
        NSData *imageData = [picRequest responseData];
        
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error != nil) {
                [self dismissWaitView];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Error" message:@"Could not save Facebook user information, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error" message:@"Could not save Facebook user information, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
                NSError *jsonError = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&jsonError];
                NSString *facebookGraph = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                PFObject *facebookInfo = [PFObject objectWithClassName:@"FacebookInfo"];
                [facebookInfo setObject:facebookGraph forKey:@"fb_graph"];
                NSString *fb_email = [dict objectForKey:@"email"];
                [facebookInfo setObject:fb_email forKey:@"fb_email"];
                [facebookInfo setObject:fb_username forKey:@"fb_username"];
                [facebookInfo setObject:user.username forKey:@"username"];
                [facebookInfo saveEventually];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginComplete object:self userInfo:nil];
            }];
        }];
    }];
    [picRequest setFailedBlock:^{
        [self dismissWaitView];
        NSError *error = [picRequest error];
        MyLog(@"%@", [error description]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Error" message:@"Could not retrieve Facebook user information, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
    [picRequest startAsynchronous];
};

- (IBAction)loginWithTwitterButtonPressed:(id)sender {
    [self showWaitView:@"Please Wait..."];
    [PFTwitterUtils logInWithTarget:self selector:@selector(twitterLogin:error:)];
}

- (void)twitterLogin:(PFUser *)user error:(NSError **)error {
    
    if(!user) {
        [self dismissWaitView];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Error" message:@"The Twitter login was cancelled.  A Twitter login is required to continue." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else  {
        
        if(user.isNew) {
            // Tweet
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[[NSString stringWithFormat:@"status=Just became part of @wecaptureit! Join in at www.kaptureit.com"]
                                  dataUsingEncoding:NSASCIIStringEncoding]];
            [[PFTwitterUtils twitter] signRequest:request];
            NSURLResponse *response = nil;
            NSError *myError = nil;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&myError];
            if(myError != nil) {
                NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                MyLog(@"%@", responseString);
            }
        }
        
        // Verify the credentials and store related data
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/account/verify_credentials.json"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [[PFTwitterUtils twitter] signRequest:request];
        NSURLResponse *response = nil;
        NSError *myError = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&myError];
        if(myError != nil) {
            [self dismissWaitView];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Error" message:@"Could not save Twitter user information, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        else {
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSError *jsonError = nil;
            NSDictionary *JSON =
            [NSJSONSerialization JSONObjectWithData: [responseString dataUsingEncoding:NSUTF8StringEncoding]
                                            options: NSJSONReadingMutableContainers
                                              error: &jsonError];
            [self parseTwitterData:JSON];
        }
    }
}

- (void)parseTwitterData:(id)result {
	NSDictionary *dict = result;
	MyLog(@"%@", dict);
    
    PFUser *user = [PFUser currentUser];
    NSString *twitter_name = [dict objectForKey:@"screen_name"];
    
    // Retrieve the twitter image
    NSString *imageUrl = [dict objectForKey:@"profile_image_url"];
    imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    NSURL *url = [NSURL URLWithString:imageUrl];
    __weak ASIHTTPRequest *picRequest = [ASIHTTPRequest requestWithURL:url];
    [picRequest setCompletionBlock:^{
        NSData *imageData = [picRequest responseData];
        
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error != nil) {
                [self dismissWaitView];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Error" message:@"Could not save Twitter user information, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return;
            }
            
            // Update the User record
            [user setObject:twitter_name forKey:@"displayname"];
            [user setObject:imageUrl forKey:@"imageUrl"];
            [user setObject:imageFile forKey:@"imageFile"];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error != nil) {
                    [self dismissWaitView];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error" message:@"Could not save Twitter user information, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    return;
                }
                
                // Delete any prior TwitterInfo record for this username
                PFQuery *query = [PFQuery queryWithClassName:@"TwitterInfo"];
                [query whereKey:@"username" equalTo:user.username];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if(error == nil)
                        [object deleteEventually];
                }];
                
                // Save the new Twitter data
                NSError *jsonError = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&jsonError];
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                PFObject *twitterInfo = [PFObject objectWithClassName:@"TwitterInfo"];
                [twitterInfo setObject:jsonString forKey:@"twitter_graph"];
                [twitterInfo setObject:twitter_name forKey:@"twitter_username"];
                [twitterInfo setObject:user.username forKey:@"username"];
                [twitterInfo saveEventually];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginComplete object:self userInfo:nil];
            }];
        }];
    }];
    [picRequest setFailedBlock:^{
        [self dismissWaitView];
        NSError *error = [picRequest error];
        MyLog(@"%@", [error description]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Error" message:@"Could not retrieve Twitter user information, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
    [picRequest startAsynchronous];
};


@end
