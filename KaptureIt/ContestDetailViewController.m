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
    
    // Add a back button on the nav bar
    UIImage *image = [UIImage imageNamed:@"BackButton"];
    UIImage *imageHighlighted = [UIImage imageNamed:@"BackButtonHighlighted"];
    UIButton *buttonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [buttonView addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView setBackgroundImage:image forState:UIControlStateNormal];
    [buttonView setBackgroundImage:imageHighlighted forState:UIControlStateHighlighted];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    [self.navigationItem setLeftBarButtonItem:backButton];
    
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
	ContestViewController *controller = [[ContestViewController alloc] init];
	controller.contest = self.contest;
	[self.navigationController pushViewController:controller animated:YES];
}

@end
