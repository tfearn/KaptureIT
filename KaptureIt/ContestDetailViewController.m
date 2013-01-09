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
@synthesize scrollView = _scrollView;
@synthesize titleLabel = _titleLabel;
@synthesize subtitleLabel = _subtitleLabel;
@synthesize imageView = _imageView;
@synthesize starttimeLabel = _starttimeLabel;
@synthesize endtimeLabel = _endtimeLabel;
@synthesize maxplayersLabel = _maxplayersLabel;
@synthesize currentplayersLabel = _currentplayersLabel;
@synthesize descriptionView = _descriptionView;
@synthesize joinContestButton = _joinContestButton;
@synthesize contest = _contest;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add a back button on the nav bar
    UIImage *image = [UIImage imageNamed:@"back-button"];
    UIImage *imageHighlighted = [UIImage imageNamed:@"back-button-highlighted"];
    UIButton *buttonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [buttonView addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView setBackgroundImage:image forState:UIControlStateNormal];
    [buttonView setBackgroundImage:imageHighlighted forState:UIControlStateHighlighted];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    [self.navigationItem setLeftBarButtonItem:backButton];
    [buttonView release];
    [backButton release];
        
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"ccc, LLL dd, h:mma"];

    self.titleLabel.text = self.contest.name;
    self.subtitleLabel.text = self.contest.subtitle;
    
	self.starttimeLabel.text = [dateFormatter stringFromDate:self.contest.starttime];
	self.endtimeLabel.text = [dateFormatter stringFromDate:self.contest.endtime];
    
    self.maxplayersLabel.text = [NSString stringWithFormat:@"%d", self.contest.maxplayers];
    
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
    
    // Get the current # of players
    [self showWaitView:@"Please wait..."];
    PFQuery *query = [PFQuery queryWithClassName:@"Player"];
    [query whereKey:@"contestObject" equalTo:[PFObject objectWithoutDataWithClassName:@"Contest" objectId:self.contest.objectId]];
    [query whereKey:@"active" equalTo:[NSNumber numberWithInt:1]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self dismissWaitView];

        if(objects != nil) {
            int currentPlayers = [objects count];
            self.currentplayersLabel.text = [NSString stringWithFormat:@"%d", currentPlayers];
            
            if(currentPlayers >= self.contest.maxplayers)
                self.joinContestButton.hidden = YES;
        }
    }];
    
    self.descriptionView.text = self.contest.description;
    
    // Set the scroll view size, text view sizes and positions
    //
    CGFloat nextY = 255;
    
    // Adjust the description textview
    CGRect frame = self.descriptionView.frame;
    frame.size.height = self.descriptionView.contentSize.height;
    self.descriptionView.frame = frame;
    nextY += frame.size.height;
    
    // Resize the scroll view accordingly
    int scrollViewHeight = MAX(nextY, 420.0);
    self.scrollView.contentSize = CGSizeMake(320, scrollViewHeight);
}

- (void)dealloc {
    self.scrollView = nil;
    self.titleLabel = nil;
    self.subtitleLabel = nil;
    self.imageView = nil;
    self.starttimeLabel = nil;
    self.endtimeLabel = nil;
    self.maxplayersLabel = nil;
    self.currentplayersLabel = nil;
    self.descriptionView = nil;
    self.joinContestButton = nil;
    self.contest = nil;
    [super dealloc];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)joinContestButtonPressed:(id)sender {
	ContestViewController *controller = [[ContestViewController alloc] init];
	controller.contest = self.contest;
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

@end
