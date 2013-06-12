//
//  ContestDetailViewController.m
//  KaptureIt
//
//  Created by Todd Fearn on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContestDetailViewController.h"

@interface ContestDetailViewController ()

@end

@implementation ContestDetailViewController
@synthesize titleLabel = _titleLabel;
@synthesize imageView = _imageView;
@synthesize timeRemainingLabel = _timeRemainingLabel;
@synthesize joinContestButton = _joinContestButton;
@synthesize contest = _contest;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create a spacer button
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [spacer setWidth:8];
    
    // Add a back button on the nav bar
    UIImage *image = [UIImage imageNamed:@"BackButton"];
    UIImage *imageHighlighted = [UIImage imageNamed:@"BackButtonHighlighted"];
    UIButton *buttonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [buttonView addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView setBackgroundImage:image forState:UIControlStateNormal];
    [buttonView setBackgroundImage:imageHighlighted forState:UIControlStateHighlighted];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    NSArray *leftBarButtons = [[NSArray alloc] initWithObjects:spacer, backButton, nil];
    [self.navigationItem setLeftBarButtonItems:leftBarButtons];
    
    self.navigationItem.title = [self.contest.name uppercaseString];
    
    self.titleLabel.text = [self.contest.subtitle uppercaseString];
    
    TimePassedFormatter *timePassedFormatter = [[TimePassedFormatter alloc] init];
	self.timeRemainingLabel.text = [timePassedFormatter format:self.contest.endtime];
    
    NSTimeInterval timeTilStartContest = [self.contest.starttime timeIntervalSinceNow];
    NSTimeInterval timeTilEndContest = [self.contest.endtime timeIntervalSinceNow];

    // Has the contest started or ended?
    if(timeTilStartContest > 0 || timeTilEndContest <= 0) {
        self.joinContestButton.hidden = YES;
    }

    [self.contest.imagefile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if(error != nil) {
            MyLog(@"%@", [error description]);
        }
        else {
            UIImage *image = [UIImage imageWithData:data];
            self.imageView.image = image;
        }
    }];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)joinContestButtonPressed:(id)sender {

#if 0
    if([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        // Post to Facebook
        NSString *message = [NSString stringWithFormat:@"Just joined the '%@' contest via Kapture | IT.", self.contest.name];
        PF_FBRequest *request = [PF_FBRequest requestForPostStatusUpdate:message];
        [request startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
        }];
    }
    if([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        // Tweet
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[[NSString stringWithFormat:@"status=Just joined the '%@' contest via @wecaptureit!", self.contest.name]
                              dataUsingEncoding:NSASCIIStringEncoding]];
        [[PFTwitterUtils twitter] signRequest:request];
        NSURLResponse *response = nil;
        NSError *myError = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&myError];
    }
#endif
    
	ContestViewController *controller = [[ContestViewController alloc] init];
	controller.contest = self.contest;
	[self.navigationController pushViewController:controller animated:YES];
}

@end
