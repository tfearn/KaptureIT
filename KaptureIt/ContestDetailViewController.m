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
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    [leftButton release];
    
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
    [query whereKey:@"bot" equalTo:[NSNumber numberWithInt:0]];
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
}

- (void)dealloc {
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